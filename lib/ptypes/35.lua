local PType35 = {}
setmetatable(PType35, PType35)
PType35.__index = PType35

function PType35:__call(buffer)
    local obj = {}
    PType35._buffer = buffer
    PType35.output = ''

    setmetatable(obj, PType35)
    return obj
end

function PType35:addFields(fields, add_field)
    
    -- add_field(ProtoField.uint32, "xcloud_35_type", "Type")
    add_field(ProtoField.uint16, "xcloud_35_channel", "Channel", base.DEC, {
        [1] = 'Data',
        [2] = 'ChannelRequest',
        [3] = 'Message',
        [4] = 'Config',
        [5] = 'Keyframe',
    })
    add_field(ProtoField.uint16, "xcloud_35_sequence", "Message sequence")
    add_field(ProtoField.uint32, "xcloud_35_unk1", "Unknown")
    add_field(ProtoField.uint32, "xcloud_35_unk1337", "Unknown")
    
    add_field(ProtoField.uint16, "xcloud_35_format", "Packet format", base.DEC, {
        [1] = 'Channel',
        [2] = 'Messaging',
        [3] = 'Ack',
        [4] = 'Video',
        [5] = 'InputConfigRequest',
        [6] = 'InputConfigResponse',
        [7] = 'Input',
    })
    add_field(ProtoField.uint16, "xcloud_35_payloadformat", "Payload format", base.DEC, {
        [1] = 'Video',
        [4] = 'Input',
    })
    add_field(ProtoField.uint64, "xcloud_35_frame_timestamp", "Frame timestamp")
    add_field(ProtoField.uint32, "xcloud_35_frame_sequence", "Frame sequence")
    add_field(ProtoField.uint32, "xcloud_35_frame_sequence_start", "Frame sequence start")
    add_field(ProtoField.uint32, "xcloud_35_frame_size", "Frame size")
    add_field(ProtoField.uint32, "xcloud_35_config_width", "Screen width")
    add_field(ProtoField.uint32, "xcloud_35_config_height", "Screen height")
    add_field(ProtoField.uint32, "xcloud_35_config_maxtouches", "Max touchpoints")
    add_field(ProtoField.uint16, "xcloud_35_message_acktype", "Message ack type", base.DEC, {
        [0] = 'NoAck',
        [1] = 'NeedsAck',
        [2] = 'IsAck',
    })
    add_field(ProtoField.uint16, "xcloud_35_message_messagetype", "Message format", base.DEC, {
        [1] = 'KeyValue',
    })
    add_field(ProtoField.uint16, "xcloud_video_payloadformat", "Video format", base.DEC, {
        [4096] = 'FormatRequest',
        [128] = 'FormatResponse',
        [60] = 'ChannelConfirm',
        [48] = 'None',
        [34] = 'None',
        [1] = 'VideoFrame',
    })
    add_field(ProtoField.uint32, "xcloud_35_message_key_length", "Key Length")
    add_field(ProtoField.string, "xcloud_35_message_key_value", "Key value")
    add_field(ProtoField.uint32, "xcloud_35_message_value_length", "Value Length")
    add_field(ProtoField.string, "xcloud_35_message_value_value", "Value value")
    add_field(ProtoField.uint32, "xcloud_35_message_kv_length", "KV total Length")

    add_field(ProtoField.uint32, "xcloud_35_video_metadata_size", "Metadata size")
    add_field(ProtoField.uint32, "xcloud_35_video_data_size", "Data size")
    add_field(ProtoField.uint32, "xcloud_35_video_metadata_size", "Metadata size")
    add_field(ProtoField.uint32, "xcloud_35_video_frame_totalsize", "Video frame size")
    add_field(ProtoField.uint32, "xcloud_35_video_frame_totalframes", "Video frame amount")
    add_field(ProtoField.uint32, "xcloud_35_video_frame_offset", "Video frame offset")

    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_count", "Gamepad frame count")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_select", "Button sequence (select)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_start", "Button sequence (start)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_dpad_down", "Button sequence (dpad down)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_dpad_left", "Button sequence (dpad left)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_dpad_right", "Button sequence (dpad right)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_dpad_up", "Button sequence (dpad up)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_leftthumb", "Button sequence (left thumbstick)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_rightthumb", "Button sequence (right thumbstick)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_b", "Button sequence (B)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_y", "Button sequence (Y)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_x", "Button sequence (X)")
    add_field(ProtoField.uint32, "xcloud_35_gamepad_frame_sequence_button_a", "Button sequence (A)")
    
    add_field(ProtoField.uint32, "xcloud_35_stats_frame_count", "Stats frame count")

    add_field(ProtoField.uint8, "xcloud_35_gamepad_frame_lefttrigger", "Left Trigger")
    add_field(ProtoField.uint8, "xcloud_35_gamepad_frame_righttrigger", "Right Trigger")
    add_field(ProtoField.uint16, "xcloud_35_gamepad_frame_leftaxis_x", "Left Axis X")
    add_field(ProtoField.uint16, "xcloud_35_gamepad_frame_leftaxis_y", "Left Axis Y")
    add_field(ProtoField.uint16, "xcloud_35_gamepad_frame_rightaxis_x", "Right Axis X")
    add_field(ProtoField.uint16, "xcloud_35_gamepad_frame_rightaxis_y", "Right Axis Y")

    add_field(ProtoField.uint16, "xcloud_35_gamepad_frame_button", "Button", base.DEC, {
        [32768] = 'Y',
        [16348] = 'X',
        [8192] = 'B',
        [4096] = 'A',
        [128] = 'Right thumbstick',
        [64] = 'Left thumbstick',
        [32] = 'Select',
        [16] = 'Start',
        [8] = 'Dpad Right',
        [4] = 'Dpad Left',
        [2] = 'Dpad Down',
        [1] = 'Dpad Up',
        [0] = 'None',
    }, 0xffff)

    add_field(ProtoField.uint16, "xcloud_35_gamepad_frame_trigger", "Trigger", base.DEC, {
        [48] = 'R Axis',
        [12] = 'L Axis',
        [2] = 'R Trigger',
        [1] = 'L Trigger',
        [0] = 'None',
    }, 0xffff) -- 1/2 = trigger, 48 = raxis, 12 = laxis
    
    

    -- add_field(ProtoField.uint16, "xcloud_35_type", "Type", base.DEC, {}, 0xffff)
    -- add_field(ProtoField.uint16, "xcloud_35_channelname_size", "Channel name size")
    -- add_field(ProtoField.string, "xcloud_35_channelname_value", "Channel name")
    -- add_field(ProtoField.uint32, "xcloud_35_channelname_padding", "Channel name padding")

    -- add_field(ProtoField.uint32, "xcloud_35_data_size", "Data size")
    -- add_field(ProtoField.bytes, "xcloud_35_data", "Data")

end

function PType35:decode(tree, fields, rtp_info)
    local offset = 0

    tree:add_le(fields.xcloud_35_channel, PType35._buffer(offset, 2))
    local channel = PType35._buffer(offset, 2):le_uint() -- was packet_type before
    offset = offset + 2

    tree:add_le(fields.xcloud_35_sequence, PType35._buffer(offset, 2))
    offset = offset + 2

    tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
    offset = offset + 4

    local packet_tree = tree:add_le(fields.xcloud_35_format, PType35._buffer(offset, 2))
    local format = PType35._buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
    offset = offset + 2

    if format == 2 then
        packet_tree:add_le(fields.xcloud_35_frame_size, PType35._buffer(offset, 4))
        local data_size = PType35._buffer(offset, 4):le_uint()
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_35_message_acktype, PType35._buffer(offset, 4))
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_35_frame_sequence, PType35._buffer(offset, 4))
        offset = offset + 4

        local message_tree = packet_tree:add_le(fields.xcloud_35_message_messagetype, PType35._buffer(offset, 4))
        local message_format = PType35._buffer(offset, 4):le_uint()
        offset = offset + 4

        if message_format == 1 then
            message_tree:add_le(fields.xcloud_35_message_key_length, PType35._buffer(offset, 4))
            local key_length = PType35._buffer(offset, 4):le_uint()
            offset = offset + 4

            message_tree:add_le(fields.xcloud_35_message_value_length, PType35._buffer(offset, 4))
            local value_length = PType35._buffer(offset, 4):le_uint()
            offset = offset + 4

            message_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
            offset = offset + 4

            message_tree:add_le(fields.xcloud_35_message_kv_length, PType35._buffer(offset, 4))
            offset = offset + 4

            message_tree:add_le(fields.xcloud_35_message_key_value, PType35._buffer(offset, key_length))
            offset = offset + key_length

            if value_length > 0 then
                message_tree:add_le(fields.xcloud_35_message_value_value, PType35._buffer(offset, value_length))
                offset = offset + value_length
            end
        end

    elseif format == 3 then
        PType35.output = PType35.output .. 'Ack'

        packet_tree:add_le(fields.xcloud_35_payloadformat, PType35._buffer(offset, 4))
        local payload_format = PType35._buffer(offset, 4):le_uint()
        offset = offset + 4

        if payload_format == 1 then
            packet_tree:add_le(fields.xcloud_35_frame_size, PType35._buffer(offset, 4))
            offset = offset + 4

            local payload_tree = packet_tree:add_le(fields.xcloud_video_payloadformat, PType35._buffer(offset, 4))
            local payload_format = PType35._buffer(offset, 4):le_uint()
            offset = offset + 4

            if PType35._buffer():len() > offset then
                payload_tree:add_le(fields.xcloud_35_frame_sequence, PType35._buffer(offset, 4))
                local frame_sequence = PType35._buffer(offset, 4):le_uint()
                PType35.output = PType35.output .. ' #' .. frame_sequence
                offset = offset + 4

                payload_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
                offset = offset + 4
            end

            -- packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
            -- offset = offset + 4

        elseif payload_format == 4 then
            packet_tree:add_le(fields.xcloud_35_frame_sequence, PType35._buffer(offset, 4))
            local frame_sequence = PType35._buffer(offset, 4):le_uint()
            PType35.output = PType35.output .. ' #' .. frame_sequence
            offset = offset + 4
        end

    elseif format == 4 then
        PType35.output = PType35.output .. 'Video Frame'

        if channel == 1 or channel == 5 then 

            packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_35_frame_size, PType35._buffer(offset, 4))
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4)) -- Video flags
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_35_frame_sequence, PType35._buffer(offset, 4))
            local frame_sequence = PType35._buffer(offset, 4):le_uint()
            PType35.output = PType35.output .. ' #' .. frame_sequence
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_35_frame_timestamp, PType35._buffer(offset, 8))
            offset = offset + 8

            packet_tree:add_le(fields.xcloud_35_video_metadata_size, PType35._buffer(offset, 4))
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_35_video_frame_totalsize, PType35._buffer(offset, 4))
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_35_video_frame_totalframes, PType35._buffer(offset, 4))
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_35_video_frame_offset, PType35._buffer(offset, 4))
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_35_video_metadata_size, PType35._buffer(offset, 4))
            local metadata_size = PType35._buffer(offset, 4):le_uint()
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_35_video_data_size, PType35._buffer(offset, 4))
            local data_size = PType35._buffer(offset, 4):le_uint()
            offset = offset + 4

            if metadata_size > 0 then
                PType35.output = PType35.output .. ' (Metadata)'
                local unk_tree = packet_tree:add_le(fields.xcloud_debug_bytes, PType35._buffer(offset, metadata_size))
                unk_tree:add_le(fields.xcloud_debug_uint64, PType35._buffer(offset+1, 8))
                offset = offset + metadata_size
            end

            if data_size > 0 then
                packet_tree:add_le(fields.xcloud_debug_bytes, PType35._buffer(offset, data_size))
                offset = offset + data_size
            end

        else 
            PType35.output = PType35.output .. ' (Corrected to Data frame)'
        end

    elseif format == 5 then
        PType35.output = PType35.output .. 'Config Request'

        packet_tree:add_le(fields.xcloud_35_frame_size, PType35._buffer(offset, 4))
        local data_size = PType35._buffer(offset, 4):le_uint()
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_35_config_width, PType35._buffer(offset, 4))
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_35_config_height, PType35._buffer(offset, 4))
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_35_config_maxtouches, PType35._buffer(offset, 4))
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_35_frame_sequence_start, PType35._buffer(offset, 4))
        local frame_sequence = PType35._buffer(offset, 4):le_uint()
        PType35.output = PType35.output .. ' #' .. frame_sequence
        offset = offset + 4

    elseif format == 6 then

        packet_tree:add_le(fields.xcloud_35_frame_size, PType35._buffer(offset, 4))
        local data_size = PType35._buffer(offset, 4):le_uint()
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_debug_uint64, PType35._buffer(offset, 8))
        offset = offset + 8

    elseif format == 7 then
        PType35.output = PType35.output .. 'Input Frame'

        packet_tree:add_le(fields.xcloud_35_frame_size, PType35._buffer(offset, 4))
        local data_size = PType35._buffer(offset, 4):le_uint()
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_35_frame_sequence, PType35._buffer(offset, 4))
        local frame_sequence = PType35._buffer(offset, 4):le_uint()
        PType35.output = PType35.output .. ' #' .. frame_sequence
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
        offset = offset + 4

        packet_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
        offset = offset + 2

        packet_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
        offset = offset + 2

        packet_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
        offset = offset + 2

        local gamepad_frame_tree = packet_tree:add_le(fields.xcloud_35_gamepad_frame_count, PType35._buffer(offset, 2))
        local gamepad_frame = PType35._buffer(offset, 2):le_uint()
        offset = offset + 2
        PType35.output = PType35.output .. ' ('

        if gamepad_frame == 1 then
            PType35.output = PType35.output .. 'Gamepad,'

            -- We got an gamepad frame here.
            gamepad_frame_tree:add_le(fields.xcloud_debug_bytes, PType35._buffer(offset, 43))
            -- offset = offset + 43

            -- Gamepad index?
            gamepad_frame_tree:add_le(fields.xcloud_debug_uint8, PType35._buffer(offset, 1))
            offset = offset + 1

            -- Some offsets
            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_dpad_up, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_dpad_down, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_dpad_left, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_dpad_right, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_start, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_select, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_leftthumb, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_rightthumb, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_debug_uint8, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_debug_uint8, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_debug_uint8, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_debug_uint8, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_a, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_b, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_x, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_sequence_button_y, PType35._buffer(offset, 1))
            offset = offset + 1

            -- End header

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_righttrigger, PType35._buffer(offset, 1))
            offset = offset + 1

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_lefttrigger, PType35._buffer(offset, 1))
            offset = offset + 1

            -- Left thumbstick x?
            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_leftaxis_x, PType35._buffer(offset, 2))
            offset = offset + 2

            -- Left thumbstick y?
            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_leftaxis_y, PType35._buffer(offset, 2))
            offset = offset + 2

            -- Right thumbstick x?
            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_rightaxis_x, PType35._buffer(offset, 2))
            offset = offset + 2

            -- Right thumbstick y?
            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_rightaxis_y, PType35._buffer(offset, 2))
            offset = offset + 2

            -- End thumbsticks

            gamepad_frame_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
            offset = offset + 2

            gamepad_frame_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
            offset = offset + 2

            gamepad_frame_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
            offset = offset + 2

            gamepad_frame_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
            offset = offset + 2

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_button, PType35._buffer(offset, 2))
            offset = offset + 2

            gamepad_frame_tree:add_le(fields.xcloud_35_gamepad_frame_trigger, PType35._buffer(offset, 2))
            offset = offset + 2

            gamepad_frame_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
            offset = offset + 2

            gamepad_frame_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
            offset = offset + 2
        end

        local stats_frame_tree = packet_tree:add_le(fields.xcloud_35_stats_frame_count, PType35._buffer(offset, 1))
        local stats_frame = PType35._buffer(offset, 1):le_uint()
        offset = offset + 1

        if stats_frame == 1 then
            PType35.output = PType35.output .. 'VideoStats'

            stats_frame_tree:add_le(fields.xcloud_debug_uint8, PType35._buffer(offset, 1))
            offset = offset + 1

            stats_frame_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
            offset = offset + 4

            stats_frame_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
            offset = offset + 4

            stats_frame_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
            offset = offset + 4




            packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_debug_uint32, PType35._buffer(offset, 4))
            offset = offset + 4

            packet_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
            offset = offset + 2
        end

        

        packet_tree:add_le(fields.xcloud_debug_uint16, PType35._buffer(offset, 2))
        offset = offset + 2

        PType35.output = PType35.output .. ')'
    end

    -- if packet_type == 2 then
    --     -- tree:add_le(fields.xcloud_35_channelname_size, PType35._buffer(offset, 2))
    --     local channelname_size = PType35._buffer(offset, 2):le_uint()
    --     offset = offset + 2

    --     local channelname_tree = tree:add_le(fields.xcloud_35_channelname_value, PType35._buffer(offset, channelname_size))
    --     offset = offset + channelname_size

    --     channelname_tree:add_le(fields.xcloud_35_channelname_size, PType35._buffer(offset-channelname_size-2, 2))
    --     channelname_tree:add_le(fields.xcloud_35_channelname_value, PType35._buffer(offset-channelname_size, channelname_size))
    --     channelname_tree:add_le(fields.xcloud_35_channelname_padding, PType35._buffer(offset, 4))
    --     offset = offset + 4

    --     tree:add_le(fields.xcloud_35_data_size, PType35._buffer(offset, 4))
    --     local data_size = PType35._buffer(offset, 4):le_uint()
    --     offset = offset + 4

    --     if data_size > 0 then
    --         tree:add_le(fields.xcloud_35_data, PType35._buffer(offset, data_size))
    --         offset = offset + data_size
    --     end

    -- elseif packet_type == 3 then
    --     tree:add_le(fields.xcloud_35_data_size, PType35._buffer(offset, 4))
    --     local data_size = PType35._buffer(offset, 4):le_uint()
    --     offset = offset + 4

    --     if data_size > 0 then
    --         tree:add_le(fields.xcloud_35_data, PType35._buffer(offset, data_size))
    --         offset = offset + data_size
    --     end

    -- end

    return self
end

return PType35