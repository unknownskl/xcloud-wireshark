local xCloudInputChannel = {}
setmetatable(xCloudInputChannel, xCloudInputChannel)
xCloudInputChannel.__index = xCloudInputChannel

function xCloudInputChannel:__call(buffer)
    local obj = {}
    xCloudInputChannel._buffer = buffer

    setmetatable(obj, xCloudInputChannel)
    return obj
end

function xCloudInputChannel:decode(tree, fields)
    local data = {}

    data.string = 'Input'
    tree:add_le(fields.gs_channel, xCloudInputChannel._buffer(0, 2))
    tree:add_le(fields.gs_control_sequence, xCloudInputChannel._buffer(2, 2))
    local channel = xCloudInputChannel._buffer(0, 2):le_uint()

    local offset = 4
    if channel == 1 then
        -- Open Channel
        local channel_tree = tree:add("Input FrameData", xCloudInputChannel._buffer())
        local output = xCloudInputChannel:frameData(channel_tree, fields)
        data.string = data.string .. ' FrameData' .. output

    elseif channel == 2 then
        -- Open Channel
        local channel_tree = tree:add("Input OpenChannel", xCloudInputChannel._buffer())
        local output = xCloudInputChannel:openChannel(channel_tree, fields)
        data.string = data.string .. ' openChannel' .. output

    elseif channel == 3 then
        -- Control
        local channel_tree = tree:add("Input Control", xCloudInputChannel._buffer())
        local output = xCloudInputChannel:control(channel_tree, fields)
        data.string = data.string .. ' Control' .. output

    elseif channel == 4 then
        -- Control
        local channel_tree = tree:add("Input Config", xCloudInputChannel._buffer())
        local output = xCloudInputChannel:config(channel_tree, fields)
        data.string = data.string .. ' Config' .. output

    else
        data.string = data.string .. ' Channel=' .. channel
    end

    data.string = '[' .. data.string .. ']'

    return data
end

function xCloudInputChannel:openChannel(tree, fields)

    local offset = 4

    tree:add_le(fields.gs_openchannel_length, xCloudInputChannel._buffer(offset, 2))
    local channel_name_length = xCloudInputChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(fields.gs_openchannel_name, xCloudInputChannel._buffer(offset, channel_name_length))
    offset = offset + channel_name_length

    -- if xCloudInputChannel._buffer(offset, 2):le_uint() == 0 then
        tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        offset = offset + 2
    -- end

    if channel_name_length > 0 then
        -- we got the first request because we have a channel name

        -- unknown
        tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        offset = offset + 2

        -- length
        tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
        local data_size = xCloudInputChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        if data_size > 0 then
            tree:add_le(fields.unconnected_unk_bytes, xCloudInputChannel._buffer(offset, data_size))
            offset = offset + data_size
        end

        -- zero padding
        tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        offset = offset + 2

    else

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- format_count
        tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
        -- local format_count = xCloudInputChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- format_count
        tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
        -- local format_count = xCloudInputChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- -- unk
        -- tree:add_le(fields.connected_audio_codec, xCloudInputChannel._buffer(offset, 4))
        -- offset = offset + 4

        -- zero padding
        tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        offset = offset + 2


    end

    return ''
end

