local xCloudQosChannel = {}
setmetatable(xCloudQosChannel, xCloudQosChannel)
xCloudQosChannel.__index = xCloudQosChannel

function xCloudQosChannel:__call(buffer)
    local obj = {}
    xCloudQosChannel._buffer = buffer

    setmetatable(obj, xCloudQosChannel)
    return obj
end

function xCloudQosChannel:decode(tree, fields)
    local data = {}

    data.string = 'Qos'
    tree:add_le(fields.gs_channel, xCloudQosChannel._buffer(0, 2))
    tree:add_le(fields.gs_control_sequence, xCloudQosChannel._buffer(2, 2))
    local channel = xCloudQosChannel._buffer(0, 2):le_uint()

    local offset = 4

    if channel == 0 then
        -- Open Channel
        local channel_tree = tree:add("Qos FrameData", xCloudQosChannel._buffer())
        local output = xCloudQosChannel:frameData(channel_tree, fields)
        data.string = data.string .. ' Data' .. output

    elseif channel == 1 then
        -- Open Channel
        local channel_tree = tree:add("Qos FrameData", xCloudQosChannel._buffer())
        local output = xCloudQosChannel:frameData(channel_tree, fields)
        data.string = data.string .. ' FrameData' .. output

    elseif channel == 2 then
        -- Open Channel
        local channel_tree = tree:add("Qos OpenChannel", xCloudQosChannel._buffer())
        local output = xCloudQosChannel:openChannel(channel_tree, fields)
        data.string = data.string .. ' openChannel' .. output

    elseif channel == 3 then
        -- Control
        local channel_tree = tree:add("Qos Control", xCloudQosChannel._buffer())
        local output = xCloudQosChannel:control(channel_tree, fields)
        data.string = data.string .. ' Control' .. output

    elseif channel == 4 then
        -- Control
        local channel_tree = tree:add("Qos Config", xCloudQosChannel._buffer())
        local output = xCloudQosChannel:config(channel_tree, fields)
        data.string = data.string .. ' Config' .. output

    else
        data.string = data.string .. ' Channel=' .. channel
    end

    data.string = '[' .. data.string .. ']'

    return data
end

function xCloudQosChannel:openChannel(tree, fields)

    local offset = 4

    tree:add_le(fields.gs_openchannel_length, xCloudQosChannel._buffer(offset, 2))
    local channel_name_length = xCloudQosChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(fields.gs_openchannel_name, xCloudQosChannel._buffer(offset, channel_name_length))
    offset = offset + channel_name_length

    -- if xCloudQosChannel._buffer(offset, 2):le_uint() == 0 then
        tree:add_le(fields.unconnected_unk_16, xCloudQosChannel._buffer(offset, 2))
        offset = offset + 2
    -- end

    if channel_name_length > 0 then
        -- we got the first request because we have a channel name

        -- unknown
        tree:add_le(fields.unconnected_unk_16, xCloudQosChannel._buffer(offset, 2))
        offset = offset + 2

        -- length
        tree:add_le(fields.connected_inputfeedback_frame_size, xCloudQosChannel._buffer(offset, 4))
        local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        if data_size > 0 then
            tree:add_le(fields.unconnected_unk_bytes, xCloudQosChannel._buffer(offset, data_size))
            offset = offset + data_size
        end

        -- zero padding
        tree:add_le(fields.connected_next_sequence, xCloudQosChannel._buffer(offset, 2))
        offset = offset + 2

    else
        -- unk
        tree:add_le(fields.connected_input_min_version, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4

        -- format_count
        tree:add_le(fields.connected_input_max_version, xCloudQosChannel._buffer(offset, 4))
        -- local format_count = xCloudQosChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- -- format_count
        -- tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        -- -- local format_count = xCloudQosChannel._buffer(offset, 4):le_uint()
        -- offset = offset + 4

        -- -- unk
        -- tree:add_le(fields.connected_audio_codec, xCloudQosChannel._buffer(offset, 4))
        -- offset = offset + 4

        -- zero padding
        tree:add_le(fields.connected_next_sequence, xCloudQosChannel._buffer(offset, 2))
        offset = offset + 2


    end

    return ''
end

function xCloudQosChannel:control(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
    local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_qos_type, xCloudQosChannel._buffer(offset, 2))
    local packet_type = xCloudQosChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    if xCloudQosChannel._buffer(offset):len() > 2 then
        -- We have more bytes to read...
        tree:add_le(fields.unconnected_unk_16, xCloudQosChannel._buffer(offset, 2))
        offset = offset + 2

        if packet_type == 0 then 
            
            -- unknown
            tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
            -- local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- unknown
            tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
            -- local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4
    
            retstring = retstring .. ' Frame='..packet_type
    
        elseif packet_type == 1 and xCloudQosChannel._buffer(offset):len() > 2 then 
            -- unknown
            tree:add_le(fields.connected_qos_frame_totalsize, xCloudQosChannel._buffer(offset, 4))
            -- local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4
            
            -- frame_index
            tree:add_le(fields.connected_qos_frame_index, xCloudQosChannel._buffer(offset, 4))
            -- local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4
            
            -- offset
            tree:add_le(fields.connected_qos_frame_offset, xCloudQosChannel._buffer(offset, 4))
            -- local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4
            
            -- data_size
            tree:add_le(fields.connected_qos_frame_size, xCloudQosChannel._buffer(offset, 4))
            local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4
    
            -- Read Video Data
            local fragment_tree = tree:add(fields.connected_qos_data, xCloudQosChannel._buffer(offset, data_size))
    
            frragment_frame = ByteArray.new(xCloudQosChannel._buffer(offset, data_size):raw(), true):tvb("Fragment data")
            fragment_tree:add(fields.connected_qos_data, frragment_frame())
            offset = offset + data_size
    
            retstring = retstring .. ' FrameData='..packet_type
    
        else 
            -- -- pad
            -- tree:add_le(fields.connected_next_sequence, xCloudQosChannel._buffer(offset-2, 2))
            -- -- offset = offset + 2

            retstring = retstring .. ' KeepAlive='..packet_type
        end

    elseif packet_type == 0 then 
        retstring = retstring .. ' KeepAlive'
        offset = offset - 2
    else 
        retstring = retstring .. ' Unknown='..packet_type
    end

    -- zero padding
    tree:add_le(fields.connected_next_sequence, xCloudQosChannel._buffer(offset, 2))
    offset = offset + 2

    return retstring
end

function xCloudQosChannel:config(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown = 0
    tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_inputfeedback_type, xCloudQosChannel._buffer(offset, 2))
    local packet_type = xCloudQosChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    if packet_type > 0 then

        tree:add_le(fields.unconnected_unk_16, xCloudQosChannel._buffer(offset, 2))
        offset = offset + 2

        -- data_size
        tree:add_le(fields.connected_inputfeedback_frame_size, xCloudQosChannel._buffer(offset, 4))
        local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- min_version
        tree:add_le(fields.connected_inputfeedback_min_version, xCloudQosChannel._buffer(offset, 4))
        local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- max_version
        tree:add_le(fields.connected_inputfeedback_max_version, xCloudQosChannel._buffer(offset, 4))
        local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        if packet_type == 5 then
            retstring = retstring .. ' ConfigRequest'

            -- width
            tree:add_le(fields.connected_inputfeedback_width, xCloudQosChannel._buffer(offset, 4))
            local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- height
            tree:add_le(fields.connected_inputfeedback_height, xCloudQosChannel._buffer(offset, 4))
            local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- unk
            tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
            local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- timestamp
            tree:add_le(fields.connected_inputfeedback_timestamp, xCloudQosChannel._buffer(offset, 4))
            local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- pad
            tree:add_le(fields.connected_next_sequence, xCloudQosChannel._buffer(offset, 2))
            local data_size = xCloudQosChannel._buffer(offset, 2):le_uint()
            offset = offset + 2

        elseif packet_type == 6 then

            -- unk
            tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
            local data_size = xCloudQosChannel._buffer(offset, 4):le_uint()
            offset = offset + 4

            -- timestamp
            tree:add_le(fields.connected_inputfeedback_timestamp, xCloudQosChannel._buffer(offset, 8))
            -- local data_size = xCloudQosChannel._buffer(offset, 8):le_uint()
            offset = offset + 8

            -- pad
            tree:add_le(fields.connected_next_sequence, xCloudQosChannel._buffer(offset, 2))
            local data_size = xCloudQosChannel._buffer(offset, 2):le_uint()
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

function xCloudQosChannel:frameData(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_qos_type, xCloudQosChannel._buffer(offset, 4))
    local packet_type = xCloudQosChannel._buffer(offset, 4):le_uint()
    offset = offset + 4

    if packet_type == 1 then
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudQosChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- next_sequence
        tree:add_le(fields.unconnected_unk_16, xCloudQosChannel._buffer(offset, 2))
        offset = offset + 2

        retstring = retstring .. ' Data'

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

return xCloudQosChannel