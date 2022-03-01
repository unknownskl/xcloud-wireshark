local xCloudFrame = {}
setmetatable(xCloudFrame, xCloudFrame)
xCloudFrame.__index = xCloudFrame

function xCloudFrame:__call(buffer)
    local obj = {}
    xCloudFrame._buffer = buffer

    setmetatable(obj, xCloudFrame)
    return obj
end

function xCloudFrame:decode(tree, fields)
    local data = {}

    data.string = ''
    data.offset = 0

    tree:add_le(fields.connected_message_type, xCloudFrame._buffer(data.offset, 2))
    data.offset = data.offset + 2
    
    tree:add_le(fields.connected_frame_index, xCloudFrame._buffer(data.offset, 2))
    -- data.string = data.string .. 'TYPE=' ..xCloudFrame._buffer(offset, 2):le_uint()
    data.offset = data.offset + 2

    tree:add_le(fields.connected_frame_yaml_size, xCloudFrame._buffer(data.offset, 4))
    local yaml_size = xCloudFrame._buffer(data.offset, 4):le_uint()
    data.offset = data.offset + 4
    
    if yaml_size ~= 0 then
        tree:add_le(fields.connected_frame_yaml_data, xCloudFrame._buffer(data.offset, yaml_size))
        data.offset = data.offset + yaml_size

        return data
    end

    -- Check if we have more bytes to read?
    if xCloudFrame._buffer(data.offset):len() > 0 then

        tree:add_le(fields.connected_frame_type, xCloudFrame._buffer(data.offset, 2))
        -- data.string = data.string .. 'TYPE=' ..xCloudFrame._buffer(offset, 2):le_uint()
        data.string = data.string .. 'frame_type=' .. xCloudFrame._buffer(data.offset, 2):le_uint()
        data.offset = data.offset + 2

        tree:add_le(fields.connected_frame_subtype, xCloudFrame._buffer(data.offset, 2))
        data.string = data.string .. ' frame_type_sub=' .. xCloudFrame._buffer(data.offset, 2):le_uint()
        data.offset = data.offset + 2

        -- local has_frame_id = xCloudFrame._buffer(data.offset, 4):le_uint()
        -- -- tree:add_le(fields.unconnected_unk_32, xCloudFrame._buffer(data.offset, 4))

        -- tree:add_le(fields.connected_frame_version, xCloudFrame._buffer(data.offset, 4))
        -- -- local frame_size = xCloudFrame._buffer(offset, 4):le_uint()
        -- data.offset = data.offset + 4

        -- tree:add_le(fields.connected_frame_id, xCloudFrame._buffer(data.offset, 4))
        -- -- data.string = data.string + ''
        -- data.offset = data.offset + 4

        -- tree:add_le(fields.unconnected_unk_32, xCloudFrame._buffer(data.offset, 4))
        -- data.offset = data.offset + 4

        -- -- tree:add_le(fields.unconnected_unk_32, xCloudFrame._buffer(data.offset, 4))
        -- -- data.offset = data.offset + 4

        -- -- tree:add_le(fields.unconnected_unk_32, xCloudFrame._buffer(data.offset, 4))
        -- -- data.offset = data.offset + 4
    end

    if xCloudFrame._buffer(data.offset):len() ~= 0 then
        data.string = data.string .. ' [BYTES_LEFT=' .. xCloudFrame._buffer(data.offset):len() .. ']'
    end

    return data
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudFrame