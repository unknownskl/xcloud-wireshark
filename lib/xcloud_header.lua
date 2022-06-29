local xCloudHeader = {}
setmetatable(xCloudHeader, xCloudHeader)
xCloudHeader.__index = xCloudHeader

function xCloudHeader:__call(buffer)
    local obj = {}
    xCloudHeader._buffer = buffer

    setmetatable(obj, xCloudHeader)
    return obj
end

function xCloudHeader:decode(tree, fields)
    local data = {}

    data.string = ''
    data.offset = 0
    data.command = -1

    local flags_tree = tree:add(fields.gs_header_flags, xCloudHeader._buffer(0, 2))
    data.string = data.string .. 'flags=' .. tostring(xCloudHeader._buffer(0, 2):bytes())

    -- Read flags: byte 1
    flags_tree:add(fields.gs_header_flag_unknown1, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_unknown2, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_unknown3, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_unknown4, xCloudHeader._buffer(0, 2))

    -- Read flags: byte 2
    flags_tree:add(fields.gs_header_flag_unknown5, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_hassequence, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_unknown6, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_hasflags, xCloudHeader._buffer(0, 2))

    -- Read flags: byte 3
    flags_tree:add(fields.gs_header_flag_isconnected, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_unknown7, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_unknown8, xCloudHeader._buffer(0, 2))

    -- Read flags: byte 4
    flags_tree:add(fields.gs_header_flag_unknown9, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_unknown10, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_unknown11, xCloudHeader._buffer(0, 2))
    flags_tree:add(fields.gs_header_flag_haspadding, xCloudHeader._buffer(0, 2))

    -- print('flags' .. tostring(xCloudHeader._buffer(0, 2):bytes()))
    -- print('bit' .. xCloudHeader._buffer(1, 1):bitfield(7, 1))

    local offset = 2

    -- hasHeaders bitflag is set. Read confirmation packet, ms and additional headers.
    -- bitflags: 0000 000x xx00 0000
    if (xCloudHeader._buffer(0, 1):bitfield(7, 1) > 0) and (xCloudHeader._buffer(1, 1):bitfield(0, 2) == 3) then
        -- read confirm LE unit32()
        tree:add_le(fields.gs_header_confirm, xCloudHeader._buffer(offset, 2))
        -- data.string = data.string .. ' confirm=' .. xCloudHeader._buffer(offset, 2):le_uint()
        offset = offset + 2

        -- read timestamp LE unit32()
        tree:add_le(fields.gs_header_ms, xCloudHeader._buffer(offset, 3))
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
        header_tree:add_le(fields.gs_header_size, xCloudHeader._buffer(offset-header_total_size, 2):bitfield(12, 4))
        header_tree:add_le(fields.gs_header_flags, xCloudHeader._buffer(offset-header_total_size, 2))


        if xCloudHeader._buffer(offset-header_total_size, 2):bitfield(12, 4) > 0 then
            header_tree:add_le(fields.gs_header_bytes, xCloudHeader._buffer(offset-header_total_size+2, header_total_size-2))
        end
    end

    -- C1 set, read padding..
    -- bitflag 0000 0000 0000 000x
    if xCloudHeader._buffer(1, 1):bitfield(6, 2) ~= 0 then
        -- Read unknown padding?
        tree:add_le(fields.unconnected_unk_24, xCloudHeader._buffer(offset, 3))
        local padding = xCloudHeader._buffer(offset, 3):le_uint()
        -- data.string = data.string .. ' padding=' .. padding
        offset = offset + 3
    end

    -- unknown pad
    -- bitflag 0x00 0000 0000 0000
    if xCloudHeader._buffer(0, 1):bitfield(1, 1) > 0 then
        -- Read unknown padding?
        tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
        -- data.string = data.string .. ' confirm2=' .. xCloudHeader._buffer(offset, 2):le_uint()
        offset = offset + 1
    end

    -- unknown confirm only?
    -- bitflag 000x 0000 0000 0000
    if xCloudHeader._buffer(0, 1):bitfield(3, 1) > 0 then
        -- Read unknown padding?
        tree:add_le(fields.gs_header_confirm, xCloudHeader._buffer(offset, 2))
        -- data.string = data.string .. ' confirm2=' .. xCloudHeader._buffer(offset, 2):le_uint()
        offset = offset + 2
    end

    -- hasSequence bitflag set
    -- bitflag 0000 0x00 0000 0000
    if xCloudHeader._buffer(0, 1):bitfield(5, 1) > 0 then
        -- read confirm LE unit32()
        tree:add_le(fields.gs_header_sequence, xCloudHeader._buffer(offset, 2))
        -- data.string = data.string .. ' sequence=' .. xCloudHeader._buffer(offset, 2):le_uint()
        offset = offset + 2
    end

    -- Read offset = 14

    -- Has flags
    -- bitflag 0000 x000 0000 0000
    if (xCloudHeader._buffer(0, 1):bitfield(4, 1) > 0) then

        -- tree:add_le(fields.unconnected_unk_16, xCloudHeader._buffer(offset, 2))
        -- offset = offset + 2

        -- tree:add_le(fields.unconnected_unk_24, xCloudHeader._buffer(offset, 3))
        -- offset = offset + 3

        -- tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
        -- offset = offset + 1

        -- -- Read unknown padding?
        -- tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
        -- offset = offset + 1
        

        -- -- -- read header length
        -- local header_size = xCloudHeader._buffer(offset, 2):bitfield(12, 4)
        -- offset = offset + 2

        -- offset = offset + header_size

        -- local header_total_size = 2 + header_size
        -- local header_tree = tree:add("Header bytes", xCloudHeader._buffer(offset-header_total_size, header_total_size))
        -- header_tree:add_le(fields.gs_header_size, xCloudHeader._buffer(offset-header_total_size, 2):bitfield(12, 4))
        -- header_tree:add_le(fields.gs_header_flags, xCloudHeader._buffer(offset-header_total_size, 2))


        -- if xCloudHeader._buffer(offset-header_total_size, 2):bitfield(12, 4) > 0 then
        --     header_tree:add_le(fields.gs_header_bytes, xCloudHeader._buffer(offset-header_total_size+2, header_total_size-2))
        -- end 
    end

    if xCloudHeader._buffer(1, 1):bitfield(0, 2) ~= 3 then
        
        data.string = data.string .. '[Unconnected]'

        if string.tohex(xCloudHeader._buffer(0, 2):string()) == "0100" then
            local probe_data_length = xCloudHeader._buffer():len()-2
            data.string = data.string .. "Syn Length=" .. probe_data_length

        elseif string.tohex(xCloudHeader._buffer(0, 2):string()) == "0200" then
            if xCloudHeader._buffer(2):len() > 2 then
                tree:add_le(fields.unconnected_ack_length, xCloudHeader._buffer(2, 4))
                data.string = data.string .. "Ack Length=" .. xCloudHeader._buffer(2, 4):le_uint()
            else 
                data.string = data.string .. "Ack Finished"
            end
        end
    end

    data.offset = offset
    data.data_size = xCloudHeader._buffer(offset):len()-2

    -- if data.data_size == 0 then
    --     data.string = data.string .. ' [NO-DATA]'
    -- else
    --     data.string = data.string .. ' [DATA='.. data.data_size ..']'
    -- end

    tree:add_le(fields.connected_next_sequence, xCloudHeader._buffer(data.offset + data.data_size, 2))
    -- data.string = data.string .. "DATA_SEQ=" .. xCloudHeader._buffer(data.offset + data.data_size, 2):le_uint()

    -- Check packet size
    local calc_size = data.offset + data.data_size + 2
    if calc_size ~= xCloudHeader._buffer():len() then
        -- data.string = data.string .. ' [LENGTH CALC ERROR]'
        tree:add_le(fields.check_length_error, 1)
    end

    return data
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudHeader