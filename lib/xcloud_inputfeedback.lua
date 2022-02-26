local xCloudInputFeedbackChannel = {}
setmetatable(xCloudInputFeedbackChannel, xCloudInputFeedbackChannel)
xCloudInputFeedbackChannel.__index = xCloudInputFeedbackChannel

function xCloudInputFeedbackChannel:__call(buffer)
    local obj = {}
    xCloudInputFeedbackChannel._buffer = buffer

    setmetatable(obj, xCloudInputFeedbackChannel)
    return obj
end

function xCloudInputFeedbackChannel:decode(tree, fields)
    local data = {}

    data.string = 'InputFeedback'
    local command = xCloudInputFeedbackChannel._buffer(0, 2):le_uint()

    local offset = 4
    if command == 1 then
        -- Open Channel
        local channel_tree = tree:add("InputFeedback FrameData", xCloudInputFeedbackChannel._buffer())
        local output = xCloudInputFeedbackChannel:frameData(channel_tree, fields)
        data.string = data.string .. ' FrameData' .. output

    elseif command == 2 then
        -- Open Channel
        local channel_tree = tree:add("InputFeedback OpenChannel", xCloudInputFeedbackChannel._buffer())
        local output = xCloudInputFeedbackChannel:openChannel(channel_tree, fields)
        data.string = data.string .. ' openChannel' .. output

    elseif command == 3 then
        -- Control
        local channel_tree = tree:add("InputFeedback Control", xCloudInputFeedbackChannel._buffer())
        local output = xCloudInputFeedbackChannel:control(channel_tree, fields)
        data.string = data.string .. ' Control' .. output

    elseif command == 4 then
        -- Control
        local channel_tree = tree:add("InputFeedback Config", xCloudInputFeedbackChannel._buffer())
        local output = xCloudInputFeedbackChannel:config(channel_tree, fields)
        data.string = data.string .. ' Config' .. output

    else
        data.string = data.string .. ' Unknown=' .. command
    end

    data.string = '[' .. data.string .. ']'

    return data
end

function xCloudInputFeedbackChannel:openChannel(tree, fields)

    local offset = 4

    tree:add_le(fields.gs_openchannel_length, xCloudInputFeedbackChannel._buffer(offset, 2))
    local channel_name_length = xCloudInputFeedbackChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(fields.gs_openchannel_name, xCloudInputFeedbackChannel._buffer(offset, channel_name_length))
    offset = offset + channel_name_length

    -- if xCloudInputFeedbackChannel._buffer(offset, 2):le_uint() == 0 then
        tree:add_le(fields.unconnected_unk_16, xCloudInputFeedbackChannel._buffer(offset, 2))
        offset = offset + 2
    -- end

    if channel_name_length > 0 then
        -- we got the first request because we have a channel name

        -- unknown
        tree:add_le(fields.unconnected_unk_16, xCloudInputFeedbackChannel._buffer(offset, 2))
        offset = offset + 2

        -- length
        tree:add_le(fields.connected_inputfeedback_frame_size, xCloudInputFeedbackChannel._buffer(offset, 4))
        local data_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        if data_size > 0 then
            tree:add_le(fields.unconnected_unk_bytes, xCloudInputFeedbackChannel._buffer(offset, data_size))
            offset = offset + data_size
        end

        -- zero padding
        tree:add_le(fields.unconnected_unk_16, xCloudInputFeedbackChannel._buffer(offset, 2))
        offset = offset + 2

    else

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
        offset = offset + 4

        -- format_count
        tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
        -- local format_count = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- format_count
        tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
        -- local format_count = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- -- unk
        -- tree:add_le(fields.connected_audio_codec, xCloudInputFeedbackChannel._buffer(offset, 4))
        -- offset = offset + 4

        -- zero padding
        tree:add_le(fields.unconnected_unk_16, xCloudInputFeedbackChannel._buffer(offset, 2))
        offset = offset + 2


    end

    return ''
end

function xCloudInputFeedbackChannel:control(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
    local data_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
    offset = offset + 4

    if data_size ~= 0 then
        -- Read data

        tree:add_le(fields.unconnected_unk_bytes, xCloudInputFeedbackChannel._buffer(offset, data_size))
        offset = offset + data_size

        retstring = retstring .. ' InputFeedbackRequest'
    else
        retstring = retstring .. ' InputFeedbackResponse'
    end

    -- zero padding
    tree:add_le(fields.unconnected_unk_16, xCloudInputFeedbackChannel._buffer(offset, 2))
    offset = offset + 2

    return retstring
end

function xCloudInputFeedbackChannel:config(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown = 0
    tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_inputfeedback_type, xCloudInputFeedbackChannel._buffer(offset, 2))
    local packet_type = xCloudInputFeedbackChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    if packet_type > 0 then

        tree:add_le(fields.unconnected_unk_16, xCloudInputFeedbackChannel._buffer(offset, 2))
        offset = offset + 2

        -- data_size
        tree:add_le(fields.connected_inputfeedback_frame_size, xCloudInputFeedbackChannel._buffer(offset, 4))
        local data_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- min_version
        tree:add_le(fields.connected_inputfeedback_min_version, xCloudInputFeedbackChannel._buffer(offset, 4))
        local data_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- max_version
        tree:add_le(fields.connected_inputfeedback_max_version, xCloudInputFeedbackChannel._buffer(offset, 4))
        local data_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        if packet_type == 5 then
            retstring = retstring .. ' ConfigRequest'

            -- width
            tree:add_le(fields.connected_inputfeedback_width, xCloudInputFeedbackChannel._buffer(offset, 4))
            local data_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- height
            tree:add_le(fields.connected_inputfeedback_height, xCloudInputFeedbackChannel._buffer(offset, 4))
            local data_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- unk
            tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
            local data_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- timestamp
            tree:add_le(fields.connected_inputfeedback_timestamp, xCloudInputFeedbackChannel._buffer(offset, 4))
            local data_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- pad
            tree:add_le(fields.unconnected_unk_16, xCloudInputFeedbackChannel._buffer(offset, 2))
            local data_size = xCloudInputFeedbackChannel._buffer(offset, 2):le_uint()
            offset = offset + 2

        elseif packet_type == 6 then

            -- unk
            tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
            local data_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- timestamp
            tree:add_le(fields.connected_inputfeedback_timestamp, xCloudInputFeedbackChannel._buffer(offset, 8))
            -- local data_size = xCloudInputFeedbackChannel._buffer(offset, 8):le_uint()
            offset = offset + 8

            -- pad
            tree:add_le(fields.unconnected_unk_16, xCloudInputFeedbackChannel._buffer(offset, 2))
            local data_size = xCloudInputFeedbackChannel._buffer(offset, 2):le_uint()
            offset = offset + 2

            retstring = retstring .. ' ConfigResponse'

        else
            retstring = retstring .. ' Unknown=' .. packet_type
        end
    else 
        retstring = retstring .. ' KeepAlive'
    end

    
    return retstring

end

function xCloudInputFeedbackChannel:frameData(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_inputfeedback_type, xCloudInputFeedbackChannel._buffer(offset, 4))
    local packet_type = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
    offset = offset + 4

    if packet_type == 3 then
        -- frame_size
        tree:add_le(fields.connected_inputfeedback_frame_size, xCloudInputFeedbackChannel._buffer(offset, 4))
        local frame_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
        offset = offset + 4
        
        -- frame_id
        tree:add_le(fields.connected_inputfeedback_frame_id, xCloudInputFeedbackChannel._buffer(offset, 4))
        local frame_id = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
        offset = offset + 4
        
        -- next_sequence
        tree:add_le(fields.unconnected_unk_16, xCloudInputFeedbackChannel._buffer(offset, 2))
        offset = offset + 2

        retstring = retstring .. ' Ack #' .. frame_id

    elseif packet_type == 7 then
        -- We got a video frame

        -- frame_size
        tree:add_le(fields.connected_inputfeedback_frame_size, xCloudInputFeedbackChannel._buffer(offset, 4))
        local frame_size = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- frame_id
        tree:add_le(fields.connected_inputfeedback_frame_id, xCloudInputFeedbackChannel._buffer(offset, 4))
        local frame_id = xCloudInputFeedbackChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
        offset = offset + 4

        -- gamepad_id
        tree:add_le(fields.unconnected_unk_8, xCloudInputFeedbackChannel._buffer(offset, 1))
        offset = offset + 1

        -- ms
        tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputFeedbackChannel._buffer(offset, 4))
        offset = offset + 4

        -- next_sequence
        tree:add_le(fields.unconnected_unk_16, xCloudInputFeedbackChannel._buffer(offset, 2))
        offset = offset + 2
        
        retstring = retstring .. ' #' .. frame_id
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

return xCloudInputFeedbackChannel