function xCloudInputChannel:control(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
    local data_size = xCloudInputChannel._buffer(offset, 4):le_uint()
    offset = offset + 4

    if data_size ~= 0 then
        -- Read data

        tree:add_le(fields.unconnected_unk_bytes, xCloudInputChannel._buffer(offset, data_size))
        offset = offset + data_size
    else
        --
    end

    -- zero padding
    tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
    offset = offset + 2

    return retstring
end

function xCloudInputChannel:config(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown = 0
    tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_video_type, xCloudInputChannel._buffer(offset, 2))
    local packet_type = xCloudInputChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    if packet_type == 5 then 
        -- type_pad
        tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        offset = offset + 2

        -- data_size
        tree:add_le(fields.connected_input_frame_size, xCloudInputChannel._buffer(offset, 4))
        local data_size = xCloudInputChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- min_version
        tree:add_le(fields.connected_input_min_version, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- max_version
        tree:add_le(fields.connected_input_max_version, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- width
        tree:add_le(fields.connected_input_width, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- height
        tree:add_le(fields.connected_input_height, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- max_touches
        tree:add_le(fields.connected_input_max_touches, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- relative_frameid
        tree:add_le(fields.connected_input_frame_refid, xCloudInputChannel._buffer(offset, 4))
        local frame_id = xCloudInputChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- pad
        tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        offset = offset + 2

        retstring = retstring .. ' InputRequest #' .. frame_id

    elseif packet_type == 6 then 
        -- type_pad
        tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        offset = offset + 2

        -- data_size
        tree:add_le(fields.connected_input_frame_size, xCloudInputChannel._buffer(offset, 4))
        local data_size = xCloudInputChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- min_version
        tree:add_le(fields.connected_input_min_version, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- max_version
        tree:add_le(fields.connected_input_max_version, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- max_version
        tree:add_le(fields.connected_input_max_version, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- timestamp
        tree:add_le(fields.connected_audio_timestamp, xCloudInputChannel._buffer(offset, 8))
        -- local frame_id = xCloudInputChannel._buffer(offset, 8):le_uint()
        offset = offset + 8

        -- pad
        tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        offset = offset + 2

        retstring = retstring .. ' InputResponse #'

    else
        retstring = retstring .. ' Unknown=' .. packet_type
    end
    
    return retstring

end

function xCloudInputChannel:frameData(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_input_type, xCloudInputChannel._buffer(offset, 4))
    local packet_type = xCloudInputChannel._buffer(offset, 4):le_uint()
    offset = offset + 4

    if packet_type == 3 then
        -- frame_size
        tree:add_le(fields.connected_input_frame_size, xCloudInputChannel._buffer(offset, 4))
        local frame_size = xCloudInputChannel._buffer(offset, 4):le_uint()
        offset = offset + 4
        
        -- frame_id
        tree:add_le(fields.connected_input_frame_id, xCloudInputChannel._buffer(offset, 4))
        local frame_id = xCloudInputChannel._buffer(offset, 4):le_uint()
        offset = offset + 4
        
        -- next_sequence
        tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        offset = offset + 2

        retstring = retstring .. ' Ack #' .. frame_id

    elseif packet_type == 7 then
        -- We got a video frame

        -- frame_size
        tree:add_le(fields.connected_input_frame_size, xCloudInputChannel._buffer(offset, 4))
        local frame_size = xCloudInputChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- frame_id
        tree:add_le(fields.connected_input_frame_id, xCloudInputChannel._buffer(offset, 4))
        local frame_id = xCloudInputChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- absolute timestamp since epoch
        tree:add_le(fields.unconnected_unk_64, xCloudInputChannel._buffer(offset, 8))
        offset = offset + 8

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 2))
        offset = offset + 2

        -- Count gamepad frames
        local gamepad_frames_tree = tree:add_le(fields.gs_input_gamepad_frame_count, xCloudInputChannel._buffer(offset, 2))
        local gamepad_frames_count = xCloudInputChannel._buffer(offset, 2):le_uint()
        offset = offset + 2

        -- @TODO: Process gamepad frames. Lets skip the bytes is we have some now.
        if gamepad_frames_count > 0 then
            gamepad_frames_tree:add_le(fields.unconnected_unk_bytes, xCloudInputChannel._buffer(offset, 43))
            offset = offset + (43 *gamepad_frames_count)
        end

        -- unknown count of soemthing? or boolean
        tree:add_le(fields.unconnected_unk_8, xCloudInputChannel._buffer(offset, 1))
        offset = offset + 1

        -- ms
        tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        --  -- gamepad_id
        --  tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        --  offset = offset + 2

        -- -- unk
        -- tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
        -- offset = offset + 2

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudInputChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_16, xCloudInputChannel._buffer(offset, 2))
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

return xCloudInputChannel