local xCloudMessagingChannel = {}
setmetatable(xCloudMessagingChannel, xCloudMessagingChannel)
xCloudMessagingChannel.__index = xCloudMessagingChannel

function xCloudMessagingChannel:__call(buffer)
    local obj = {}
    xCloudMessagingChannel._buffer = buffer

    setmetatable(obj, xCloudMessagingChannel)
    return obj
end

function xCloudMessagingChannel:decode(tree, fields)
    local data = {}

    data.string = 'Messaging'
    local command = xCloudMessagingChannel._buffer(0, 2):le_uint()

    local offset = 4
    if command == 2 then
        -- Open Channel
        local channel_tree = tree:add("Messaging OpenChannel", xCloudMessagingChannel._buffer())
        local output = xCloudMessagingChannel:openChannel(channel_tree, fields)
        data.string = data.string .. ' openChannel' .. output

    elseif command == 3 then
        -- Control
        local channel_tree = tree:add("Messaging Control", xCloudMessagingChannel._buffer())
        local output = xCloudMessagingChannel:control(channel_tree, fields)
        data.string = data.string .. ' Control' .. output

    else
        data.string = data.string .. ' (Unknown)'
    end

    data.string = '[' .. data.string .. ']'

    return data
end

function xCloudMessagingChannel:openChannel(tree, fields)

    local offset = 4

    tree:add_le(fields.gs_openchannel_length, xCloudMessagingChannel._buffer(offset, 2))
    local channel_name_length = xCloudMessagingChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(fields.gs_openchannel_name, xCloudMessagingChannel._buffer(offset, channel_name_length))
    offset = offset + channel_name_length

    -- if xCloudMessagingChannel._buffer(offset, 2):le_uint() == 0 then
        tree:add_le(fields.unconnected_unk_16, xCloudMessagingChannel._buffer(offset, 2))
        offset = offset + 2
    -- end

    if channel_name_length > 0 then
        -- we got the first request because we have a channel name

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        offset = offset + 4

        -- unknown

        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        offset = offset + 4

    else

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        offset = offset + 4

        -- format_count
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        -- local format_count = xCloudMessagingChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- format_count
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        -- local format_count = xCloudMessagingChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- -- unk
        -- tree:add_le(fields.connected_audio_codec, xCloudMessagingChannel._buffer(offset, 4))
        -- offset = offset + 4

        -- zero padding
        tree:add_le(fields.unconnected_unk_16, xCloudMessagingChannel._buffer(offset, 2))
        offset = offset + 2


    end

    return ''
end

function xCloudMessagingChannel:control(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_messaging_type, xCloudMessagingChannel._buffer(offset, 2))
    local packet_type = xCloudMessagingChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    if packet_type == 0 then
        retstring = retstring .. ' KeepAlive'

    elseif packet_type == 2 then
        tree:add_le(fields.unconnected_unk_16, xCloudMessagingChannel._buffer(offset, 2))
        offset = offset + 2

        -- payload_size?
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        offset = offset + 4

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        offset = offset + 4

        -- frame_id
        tree:add_le(fields.connected_messaging_frame_id, xCloudMessagingChannel._buffer(offset, 4))
        local frame_id = xCloudMessagingChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        offset = offset + 4

        -- key_length
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        local key_length = xCloudMessagingChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- value_length
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        local value_length = xCloudMessagingChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        offset = offset + 4

        -- payload_size
        tree:add_le(fields.unconnected_unk_32, xCloudMessagingChannel._buffer(offset, 4))
        offset = offset + 4

        local keystr = ''
        if key_length > 0 then 
            -- Read Key Value
            tree:add_le(fields.connected_messaging_key, xCloudMessagingChannel._buffer(offset, key_length))
            keystr = keystr .. ' Key=' .. xCloudMessagingChannel._buffer(offset, key_length):string()
            offset = offset + key_length
        end

        if value_length > 0 then 
            -- Read Key Value
            tree:add_le(fields.connected_messaging_value, xCloudMessagingChannel._buffer(offset, value_length))
            -- local key_ngth = xCloudMessagingChannel._buffer(offset, key_length):string()
            offset = offset + value_length
        end

        -- next_sequence
        tree:add_le(fields.unconnected_unk_16, xCloudMessagingChannel._buffer(offset, 2))
        offset = offset + 2

        retstring = retstring .. ' Message #' .. frame_id .. keystr

    else 
        retstring = retstring .. ' Unknown=' .. packet_type
    end

    return retstring
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudMessagingChannel