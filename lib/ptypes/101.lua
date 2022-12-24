local PType101 = {}
setmetatable(PType101, PType101)
PType101.__index = PType101

function PType101:__call(buffer)
    local obj = {}
    PType101._buffer = buffer
    PType101.output = ''

    setmetatable(obj, PType101)
    return obj
end

function PType101:addFields(fields, add_field)
    add_field(ProtoField.uint32, "xcloud_101_type", "Type", base.DEC, {
        [0] = 'MTU Size check',
        [4] = 'Disconnect',
        [9] = 'Unknown',
        [18] = 'Unknown',
    })
    -- add_field(ProtoField.uint24, "xcloud_101_timestamp", "Timestamp")
    -- add_field(ProtoField.uint16, "xcloud_101_sequence", "Sequence")
    -- add_field(ProtoField.uint32, "xcloud_101_message", "Message", base.DEC, {
    --     [5] = 'ConnectRequest',
    --     [6] = 'ConnectResponse',
    -- })
end

function PType101:decode(tree, fields, rtp_info)
    local offset = 0

    tree:add_le(fields.xcloud_debug_uint16, PType101._buffer(offset, 2))
    offset = offset + 2

    tree:add_le(fields.xcloud_debug_uint16, PType101._buffer(offset, 2))
    offset = offset + 2

    tree:add_le(fields.xcloud_101_type, PType101._buffer(offset, 4))
    local packet_type = PType101._buffer(offset, 4):le_uint()
    offset = offset + 4

    if packet_type == 9 then
        tree:add_le(fields.xcloud_debug_uint32, PType101._buffer(offset, 4))
        offset = offset + 4

        tree:add_le(fields.xcloud_debug_uint32, PType101._buffer(offset, 4))
        offset = offset + 4

        tree:add_le(fields.xcloud_debug_uint32, PType101._buffer(offset, 4))
        offset = offset + 4

        tree:add_le(fields.xcloud_debug_uint32, PType101._buffer(offset, 4))
        offset = offset + 4

        tree:add_le(fields.xcloud_debug_uint32, PType101._buffer(offset, 4))
        offset = offset + 4

        tree:add_le(fields.xcloud_debug_uint32, PType101._buffer(offset, 4))
        offset = offset + 4

        tree:add_le(fields.xcloud_debug_uint32, PType101._buffer(offset, 4))
        offset = offset + 4

        tree:add_le(fields.xcloud_debug_uint32, PType101._buffer(offset, 4))
        offset = offset + 4
    end

    --     tree:add_le(fields.xcloud_101_timestamp, PType101._buffer(offset, 3))
    --     local packet_type = PType101._buffer(offset, 3):le_uint()
    --     offset = offset + 3

    --     tree:add_le(fields.xcloud_101_sequence, PType101._buffer(offset, 2))
    --     offset = offset + 2
        
    --     tree:add_le(fields.xcloud_debug_uint16, PType101._buffer(offset, 2))
    --     offset = offset + 2

    --     tree:add_le(fields.xcloud_debug_uint32, PType101._buffer(offset, 4))
    --     offset = offset + 4

    --     tree:add_le(fields.xcloud_101_message, PType101._buffer(offset, 4))
    --     offset = offset + 4

    -- elseif packet_type == 1 then

    --     tree:add_le(fields.xcloud_101_sequence, PType101._buffer(offset, 2))
    --     offset = offset + 2

    --     tree:add_le(fields.xcloud_debug_uint16, PType101._buffer(offset, 2))
    --     offset = offset + 2

    --     tree:add_le(fields.xcloud_debug_uint16, PType101._buffer(offset, 2))
    --     offset = offset + 2

    -- elseif packet_type == 2 then
    -- end
end

return PType101