local xCloudVideoChannel = {}
setmetatable(xCloudVideoChannel, xCloudVideoChannel)
xCloudVideoChannel.__index = xCloudVideoChannel

function xCloudVideoChannel:__call(buffer)
    local obj = {}
    xCloudVideoChannel._buffer = buffer

    setmetatable(obj, xCloudVideoChannel)
    return obj
end

function xCloudVideoChannel:decode(tree, fields)
    local data = {}

    data.string = 'Video'
    local command = xCloudVideoChannel._buffer(0, 2):le_uint()

    local offset = 4

    if command == 1 then
        -- FrameData
        local channel_tree = tree:add("Video FrameData", xCloudVideoChannel._buffer())
        local output = xCloudVideoChannel:frameData(channel_tree, fields)
        data.string = data.string .. ' frameData' .. output

    elseif command == 2 then
        -- Open Channel
        local channel_tree = tree:add("Video OpenChannel", xCloudVideoChannel._buffer())
        local output = xCloudVideoChannel:openChannel(channel_tree, fields)
        data.string = data.string .. ' openChannel' .. output

    elseif command == 3 then
        -- Control
        local channel_tree = tree:add("Video Control", xCloudVideoChannel._buffer())
        local output = xCloudVideoChannel:control(channel_tree, fields)
        data.string = data.string .. ' Control' .. output

    elseif command == 4 then
        -- Config
        local channel_tree = tree:add("Video Config", xCloudVideoChannel._buffer())
        local output = xCloudVideoChannel:config(channel_tree, fields)
        data.string = data.string .. ' Config' .. output

    else
        data.string = data.string .. ' (Unknown)'
    end

    data.string = '[' .. data.string .. ']'

    return data
end

function xCloudVideoChannel:openChannel(tree, fields)

    local offset = 4

    tree:add_le(fields.gs_openchannel_length, xCloudVideoChannel._buffer(offset, 2))
    local channel_name_length = xCloudVideoChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(fields.gs_openchannel_name, xCloudVideoChannel._buffer(offset, channel_name_length))
    offset = offset + channel_name_length

    -- if xCloudVideoChannel._buffer(offset, 2):le_uint() == 0 then
        tree:add_le(fields.unconnected_unk_16, xCloudVideoChannel._buffer(offset, 2))
        offset = offset + 2
    -- end

    if channel_name_length > 0 then
        -- we got the first request because we have a channel name

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

    else
        -- relative timmestamp?
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- hz
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- unk
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- zero padding
        tree:add_le(fields.unconnected_unk_16, xCloudVideoChannel._buffer(offset, 2))
        offset = offset + 2

    end

    return ''
end

function xCloudVideoChannel:control(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_video_type, xCloudVideoChannel._buffer(offset, 2))
    local packet_type = xCloudVideoChannel._buffer(offset, 2):le_uint()
    offset = offset + 2

    if packet_type == 0 then
        retstring = retstring .. ' KeepAlive'

    elseif packet_type == 3 then
        retstring = retstring .. ' Ack'
    else 
        retstring = retstring .. ' Unknown=' .. packet_type
    end

    return retstring

end

