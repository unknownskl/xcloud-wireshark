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

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

return xCloudCoreChannel