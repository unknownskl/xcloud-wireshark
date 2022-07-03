local xClouxCloudChannelControl = {}
setmetatable(xClouxCloudChannelControl, xClouxCloudChannelControl)
xClouxCloudChannelControl.__index = xClouxCloudChannelControl

function xClouxCloudChannelControl:__call(buffer)
    local obj = {}
    xClouxCloudChannelControl._buffer = buffer

    setmetatable(obj, xClouxCloudChannelControl)
    return obj
end

function xClouxCloudChannelControl:openChannel(tree, fields)

    local offset = 0

    tree:add_le(fields.unconnected_unk_bytes, xClouxCloudChannelControl._buffer(offset, 4))
    offset = offset + 4

    tree:add_le(fields.connected_openchannel_size, xClouxCloudChannelControl._buffer(offset, 2))
    local channel_name_length = xClouxCloudChannelControl._buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(fields.connected_openchannel_name, xClouxCloudChannelControl._buffer(offset, channel_name_length))
    offset = offset + channel_name_length

    tree:add_le(fields.connected_openchannel_padding, xClouxCloudChannelControl._buffer(offset, 2))
    offset = offset + 2

    -- unknown
    tree:add_le(fields.unconnected_unk_16, xClouxCloudChannelControl._buffer(offset, 2))
    offset = offset + 2

    -- if channel_name_length > 0 then
        -- we got the first request because we have a channel name


        -- length
        -- tree:add_le(fields.connected_inputfeedback_frame_size, xClouxCloudChannelControl._buffer(offset, 4))
        -- local data_size = xClouxCloudChannelControl._buffer(offset, 4):le_uint()
        -- offset = offset + 4

        -- if data_size > 0 then
        --     tree:add_le(fields.unconnected_unk_bytes, xClouxCloudChannelControl._buffer(offset, data_size))
        --     offset = offset + data_size
        -- end

    -- else
    --     -- unk
    --     tree:add_le(fields.unconnected_unk_32, xClouxCloudChannelControl._buffer(offset, 4))
    --     offset = offset + 4

        -- -- format_count
        -- tree:add_le(fields.unconnected_unk_32, xClouxCloudChannelControl._buffer(offset, 4))
        -- -- local format_count = xClouxCloudChannelControl._buffer(offset, 4):le_uint()
        -- offset = offset + 4

        -- -- unk
        -- tree:add_le(fields.unconnected_unk_32, xClouxCloudChannelControl._buffer(offset, 4))
        -- offset = offset + 4

        -- -- unk
        -- tree:add_le(fields.unconnected_unk_32, xClouxCloudChannelControl._buffer(offset, 4))
        -- offset = offset + 4

        -- -- unk
        -- tree:add_le(fields.unconnected_unk_32, xClouxCloudChannelControl._buffer(offset, 4))
        -- local data_size = xClouxCloudChannelControl._buffer(offset, 4):le_uint()
        -- offset = offset + 4

        -- if data_size ~= 0 then
        --     -- unk
        --     tree:add_le(fields.unconnected_unk_bytes, xClouxCloudChannelControl._buffer(offset, data_size))
        --     offset = offset + data_size
        -- end

    -- end

    return ''
end

return xClouxCloudChannelControl