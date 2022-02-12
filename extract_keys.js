const crypto = require('crypto')

class SrtpCrypto {

    srtpKey

    masterKey
    masterSalt

    keys

    _crypto

    _sequence = 0
    _roc = 0

    constructor(srtpKey){
        const key = Buffer.from(srtpKey, 'base64')
        this.srtpKey = key

        this.masterKey = key.slice(0,16)
        this.masterSalt = key.slice(16)

        this.keys = {}

        if(this.masterKey.length != 16){
            throw Error('Masterkey is incorrect size')
        }
        if(this.masterSalt.length != 14){
            throw Error('Mastersalt is incorrect size')
        }

        // this._derive_session_keys(this.masterKey, this.masterSalt)


        this.keys.cryptKey = this._derive_single_key(this.masterKey, this.masterSalt, 0)
        this.keys.authKey = this._derive_single_key(this.masterKey, this.masterSalt, 1)
        this.keys.saltKey = this._derive_single_key(this.masterKey, this.masterSalt, 2, 14)

        if(this.keys.cryptKey === undefined){
            throw Error('Cannot init crypto. No Cryptkey found')
        }
    }

    _derive_session_keys(masterKey, masterSalt){
        this.keys.cryptKey = this._derive_single_key(masterKey, masterSalt, 0)
        this.keys.authKey = this._derive_single_key(masterKey, masterSalt, 1)
        this.keys.saltKey = this._derive_single_key(masterKey, masterSalt, 2, 14)
    }

    _derive_single_key(masterKey, masterSalt, keyIndex, maxSize = 16){
        const pkt_i = 0
        const key_derivation_rate = 0

        if(masterKey.length != 16){
            throw Error('Masterkey is incorrect size')
        }
        if(masterSalt.length != 14){
            throw Error('Mastersalt is incorrect size')
        }

        const r = BigInt(0) // @TODO: Change this static value but we dont use of change this at all.

        // salt to int
        let saltInt = this._bytes_to_int(masterSalt)

        saltInt ^= BigInt(((BigInt(keyIndex) << BigInt(48)) + r))
        const prngValue = saltInt << BigInt(16)
        const iv = this._int_to_bytes(prngValue)
        const key = this._crypt_ctr_oneshot(masterKey, iv, Buffer.from('00'.repeat(16), 'hex'), maxSize)

        return key
    }

    _crypt_ctr_oneshot(masterKey, iv, plaintext, maxSize){
        var cipher = crypto.createCipheriv("aes-128-ctr", masterKey, iv)
        const output = Buffer.concat([cipher.update(plaintext), cipher.final()]);

        return output.slice(0, maxSize)
    }

    _int_to_bytes(bigNumber){
        let result = new Uint8Array(16);
        let i = 0;
        while (bigNumber > BigInt(0)) {
            result[i] = Number(bigNumber % (BigInt(256)))
            bigNumber = bigNumber / (BigInt(256))
            i += 1;
        }
        return Buffer.from(result).reverse();
    }

    _bytes_to_int(buffer){
        return [...Buffer.from(buffer, 'binary')].map(
            (el, index, { length }) => {
            return BigInt(el * (256 ** (length - (1+index))))
            }).reduce((prev, curr) => {
            return prev + curr;
        }, BigInt(0));
    }
}

var xCloudCrypto = new SrtpCrypto('kzdAUmPGFXTRYvXmDxdof30injNmjpaJFltuQuP8')

console.log('xCloud-Wireshark Crypto keys decoder for Wireshark dissector.')
// console.log(xCloudCrypto)
console.log('AES Key:', xCloudCrypto.keys.cryptKey.toString('hex'))

const saltBytes = xCloudCrypto.keys.saltKey.slice(2).toString('hex')
console.log('IV Salt:', saltBytes)