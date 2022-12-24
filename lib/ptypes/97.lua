local PType97 = {}
setmetatable(PType97, PType97)
PType97.__index = PType97

function PType97:__call(buffer)
    local obj = {}
    PType97._buffer = buffer
    PType97.output = ''

    setmetatable(obj, PType97)
    return obj
end

function PType97:addFields(fields, add_field)
    
    -- add_field(ProtoField.uint32, "xcloud_97_type", "Type")
    add_field(ProtoField.uint32, "xcloud_97_type", "Type", base.DEC, {
        [2] = 'OpenChannelRequest',
        [3] = 'OpenChannelRequestData'
    })
    add_field(ProtoField.uint16, "xcloud_97_channelname_size", "Channel name size")
    add_field(ProtoField.string, "xcloud_97_channelname_value", "Channel name")
    add_field(ProtoField.uint32, "xcloud_97_channelname_padding", "Channel name padding")

    add_field(ProtoField.uint32, "xcloud_97_data_size", "Data size")
    add_field(ProtoField.bytes, "xcloud_97_data", "Data")

end

function PType97:decode(tree, fields, rtp_info)
    local offset = 0

    tree:add_le(fields.xcloud_97_type, PType97._buffer(offset, 4))
    local packet_type = PType97._buffer(offset, 4):le_uint()
    offset = offset + 4

    if packet_type == 2 then
        -- tree:add_le(fields.xcloud_97_channelname_size, PType97._buffer(offset, 2))
        local channelname_size = PType97._buffer(offset, 2):le_uint()
        offset = offset + 2

        local channelname_tree = tree:add_le(fields.xcloud_97_channelname_value, PType97._buffer(offset, channelname_size))
        offset = offset + channelname_size

        channelname_tree:add_le(fields.xcloud_97_channelname_size, PType97._buffer(offset-channelname_size-2, 2))
        channelname_tree:add_le(fields.xcloud_97_channelname_value, PType97._buffer(offset-channelname_size, channelname_size))
        channelname_tree:add_le(fields.xcloud_97_channelname_padding, PType97._buffer(offset, 4))
        offset = offset + 4

        tree:add_le(fields.xcloud_97_data_size, PType97._buffer(offset, 4))
        local data_size = PType97._buffer(offset, 4):le_uint()
        offset = offset + 4

        if data_size > 0 then
            tree:add_le(fields.xcloud_97_data, PType97._buffer(offset, data_size))
            offset = offset + data_size
        end

    elseif packet_type == 3 then
        tree:add_le(fields.xcloud_97_data_size, PType97._buffer(offset, 4))
        local data_size = PType97._buffer(offset, 4):le_uint()
        offset = offset + 4

        if data_size > 0 then
            tree:add_le(fields.xcloud_97_data, PType97._buffer(offset, data_size))
            offset = offset + data_size
        end

    end

    return self
end

return PType97