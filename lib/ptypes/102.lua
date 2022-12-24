local PType102 = {}
setmetatable(PType102, PType102)
PType102.__index = PType102

function PType102:__call(buffer)
    local obj = {}
    PType102._buffer = buffer
    PType102.output = ''

    setmetatable(obj, PType102)
    return obj
end

function PType102:addFields(fields, add_field)
    add_field(ProtoField.uint32, "xcloud_100_type", "Type", base.DEC, {
        [0] = 'OpenChannelRequest',
        [1] = 'OpenChannelRequestData',
        [2] = 'OpenChannelRequestData',
    })
    add_field(ProtoField.uint16, "xcloud_100_channelname_size", "Channel name size")
end

function PType102:decode(tree, fields, rtp_info)
    local offset = 0

    tree:add_le(fields.xcloud_100_type, PType102._buffer(offset, 2))
    local packet_type = PType102._buffer(offset, 2):le_uint()
    offset = offset + 2

end

return PType102