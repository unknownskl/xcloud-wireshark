-- ################################################
-- #   xCloud Gamestreaming protocol dissector    #
-- #          by UnknownSKL (2022)                #
-- #   credits to tuxuser for the base template   #
-- ################################################

-- declare protocol
xcloud_proto = Proto("xCloud-RTP", "xCloud-Gamestreaming")

-- declare options
xcloud_proto.prefs["crypt_key"] =
    Pref.string("AES Key", "81966e259110b8a6aa786b19880560b5", "Crypt key from crypto context")

xcloud_proto.prefs["iv_salt"] =
    Pref.string("IV Salt", "f08ee743fe80f561bd57995c", "IV Salt from crypto context")

-- Load helper classes
local xCloudHeader = require 'lib/xcloud_header'
    
-- helper functions
local gcrypt
do
    local ok, res = pcall(require, "luagcrypt")
    if ok then
        if res.CIPHER_MODE_POLY1305 then
            gcrypt = res
        else
            report_failure("wg.lua: Libgcrypt 1.7 or newer is required for decryption")
        end
    else
        report_failure("wg.lua: cannot load Luagcrypt, decryption is unavailable.\n" .. res)
end
end

-- Convenience field adding code from: https://github.com/Lekensteyn/kdnet/blob/master/kdnet.lua
-- Thx Mr. Peter Wu (Lekensteyn)
local hf = {}
function add_field(proto_field_constructor, name, desc, ...)
    local field_name = "xcloud_rtp." .. name
    name = string.gsub(name, "%.", "_")
    -- If the description is omitted, use the name as label
    if type(desc) == "string" then
        hf[name] = proto_field_constructor(field_name, desc, ...)
    else
        hf[name] = proto_field_constructor(field_name, name, desc, ...)
    end
end

-- add Types
hasSequence_types = {
    [0] = "No",
    [3] = "Yes"
}
hasMs_types = {
    [0] = "No",
    [1] = "Yes"
}

packetChannel_types = {
    [1] = "FrameData",
    [2] = "OpenChannel",
    [3] = "Control",
    [4] = "Data",
    [5] = "Data"
}
packetCommand_types = {
    [1] = "Ping",
    [1] = "ServerHandshake",
    [2] = "ClientHandshake",
    [3] = "Control",
    [4] = "VideoFrame",
    [5] = "InputChannelRequest",
    [6] = "InputChannelResponse",
    [7] = "InputFrame"
}

ssrc_types = {
    [0] = "Core",
    [1024] = "Control",
    [1025] = "Qos",
    [1026] = "Video",
    [1027] = "Audio",
    [1028] = "Messaging",
    [1029] = "ChatAudio",
    [1030] = "Input",
    [1031] = "InputFeedback"
}

fData_types = {
    [4] = "Frame"
}

-- RTP fields
add_field(ProtoField.bytes, "payload_rtp_aad", "Additional Authentication Data (AAD)")
add_field(ProtoField.bytes, "payload_rtp_tag", "Auth Tag")
add_field(ProtoField.bytes, "payload_rtp_payload", "RTP Payload")
add_field(ProtoField.bytes, "payload_encrypted", "Encrypted payload")
add_field(ProtoField.bytes, "payload_decrypted", "Decrypted payload")

add_field(ProtoField.uint16, "rtp_sequence", "Sequence")
add_field(ProtoField.uint32, "rtp_ssrc", "SSRC", base.DEC, ssrc_types)

-- Headerr Fiels
add_field(ProtoField.uint16, "gs_header_flags", "Header flags", base.DEC, {}, 0xffff)
add_field(ProtoField.uint16, "gs_header_sequence", "Sequence")
add_field(ProtoField.uint16, "gs_header_confirm", "Confirm Sequence")
add_field(ProtoField.uint16, "gs_header_ms", "Ms")
add_field(ProtoField.uint16, "gs_header_fragment", "Fragment num")

-- Unconnected Fields
add_field(ProtoField.uint32, "unconnected_ack_length", "Ack length")
add_field(ProtoField.uint16, "unconnected_command", "Command")
add_field(ProtoField.string, "unconnected_unk_bytes", "Unknown bytes")
add_field(ProtoField.uint64, "unconnected_unk_64", "Unknown uint64")
add_field(ProtoField.uint32, "unconnected_unk_32", "Unknown uint32")
add_field(ProtoField.uint24, "unconnected_unk_24", "Unknown uint24")
add_field(ProtoField.uint32, "unconnected_unk_16_int", "Unknown int16")
add_field(ProtoField.int32, "unconnected_unk_16", "Unknown uint16")
add_field(ProtoField.uint32, "unconnected_unk_8", "Unknown uint8")

