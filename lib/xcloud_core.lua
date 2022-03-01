local xCloudCoreChannel = {}
setmetatable(xCloudCoreChannel, xCloudCoreChannel)
xCloudCoreChannel.__index = xCloudCoreChannel

function xCloudCoreChannel:__call(buffer)
    local obj = {}
    xCloudCoreChannel._buffer = buffer

    setmetatable(obj, xCloudCoreChannel)
    return obj
end

function xCloudCoreChannel:decode(tree, fields)
    local data = {}

    data.string = 'Core'
    
    local channel_tree = tree:add(fields.gs_command, xCloudCoreChannel._buffer(0, 2))
    local command = xCloudCoreChannel._buffer(0, 2):le_uint()

    local offset = 0

    -- if command == 0 then
    --     -- Open Channel
    --     local channel_tree = tree:add("Core FrameData", xCloudCoreChannel._buffer())
    --     local output = xCloudCoreChannel:frameData(channel_tree, fields)
    --     data.string = data.string .. ' Data' .. output

    -- elseif command == 1 then
    --     -- Open Channel
    --     local channel_tree = tree:add("Core FrameData", xCloudCoreChannel._buffer())
    --     local output = xCloudCoreChannel:frameData(channel_tree, fields)
    --     data.string = data.string .. ' FrameData' .. output

    -- elseif command == 2 then
    --     -- Open Channel
    --     local channel_tree = tree:add("Core OpenChannel", xCloudCoreChannel._buffer())
    --     local output = xCloudCoreChannel:openChannel(channel_tree, fields)
    --     data.string = data.string .. ' openChannel' .. output

    -- elseif command == 3 then
    --     -- Control
    --     local channel_tree = tree:add("Core Control", xCloudCoreChannel._buffer())
    --     local output = xCloudCoreChannel:control(channel_tree, fields)
    --     data.string = data.string .. ' Control' .. output

    -- elseif command == 4 then
    --     -- Control
    --     local channel_tree = tree:add("Core Config", xCloudCoreChannel._buffer())
    --     local output = xCloudCoreChannel:config(channel_tree, fields)
    --     data.string = data.string .. ' Config' .. output

    -- else
        data.string = data.string .. ' Unknown=' .. command
    -- end

    data.string = '[' .. data.string .. ']'

    return data
end

-- function xCloudCoreChannel:openChannel(tree, fields)

--     local offset = 4

--     tree:add_le(fields.gs_openchannel_length, xCloudCoreChannel._buffer(offset, 2))
--     local channel_name_length = xCloudCoreChannel._buffer(offset, 2):le_uint()
--     offset = offset + 2

--     tree:add_le(fields.gs_openchannel_name, xCloudCoreChannel._buffer(offset, channel_name_length))
--     offset = offset + channel_name_length

--     -- if xCloudCoreChannel._buffer(offset, 2):le_uint() == 0 then
--         tree:add_le(fields.unconnected_unk_16, xCloudCoreChannel._buffer(offset, 2))
--         offset = offset + 2
--     -- end

--     if channel_name_length > 0 then
--         -- we got the first request because we have a channel name

--         -- unknown
--         tree:add_le(fields.unconnected_unk_16, xCloudCoreChannel._buffer(offset, 2))
--         offset = offset + 2

--         -- length
--         tree:add_le(fields.connected_inputfeedback_frame_size, xCloudCoreChannel._buffer(offset, 4))
--         local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--         offset = offset + 4

--         if data_size > 0 then
--             tree:add_le(fields.unconnected_unk_bytes, xCloudCoreChannel._buffer(offset, data_size))
--             offset = offset + data_size
--         end

--         -- zero padding
--         tree:add_le(fields.connected_next_sequence, xCloudCoreChannel._buffer(offset, 2))
--         offset = offset + 2