function xCloudVideoChannel:config(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown = 0
    tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_video_type, xCloudVideoChannel._buffer(offset, 4))
    local packet_type = xCloudVideoChannel._buffer(offset, 4):le_uint()
    offset = offset + 4

    if packet_type == 1 then
        -- Type is request
        retstring = retstring .. ' Request'

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- device_type -- 1 = xbox, 6 = pc?
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- wiidth
        tree:add_le(fields.connected_video_width, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- height
        tree:add_le(fields.connected_video_height, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- fps
        tree:add_le(fields.connected_video_fps, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- relative_timestamp
        tree:add_le(fields.connected_video_timestamp, xCloudVideoChannel._buffer(offset, 8))
        offset = offset + 8

        -- format_count
        tree:add_le(fields.connected_video_format_count, xCloudVideoChannel._buffer(offset, 4))
        local format_count = xCloudVideoChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- Loop over available formats
        for i=1,format_count do
            local format_tree = tree:add("Video format [" .. i .. "]", xCloudVideoChannel._buffer(offset, 16))

            -- format_fps
            format_tree:add_le(fields.connected_video_fps, xCloudVideoChannel._buffer(offset, 4))
            offset = offset + 4

            -- format_width
            format_tree:add_le(fields.connected_video_width, xCloudVideoChannel._buffer(offset, 4))
            offset = offset + 4

            -- format_height
            format_tree:add_le(fields.connected_video_height, xCloudVideoChannel._buffer(offset, 4))
            offset = offset + 4

            -- format_codec -- H264 = 0, H265 = 1, YUV = 2,RGB = 3
            format_tree:add_le(fields.connected_video_codec, xCloudVideoChannel._buffer(offset, 4))
            offset = offset + 4
        end

        -- unknown
        tree:add_le(fields.unconnected_unk_16, xCloudVideoChannel._buffer(offset, 2))
        offset = offset + 2

    elseif packet_type == 2 then
        -- Type is response
        retstring = retstring .. ' Response'

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- device_type -- 1 = xbox, 6 = pc?
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- wiidth
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- height
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4

        -- fps
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4


        else
            retstring = retstring .. '(Unknown)'
        end
    return retstring

end

function xCloudVideoChannel:frameData(tree, fields)

    local offset = 4
    local retstring = ''

    -- unknown
    tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
    offset = offset + 4

    -- packet_type
    tree:add_le(fields.connected_video_type, xCloudVideoChannel._buffer(offset, 4))
    local packet_type = xCloudVideoChannel._buffer(offset, 4):le_uint()
    offset = offset + 4

    if packet_type == 4 then
        -- We got a video frame

        -- frame_count?
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- frame id
        tree:add_le(fields.connected_video_frame_id, xCloudVideoChannel._buffer(offset, 4))
        local frameid = xCloudVideoChannel._buffer(offset, 4):le_uint()
        offset = offset + 4
        
        -- frame_flags -- 6 = keyframe, 4 = frame?
        tree:add_le(fields.connected_video_devicetype, xCloudVideoChannel._buffer(offset, 4))
        local frame_flags = xCloudVideoChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- unknown
        tree:add_le(fields.connected_video_timestamp, xCloudVideoChannel._buffer(offset, 8))
        offset = offset + 8
        
        -- unknown
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- packet_count?
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- total_size
        tree:add_le(fields.connected_video_frame_totalsize, xCloudVideoChannel._buffer(offset, 4))
        local total_size = xCloudVideoChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- metadata_size
        tree:add_le(fields.unconnected_unk_32, xCloudVideoChannel._buffer(offset, 4))
        offset = offset + 4
        
        -- offset
        tree:add_le(fields.connected_video_frame_offset, xCloudVideoChannel._buffer(offset, 4))
        local data_offset = xCloudVideoChannel._buffer(offset, 4):le_uint()
        offset = offset + 4
        
        -- metadata_size
        tree:add_le(fields.connected_video_frame_metadatasize, xCloudVideoChannel._buffer(offset, 4))
        local metadata_size = xCloudVideoChannel._buffer(offset, 4):le_uint()
        offset = offset + 4
        
        -- data_size
        tree:add_le(fields.connected_video_frame_size, xCloudVideoChannel._buffer(offset, 4))
        local data_size = xCloudVideoChannel._buffer(offset, 4):le_uint()
        offset = offset + 4

        -- Read Video Data
        local video_tree = tree:add(fields.connected_video_data, xCloudVideoChannel._buffer(offset, data_size))

        video_frame = ByteArray.new(xCloudVideoChannel._buffer(offset, data_size):raw(), true):tvb("Video")
        video_tree:add(fields.connected_video_data, video_frame())
        offset = offset + data_size

        if metadata_size > 0 then
            tree:add_le(fields.connected_video_frame_metadata, xCloudVideoChannel._buffer(offset, metadata_size))
            offset = offset + metadata_size
        end

        -- unknown
        tree:add_le(fields.unconnected_unk_16, xCloudVideoChannel._buffer(offset, 2))
        offset = offset + 2


        retstring = retstring .. ' ' .. frame_flags .. ' #' .. frameid .. ' ' .. (data_offset + data_size) .. '/' .. total_size
        
    else
        retstring = retstring .. ' Unknown'
    end

    return retstring
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudVideoChannel