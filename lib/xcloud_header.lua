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
    -- print('obj.buffer:')
    -- print(xCloudHeader._buffer)

    -- data.hexFlags = xCloudHeader._flags
    data.string = ''
    data.offset = 0
    data.command = -1

    tree:add(fields.gs_header_flags, xCloudHeader._buffer(0, 2))

    data.string = data.string .. 'flags=' .. tostring(xCloudHeader._buffer(0, 2):bytes())

    -- print('flags' .. tostring(xCloudHeader._buffer(0, 2):bytes()))
    -- print('bit' .. xCloudHeader._buffer(1, 1):bitfield(7, 1))

    local offset = 2

    if xCloudHeader._buffer(1, 1):bitfield(0, 2) == 3 then
        -- data.string = data.string .. '[Connected]'
    else 
        data.string = data.string .. '[Unconnected]'
    end

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
        -- tree:add_le(fields.gs_header_ms, xCloudHeader._buffer(offset, 3))
        local header_size = xCloudHeader._buffer(offset, 2):bitfield(12, 4)
        -- data.string = data.string .. ' header=' .. header_size
        offset = offset + 2

         -- -- read header length
        -- tree:add_le(fields.unconnected_unk_bytes, xCloudHeader._buffer(offset, header_size))
        offset = offset + header_size
    end

    -- Some custom padding

    -- if 05c1
    if (string.tohex(xCloudHeader._buffer(0, 2):raw()) == '05C1') then
        tree:add_le(fields.unconnected_unk_bytes, xCloudHeader._buffer(offset, 2))
        -- data.string = data.string .. ' 05Cx=' .. xCloudHeader._buffer(offset, 2):le_uint()
        offset = offset + 2
    end

    -- if 45C1
    if (string.tohex(xCloudHeader._buffer(0, 2):raw()) == '45C1') then
        tree:add_le(fields.unconnected_unk_16, xCloudHeader._buffer(offset, 2))
        -- data.string = data.string .. ' 05Cx=' .. xCloudHeader._buffer(offset, 2):le_uint()
        offset = offset + 2
    end

    -- if 04c1
    if (string.tohex(xCloudHeader._buffer(0, 2):raw()) == '04C1') then
        tree:add_le(fields.unconnected_unk_16, xCloudHeader._buffer(offset, 2))
        -- data.string = data.string .. ' 05Cx=' .. xCloudHeader._buffer(offset, 2):le_uint()
        offset = offset + 2
    end

    -- 4xxx has an extra byte
    if xCloudHeader._buffer(0, 1):bitfield(1, 1) > 0 then
        tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
        -- data.string = data.string .. ' 05Cx=' .. xCloudHeader._buffer(offset, 2):le_uint()
        offset = offset + 1
    end

    -- C1 set, read padding..
    if xCloudHeader._buffer(1, 1):bitfield(7, 1) > 0 then
        -- Read unknown padding?
        tree:add_le(fields.unconnected_unk_8, xCloudHeader._buffer(offset, 1))
        -- data.string = data.string .. ' padding'
        offset = offset + 1
    end

    -- hasSequence bitflag set
    if xCloudHeader._buffer(0, 1):bitfield(5, 1) > 0 then
        -- read confirm LE unit32()
        tree:add_le(fields.gs_header_sequence, xCloudHeader._buffer(offset, 2))
        -- data.string = data.string .. ' sequence=' .. xCloudHeader._buffer(offset, 2):le_uint()
        offset = offset + 2
    end

    -- read opcode LE uint16()
    tree:add_le(fields.gs_channel, xCloudHeader._buffer(offset, 2))
    data.string = data.string .. ' channel=' .. xCloudHeader._buffer(offset, 2):le_uint()
    data.command = xCloudHeader._buffer(offset, 2):le_uint()
    data.offset = offset

    return data
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudHeader