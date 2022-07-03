local Router = {}
setmetatable(Router, Router)
Router.__index = Router

function Router:__call(fields)
    local obj = {}
    Router.fields = fields

    setmetatable(obj, Router)
    return obj
end


function Router:read(buffer, tree)
    local offset = 0

    tree:add_le(Router.fields.data_packet_type, buffer(offset, 4))
    local data_packet_type = buffer(offset, 4):le_uint()
    offset = offset + 4

    if data_packet_type == 2 then 
        Router:openChannel(buffer, tree)
    end

    if data_packet_type == 3 then 
        Router:openChannelResponse(buffer, tree)
    end

    return ''
end

function Router:openChannel(buffer, tree)

    local offset = 4

    tree:add_le(Router.fields.connected_openchannel_size, buffer(offset, 2))
    local channel_name_length = buffer(offset, 2):le_uint()
    offset = offset + 2

    tree:add_le(Router.fields.connected_openchannel_name, buffer(offset, channel_name_length))
    offset = offset + channel_name_length

    tree:add_le(Router.fields.connected_openchannel_padding, buffer(offset, 2))
    offset = offset + 2

    -- unknown
    tree:add_le(Router.fields.unconnected_unk_16, buffer(offset, 2))
    offset = offset + 2

    -- unknown
    tree:add_le(Router.fields.unconnected_unk_16, buffer(offset, 2))
    offset = offset + 2

    -- unknown
    tree:add_le(Router.fields.unconnected_unk_16, buffer(offset, 2))
    offset = offset + 2

    -- -- unknown - optional?
    -- tree:add_le(Router.fields.unconnected_unk_16, buffer(offset, 2))
    -- offset = offset + 2

    return ''
end

function Router:openChannelResponse(buffer, tree)

    local offset = 4

    tree:add_le(Router.fields.data_openchannel_status, buffer(offset, 4))
    offset = offset + 4

    tree:add_le(Router.fields.unconnected_unk_16, buffer(offset, 2))
    offset = offset + 2

    return ''
end

return Router