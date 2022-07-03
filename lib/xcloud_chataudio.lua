local xCloudChatAudioChannel = {}
setmetatable(xCloudChatAudioChannel, xCloudChatAudioChannel)
xCloudChatAudioChannel.__index = xCloudChatAudioChannel

function xCloudChatAudioChannel:__call(buffer)
    local obj = {}
    xCloudChatAudioChannel._buffer = buffer

    setmetatable(obj, xCloudChatAudioChannel)
    return obj
end

function xCloudChatAudioChannel:decode(tree, fields)
    local data = {}

    data.string = 'ChatAudio'
    tree:add_le(fields.gs_channel, xCloudChatAudioChannel._buffer(0, 2))
    tree:add_le(fields.gs_control_sequence, xCloudChatAudioChannel._buffer(2, 2))
    local channel = xCloudChatAudioChannel._buffer(0, 2):le_uint()

    local offset = 4

    if channel == 2 then
        -- Open Channel
        local channel_tree = tree:add("ChatAudio OpenChannel", xCloudChatAudioChannel._buffer())
        xCloudChatAudioChannel:openChannel(channel_tree, fields)
    else
        data.string = data.string .. ' Channel=' .. channel
    end

    data.string = '[' .. data.string .. ']'

    return data
end

function xCloudChatAudioChannel:openChannel(tree, fields)

    local offset = 4

    tree:add_le(fields.gs_openchannel_length, xCloudChatAudioChannel._buffer(offset, 2))
    local channel_name_length = xCloudChatAudioChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(fields.gs_openchannel_name, xCloudChatAudioChannel._buffer(offset, channel_name_length))
    offset = offset + channel_name_length

    -- if xCloudChatAudioChannel._buffer(offset, 2):le_uint() == 0 then
    tree:add_le(fields.unconnected_unk_16, xCloudChatAudioChannel._buffer(offset, 2)) -- padding
    offset = offset + 2
    -- end

    if channel_name_length > 0 then
        -- we got the first request because we have a channel name

        -- unknown
        tree:add_le(fields.unconnected_unk_16, xCloudChatAudioChannel._buffer(offset, 2))
        offset = offset + 2

        -- unknown
        tree:add_le(fields.unconnected_unk_16, xCloudChatAudioChannel._buffer(offset, 2))
        offset = offset + 2

        -- unknown
        tree:add_le(fields.unconnected_unk_16, xCloudChatAudioChannel._buffer(offset, 2))
        offset = offset + 2

    else

        if xCloudChatAudioChannel._buffer(offset, 4):le_uint() == 7 then

            -- relative timmestamp?
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- timestamp
            tree:add_le(fields.unconnected_unk_64, xCloudChatAudioChannel._buffer(offset, 8))
            offset = offset + 8

            -- -- hz
            -- tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            -- offset = offset + 4

            -- format_count
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- format_channels
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- format_frequency
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- format_codec
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- format_bits
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- format_isfloat
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- zero padding
            tree:add_le(fields.unconnected_unk_16, xCloudChatAudioChannel._buffer(offset, 2))
            offset = offset + 2

        else
                
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- unk
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- hz
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- unk
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- unk
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- unk
            tree:add_le(fields.unconnected_unk_32, xCloudChatAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- zero padding
            tree:add_le(fields.unconnected_unk_16, xCloudChatAudioChannel._buffer(offset, 2))
            offset = offset + 2
        end
    end

    return ''
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudChatAudioChannel