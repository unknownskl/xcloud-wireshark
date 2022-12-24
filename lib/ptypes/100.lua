local PType100 = {}
setmetatable(PType100, PType100)
PType100.__index = PType100

function PType100:__call(buffer)
    local obj = {}
    PType100._buffer = buffer
    PType100.output = ''

    setmetatable(obj, PType100)
    return obj
end

function PType100:addFields(fields, add_field)
    add_field(ProtoField.uint32, "xcloud_100_type", "Type", base.DEC, {
        [0] = 'Unknown',
        [1] = 'Unknown',
        [2] = 'Unknown',
    })
    add_field(ProtoField.uint24, "xcloud_100_timestamp", "Timestamp")
    add_field(ProtoField.uint16, "xcloud_100_sequence", "Sequence")
    add_field(ProtoField.uint32, "xcloud_100_message", "Message", base.DEC, {
        [5] = 'ConnectRequest',
        [6] = 'ConnectResponse',
    })
end

function PType100:decode(tree, fields, rtp_info)
    local offset = 0

    tree:add_le(fields.xcloud_100_type, PType100._buffer(offset, 2))
    local packet_type = PType100._buffer(offset, 2):le_uint()
    offset = offset + 2

    if packet_type == 0 then

        tree:add_le(fields.xcloud_100_timestamp, PType100._buffer(offset, 3))
        local packet_type = PType100._buffer(offset, 3):le_uint()
        offset = offset + 3

        tree:add_le(fields.xcloud_100_sequence, PType100._buffer(offset, 2))
        offset = offset + 2
        
        tree:add_le(fields.xcloud_debug_uint16, PType100._buffer(offset, 2))
        offset = offset + 2

        tree:add_le(fields.xcloud_debug_uint32, PType100._buffer(offset, 4))
        offset = offset + 4

        tree:add_le(fields.xcloud_100_message, PType100._buffer(offset, 4))
        offset = offset + 4

    elseif packet_type == 1 then

        tree:add_le(fields.xcloud_100_sequence, PType100._buffer(offset, 2))
        offset = offset + 2

        tree:add_le(fields.xcloud_debug_uint16, PType100._buffer(offset, 2))
        offset = offset + 2

        tree:add_le(fields.xcloud_debug_uint16, PType100._buffer(offset, 2))
        offset = offset + 2

    elseif packet_type == 2 then
    end
end

return PType100