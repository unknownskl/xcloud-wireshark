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

    if command == 0 then
        -- Open Channel
        local channel_tree = tree:add("Audio FrameData", xCloudAudioChannel._buffer())
        local output = xCloudAudioChannel:frameData(channel_tree, fields)
        data.string = data.string .. ' frameData' .. output

    elseif command == 2 then
        -- Open Channel
        local channel_tree = tree:add("Audio OpenChannel", xCloudAudioChannel._buffer())
        local output = xCloudAudioChannel:openChannel(channel_tree, fields)
        data.string = data.string .. ' openChannel' .. output

    elseif command == 3 then
        -- Control
        local channel_tree = tree:add("Audio Control", xCloudAudioChannel._buffer())
        local output = xCloudAudioChannel:control(channel_tree, fields)
        data.string = data.string .. ' Control' .. output

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
        local packet_type = xCloudAudioChannel._buffer(offset, 4):le_uint()

        if packet_type == 7 then
            -- show packet_type
            tree:add_le(fields.connected_audio_type, xCloudAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- timestamp
            tree:add_le(fields.connected_audio_timestamp, xCloudAudioChannel._buffer(offset, 8))
            offset = offset + 8

            -- format_count
            tree:add_le(fields.connected_audio_format_count, xCloudAudioChannel._buffer(offset, 4))
            local format_count = xCloudAudioChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            for i=1,format_count do
                local format_tree = tree:add("Audio format [" .. i .. "]", xCloudAudioChannel._buffer(offset, 12))    

                -- format_channels
                format_tree:add_le(fields.connected_audio_format_channels, xCloudAudioChannel._buffer(offset, 4))
                offset = offset + 4

                -- format_frequency
                format_tree:add_le(fields.connected_audio_format_frequency, xCloudAudioChannel._buffer(offset, 4))
                offset = offset + 4

                -- format_codec
                format_tree:add_le(fields.connected_audio_codec, xCloudAudioChannel._buffer(offset, 4))
                offset = offset + 4
            end

            -- zero padding
            tree:add_le(fields.unconnected_unk_16, xCloudAudioChannel._buffer(offset, 2))
            offset = offset + 2
        else

            -- unk
            tree:add_le(fields.connected_audio_frame_refid, xCloudAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- format_count
            tree:add_le(fields.connected_audio_format_channels, xCloudAudioChannel._buffer(offset, 4))
            local format_count = xCloudAudioChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- format_count
            tree:add_le(fields.connected_audio_format_frequency, xCloudAudioChannel._buffer(offset, 4))
            local format_count = xCloudAudioChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- unk
            tree:add_le(fields.connected_audio_codec, xCloudAudioChannel._buffer(offset, 4))
            offset = offset + 4

            -- zero padding
            tree:add_le(fields.unconnected_unk_16, xCloudAudioChannel._buffer(offset, 2))
            offset = offset + 2

        end

    end

    return ''
end

function xCloudAudioChannel:control(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudAudioChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_audio_type, xCloudAudioChannel._buffer(offset, 2))
    local packet_type = xCloudAudioChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    if packet_type == 0 then
        retstring = retstring .. ' KeepAlive'

    elseif packet_type == 3 then
        retstring = retstring .. ' Ack'

    elseif packet_type == 16 then
        retstring = retstring .. ' Connected'

        tree:add_le(fields.unconnected_unk_16, xCloudAudioChannel._buffer(offset, 2))
        offset = offset + 2

        -- zero padding
        tree:add_le(fields.unconnected_unk_16, xCloudAudioChannel._buffer(offset, 2))
        offset = offset + 2

    else 
        retstring = retstring .. ' Unknown=' .. packet_type
    end

    return retstring
end

function xCloudAudioChannel:frameData(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudAudioChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_audio_type, xCloudAudioChannel._buffer(offset, 4))
    local packet_type = xCloudAudioChannel._buffer(offset, 4):le_uint()
    offset = offset + 4

    if packet_type == 4 then
        
        -- frame_id
        tree:add_le(fields.connected_audio_frame_id, xCloudAudioChannel._buffer(offset, 4))
        local frame_id = xCloudAudioChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- timestamp
        tree:add_le(fields.connected_audio_timestamp, xCloudAudioChannel._buffer(offset, 8))
        offset = offset + 8
        
        -- audio_size
        tree:add_le(fields.connected_audio_frame_size, xCloudAudioChannel._buffer(offset, 4))
        local data_size = xCloudAudioChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- Read Audio Data
        local audio_tree = tree:add(fields.connected_audio_data, xCloudAudioChannel._buffer(offset, data_size))

        audio_frame = ByteArray.new(xCloudAudioChannel._buffer(offset, data_size):raw(), true):tvb("Audio")
        audio_tree:add(fields.connected_audio_data, audio_frame())
        offset = offset + data_size



        -- zero padding
        tree:add_le(fields.unconnected_unk_16, xCloudAudioChannel._buffer(offset, 2))
        offset = offset + 2

        retstring = retstring .. ' #' .. frame_id .. ' ' .. data_size .. '/' .. data_size

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

return xCloudAudioChannel