-- Connected Fields
add_field(ProtoField.uint16, "connected_last_received", "Last received Sequence")
add_field(ProtoField.uint16, "connected_time_ms", "Timestamp since connected")


add_field(ProtoField.bytes, "connected_video_data", "Video Frame")

-- Flag fields
add_field(ProtoField.uint16, "gs_flag_opcode", "Bitflags", base.DEC, {}, 0xffff)
add_field(ProtoField.uint16, "gs_flag_sequence", "hasSequence", base.DEC, hasSequence_types, 0xC0)
add_field(ProtoField.uint16, "gs_flag_ms", "hasMs", base.DEC, hasMs_types, 0x4000)
add_field(ProtoField.uint16, "gs_flag_confirm", "hasConfirm", base.DEC, hasMs_types, 0x100)
add_field(ProtoField.uint16, "gs_flag_unknown", "hasUnknown", base.DEC, hasMs_types, 0x400)
add_field(ProtoField.uint16, "gs_flag_unknown2", "hasUnknown2", base.DEC, hasMs_types, 0x1)
add_field(ProtoField.uint16, "gs_flag_udpack", "isUDPAck", base.DEC, hasMs_types, 0x200)
add_field(ProtoField.uint16, "gs_flag_unknown4", "hasUnknown4", base.DEC, hasMs_types, 0x2000)
add_field(ProtoField.uint16, "gs_flag_unknown5", "hasUnknown5", base.DEC, hasMs_types, 0x800)
add_field(ProtoField.uint16, "gs_flag_unknown6", "hasUnknown6", base.DEC, hasMs_types, 0x1000)

add_field(ProtoField.uint16, "gs_input_buttons", "Button Bitflags", base.DEC, {}, 0xffff)

add_field(ProtoField.uint16, "gs_sequence", "Sequence")
add_field(ProtoField.uint32, "gs_ms", "Microseconds since start")
add_field(ProtoField.uint16, "gs_channel", "Channel", base.DEC, packetChannel_types)
add_field(ProtoField.uint16, "gs_command", "Command", base.DEC, packetCommand_types)
add_field(ProtoField.uint16, "gs_message_data_type", "Message Data type", base.DEC)
add_field(ProtoField.uint16, "gs_packet_index", "Fragment index")
add_field(ProtoField.uint16, "gs_packet_data_packets", "Fragment data packets")

add_field(ProtoField.uint32, "gs_packet_total_count", "Fragments count")
add_field(ProtoField.uint32, "gs_packet_data_type", "Data type")
add_field(ProtoField.uint32, "gs_packet_total_length", "Fragment total length")
add_field(ProtoField.uint32, "gs_packet_offset", "Fragment offset")
add_field(ProtoField.string, "gs_packet_data", "Fragment data")
add_field(ProtoField.uint16, "gs_packet_fragment_num", "Fragment num")

add_field(ProtoField.string, "gs_packet_kv_key", "KV Key")
add_field(ProtoField.string, "gs_packet_kv_value", "KV Value")
add_field(ProtoField.uint32, "gs_packet_kv_key_length", "KV Key Length")
add_field(ProtoField.uint32, "gs_packet_kv_value_length", "KV Value Length")
add_field(ProtoField.uint32, "gs_packet_kv_payload_length", "KV Payload Length")

add_field(ProtoField.uint32, "gs_video_fdata", "Video fData", base.DEC, fData_types)
add_field(ProtoField.uint32, "gs_video_frameid", "Video Frame ID")
add_field(ProtoField.uint64, "gs_video_timestamp", "Video Timestamp")
add_field(ProtoField.uint32, "gs_video_data_total_length", "Video Data Total length")
add_field(ProtoField.uint32, "gs_video_data_length", "Video Data length")
add_field(ProtoField.uint32, "gs_video_data_offset", "Video Data offset")

add_field(ProtoField.string, "gs_openchannel_name", "Channel Name")
add_field(ProtoField.uint32, "gs_temp_length", "DEBUG")
add_field(ProtoField.uint32, "gs_temp_data", "DEBUG DATA")

xcloud_proto.fields = hf

function decrypt(encrypted, key, aad, sequence, ssrc)
    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES128, gcrypt.CIPHER_MODE_GCM)

    local tag = encrypted(encrypted:len()-16)
    local data = encrypted(0, encrypted:len()-16)

    local iv_salt = string.fromhex(xcloud_proto.prefs.iv_salt)
    local iv = calc_iv(iv_salt, ssrc, sequence)

    cipher:setkey(key)
    cipher:setiv(iv)
    cipher:authenticate(aad:raw())

    local decrypted = cipher:decrypt(data:raw())
    
    return decrypted
end

function calc_iv(salt, ssrc, pkti)
    local pre = string.sub(salt, 0, 4)
    local tail = string.sub(salt, 5)

    local saltint = Struct.unpack('>e', tail)
    local ssrc_p = UInt64(ssrc:uint())

    local xor = saltint:bxor(pkti)
    local xor = xor:bxor(ssrc_p:lshift(48))
    local new_iv = pre .. string.fromhex(xor:tohex())

    return new_iv
end 

function stringtonumber(str)
    local function _b2n(exp, num, digit, ...)
        if not digit then return num end
        return _b2n(exp*256, num + digit*exp, ...)
    end
    return _b2n(256, string.byte(str, 1, -1))
end

function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

-- create a function to dissect it
function xcloud_proto.dissector(tvbuf, pinfo, tree)
    pinfo.cols.protocol = "xCloud-Gamestreaming" --xcloud_proto.name

    -- Read RTP Headers using the RTP Dissector
    -- rtp_table = Dissector.get ("rtp")
    -- tvb=tvbuf(0)
    -- rtp_table:call(tvbuf(0):tvb(), pinfo, tree)

    -- tvb=tvbuf(12)
    is_rtp=tvbuf(0, 1)

    if string.tohex(is_rtp:raw()) == "80" then
        -- First packet is from client?
        -- print(pinfo)

        local decryption_key = string.fromhex(xcloud_proto.prefs.crypt_key)
        local subtree = tree:add("xCloud Gamestreaming", tvbuf(12):tvb())

        -- Read RTP
        local rtp_tree = subtree:add("RTP Header", tvbuf())
        local rtp_sequence = tvbuf(2, 2):uint()
        rtp_tree:add(hf.rtp_sequence, tvbuf(2, 2))
        local rtp_ssrc = tvbuf(8, 4)
        rtp_tree:add(hf.rtp_ssrc, tvbuf(8, 4))

        -- New Read RTP
        -- rtp_table = Dissector.get ("rtp")
        -- tvb=tvbuf(0)
        -- rtp_table:call(tvbuf(0):tvb(), pinfo, rtp_tree)
        
        -- Process encrypted tree
        local payload = tvbuf(12)
        local payload_tree = subtree:add(hf.payload_encrypted, payload)
        payload_tree:add(hf.payload_rtp_aad, tvbuf(0, 12))
        payload_tree:add(hf.payload_rtp_tag, payload(payload:len()-16))
        payload_tree:add(hf.payload_rtp_payload, payload(0, payload:len()-16))

        local decrypted = decrypt(payload, decryption_key, tvbuf(0, 12), rtp_sequence, rtp_ssrc)
        decr_tvb = ByteArray.new(decrypted, true):tvb("Decrypted payload")

        -- Process decrypted tree
        local decryped_tree = subtree:add(hf.payload_decrypted, decr_tvb())

        -- local packetinfo = dissect_data_packet(decryped_tree, decr_tvb, rtp_ssrc:uint())
        local headers = xCloudHeader(decr_tvb():tvb()):decode(decryped_tree, hf)
        -- print(headers:decode().string)
        local packetinfo = headers.string

        -- packetinfo = "<RTPSequence=" .. tvbuf(2, 2):uint() .. " SSRC=" .. tvbuf(8, 4):uint() .. "[" .. ssrc_types[tvbuf(8, 4):uint()] .. "] Flags=" .. string.tohex(decr_tvb(0, 2):raw()) .. "> " .. packetinfo
        pinfo.cols.info = "xCloud SSRC=" .. tvbuf(8, 4):uint() .. "[" .. ssrc_types[tvbuf(8, 4):uint()] .. "] " .. packetinfo
    else
        local subtree = tree:add("non xCloud Gamestreaming packet: " .. string.tohex(is_rtp:raw()), tvbuf(12):tvb())

        if string.tohex(is_rtp:raw()) == "01" or string.tohex(is_rtp:raw()) == "00" then
            local stun_dissector = Dissector.get("stun-udp")
            stun_dissector:call(tvbuf():tvb(), pinfo, tree)

            pinfo.cols.info = "STUN"
        end
    end
end

function xcloud_proto.init()
end

-- teredo_table = Dissector.get ("teredo")
-- teredo_table:add(3074)

udp_table = DissectorTable.get("udp.port")
udp_table:add(0, xcloud_proto)
-- udp_table:add(58953, xcloud_proto)