--     else
--         -- unk
--         tree:add_le(fields.connected_input_min_version, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4

--         -- format_count
--         tree:add_le(fields.connected_input_max_version, xCloudCoreChannel._buffer(offset, 4))
--         -- local format_count = xCloudCoreChannel._buffer(offset, 4):le_uint()
--         offset = offset + 4

--         -- -- format_count
--         -- tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         -- -- local format_count = xCloudCoreChannel._buffer(offset, 4):le_uint()
--         -- offset = offset + 4

--         -- -- unk
--         -- tree:add_le(fields.connected_audio_codec, xCloudCoreChannel._buffer(offset, 4))
--         -- offset = offset + 4

--         -- zero padding
--         tree:add_le(fields.connected_next_sequence, xCloudCoreChannel._buffer(offset, 2))
--         offset = offset + 2


--     end

--     return ''
-- end

-- function xCloudCoreChannel:control(tree, fields)

--     local offset = 4
--     local retstring = ''

--     -- unknown
--     tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--     local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--     offset = offset + 4

--     -- packet_type
--     tree:add_le(fields.connected_qos_type, xCloudCoreChannel._buffer(offset, 2))
--     local packet_type = xCloudCoreChannel._buffer(offset, 2):le_uint()
--     offset = offset + 2

--     if xCloudCoreChannel._buffer(offset):len() > 2 then
--         -- We have more bytes to read...
--         tree:add_le(fields.unconnected_unk_16, xCloudCoreChannel._buffer(offset, 2))
--         offset = offset + 2

--         if packet_type == 0 then 
            
--             -- unknown
--             tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--             -- local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4

--             -- unknown
--             tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--             -- local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4
    
--             retstring = retstring .. ' Frame='..packet_type
    
--         elseif packet_type == 1 and xCloudCoreChannel._buffer(offset):len() > 2 then 
--             -- unknown
--             tree:add_le(fields.connected_qos_frame_totalsize, xCloudCoreChannel._buffer(offset, 4))
--             -- local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4
            
--             -- frame_index
--             tree:add_le(fields.connected_qos_frame_index, xCloudCoreChannel._buffer(offset, 4))
--             -- local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4
            
--             -- offset
--             tree:add_le(fields.connected_qos_frame_offset, xCloudCoreChannel._buffer(offset, 4))
--             -- local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4
            
--             -- data_size
--             tree:add_le(fields.connected_qos_frame_size, xCloudCoreChannel._buffer(offset, 4))
--             local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4
    
--             -- Read Video Data
--             local fragment_tree = tree:add(fields.connected_qos_data, xCloudCoreChannel._buffer(offset, data_size))
    
--             frragment_frame = ByteArray.new(xCloudCoreChannel._buffer(offset, data_size):raw(), true):tvb("Fragment data")
--             fragment_tree:add(fields.connected_qos_data, frragment_frame())
--             offset = offset + data_size
    
--             retstring = retstring .. ' FrameData='..packet_type
    
--         else 
--             -- -- pad
--             -- tree:add_le(fields.connected_next_sequence, xCloudCoreChannel._buffer(offset-2, 2))
--             -- -- offset = offset + 2

--             retstring = retstring .. ' KeepAlive='..packet_type
--         end

--     elseif packet_type == 0 then 
--         retstring = retstring .. ' KeepAlive'
--         offset = offset - 2
--     else 
--         retstring = retstring .. ' Unknown='..packet_type
--     end

--     -- zero padding
--     tree:add_le(fields.connected_next_sequence, xCloudCoreChannel._buffer(offset, 2))
--     offset = offset + 2

--     return retstring
-- end

-- function xCloudCoreChannel:config(tree, fields)

--     local offset = 4
--     local retstring = ''

--     -- unknown = 0
--     tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--     offset = offset + 4

--     -- packet_type
--     tree:add_le(fields.connected_inputfeedback_type, xCloudCoreChannel._buffer(offset, 2))
--     local packet_type = xCloudCoreChannel._buffer(offset, 2):le_uint()
--     offset = offset + 2

--     if packet_type > 0 then

--         tree:add_le(fields.unconnected_unk_16, xCloudCoreChannel._buffer(offset, 2))
--         offset = offset + 2

--         -- data_size
--         tree:add_le(fields.connected_inputfeedback_frame_size, xCloudCoreChannel._buffer(offset, 4))
--         local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--         offset = offset + 4

--         -- min_version
--         tree:add_le(fields.connected_inputfeedback_min_version, xCloudCoreChannel._buffer(offset, 4))
--         local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--         offset = offset + 4

--         -- max_version
--         tree:add_le(fields.connected_inputfeedback_max_version, xCloudCoreChannel._buffer(offset, 4))
--         local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--         offset = offset + 4

--         if packet_type == 5 then
--             retstring = retstring .. ' ConfigRequest'

--             -- width
--             tree:add_le(fields.connected_inputfeedback_width, xCloudCoreChannel._buffer(offset, 4))
--             local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4

--             -- height
--             tree:add_le(fields.connected_inputfeedback_height, xCloudCoreChannel._buffer(offset, 4))
--             local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4

--             -- unk
--             tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--             local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4

--             -- timestamp
--             tree:add_le(fields.connected_inputfeedback_timestamp, xCloudCoreChannel._buffer(offset, 4))
--             local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4

--             -- pad
--             tree:add_le(fields.connected_next_sequence, xCloudCoreChannel._buffer(offset, 2))
--             local data_size = xCloudCoreChannel._buffer(offset, 2):le_uint()
--             offset = offset + 2

--         elseif packet_type == 6 then

--             -- unk
--             tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--             local data_size = xCloudCoreChannel._buffer(offset, 4):le_uint()
--             offset = offset + 4

--             -- timestamp
--             tree:add_le(fields.connected_inputfeedback_timestamp, xCloudCoreChannel._buffer(offset, 8))
--             -- local data_size = xCloudCoreChannel._buffer(offset, 8):le_uint()
--             offset = offset + 8

--             -- pad
--             tree:add_le(fields.connected_next_sequence, xCloudCoreChannel._buffer(offset, 2))
--             local data_size = xCloudCoreChannel._buffer(offset, 2):le_uint()
--             offset = offset + 2

--             retstring = retstring .. ' ConfigResponse'

--         else
--             retstring = retstring .. ' Unknown=' .. packet_type
--         end
--     else 
--         retstring = retstring .. ' KeepAlive'
--     end

    
--     return retstring

-- end

-- function xCloudCoreChannel:frameData(tree, fields)

--     local offset = 4
--     local retstring = ''

--     -- unknown
--     tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--     offset = offset + 4

--     -- packet_type
--     tree:add_le(fields.connected_qos_type, xCloudCoreChannel._buffer(offset, 4))
--     local packet_type = xCloudCoreChannel._buffer(offset, 4):le_uint()
--     offset = offset + 4

--     if packet_type == 1 then
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- unk
--         tree:add_le(fields.unconnected_unk_32, xCloudCoreChannel._buffer(offset, 4))
--         offset = offset + 4
        
--         -- next_sequence
--         tree:add_le(fields.unconnected_unk_16, xCloudCoreChannel._buffer(offset, 2))
--         offset = offset + 2

--         retstring = retstring .. ' Data'

--     else
--         retstring = retstring .. ' Unknown=' .. packet_type
--     end

--     return retstring
-- end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudCoreChannel