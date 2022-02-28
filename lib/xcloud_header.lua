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

    tree:add(fields.gs_header_flags, xCloudHeader._buffer(0, 2))
    data.string = data.string .. 'flags=' .. tostring(xCloudHeader._buffer(0, 2):bytes())

    -- print('flags' .. tostring(xCloudHeader._buffer(0, 2):bytes()))
    -- print('bit' .. xCloudHeader._buffer(1, 1):bitfield(7, 1))

    local offset = 2

    -- if bit is xxxx 11xx
    if xCloudHeader._buffer(1, 1):bitfield(0, 2) == 3 then

        -- hasHeaders bitflag is set. Read confirmmation packet, ms and additional headers.
        if xCloudHeader._buffer(0, 1):bitfield(7, 1) > 0 then
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

        
            -- Still need to figure the part below out.. Maybe FEC?
            -- if 05c1
            if (string.tohex(xCloudHeader._buffer(0, 2):raw()) == '05C1') then
                -- tree:add_le(fields.unconnected_unk_16, xCloudHeader._buffer(offset, 2))
                tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
                tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset+1, 1))
                data.string = data.string .. ' 05C1=' .. xCloudHeader._buffer(offset, 1):le_uint() .. ' ' .. xCloudHeader._buffer(offset+1, 1):le_uint()
                offset = offset + 2
            end

            -- if 45C1
            if (string.tohex(xCloudHeader._buffer(0, 2):raw()) == '45C1') then
                -- tree:add_le(fields.unconnected_unk_16, xCloudHeader._buffer(offset, 2))
                tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
                tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset+1, 1))
                data.string = data.string .. ' 45C1=' .. xCloudHeader._buffer(offset, 1):le_uint() .. ' ' .. xCloudHeader._buffer(offset+1, 1):le_uint()
                offset = offset + 2
            end

            -- if 14C1
            if (string.tohex(xCloudHeader._buffer(0, 2):raw()) == '14C1') then
                -- tree:add_le(fields.unconnected_unk_16, xCloudHeader._buffer(offset, 2))
                tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
                tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset+1, 1))
                data.string = data.string .. ' 14C1=' .. xCloudHeader._buffer(offset, 1):le_uint() .. ' ' .. xCloudHeader._buffer(offset+1, 1):le_uint()
                offset = offset + 2
            end

            -- if 04c1
            if (string.tohex(xCloudHeader._buffer(0, 2):raw()) == '04C1') then
                tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
                tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset+1, 1))
                data.string = data.string .. ' 04C1=' .. xCloudHeader._buffer(offset, 1):le_uint() .. ' ' .. xCloudHeader._buffer(offset+1, 1):le_uint()
                offset = offset + 2
            end

            -- 4xxx has an extra byte
            if xCloudHeader._buffer(0, 1):bitfield(1, 1) > 0 then
                tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
                data.string = data.string .. ' 4xxx=' .. xCloudHeader._buffer(offset, 1):le_uint()
                offset = offset + 1
            end

        -- C1 set, read padding..
        if xCloudHeader._buffer(1, 1):bitfield(7, 1) > 0 then
            -- Read unknown padding?
            tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
            local padding = xCloudHeader._buffer(offset, 1):le_uint()
            data.string = data.string .. ' padding=' .. padding
            offset = offset + 1
        end

        -- unknown confirm only?
        if xCloudHeader._buffer(0, 1):bitfield(3, 1) > 0 then
            -- Read unknown padding?
            tree:add_le(fields.gs_header_confirm, xCloudHeader._buffer(offset, 2))
            data.string = data.string .. ' confirm2=' .. xCloudHeader._buffer(offset, 2):le_uint()
            offset = offset + 2
        end

        -- hasSequence bitflag set
        if xCloudHeader._buffer(0, 1):bitfield(5, 1) > 0 then
            -- read confirm LE unit32()
            tree:add_le(fields.gs_header_sequence, xCloudHeader._buffer(offset, 2))
            data.string = data.string .. ' sequence=' .. xCloudHeader._buffer(offset, 2):le_uint()
            offset = offset + 2
        end

        -- read opcode LE uint16()
        -- tree:add_le(fields.gs_channel, xCloudHeader._buffer(offset, 1))
        -- data.string = data.string .. ' channel=' .. xCloudHeader._buffer(offset, 1):le_uint()
        -- data.command = xCloudHeader._buffer(offset, 1):le_uint()


    else 
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

    return data
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudHeader