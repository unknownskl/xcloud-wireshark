local xCloudHeader = {}
setmetatable(xCloudHeader, xCloudHeader)
xCloudHeader.__index = xCloudHeader

function xCloudHeader:__call(buffer)
    local obj = {}
    xCloudHeader._buffer = buffer

    setmetatable(obj, xCloudHeader)
    return obj
end

function xCloudHeader:addFields(fields, add_field)
    -- flags
    add_field(ProtoField.uint16, "xcloud_header_flags", "Header flags", base.DEC, {}, 0xffff)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown1", "Unknown flag 1", base.DEC, {}, 0x8000)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown2", "Has extra byte after header", base.DEC, {}, 0x4000)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown3", "Unknown flag 3", base.DEC, {}, 0x2000)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown4", "(?) Header is reversed", base.DEC, {}, 0x1000)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown5", "Has timestamp and expects another packet with the same timestamp", base.DEC, {}, 0x0800)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown6", "Has sequence", base.DEC, {}, 0x0400)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown7", "Unknown flag 7 (isack?)", base.DEC, {}, 0x0200)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown8", "Has timestamp and confirm", base.DEC, {}, 0x0100)
    add_field(ProtoField.uint16, "xcloud_header_flag_isconnected", "Is connected", base.DEC, {}, 0x00c0)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown10", "Unknown flag 10", base.DEC, {}, 0x0020)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown11", "Unknown flag 11", base.DEC, {}, 0x0010)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown12", "Unknown flag 12", base.DEC, {}, 0x0008)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown13", "Unknown flag 13", base.DEC, {}, 0x0004)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown14", "Unknown flag 14", base.DEC, {}, 0x0002)
    add_field(ProtoField.uint16, "xcloud_header_flag_unknown15", "Has an extra 3 bytes after header", base.DEC, {}, 0x0001)

    -- data types
    add_field(ProtoField.uint16, "xcloud_header_sequence", "Sequence")
    add_field(ProtoField.uint16, "xcloud_header_sequence_next", "Next Sequence")
    add_field(ProtoField.uint16, "xcloud_header_sequence_confirm", "Confirm Sequence")
    add_field(ProtoField.uint24, "xcloud_header_ms", "Timestamp")
    add_field(ProtoField.uint24, "xcloud_header_channel_ms", "Channel timestamp in usec")
    add_field(ProtoField.bytes, "xcloud_header_unk_bytes", "Unk Header Bytes")
    add_field(ProtoField.uint16, "xcloud_header_unk_size", "Unk Header Size")
    add_field(ProtoField.uint16, "xcloud_header_unk_flags", "Unk Header flags", base.DEC, {}, 0xffff)
    add_field(ProtoField.uint8, "xcloud_header_unk2", "Unk2 digit")
    add_field(ProtoField.uint8, "xcloud_header_unk3", "Unk3 digit")

    add_field(ProtoField.uint16, "xcloud_header_c1_unk2", "C1 unk2")
    add_field(ProtoField.uint16, "xcloud_header_c1_unk4", "C1 unk4")

    add_field(ProtoField.uint8, "xcloud_header_dropped_type", "Dropped packet bitflag", base.DEC, {
        [129] = 'timestamp + last frameid',
        [130] = 'timestamp + timestamp(?)',
    })
    add_field(ProtoField.uint24, "xcloud_header_dropped_ms", "Dropped timestamp")
    add_field(ProtoField.uint24, "xcloud_header_dropped_delayms", "Delay in MS(24bit,?)")
    add_field(ProtoField.uint16, "xcloud_header_dropped_delayms16", "Delay in MS(16bit,?)")
    add_field(ProtoField.uint16, "xcloud_header_dropped_lastsequence", "Last sequence")


end

function xCloudHeader:decode(tree, fields, rtp_info)
    local data = {}

    data.string = ''
    data.offset = 0
    data.command = -1

    local flags_tree = tree:add(fields.xcloud_header_flags, xCloudHeader._buffer(0, 2))
    data.string = data.string .. '[flags=' .. tostring(xCloudHeader._buffer(0, 2):bytes()) .. ']'

    -- Read flags: byte 1
    flags_tree:add(fields.xcloud_header_flag_unknown1, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown2, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown3, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown4, xCloudHeader._buffer(0, 2))

    -- Read flags: byte 2
    flags_tree:add(fields.xcloud_header_flag_unknown5, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown6, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown7, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown8, xCloudHeader._buffer(0, 2))

    -- Read flags: byte 3
    flags_tree:add(fields.xcloud_header_flag_isconnected, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown10, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown11, xCloudHeader._buffer(0, 2))

    -- Read flags: byte 4
    flags_tree:add(fields.xcloud_header_flag_unknown12, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown13, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown14, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.xcloud_header_flag_unknown15, xCloudHeader._buffer(0, 2))

    local offset = 2
        
    -- hasHeaders bitflag is set. Read confirmation packet, ms and additional headers.
    -- bitflags: 0000 000x xx00 0000
    if (xCloudHeader._buffer(0, 1):bitfield(7, 1) > 0) and (xCloudHeader._buffer(1, 1):bitfield(0, 2) == 3) then

        -- bitflags 0000 0x00 0000 0000
        if xCloudHeader._buffer(0, 1):bitfield(5, 1) == 1 then
            tree:add_le(fields.xcloud_header_sequence_confirm, xCloudHeader._buffer(offset, 2))
            offset = offset + 2
        else
            tree:add_le(fields.xcloud_header_sequence, xCloudHeader._buffer(offset, 2))
            offset = offset + 2
        end

        -- read timestamp LE unit32()
        tree:add_le(fields.xcloud_header_ms, xCloudHeader._buffer(offset, 3))
        -- data.string = data.string .. ' ms=' .. xCloudHeader._buffer(offset, 3):le_uint()
        offset = offset + 3

        -- -- read header length
        local header_size = xCloudHeader._buffer(offset, 2):bitfield(12, 4)
        -- data.string = data.string .. ' header=' .. header_size
        offset = offset + 2

        -- -- read header length
        -- tree:add_le(fields.unconnected_unk_bytes, xCloudHeader._buffer(offset, header_size))
        offset = offset + header_size

        local header_total_size = 2 + header_size
        local header_tree = tree:add("Header bytes", xCloudHeader._buffer(offset-header_total_size, header_total_size))
        header_tree:add_le(fields.xcloud_header_unk_size, xCloudHeader._buffer(offset-header_total_size, 2):bitfield(12, 4))
        header_tree:add_le(fields.xcloud_header_unk_flags, xCloudHeader._buffer(offset-header_total_size, 2))


        if xCloudHeader._buffer(offset-header_total_size, 2):bitfield(12, 4) > 0 then
            header_tree:add_le(fields.xcloud_header_unk_bytes, xCloudHeader._buffer(offset-header_total_size+2, header_total_size-2))
        end

    end

    -- bitflag 0x00 0000 0000 0000 -- is big endian?
    if xCloudHeader._buffer(0, 1):bitfield(1, 1) > 0 then

        tree:add_le(fields.xcloud_debug_uint8, xCloudHeader._buffer(offset, 1))
        local padding = xCloudHeader._buffer(offset, 1):le_uint()
        -- data.string = data.string .. ' padding=' .. padding
        offset = offset + 1
    end

    -- C1 set, read padding..
    -- bitflag 0000 0000 0000 000x
    if xCloudHeader._buffer(1, 1):bitfield(6, 2) ~= 0 then
        tree:add(fields.xcloud_header_channel_ms, xCloudHeader._buffer(offset, 1))
        offset = offset + 1

        tree:add(fields.xcloud_header_channel_ms, xCloudHeader._buffer(offset, 1))
        offset = offset + 1

        tree:add_le(fields.xcloud_header_channel_ms, xCloudHeader._buffer(offset, 1))
        offset = offset + 1
    end

    -- unknown confirm only?
    -- bitflag 000x 0000 0000 0000
    if xCloudHeader._buffer(0, 1):bitfield(3, 1) > 0 then
        -- Read unknown padding?
        tree:add_le(fields.xcloud_header_sequence_confirm, xCloudHeader._buffer(offset, 2))
        -- data.string = data.string .. ' confirm2=' .. xCloudHeader._buffer(offset, 2):le_uint()
        offset = offset + 2
    end

    -- hasSequence bitflag set
    -- bitflag 0000 0x00 0000 0000
    if xCloudHeader._buffer(0, 1):bitfield(5, 1) > 0 then
        -- bitflag 0000 000x 0000 0000
        tree:add_le(fields.xcloud_header_sequence, xCloudHeader._buffer(offset, 2))
        offset = offset + 2
    end

    -- Read offset = 14

    -- Latency detected?
    -- bitflag 0000 x000 0000 0000
    if (xCloudHeader._buffer(0, 1):bitfield(4, 1) > 0) then

        tree:add_le(fields.xcloud_header_sequence_confirm, xCloudHeader._buffer(offset, 2))
        offset = offset + 2

        local dropped_tree = tree:add_le(fields.xcloud_header_dropped_type, xCloudHeader._buffer(offset, 1)) 
        local latency_flag = xCloudHeader._buffer(offset, 1):uint()
        offset = offset + 1

        tree:add_le(fields.xcloud_header_ms, xCloudHeader._buffer(offset, 3))
        offset = offset + 3

        if latency_flag == 129 then
            dropped_tree:add_le(fields.xcloud_header_dropped_delayms16, xCloudHeader._buffer(offset, 2))
            offset = offset + 2
        else
            dropped_tree:add_le(fields.xcloud_header_dropped_delayms, xCloudHeader._buffer(offset, 3))
            offset = offset + 3
        end
    end

    data.offset = offset
    data.data_size = xCloudHeader._buffer(offset):len()-2

    data_payload = ByteArray.new(xCloudHeader._buffer(0, data.offset):raw(), true):tvb("Header Payload")

    -- tree:add_le(fields.xcloud_header_nex, xCloudHeader._buffer(data.offset + data.data_size, 2))

    -- -- Check packet size
    -- local calc_size = data.offset + data.data_size + 2
    -- if calc_size ~= xCloudHeader._buffer():len() then
    --     data.string = data.string .. ' [MALFORMED]'
    --     tree:add_expert_info(PI_MALFORMED, PI_ERROR, "identifyer mismatch!")
    -- end

    return data
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudHeader