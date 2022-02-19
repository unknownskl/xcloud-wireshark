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

-- Unconnected Fields
add_field(ProtoField.uint32, "unconnected_ack_length", "Ack length")
add_field(ProtoField.uint16, "unconnected_command", "Command")
add_field(ProtoField.string, "unconnected_unk_bytes", "Unknown bytes")
add_field(ProtoField.uint64, "unconnected_unk_64", "Unknown uint64")
add_field(ProtoField.uint32, "unconnected_unk_32", "Unknown uint32")
add_field(ProtoField.uint32, "unconnected_unk_16_int", "Unknown int16")
add_field(ProtoField.int32, "unconnected_unk_16", "Unknown uint16")
add_field(ProtoField.uint32, "unconnected_unk_8", "Unknown uint8")

-- Connected Fields
add_field(ProtoField.uint16, "connected_last_received", "Last received Sequence")
add_field(ProtoField.uint16, "connected_time_ms", "Timestamp since connected")
add_field(ProtoField.bytes, "connected_video_data", "Video Frame")

-- Flag fields

add_field(ProtoField.uint8, "gs_header_flags", "Header flags", base.DEC, {}, 0xff)
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
add_field(ProtoField.bytes, "gs_video_frameid", "Video Frame ID")
add_field(ProtoField.uint64, "gs_video_timestamp", "Video Timestamp")

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
        local packetinfo = dissect_data_packet(decryped_tree, decr_tvb, rtp_ssrc:uint())

        pinfo.cols.info = "xCloud <RTPSequence=" .. tvbuf(2, 2):uint() .. " SSRC=" .. tvbuf(8, 4):uint() .. "[" .. ssrc_types[tvbuf(8, 4):uint()] .. "] Flags=" .. string.tohex(decr_tvb(0, 2):raw()) .. "> " .. packetinfo
    else
        local subtree = tree:add("non xCloud Gamestreaming packet: " .. string.tohex(is_rtp:raw()), tvbuf(12):tvb())

        if string.tohex(is_rtp:raw()) == "01" or string.tohex(is_rtp:raw()) == "00" then
            local stun_dissector = Dissector.get("stun-udp")
            stun_dissector:call(tvbuf():tvb(), pinfo, tree)

            pinfo.cols.info = "STUN"
        end
    end
end

function dissect_data_packet(tree, buffer, ssrc)
    local packet_headers = ""
    local packet_tags = ""

    -- Read first 2 bytes for flags
    local bit1 = string.tohex(buffer(0, 1):raw())
    local bit2 = string.tohex(buffer(1, 1):raw())

    local flags = tree:add(hf.gs_flag_opcode, buffer(0, 2))
    flags:add(hf.gs_flag_opcode, buffer(0, 2))
    flags:add(hf.gs_flag_ms, buffer(0, 2))
    flags:add(hf.gs_flag_unknown4, buffer(0, 2))
    flags:add(hf.gs_flag_unknown6, buffer(0, 2))
    flags:add(hf.gs_flag_unknown5, buffer(0, 2))
    flags:add(hf.gs_flag_unknown, buffer(0, 2))
    flags:add(hf.gs_flag_udpack, buffer(0, 2))
    flags:add(hf.gs_flag_confirm, buffer(0, 2))
    flags:add(hf.gs_flag_sequence, buffer(0, 2))
    flags:add(hf.gs_flag_unknown2, buffer(0, 2))

    local offset = 2

    -- Process unconnected (Should ssrc=0[core] be processed in here? Seems so..)
    if (bit1 == "00" or bit1 == "01" or bit1 == "02" or bit1 == "28") and bit2 == "00" then
        return dissect_unconnected(tree, buffer)
    end

    -- Process connected

    local packetinfo = {
        sequence = -1,
        command = -1
    }

    -- if (bit1 == "14" and bit2 == "C0") then
    --     offset = offset+2
    -- end

    -- if (bit1 == "04" and bit2 == "C1") then
    --     offset = offset+3
    -- end

    -- if (bit1 == "45" and bit2 == "C1") then
    --     offset = offset+11
    -- end

    -- if (bit1 == "45" and bit2 == "C0") then
    --     offset = offset+9 -- this is sometimes 9.. Why?
    --     -- 45c07 e0071a10 c0a54 830000132e d400 0100 == 12
    --     -- 45c07 90021950 c0621 9622 ce00 0100 == 9

    -- end

    if ((bit1 == "45" or bit1 == "05" or bit1 == "55") and (bit2 == "C0" or bit2 == "C1")) then
        -- last_received_sequence:uint16
        tree:add_le(hf.connected_last_received, buffer(offset, 2))
        offset = offset + 2

        -- last_local_sequence:uint16
        tree:add_le(hf.connected_time_ms, buffer(offset, 2))
        offset = offset + 2

        -- last_local_sequence:uint16
        tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
        offset = offset + 2

        -- unknown:uint8 (bitflag?)
        tree:add_le(hf.unconnected_unk_8, buffer(offset, 1))
        offset = offset + 1
        local unknown_bitflag = buffer(offset-1, 1):le_uint()

        -- gs_header_flags
        local flags = tree:add(hf.gs_header_flags, buffer(offset-1, 1))
        flags:add(hf.gs_header_flags, buffer(offset-1, 1))

        -- packet_headers = packet_headers .. " Flags2=" .. buffer(offset-1, 1):le_uint()

        local offset_before = offset

        -- @TODO: Convert the horrible code below with bitmasks.. 

        if unknown_bitflag == 0 and bit1 == "45" then -- 0000 0000
            offset = offset + 1
        end
        if unknown_bitflag == 1  then
            offset = offset + 1
            
            if  bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 2 then -- 0000 0010
            offset = offset + 2

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 3 then -- 0000 0011
            offset = offset + 3

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 4 then
            offset = offset + 4
        end
        if unknown_bitflag == 5 then -- 0000 0101
            offset = offset + 5

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 6 then -- 0000 0110
            offset = offset + 6

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 116 then
            offset = offset + 4
        end
        if unknown_bitflag == 82 then
            offset = offset + 3
        end
        if unknown_bitflag == 17 then
            offset = offset + 1
            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 19 then
            offset = offset + 3
            if bit1 == "45" then
                offset = offset + 1
            end
        end

        if unknown_bitflag == 21 then
            offset = offset + 5
            if bit1 == "45" then
                offset = offset + 1
            end
        end

        if unknown_bitflag == 24 then
            offset = offset + 8
            if bit1 == "45" then
                offset = offset + 1
            end
        end

        if unknown_bitflag == 33 then
            offset = offset + 2
            
            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 34 then -- 0010 0010
            offset = offset + 0
            
            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 35 then
            offset = offset + 4
        end
        if unknown_bitflag == 40 then
            offset = offset + 8
            
            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 69 then
            offset = offset + 5
        end
        if unknown_bitflag == 51 then
            offset = offset + 4
        end
        if unknown_bitflag == 81 then -- 0101 0001
            offset = offset + 2
        end
        if unknown_bitflag == 49 then
            offset = offset + 1

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 65 then
            offset = offset + 1

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 66 then -- 0100 0010
            offset = offset + 3
        end
        if unknown_bitflag == 67 then -- 0100 0011
            offset = offset + 3
        end
        if unknown_bitflag == 68 then -- 0100 0100
            offset = offset + 4
        end
        if unknown_bitflag == 33 then -- 0010 0001 -- found on 05c0
            offset = offset -1
        end
        if unknown_bitflag == 34 then -- 0010 0010
            offset = offset + 2
        end
        if unknown_bitflag == 83 then -- 0101 0011
            offset = offset + 3

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 81 then -- 0101 0001 -- found on 05c0
            offset = offset - 1

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 84 then -- 0101 0100
            offset = offset + 5
        end
        if unknown_bitflag == 86 then -- 0101 0110
            offset = offset + 6
        end
        if unknown_bitflag == 97 then -- 0110 0011 -- found on 05c0
            offset = offset - 1

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 98 then -- 0110 0011
            offset = offset + 2

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 99 then -- 0110 0011
            offset = offset + 3

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        if unknown_bitflag == 100 then -- 0110 0100
            offset = offset + 4

            if bit1 == "45" then
                offset = offset + 1
            end
        end
        -- if unknown_bitflag == 17 and bit1 == "05" then -- 0001 0001 -- found on 05c0
        --     offset = offset -1
        -- end
        if unknown_bitflag == 18 then -- 0001 0010
            offset = offset + 2
        end
        if unknown_bitflag == 97 then -- 0110 0001
            offset = offset + 2
        end
        -- if unknown_bitflag == 1 and bit1 == "05" then
        --     offset = offset -1
        -- end

        if bit1 == "01" then
            offset = offset + 1
        end

        if bit1 == "55" then
            offset = offset + 3
        end
        -- if bit1 == "05" and bit2 == "C0" then
        --     offset = offset + 
        -- end
        -- if unknown_bitflag > 10 then
        --     offset = offset + 3
        -- end

        -- packet_headers = packet_headers .. " Padding=" .. (offset - offset_before)

        -- offset = offset+8 -- sometimes 7 or 12?
    end
        
    if bit2 == "C1" then
        offset = offset + 3
        -- packet_headers = packet_headers .. " PaddingC1=3"
    end

    if bit1 == "14" then 
        offset = offset + 2
    end

    local has_seq = {"C0", "C1"}
    for index, hex_match in pairs(has_seq) do
        if hex_match == bit2 then
            tree:add_le(hf.gs_sequence, buffer(offset, 2))
            offset = offset + 2

            packetinfo.sequence = buffer(offset-2, 2):le_uint()

            break
        end
    end

    if bit1 == "45" then 
        -- -- num:uint32
        -- tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        -- offset = offset + 4
        -- -- num:uint32
        -- tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        -- offset = offset + 4
    end

    -- local has_ms = {"55", "45"}
    -- for index, hex_match in pairs(has_ms) do
    --     if hex_match == bit1 then

    --         tree:add_le(hf.gs_ms, buffer(offset, 4))
    --         offset = offset + 4
    --         break
    --     end
    -- end

    -- Switch back to main tree
    
    -- command
    -- local pre_command = buffer(offset, 2):le_uint()
    -- if pre_command == 0 or pre_command == 1 or pre_command == 4 or pre_command == 5 then
    --     offset = offset + 8
    -- end

    tree:add_le(hf.gs_channel, buffer(offset, 2))
    packetinfo.channel = buffer(offset, 2):le_uint()
    offset = offset + 2
    -- packet index
    tree:add_le(hf.gs_packet_index, buffer(offset, 2))
    offset = offset + 2


    -- if bit1 == "04" or bit1 == "45"or bit1 == "05" then 
    --     -- num:uint32
    --     tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --     offset = offset + 4
    --     -- num:uint32
    --     tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --     offset = offset + 4
    -- end

    -- if packetinfo.channel == 2 and pre_command == 4 then
    --     packet_tags = packet_tags .. "HandshakeResponse"

    --     -- num:uint32 = 1
    --     tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --     offset = offset + 4

    --     -- length:uint32 = 100
    --     tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --     offset = offset + 4

    --     -- num:uint32 = 100
    --     tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --     offset = offset + 4

    --     -- fps:uint32 = 100
    --     tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --     offset = offset + 4

    --     -- width:uint32 = 1920
    --     tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --     offset = offset + 4

    --     -- height:uint32 = 1080
    --     tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --     offset = offset + 4

    --     -- num:uint32 = 0000 0000
    --     tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --     offset = offset + 4

    --     -- padding:uint16 = 0000
    --     tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
    --     offset = offset + 2
    -- end

    -- Channel open?
    if packetinfo.channel == 2 then
        packet_tags = packet_tags .. "OpenChannel"
        local channel_name_length = buffer(offset, 2):le_uint()

        if channel_name_length ~= 0 then
            tree:add_le(hf.gs_openchannel_name, buffer(offset+2, channel_name_length))
            offset = offset + channel_name_length + 2
        else
            offset = offset
        end

        -- num:uint32
        tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        offset = offset + 4

        -- data_length?:uint32
        tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
        local item_length = buffer(offset, 2):le_uint()
        offset = offset + 2
        
        if item_length > 0 then

            -- data_length2?:uint32
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2

            -- item_length:uint16
            tree:add_le(hf.unconnected_unk_bytes, buffer(offset, 4))
            offset = offset + 4

            -- padding:uint16
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2
        else
            -- binary_length?:uint32
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            local binary_length = buffer(offset, 2):le_uint()
            offset = offset + 2

            if binary_length > 0 then 
                tree:add_le(hf.unconnected_unk_16, buffer(offset, binary_length))
                offset = offset + binary_length + 1
            end

            -- padding:uint16
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2
        end
    end

    -- Data
    if packetinfo.channel == 0 then
        packet_tags = packet_tags .. "Audio"
        -- local channel_name_length = buffer(offset, 2):le_uint()

        if ssrc == 1027 then -- Video frame
            packet_tags = packet_tags .. "AudioFrame"

            --
        end

        -- tree:add_le(hf.gs_openchannel_name, buffer(offset+2, channel_name_length))
        -- offset = offset + channel_name_length + 2
    end

    -- Data
    -- if packetinfo.channel == 1 then
    --     -- packet_tags = packet_tags .. "Data"
    --     -- local channel_name_length = buffer(offset, 2):le_uint()

    --     if ssrc == 1026 then -- Video frame
    --         packet_tags = packet_tags .. "VideoFrame"

    --         -- -- num:uint32
    --         -- tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         -- offset = offset + 4
    --         -- -- command:uint32 = 4
    --         -- tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         -- offset = offset + 4

    --         -- type:uint32 = 1
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         offset = offset + 4

    --         -- frame_id:uint32 = 1253
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         packet_tags = packet_tags .. " FrameId=" .. buffer(offset, 4):le_uint()
    --         offset = offset + 4

    --         -- frametype again?:uint32 = 4
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         offset = offset + 4
            
    --         -- num:uint32 = 0
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         offset = offset + 4

    --         -- timestamp:uint64
    --         tree:add_le(hf.unconnected_unk_64, buffer(offset, 8))
    --         offset = offset + 8

    --         -- packet_count:uint32 = 0
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         offset = offset + 4
    --         -- total_size:uint32 = 9
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         offset = offset + 4

    --         -- metadata_size:uint32 = 2416
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         offset = offset + 4

    --         -- data_offset:uint32 = 2
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         packet_tags = packet_tags .. " Offset=" .. buffer(offset, 4):le_uint()
    --         local data_offset = buffer(offset, 4):le_uint()
    --         offset = offset + 4

    --         -- num:uint32 = 1213
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         offset = offset + 4

    --         -- data_size:uint32 = 0
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         local frame_size = buffer(offset, 4):le_uint()
    --         offset = offset + 4

    --         local video_tree = tree:add(hf.connected_video_data, buffer(offset, frame_size))

    --         video_frame = ByteArray.new(buffer(offset):raw(), true):tvb("Video")
    --         video_tree:add(hf.connected_video_data, video_frame())
    --         offset = offset + frame_size

    --         if data_offset == 0 then
    --             -- num:uint32 = 0
    --             tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --             local frame_size = buffer(offset, 4):le_uint()
    --             offset = offset + 4

    --             -- num:uint32 = 0
    --             tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --             offset = offset + 4

    --             -- num:uint8 = 0
    --             tree:add_le(hf.unconnected_unk_8, buffer(offset, 1))
    --             offset = offset + 1
    --         end

    --         -- num:uint16 = 0
    --         tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
    --         offset = offset + 2
    --     end
    --     if ssrc == 1030 then -- Input frame
    --         packet_tags = packet_tags .. "InputFrame"
    --     end
    --     if ssrc == 1031 then -- InputFeedback frame
    --         packet_tags = packet_tags .. "InputFeedbackFrame"
    --     end

    --     -- tree:add_le(hf.gs_openchannel_name, buffer(offset+2, channel_name_length))
    --     -- offset = offset + channel_name_length + 2
    -- end

    if packetinfo.channel == 3 then
        packet_tags = packet_tags .. "Control"
        -- local channel_name_length = buffer(offset, 2):le_uint()

        if ssrc == 1024 then -- Control frame
            packet_tags = packet_tags .. "Control"
        end
        if ssrc == 1025 then -- Qos frame
            packet_tags = packet_tags .. "Qos"

            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4

            -- fragment_index:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 2))
            local fragment_count = buffer(offset, 2):le_uint()
            offset = offset + 2

            -- num:uint16 = 0
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2

            -- data_length:uint16 = 0
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            local data_length = buffer(offset, 2):le_uint()
            offset = offset + 2

            if data_length > 1 then
                -- type?:uint16 = 0
                tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
                local data_length = buffer(offset, 2):le_uint()
                offset = offset + 2

                -- fragment_total_count:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- data_offset:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- data_length:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                local data_length = buffer(offset, 4):le_uint()
                offset = offset + 4

                -- data:uint32 = 0
                tree:add_le(hf.unconnected_unk_bytes, buffer(offset, data_length))
                offset = offset + data_length

                -- padding:uint32 = 0
                tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
                offset = offset + 2
            end

            -- padding:uint16 = 0
            -- tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            -- offset = offset + 2

            -- -- num:uint32 = 0
            -- tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            -- offset = offset + 4
        end
        if ssrc == 1026 then -- Video frame
            packet_tags = packet_tags .. "Video"

            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            local count = buffer(offset, 4):le_uint()
            offset = offset + 4

            if count > 0 then
                -- num:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- num:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- num:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- num:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- num:uint64 = 0
                tree:add_le(hf.unconnected_unk_64, buffer(offset, 8))
                offset = offset + 8

                -- -- num:uint32 = 0
                -- tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                -- offset = offset + 4

                -- -- num:uint32 = 0
                -- tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                -- offset = offset + 4



                -- num:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
            end

            -- num:uint16 = 0
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2
        end
        if ssrc == 1027 then -- Audio frame
            packet_tags = packet_tags .. "Audio"

            -- num:uint32
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4

            -- padding:uint16 = 0
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2
        end
        if ssrc == 1028 then -- Message frame
            packet_tags = packet_tags .. "Message"

            -- num:uint32
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4

            -- padding:uint16 = 0
            tree:add_le(hf.gs_message_data_type, buffer(offset, 2))
            local data_type = buffer(offset, 2):le_uint()
            offset = offset + 2
            
            if data_type == 2 then -- Message
                -- num:uint16 = 0
                tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
                local data_type = buffer(offset, 2):le_uint()
                offset = offset + 2

                -- total_length:uint32
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- num:uint32
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- timestamp_ms:uint32
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- num:uint32
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- key_length:uint32
                tree:add_le(hf.gs_packet_kv_key_length, buffer(offset, 4))
                local key_length = buffer(offset, 4):le_uint()
                offset = offset + 4

                -- value_length:uint32
                tree:add_le(hf.gs_packet_kv_value_length, buffer(offset, 4))
                local value_length = buffer(offset, 4):le_uint()
                offset = offset + 4

                -- num:uint32
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- payload_length:uint32
                tree:add_le(hf.gs_packet_kv_payload_length, buffer(offset, 4))
                offset = offset + 4

                if key_length > 0 then
                    -- key_value:string
                    tree:add_le(hf.gs_packet_kv_key, buffer(offset, key_length))
                    offset = offset + key_length
                end

                if value_length > 0 then
                    -- value_value:string
                    tree:add_le(hf.gs_packet_kv_value, buffer(offset, value_length))
                    offset = offset + value_length
                end

                -- padding:uint16 = 0
                tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
                offset = offset + 2
            end
        end
        if ssrc == 1029 then -- ChatAudio frame
            packet_tags = packet_tags .. "ChatAudio"
        end
        if ssrc == 1030 then -- Input frame
            packet_tags = packet_tags .. "Input"
        end
        if ssrc == 1031 then -- InputFeedback frame
            packet_tags = packet_tags .. "InputFeedback"
        end

        -- tree:add_le(hf.gs_openchannel_name, buffer(offset+2, channel_name_length))
        -- offset = offset + channel_name_length + 2
    end

    -- Handshake
    if packetinfo.channel == 0 or packetinfo.channel == 1 or packetinfo.channel == 4 or packetinfo.channel == 5 then
        packet_tags = packet_tags .. "Data"
        -- local channel_name_length = buffer(offset, 2):le_uint()

        -- num:uint32 = 100
        tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        offset = offset + 4

        -- handshake_type:uint32 = 100
        tree:add_le(hf.gs_command, buffer(offset, 2))
        local opcode = buffer(offset, 2):le_uint()
        packet_tags = packet_tags .. " Type=" .. opcode
        offset = offset + 4

        if opcode == 1 then
            -- num:uint32 = 1
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- length:uint32 = 44
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- device_type:uint32 = 6  // iPhone
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- width:uint32 = 100
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- height:uint32 = 100
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- fps:uint32 = 100
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- timestamp:uint32 = 100
            tree:add_le(hf.unconnected_unk_64, buffer(offset, 8))
            offset = offset + 8
    
            -- device_type:uint32 = 1 // Xbox One
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- fps:uint32
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- width:uint32 = 100
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- height:uint32 = 100
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- num:uint32 = 0000 0000
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- padding:uint16 = 0000
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2
        end

        if opcode == 2 then
            -- num:uint32 = 1
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- length:uint32 = 100
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- num:uint32 = 100
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- fps:uint32 = 100
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- width:uint32 = 1920
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- height:uint32 = 1080
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- num:uint32 = 0000 0000
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
    
            -- padding:uint16 = 0000
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2
        end

        if opcode == 4 then
            -- packet_tags = packet_tags .. "Data"
            -- local channel_name_length = buffer(offset, 2):le_uint()
    
            if ssrc == 1026 then -- Video frame
                packet_tags = packet_tags .. " VideoFrame"
    
                -- -- num:uint32
                -- tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                -- offset = offset + 4
                -- -- command:uint32 = 4
                -- tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                -- offset = offset + 4
    
                -- type:uint32 = 1
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
    
                -- frame_id:uint32 = 1253
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                packet_tags = packet_tags .. " FrameId=" .. buffer(offset, 4):le_uint()
                offset = offset + 4
    
                -- frametype again?:uint32 = 4
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
                
                -- num:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
    
                -- timestamp:uint64
                tree:add_le(hf.unconnected_unk_64, buffer(offset, 8))
                offset = offset + 8
    
                -- packet_count:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
                -- total_size:uint32 = 9
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
    
                -- metadata_size:uint32 = 2416
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
    
                -- data_offset:uint32 = 2
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                packet_tags = packet_tags .. " Offset=" .. buffer(offset, 4):le_uint()
                local data_offset = buffer(offset, 4):le_uint()
                offset = offset + 4
    
                -- num:uint32 = 1213
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
    
                -- data_size:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                local frame_size = buffer(offset, 4):le_uint()
                offset = offset + 4
    
                local video_tree = tree:add(hf.connected_video_data, buffer(offset, frame_size))
    
                video_frame = ByteArray.new(buffer(offset):raw(), true):tvb("Video")
                video_tree:add(hf.connected_video_data, video_frame())
                offset = offset + frame_size
    
                if data_offset == 0 then
                    -- num:uint32 = 0
                    tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                    local frame_size = buffer(offset, 4):le_uint()
                    offset = offset + 4
    
                    -- num:uint32 = 0
                    tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                    offset = offset + 4
    
                    -- num:uint8 = 0
                    tree:add_le(hf.unconnected_unk_8, buffer(offset, 1))
                    offset = offset + 1
                end
    
                -- num:uint16 = 0
                tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
                offset = offset + 2
            end
            if ssrc == 1030 then -- Input frame
                packet_tags = packet_tags .. "InputFrame2"

            end
            if ssrc == 1031 then -- InputFeedback frame
                packet_tags = packet_tags .. "InputFeedbackFrame"
            end
    
            -- tree:add_le(hf.gs_openchannel_name, buffer(offset+2, channel_name_length))
            -- offset = offset + channel_name_length + 2
        end

        if opcode == 5 then
            packet_tags = packet_tags .. " InputChannelRequest"
        end

        if opcode == 6 then
            packet_tags = packet_tags .. " InputChannelResponse"
        end

        if opcode == 7 then
            packet_tags = packet_tags .. " InputFrame"

            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4

            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4

            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4

            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4

            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4

            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4

            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4

            -- button flags?:uint32 = 0
            tree:add_le(hf.gs_input_buttons, buffer(offset, 2))
            offset = offset + 2

            -- button flags?:uint32 = 0
            tree:add_le(hf.gs_input_buttons, buffer(offset, 2))
            offset = offset + 2

            -- num:uint16 = 0
            tree:add_le(hf.gs_input_buttons, buffer(offset, 2))
            offset = offset + 2

            -- num:uint16 = 0
            tree:add_le(hf.gs_input_buttons, buffer(offset, 2))
            offset = offset + 2

            -- num:uint16 = 0
            tree:add_le(hf.gs_input_buttons, buffer(offset, 2))
            offset = offset + 2

            -- num:uint16 = 0
            tree:add_le(hf.unconnected_unk_16_int, buffer(offset, 2))
            offset = offset + 2

            -- num:uint16 = 0
            tree:add_le(hf.unconnected_unk_16_int, buffer(offset, 2))
            offset = offset + 2

            -- num:uint16 = 0
            tree:add_le(hf.unconnected_unk_8, buffer(offset, 1))
            offset = offset + 1

            -- pad:uint32 = 0
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2
        end

        -- tree:add_le(hf.gs_openchannel_name, buffer(offset+2, channel_name_length))
        -- offset = offset + channel_name_length + 2
    end

    -- Text fragment?
    -- -- if (bit1 == "04" or bit1 == "05" or bit1 == "45" or bit1 == "55") and (bit2 == "C0" or bit2 == "C1") then
        
    --     if bit2 == "C1" then
    --         tree:add_le(hf.gs_ms, buffer(offset, 3))
    --         offset = offset + 3
    --     end

    --     if bit1 == "04" then
    --         tree:add(hf.gs_ms, buffer(offset, 3))
    --         offset = offset + 3
    --         offset = offset + 5
    --     end
    --     if bit1 == "05" then
    --         tree:add_le(hf.gs_ms, buffer(offset, 4))
    --         offset = offset + 4
    --         offset = offset + 4
    --     end
    --     if bit1 == "45" or bit1 == "55" then
    --         offset = offset + 4
    --     end
    --     if bit1 == "55" then
    --         offset = offset + 2
    --     end

    --     tree:add_le(hf.gs_channel, buffer(offset, 2))
    --     offset = offset + 2
        -- Command is 03
        -- if packetinfo.channel == 3 then
        --     -- tree:add_le(hf.gs_packet_index, buffer(offset, 2))
        --     offset = offset + 4

        --     tree:add_le(hf.gs_packet_data_packets, buffer(offset, 2)) -- packet type? 1=string, 2 = kv, 3 = binary?, 16 = 0000 0100
        --     local data_type = buffer(offset, 2):le_uint()
        --     if data_type == 1 or data_type == 2 then
        --         packet_tags = packet_tags .. "MessageType=" .. data_type

        --         -- num:uint32 = 100
        --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        --         offset = offset + 4
        --         -- num:uint32 = 100
        --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        --         offset = offset + 4
        --         -- num:uint32 = 100
        --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        --         offset = offset + 4
        --         -- num:uint32 = 100
        --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        --         offset = offset + 4
        --         -- num:uint32 = 100
        --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        --         offset = offset + 4
        --         -- num:uint32 = 100
        --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        --         offset = offset + 4
        --         -- num:uint32 = 100
        --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        --         offset = offset + 4
        --         -- num:uint32 = 100
        --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        --         offset = offset + 4
        --         -- num:uint32 = 100
        --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
        --         offset = offset + 4

        --         -- offset = offset + 2
        --         -- tree:add_le(hf.gs_packet_total_length, buffer(offset, 2))
        --         -- offset = offset + 4
        --         -- tree:add_le(hf.gs_packet_data_type, buffer(offset, 2))
        --         -- local data_type = buffer(offset, 2):le_uint()
        --         -- offset = offset + 2

        --         -- if data_type == 10 then
        --         --     tree:add_le(hf.gs_packet_offset, buffer(offset, 4))
        --         --     offset = offset + 4
        --         --     local data_length = buffer(offset, 4):le_uint()
        --         --     -- print("data_length: " .. data_length)
        --         --     tree:add_le(hf.gs_packet_data, buffer(offset+4, data_length))
        --         --     offset = offset + 4 + data_length
        --         --     tree:add_le(hf.gs_packet_fragment_num, buffer(offset, 2))

        --         --     packet_tags = packet_tags .. " FragmentNum=" .. buffer(offset, 2):le_uint()
        --         -- end

        --         -- if data_type == 1 or data_type == 0 then
        --         --     -- offset = offset + 4
        --         --     local key_length = buffer(offset, 4):le_uint()
        --         --     offset = offset + 4
        --         --     local value_length = buffer(offset, 4):le_uint()
        --         --     offset = offset + 4
        --         --     local payload_length = buffer(offset, 4):le_uint()
        --         --     offset = offset + 4
        --         --     -- print(buffer(offset, 4):raw())
        --         --     tree:add_le(hf.gs_packet_kv_key, buffer(offset))
        --         --     offset = offset + key_length
        --         --     -- tree:add_le(hf.gs_packet_kv_value, buffer(offset, value_length))
        --         --     -- offset = offset + value_length

        --         --     packet_tags = packet_tags .. " KV=" .. data_type
        --         -- end
        --     end

        -- end

    --     -- Command is 02
    --     if buffer(offset-2, 2):le_uint() == 2 then
    --         offset = offset + 2
    --         local channel_name_length = buffer(offset, 2):le_uint()
    --         tree:add_le(hf.gs_openchannel_name, buffer(offset+2, channel_name_length))
    --         offset = offset + channel_name_length + 2
    --     end

    --     -- Command is 04
    --     if buffer(offset-2, 2):le_uint() == 4 then
    --         offset = offset + 2
    --         tree:add_le(hf.gs_packet_index, buffer(offset, 2))
    --         offset = offset + 4

    --         tree:add_le(hf.gs_packet_total_length, buffer(offset, 4))
    --         offset = offset + 4

    --         tree:add_le(hf.gs_video_fdata, buffer(offset, 4))
    --         offset = offset + 4

    --         tree:add_le(hf.gs_video_frameid, buffer(offset, 4))
    --         offset = offset + 4

    --         tree:add_le(hf.gs_video_timestamp, buffer(offset, 8))
    --         offset = offset + 8

            

            
    --     end
        
    -- -- end

    -- Open Channel
    -- if bit1 == "45" and bit2 == "C0" then
    --     offset = offset + 5
    --     tree:add_le(hf.gs_channel, buffer(offset, 2))
    --     offset = offset + 4

    --     if buffer(offset, 4):le_uint() == 2 then
    --         local channel_name_length = buffer(offset, 2):le_uint()
    --         tree:add_le(hf.gs_openchannel_name, buffer(offset+2, channel_name_length))
    --         offset = offset + channel_name_length + 2
    --     end
    -- end

    -- flags:add_le(hf.gs_sequence, buffer(2, 2))
    -- flags:add_le(hf.gs_ms, buffer(4, 3))

    local packetstring = "<Sequence=" .. packetinfo.sequence .. packet_headers .. " Channel=" .. packetinfo.channel .. "> <" .. packet_tags .. ">"
    return packetstring

end

function dissect_unconnected(tree, buffer)
    local packetstring = "<ConnectionProbing"

    -- Read first 2 bytes for flags
    local bit1 = string.tohex(buffer(0, 1):raw())
    local bit2 = string.tohex(buffer(1, 1):raw())

    -- Deserialise packet
    if bit1 == "01" then
        local probe_data_length = buffer():len()-2
        packetstring = packetstring .. "Syn Length=" .. probe_data_length
    end
    if bit1 == "02" then
        if buffer(2):len() > 2 then
            tree:add_le(hf.unconnected_ack_length, buffer(2, 4))
            packetstring = packetstring .. "Ack Length=" .. buffer(2, 4):le_uint()
        else 
            packetstring = packetstring .. "Ack Finished"
        end
    end
    -- if bit1 == "28" then
    --     packetstring = packetstring .. "Unknown2 Command=" .. buffer(2, 2):le_uint()
    --     tree:add_le(hf.unconnected_command, buffer(2, 2))

    --     offset = 4
    --     if buffer(2, 2):le_uint() == 0 then
    --         -- num:uint32 = 9
    --         tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
    --         offset = offset + 4
    --         -- padding:uint16 = 0
    --         tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
    --         offset = offset + 2
    --     end
    -- end
    if bit1 == "00" or bit1 == "01" or bit1 == "28" then
        local udp_opcode = buffer(2, 1):le_uint()
        packetstring = packetstring .. " OpCode=" .. udp_opcode .. " "


        packetstring = packetstring .. "Unknown Command=" .. buffer(2, 1):le_uint()
        tree:add_le(hf.unconnected_command, buffer(2, 1))

        offset = 4
        if buffer(2, 2):le_uint() == 0 then
            packetstring = packetstring .. " ConnectionRequest"
            -- num:uint32 = 9
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            local opcode = buffer(offset, 4):le_uint()
            offset = offset + 4

            if opcode == 18 then
                -- Confirmation from xbox?
                packetstring = packetstring .. " ClientToConsole"
            end

            if opcode == 9 then
                -- Connection request?
                packetstring = packetstring .. " ConsoleToClient"

                -- num:uint32 = 100
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
                -- num:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
                -- num:uint32 = 8000
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
                -- num:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4

                -- num:uint32 = 10
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
                -- num:uint32 = 100
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
                -- num:uint32 = 5000
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
                -- num:uint32 = 0
                tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
                offset = offset + 4
            end
            -- padding:uint16 = 0
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2
        end

        if buffer(2, 2):le_uint() == 3 then
            packetstring = packetstring .. " ConnectionResponse"
            -- length:uint8 = 0
            tree:add_le(hf.unconnected_unk_8, buffer(offset, 1))
            offset = offset + 1
            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
            -- num:uint32 = 0
            tree:add_le(hf.unconnected_unk_32, buffer(offset, 4))
            offset = offset + 4
            -- padding:uint16 = 0
            tree:add_le(hf.unconnected_unk_16, buffer(offset, 2))
            offset = offset + 2
        end
    end

    return packetstring .. ">"
end

function xcloud_proto.init()
end

-- teredo_table = Dissector.get ("teredo")
-- teredo_table:add(3074)

udp_table = DissectorTable.get("udp.port")
udp_table:add(0, xcloud_proto)
-- udp_table:add(58953, xcloud_proto)