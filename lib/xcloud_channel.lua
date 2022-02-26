local xCloudChannel = {}
setmetatable(xCloudChannel, xCloudChannel)
xCloudChannel.__index = xCloudChannel

function xCloudChannel:__call(buffer)
    local obj = {}
    xCloudChannel._buffer = buffer

    setmetatable(obj, xCloudChannel)
    return obj
end

function xCloudChannel:openChannel(tree, fields)
    local data = {}

    data.string = 'OpenChannel'

    local offset = 4

    
    tree:add_le(fields.gs_openchannel_length, xCloudChannel._buffer(offset, 2))
    local channel_name_length = xCloudChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(fields.gs_openchannel_name, xCloudChannel._buffer(offset, channel_name_length))
    offset = offset + channel_name_length

    -- if xCloudChannel._buffer(offset, 2):le_uint() == 0 then
        tree:add_le(fields.unconnected_unk_16, xCloudChannel._buffer(offset, 2))
        offset = offset + 2
    -- end

    if xCloudChannel._buffer(offset, 2):le_uint() ~= 0 then
        tree:add_le(fields.unconnected_unk_32, xCloudChannel._buffer(offset, 4))
        offset = offset + 4
    else
        offset = offset + 2
    end

    if xCloudChannel._buffer(offset, 2):le_uint() ~= 0 then
        tree:add_le(fields.unconnected_unk_32, xCloudChannel._buffer(offset, 4))
        offset = offset + 4
    else
        offset = offset + 2
    end

    if xCloudChannel._buffer(offset, 2):le_uint() ~= 0 then
        tree:add_le(fields.unconnected_unk_32, xCloudChannel._buffer(offset, 4))
        offset = offset + 4
    else
        offset = offset + 2
    end

    data.string = '[' .. data.string .. ']'

    return data
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudChannel