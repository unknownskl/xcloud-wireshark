local PType101 = require 'ptypes/101'
local PType100 = require 'ptypes/100'
local PType97 = require 'ptypes/97'
local PType35 = require 'ptypes/35'

local Router = {}
setmetatable(Router, Router)
Router.__index = Router

function Router:__call(fields)
    local obj = {}
    Router.fields = fields
    Router.output = ''

    setmetatable(obj, Router)
    return obj
end

function Router:addFields(fields, add_field)
    PType101:addFields(fields, add_field)
    PType100:addFields(fields, add_field)
    PType97:addFields(fields, add_field)
    PType35:addFields(fields, add_field)
end


function Router:read(buffer, tree, rtp_info)
    local offset = 0

    if rtp_info.rtp_p_type_f == 102 then
        self.output = 'MTU Handshake'
    end

    if rtp_info.rtp_p_type_f == 101 then
        local packet = PType101(buffer):decode(tree, Router.fields, rtp_info)
        self.output = 'P101'
    end

    if rtp_info.rtp_p_type_f == 100 then
        local packet = PType100(buffer):decode(tree, Router.fields, rtp_info)
        self.output = 'P100'
    end

    if rtp_info.rtp_p_type_f == 97 then
        local packet = PType97(buffer):decode(tree, Router.fields, rtp_info)

        self.output = 'Channel Handshake'
    end

    if rtp_info.rtp_p_type_f == 35 then
        local packet = PType35(buffer):decode(tree, Router.fields, rtp_info)

        self.output = packet.output
    end

    -- tree:add_le(Router.fields.data_packet_type, buffer(offset, 4))
    -- local data_packet_type = buffer(offset, 4):le_uint()
    -- offset = offset + 4

    -- if data_packet_type == 2 then 
    --     Router:openChannel(buffer, tree)
    -- end

    -- if data_packet_type == 3 then 
    --     Router:openChannelResponse(buffer, tree)
    -- end

    return self
end

return Router