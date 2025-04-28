local QBCore = exports['qb-core']:GetCoreObject()

-- 常量定义
local MAX_DISTANCE = 10.0
local MESSAGE_COLOR = { 244, 237, 159 }
local CACHE_DURATION = 300 -- 5分钟缓存时间

-- 缓存系统
local Cache = {
    playerData = {},
    playerCoords = {},
    lastUpdate = {}
}

-- 更新玩家数据缓存
local function KiriameRPchat_UpdatePlayerDataCache(source)
    local currentTime = os.time()
    local Player = QBCore.Functions.GetPlayer(source)
    
    if Player then
        Cache.playerData[source] = Player.PlayerData
        Cache.lastUpdate[source] = currentTime
        return Player.PlayerData
    end
    return nil
end

-- 更新玩家坐标缓存
local function KiriameRPchat_UpdatePlayerCoordsCache(source)
    local currentTime = os.time()
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    
    Cache.playerCoords[source] = coords
    Cache.lastUpdate[source] = currentTime
    return coords
end

-- 获取缓存的玩家数据
local function KiriameRPchat_GetCachedPlayerData(source)
    local currentTime = os.time()
    if Cache.playerData[source] and Cache.lastUpdate[source] and 
       (currentTime - Cache.lastUpdate[source]) < CACHE_DURATION then
        return Cache.playerData[source]
    end
    return KiriameRPchat_UpdatePlayerDataCache(source)
end

-- 获取缓存的玩家坐标
local function KiriameRPchat_GetCachedPlayerCoords(source)
    local currentTime = os.time()
    if Cache.playerCoords[source] and Cache.lastUpdate[source] and 
       (currentTime - Cache.lastUpdate[source]) < CACHE_DURATION then
        return Cache.playerCoords[source]
    end
    return KiriameRPchat_UpdatePlayerCoordsCache(source)
end

-- 计算两个玩家之间的距离
function KiriameRPchat_CalculateDistance(senderid, targeterid)
    local senderCoords = KiriameRPchat_GetCachedPlayerCoords(senderid)
    local targetCoords = KiriameRPchat_GetCachedPlayerCoords(targeterid)
    
    if not senderCoords or not targetCoords then
        return math.huge -- 返回一个很大的值表示无效距离
    end
    
    return #(targetCoords - senderCoords)
end

-- 获取玩家的全名
function KiriameRPchat_GetPlayerCharname(source)
    local playerData = KiriameRPchat_GetCachedPlayerData(source)
    if playerData and playerData.charinfo then
        return string.format("%s %s", 
            playerData.charinfo.firstname, 
            playerData.charinfo.lastname)
    end
    return "未知玩家"
end

-- 触发客户端事件给附近玩家
function KiriameRPchat_DisplayMessageToNearbyPlayers(src, message)
    local Players = GetPlayers()
    local srcCoords = KiriameRPchat_GetCachedPlayerCoords(src)
    
    if not srcCoords then return end
    
    for _, targetid in ipairs(Players) do
        if targetid ~= src and DoesPlayerExist(targetid) then
            local distance = KiriameRPchat_CalculateDistance(src, targetid)
            if distance <= MAX_DISTANCE then
                TriggerClientEvent('kiriame_rpchat:client:shareDisplay', targetid, '*' .. message, src)
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

-- 调试打印
function KiriameRPchat_ServerDebugPrint(message)
    if Config.Debug then
        print(string.format("[DEBUG] %s", message))
    end
end

-- 清理缓存
AddEventHandler('playerDropped', function()
    local source = source
    Cache.playerData[source] = nil
    Cache.playerCoords[source] = nil
    Cache.lastUpdate[source] = nil
end)

-- 定期清理过期缓存
CreateThread(function()
    while true do
        local currentTime = os.time()
        for source, lastUpdate in pairs(Cache.lastUpdate) do
            if (currentTime - lastUpdate) > CACHE_DURATION then
                Cache.playerData[source] = nil
                Cache.playerCoords[source] = nil
                Cache.lastUpdate[source] = nil
            end
        end
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
            KiriameRPchat_ServerDebugPrint(string.format("命令 '%s' 收到无效参数 %s 用于参数 %s (%s), 收到 '%s'",
                string.strsplit(' ', raw) or raw, param.type, i, param.name, arg))
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
            KiriameRPchat_ServerDebugPrint(string.format("命令 '%s' 执行失败!\n%s", 
                string.strsplit(' ', raw) or raw, resp))
        end
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