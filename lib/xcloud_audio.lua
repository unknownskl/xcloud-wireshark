local xCloudAudioChannel = {}
setmetatable(xCloudAudioChannel, xCloudAudioChannel)
xCloudAudioChannel.__index = xCloudAudioChannel

function xCloudAudioChannel:__call(buffer)
    local obj = {}
    xCloudAudioChannel._buffer = buffer

    setmetatable(obj, xCloudAudioChannel)
    return obj
end

function xCloudAudioChannel:decode(tree, fields)
    local data = {}

    data.string = 'Audio'
    local command = xCloudAudioChannel._buffer(0, 2):le_uint()

    local offset = 4

    if command == 2 then
        -- Open Channel
        local channel_tree = tree:add("Audio OpenChannel", xCloudAudioChannel._buffer())
        xCloudAudioChannel:openChannel(channel_tree, fields)
    else
        data.string = data.string .. ' (Unknown)'
    end

    data.string = '[' .. data.string .. ']'

    return data
end

function xCloudAudioChannel:openChannel(tree, fields)

    local offset = 4

    tree:add_le(fields.gs_openchannel_length, xCloudAudioChannel._buffer(offset, 2))
    local channel_name_length = xCloudAudioChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(fields.gs_openchannel_name, xCloudAudioChannel._buffer(offset, channel_name_length))
    offset = offset + channel_name_length

    -- if xCloudAudioChannel._buffer(offset, 2):le_uint() == 0 then
        tree:add_le(fields.unconnected_unk_16, xCloudAudioChannel._buffer(offset, 2))
        offset = offset + 2
    -- end

    if channel_name_length > 0 then
        -- we got the first request because we have a channel name

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudAudioChannel._buffer(offset, 4))
        offset = offset + 4

        -- unknown

        tree:add_le(fields.unconnected_unk_32, xCloudAudioChannel._buffer(offset, 4))
        offset = offset + 4

    else
        -- relative timmestamp?
        tree:add_le(fields.unconnected_unk_32, xCloudAudioChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudAudioChannel._buffer(offset, 4))
        offset = offset + 4

        -- hz
        tree:add_le(fields.unconnected_unk_32, xCloudAudioChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudAudioChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudAudioChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudAudioChannel._buffer(offset, 4))
        offset = offset + 4

        -- zero padding
        tree:add_le(fields.unconnected_unk_16, xCloudAudioChannel._buffer(offset, 2))
        offset = offset + 2

    end

    return ''
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudAudioChannel