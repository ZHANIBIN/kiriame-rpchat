local API = exports['kiriame_rpchat']:GetAPIInterface()

-- 常量定义
local MAX_DISTANCE = 10.0
local MESSAGE_COLOR = { 244, 237, 159 }

-- 玩家数据缓存
local PlayerDataCache = {}
local PlayerCoordsCache = {}

-- 更新玩家数据缓存
function KiriameRPchat_UpdatePlayerDataCache(source)
    if not source then return end
    PlayerDataCache[source] = API.getPlayerData(source)
end

-- 更新玩家坐标缓存
function KiriameRPchat_UpdatePlayerCoordsCache(source)
    if not source then return end
    PlayerCoordsCache[source] = API.getPlayerCoords(source)
end

-- 获取缓存的玩家数据
local function KiriameRPchat_GetCachedPlayerData(source)
    if not source then return nil end
    if PlayerDataCache[source] then
        return PlayerDataCache[source]
    end
    return KiriameRPchat_UpdatePlayerDataCache(source)
end

-- 获取缓存的玩家坐标
local function KiriameRPchat_GetCachedPlayerCoords(source)
    if not source then return nil end
    if PlayerCoordsCache[source] then
        return PlayerCoordsCache[source]
    end
    return KiriameRPchat_UpdatePlayerCoordsCache(source)
end

-- 获取玩家角色名
function KiriameRPchat_GetPlayerCharname(source)
    return API.getPlayerCharname(source)
end

-- 获取玩家工作信息
function KiriameRPchat_GetPlayerJob(source)
    local Player = API.getPlayerData(source)
    if not Player then return nil end
    return API.getPlayerJob(source)
end

-- 获取玩家帮派信息
function KiriameRPchat_GetPlayerGang(source)
    local Player = API.getPlayerData(source)
    if not Player then return nil end
    return API.getPlayerGang(source)
end

-- 获取玩家金钱信息
function KiriameRPchat_GetPlayerMoney(source)
    local Player = API.getPlayerData(source)
    if not Player then return nil end
    return API.getPlayerMoney(source)
end

-- 获取玩家坐标
function KiriameRPchat_GetPlayerCoords(source)
    return API.getPlayerCoords(source)
end

-- 获取玩家标识符
function KiriameRPchat_GetPlayerIdentifier(source, type)
    return API.getPlayerIdentifier(source, type)
end

-- 获取所有玩家
function KiriameRPchat_GetPlayers()
    return API.getPlayers()
end

-- 检查玩家是否存在
function KiriameRPchat_DoesPlayerExist(source)
    return API.doesPlayerExist(source)
end

-- 检查玩家是否有权限
function KiriameRPchat_IsPlayerAceAllowed(source, permission)
    return API.isPlayerAceAllowed(source, permission)
end

-- 发送通知
function KiriameRPchat_SendNotification(source, message, type, duration)
    API.sendNotification(source, message, type, duration)
end

-- 计算两个玩家之间的距离
function KiriameRPchat_GetDistanceBetweenPlayers(source, target)
    local sourceCoords = KiriameRPchat_GetPlayerCoords(source)
    local targetCoords = KiriameRPchat_GetPlayerCoords(target)
    return #(sourceCoords - targetCoords)
end

-- 向附近玩家显示消息
function KiriameRPchat_DisplayMessageToNearbyPlayers(source, message, distance)
    local sourceCoords = KiriameRPchat_GetPlayerCoords(source)
    local players = KiriameRPchat_GetPlayers()
    
    for _, targetid in ipairs(players) do
        if KiriameRPchat_DoesPlayerExist(targetid) then
            local targetCoords = KiriameRPchat_GetPlayerCoords(targetid)
            local dist = #(sourceCoords - targetCoords)
            
            if dist <= distance then
                TriggerClientEvent('kiriame_rpchat:client:receiveMessage', targetid, message)
            end
        end
    end
end

function KiriameRPchat_IsRestrictedFrequency(frequency)
    if not Config.RestrictChannel then return false end
    
    for k, v in pairs(Config.RestrictChannel) do
        if frequency == v then
            return true, k
        end
    end
    return false, nil
end

-- 设置无线电频率
function KiriameRPchat_SetRadioFrequency(source, slot, frequency)
    local isRestricted, channelKey = KiriameRPchat_IsRestrictedFrequency(frequency)
    local playerData = KiriameRPchat_GetCachedPlayerData(source)
    
    if not playerData then return end
    
    local jobType = playerData.job.type
    
    if isRestricted then
        if jobType == "leo" then
            TriggerClientEvent('kiriame_rpchat:client:setRadioFrequency', source, slot, frequency)
            TriggerClientEvent('chatMessage', source,
                string.format(" ** [S: %s | CH: %d] 你已加入加密频道", channelKey, frequency),
                MESSAGE_COLOR)
        else
            TriggerClientEvent('QBCore:Notify', source, "你无法加入一个被加密的频道！", 'warn', 5000)
        end
    else
        TriggerClientEvent('kiriame_rpchat:client:setRadioFrequency', source, slot, frequency)
    end
end

-- 统一的聊天消息发送函数
function KiriameRPchat_SendChatMessage(target, message, color)
    TriggerClientEvent('chat:addMessage', target, {
        color = color or {255, 255, 255},
        multiline = true,
        args = { message }
    })
end

-- 清理缓存
AddEventHandler('playerDropped', function()
    local source = source
    PlayerDataCache[source] = nil
    PlayerCoordsCache[source] = nil
end)

-- 玩家切换角色时清理缓存
AddEventHandler('QBCore:Server:OnPlayerUnload', function()
    local source = source
    PlayerDataCache[source] = nil
    PlayerCoordsCache[source] = nil
end)

-- 定期清理过期缓存
CreateThread(function()
    while true do
        Wait(60000) -- 每分钟检查一次
    end
end)

-- 命令系统类型定义
---@class OxCommandParams
---@field name string
---@field help string
---@field type? 'number' | 'playerId' | 'string' | 'longString' | 'text'
---@field optional? boolean

---@class OxCommandProperties
---@field help string?
---@field params OxCommandParams[]?

---@type OxCommandProperties[]
local registeredCommands = {}

-- 参数解析函数
---@param source number
---@param args table
---@param raw string
---@param params OxCommandParams[]?
---@return table?
local function KiriameRPchat_ParseArguments(source, args, raw, params)
    if not params then return args end

    local paramsNum = #params
    for i = 1, paramsNum do
        local arg, param = args[i], params[i]
        local value

        if param.type == 'number' then
            value = tonumber(arg)
        elseif param.type == 'string' then
            value = not tonumber(arg) and arg
        elseif param.type == 'text' then
            value = arg
        elseif param.type == 'playerId' then
            value = arg == 'me' and source or tonumber(arg)
            if not value or not DoesPlayerExist(value) then
                value = false
            end
        elseif param.type == 'longString' and i == paramsNum then
            if arg then
                local start = raw:find(arg, 1, true)
                value = start and raw:sub(start)
            end
        else
            value = arg
        end

        if not value and not param.optional then
            return nil
        end

        args[param.name] = value
        args[i] = nil
    end

    return args
end

-- 添加命令函数
---@param commandName string | string[]
---@param properties OxCommandProperties | false
---@param cb fun(source: number, args: table, raw: string)
function KiriameRPchat_AddCommand(commandName, properties, cb)
    local params = properties and properties.params

    if params then
        for i = 1, #params do
            local param = params[i]
            if param.type then
                param.help = param.help and ('%s (类型: %s)'):format(param.help, param.type) or 
                    ('(类型: %s)'):format(param.type)
            end
        end
    end

    local commands = type(commandName) ~= 'table' and { commandName } or commandName
    local numCommands = #commands
    local totalCommands = #registeredCommands

    local function commandHandler(source, args, raw)
        args = KiriameRPchat_ParseArguments(source, args, raw, params)
        if not args then return end

        local success, resp = pcall(cb, source, args, raw)
        if not success then
            return false
        end

        return true
    end

    for i = 1, numCommands do
        totalCommands += 1
        commandName = commands[i]

        RegisterCommand(commandName, commandHandler)

        if properties then
            properties.name = ('/%s'):format(commandName)
            registeredCommands[totalCommands] = properties

            if i ~= numCommands and numCommands ~= 1 then
                properties = table.clone(properties)
            end
        end
    end

    if #registeredCommands > 0 then
        TriggerClientEvent('chat:addSuggestions', -1, registeredCommands)
    end

    AddEventHandler('playerJoining', function()
        TriggerClientEvent('chat:addSuggestions', source, registeredCommands)
    end)
end