local xcloud_crypto = {}

local bigint = require 'vendor/bigint'

-- helper functions
local gcrypt
do
    local ok, res = pcall(require, "luagcrypt")
    if ok then
        if res.CIPHER_MODE_POLY1305 then
            gcrypt = res
        else
            report_failure("xcloud_crypto.lua: Libgcrypt 1.7 or newer is required for decryption")
        end
    else
        report_failure("xcloud_crypto.lua: cannot load Luagcrypt, decryption is unavailable.\n" .. res)
    end
end

-- Convert bytes to their hexadecimal representation
function tohex(s)
    local hex = string.gsub(s, ".", function(c)
        return string.format("%02x", string.byte(c))
    end)
    return hex
end

-- Convert a string of hexadecimal numbers to a bytes string
function fromhex(hex)
    if string.match(hex, "[^0-9a-fA-F]") then
        error("Invalid chars in hex")
    end
    if string.len(hex) % 2 == 1 then
        error("Hex string must be a multiple of two")
    end
    local s = string.gsub(hex, "..", function(v)
        return string.char(tonumber(v, 16))
    end)
    return s
end

function xcloud_crypto.crypt_ctr_oneshot(masterKey, iv, plaintext)
    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES128, gcrypt.CIPHER_MODE_CTR)

    -- print(tohex(iv));
    cipher:setkey(masterKey)
    cipher:setctr(iv)

    local crypted = cipher:encrypt(plaintext)
    return crypted
end

function xcloud_crypto.derive_single_key(masterKey, masterSalt, keyIndex, maxSize)
    local saltIn = bigint.FromBytes(masterSalt, false)

    -- saltXor = (keyIndex << 48) + 0
    local _saltXor = (bigint.FromNumber(keyIndex):Shl(48))

    -- saltIn ^= _saltXor
    saltIn = saltIn:Bxor(_saltXor)

    -- saltIn << 16
    local iv = saltIn:Shl(16):ToBytes()

    -- Shift left by 16
    local key = xcloud_crypto.crypt_ctr_oneshot(masterKey, iv, fromhex('00000000000000000000000000000000'), maxSize)

    if maxSize == nil then
        maxSize = 16
    end

    -- Truncate key to maxSize
    return string.sub(key, 0, maxSize)
end

function xcloud_crypto.derive_keys(keyB64)
    local _srtpKey = ByteArray.new(keyB64, true):base64_decode():raw()

    local _masterKey = string.sub(_srtpKey, 0, 16)
    local _masterSalt = string.sub(_srtpKey, 17)

    local _cryptKey = xcloud_crypto.derive_single_key(_masterKey, _masterSalt, 0)
    local _authKey = xcloud_crypto.derive_single_key(_masterKey, _masterSalt, 1)
    local _saltKey = xcloud_crypto.derive_single_key(_masterKey, _masterSalt, 2, 14)

    return _cryptKey, _authKey, _saltKey
end

function xcloud_crypto.calc_iv(salt, ssrc, pkti)
    local pre = string.sub(salt, 0, 4)
    local tail = string.sub(salt, 5)

    local saltint = Struct.unpack('>e', tail)
    local ssrc_p = UInt64(ssrc:uint())

    local xor = saltint:bxor(pkti)
    local xor = xor:bxor(ssrc_p:lshift(48))
    local new_iv = pre .. string.fromhex(xor:tohex())

    return new_iv
end

function xcloud_crypto.decrypt(encrypted, key, iv_salt, aad, sequence, ssrc)
    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES128, gcrypt.CIPHER_MODE_GCM)

    local tag = encrypted(encrypted:len()-16)
    local data = encrypted(0, encrypted:len()-16)

    local iv = xcloud_crypto.calc_iv(iv_salt, ssrc, sequence)

    cipher:setkey(key)
    cipher:setiv(iv)
    cipher:authenticate(aad:raw())

    local decrypted = cipher:decrypt(data:raw())
    
    return decrypted
end

function test_crypto()
    -- Initialize the gcrypt library (required for standalone applications that
    -- do not use Libgcrypt themselves).
    gcrypt.init()

    local _srtpKeyB64 = 'kzdAUmPGFXTRYvXmDxdof30injNmjpaJFltuQuP8'
    local _aesKey, _authKey, _saltKey = xcloud_crypto.derive_keys(_srtpKeyB64)
    -- assert(_srtpKeyB64 == 'kzdAUmPGFXTRYvXmDxdof30injNmjpaJFltuQuP8', 'B64 mismatch')

    -- local _srtpKey = base64.decode(_srtpKeyB64)
    -- assert(tohex(_srtpKey) == '9337405263c61574d162f5e60f17687f7d229e33668e9689165b6e42e3fc', 'SrtpKey mismatch')

    -- local _masterKey = string.sub(_srtpKey, 0, 16)
    -- assert(tohex(_masterKey) == '9337405263c61574d162f5e60f17687f', 'Master Key mismatch')

    -- local _masterSalt = string.sub(_srtpKey, 17)
    -- assert(tohex(_masterSalt) == '7d229e33668e9689165b6e42e3fc', 'Master Salt mismatch');

    -- local _aesKey = derive_single_key(_masterKey, _masterSalt, 0)
    -- print("aesKey="..tohex(_aesKey))
    assert(tohex(_aesKey) == '81966e259110b8a6aa786b19880560b5', 'AES key mismatch')
    -- print('')

    -- local _authKey = derive_single_key(_masterKey, _masterSalt, 1)
    -- print("authKey="..tohex(_authKey))
    assert(tohex(_authKey) == '2fcf42a0e889dbf53dc509ed367bc70e', 'Auth key mismatch')
    -- print('')

    -- local _saltKey = derive_single_key(_masterKey, _masterSalt, 2, 14)
    -- _saltKey = string.sub(_saltKey, 0, 14)
    -- print("saltKey="..tohex(_saltKey))
    assert(tohex(_saltKey) == '65acf08ee743fe80f561bd57995c', 'Salt key mismatch')
end

return xcloud_crypto