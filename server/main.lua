local QBCore = exports['qb-core']:GetCoreObject()

-- 常量定义
local CHAT_COLORS = {
    me = { 187, 160, 215 },
    low = { 128, 128, 128 },
    docommand = { 187, 160, 215 }, --motherfucker lua
    b = { 125, 123, 120 },
    s = { 255, 255, 255 },
    pm = {236, 224, 21 },
    w = { 179, 134, 62 },
    to = { 255, 255, 255 },
    whisper = { 179, 134, 62 }
}

-- 缓存系统
local ChatCache = {
    playerCoords = {},
    lastUpdate = {}
}

-- 更新玩家坐标缓存
local function KiriameRPchat_UpdatePlayerCoordsCache(source)
    local currentTime = os.time()
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    
    ChatCache.playerCoords[source] = coords
    ChatCache.lastUpdate[source] = currentTime
    return coords
end

-- 获取缓存的玩家坐标
local function KiriameRPchat_GetCachedPlayerCoords(source)
    local currentTime = os.time()
    if ChatCache.playerCoords[source] and ChatCache.lastUpdate[source] and 
       (currentTime - ChatCache.lastUpdate[source]) < 1 then -- 1秒缓存
        return ChatCache.playerCoords[source]
    end
    return KiriameRPchat_UpdatePlayerCoordsCache(source)
end

-- 玩家加载事件
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    TriggerClientEvent('chat:addMessage', source, {
        color = { 255, 255, 255 },
        multiline = true,
        args = { Config.WelcomeWord }
    })
end)

-- 聊天消息处理
AddEventHandler('chatMessage', function(source, name, message)
    if string.sub(message, 1, 1) == "/" then
        CancelEvent()
        return
    end

    local printmessage = string.format("%s 说: %s", KiriameRPchat_GetPlayerCharname(source), message)
    printmessage = string.gsub(printmessage, "%^", "^6*")

    KiriameRPchat_SendChatMessageToPlayers(source, printmessage)
    CancelEvent()
end)

-- 发送聊天消息给玩家
function KiriameRPchat_SendChatMessageToPlayers(source, message)
    local srcCoords = KiriameRPchat_GetCachedPlayerCoords(source)
    local Players = GetPlayers()

    for _, v in pairs(Players) do
        if v == source or KiriameRPchat_IsPlayerInRange(source, v) then
            TriggerClientEvent('chat:addMessage', v, {
                color = Config.PrefixColor,
                multiline = true,
                args = { message }
            })
        end
    end
end

-- 检查玩家是否在范围内
function KiriameRPchat_IsPlayerInRange(source, target)
    local srcCoords = KiriameRPchat_GetCachedPlayerCoords(source)
    local targetCoords = KiriameRPchat_GetCachedPlayerCoords(target)
    return #(srcCoords - targetCoords) < Config.ChatDistance
end

-- 通用消息发送函数
local function KiriameRPchat_SendMessageToNearbyPlayers(source, message, color, distance)
    local Players = GetPlayers()
    local srcCoords = KiriameRPchat_GetCachedPlayerCoords(source)
    
    for _, targetid in ipairs(Players) do
        if DoesPlayerExist(targetid) then
            local targetCoords = KiriameRPchat_GetCachedPlayerCoords(targetid)
            if #(targetCoords - srcCoords) <= distance then
                TriggerClientEvent('chat:addMessage', targetid, {
                    color = color,
                    multiline = true,
                    args = { message }
                })
            end
        end
    end
end

-- 动作命令
KiriameRPchat_AddCommand('me', {
    help = '执行一个动作',
    params = { { name = 'action', type = 'text', help = '要执行的动作' } }
}, function(source, args,raw)
    local message = string.format(" * %s %s", KiriameRPchat_GetPlayerCharname(source), raw:sub(4))
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.me, 10)
end)

-- 小声说话命令
KiriameRPchat_AddCommand('low', {
    help = '小声说话',
    params = { { name = 'action', type = 'text', help = '要说的话' } }
}, function(source, args,raw)
    local message = string.format("%s小声说:%s", KiriameRPchat_GetPlayerCharname(source), raw:sub(5))
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.low, 4)
end)

-- 动作描述命令
KiriameRPchat_AddCommand('do', {
    help = '描述一个动作',
    params = { { name = 'action', type = 'text', help = '要描述的动作' } }
}, function(source, args,raw)
    local message = string.format("%s*(%s[%d]))", raw:sub(4), KiriameRPchat_GetPlayerCharname(source), source)
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.docommand, 10)
end)

-- 广播命令
KiriameRPchat_AddCommand('b', {
    help = '广播消息',
    params = { { name = 'action', type = 'text', help = '要广播的消息' } }
}, function(source, args,raw)
    local message = string.format("((%s[%d] 说:%s))", KiriameRPchat_GetPlayerCharname(source), source, raw:sub(3))
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.b, 10)
end)

-- 大喊命令
KiriameRPchat_AddCommand('s', {
    help = '大喊',
    params = { { name = 'action', type = 'text', help = '要喊的话' } }
}, function(source, args,raw)
    local message = string.format("%s 大喊:%s", KiriameRPchat_GetPlayerCharname(source), raw:sub(3))
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.s, 10)
end)

-- 私聊命令
KiriameRPchat_AddCommand('pm', {
    help = '对话',
    params = {
        { name = 'targetid', type = 'playerId', help = '目标玩家ID' },
        { name = 'action', type = 'text', help = '要说的话' }
    }
}, function(source, args, raw)
    if not DoesPlayerExist(args.targetid) then
        QBCore.Functions.Notify(source, string.format("目标ID: %d 不存在", args.targetid), 'error', 5000)
        return
    end

    local distance = KiriameRPchat_CalculateDistance(source, args.targetid)
    if distance > 2 then
        TriggerClientEvent('chatMessage', source,
            string.format("((这种距离(%.1f)想说话有点难哦))", distance))
        return
    end

    local senderName = KiriameRPchat_GetPlayerCharname(source)
    local targetName = KiriameRPchat_GetPlayerCharname(args.targetid)

    -- 计算目标玩家ID的位数
    local idLength = #tostring(args.targetid)

    -- 根据目标玩家ID的位数截断raw字符串
    local messageLength = #raw - idLength - 5
    local truncatedMessage = messageLength > 0 and raw:sub(6, 6 + messageLength) or ''

    TriggerClientEvent('chatMessage', source,
        string.format("((私信发送给了%s:%s))", targetName, source, truncatedMessage),
        CHAT_COLORS.pm)

    TriggerClientEvent('chatMessage', args.targetid,
        string.format('((私信来自于%s[%d] :%s))', senderName, source, truncatedMessage),
        CHAT_COLORS.pm)
end)
-- 耳语命令
KiriameRPchat_AddCommand('w', {
    help = '对话',
    params = {
        { name = 'targetid', type = 'playerId', help = '目标玩家ID' },
        { name = 'action', type = 'text', help = '要说的话' }
    }
}, function(source, args, raw)
    if not DoesPlayerExist(args.targetid) then
        QBCore.Functions.Notify(source, string.format("目标ID: %d 不存在", args.targetid), 'error', 5000)
        return
    end

    local distance = KiriameRPchat_CalculateDistance(source, args.targetid)
    if distance > 2 then
        TriggerClientEvent('chatMessage', source,
            string.format("((这种距离(%.1f)想说话有点难哦))", distance))
        return
    end

    local senderName = KiriameRPchat_GetPlayerCharname(source)
    local targetName = KiriameRPchat_GetPlayerCharname(args.targetid)

    -- 计算目标玩家ID的位数
    local idLength = #tostring(args.targetid)

    -- 根据目标玩家ID的位数截断raw字符串
    local messageLength = #raw - idLength - 4
    local truncatedMessage = messageLength > 0 and raw:sub(5, 5 + messageLength) or ''

    TriggerClientEvent('chatMessage', source,
        string.format("你对%s [%d] 小声的说:%s", targetName, source, truncatedMessage),
        CHAT_COLORS.whisper)

    TriggerClientEvent('chatMessage', args.targetid,
        string.format('%s [%d] 小声的对你说:%s', senderName, source, truncatedMessage),
        CHAT_COLORS.whisper)
end)

-- 对话命令
KiriameRPchat_AddCommand('to', {
    help = '对话',
    params = {
        { name = 'targetid', type = 'playerId', help = '目标玩家ID' },
        { name = 'action', type = 'text', help = '要说的话' }
    }
}, function(source, args, raw)
    if not DoesPlayerExist(args.targetid) then
        QBCore.Functions.Notify(source, string.format("目标ID: %d 不存在", args.targetid), 'error', 5000)
        return
    end

    local distance = KiriameRPchat_CalculateDistance(source, args.targetid)
    if distance > 2 then
        TriggerClientEvent('chatMessage', source,
            string.format("((这种距离(%.1f)想说话有点难哦))", distance))
        return
    end

    local senderName = KiriameRPchat_GetPlayerCharname(source)
    local targetName = KiriameRPchat_GetPlayerCharname(args.targetid)

    -- 计算目标玩家ID的位数
    local idLength = #tostring(args.targetid)

    -- 根据目标玩家ID的位数截断raw字符串
    local messageLength = #raw - idLength - 5
    local truncatedMessage = messageLength > 0 and raw:sub(6, 6 + messageLength) or ''

    TriggerClientEvent('chatMessage', source,
        string.format("你对%s [%d] 说:%s", targetName, source, truncatedMessage),
        CHAT_COLORS.to)

    TriggerClientEvent('chatMessage', args.targetid,
        string.format('^8[!]^0 %s [%d] 对你说:%s', senderName, source, truncatedMessage),
        CHAT_COLORS.to)
end)

-- 3D动作命令
KiriameRPchat_AddCommand('ame', {
    help = '3D动作',
    params = { { name = 'action', type = 'text', help = '要执行的动作' } }
}, function(source, args,raw)
    local Players = GetPlayers()
    for _, targetid in ipairs(Players) do
        if KiriameRPchat_CalculateDistance(source, targetid) <= 10 and DoesPlayerExist(targetid) then
            TriggerClientEvent('kiriame_rpchat:client:shareDisplay', targetid, '*' .. raw:sub(5), source)
        end
    end
end)

KiriameRPchat_AddCommand('meing', {
    help = '3D动作',
    params = { { name = 'action', type = '', help = '要执行的动作' } }
}, function(source, args,raw)
    local Players = GetPlayers()
    for _, targetid in ipairs(Players) do
        if KiriameRPchat_CalculateDistance(source, targetid) <= 10 and DoesPlayerExist(targetid) then
            if args.action ~= 'off' then
            TriggerClientEvent('kiriame_rpchat:client:shareDisplay', targetid, '*' .. raw:sub(7), source)
            else
                TriggerClientEvent('kiriame_rpchat:client:shareDisplay', targetid, '*' .. "" , source)

            end
        end
    end
end)

-- 显示标签命令
KiriameRPchat_AddCommand('showtags', {
    help = '显示玩家名称标签'
}, function(source)
    TriggerClientEvent('kiriame_rpchat:client:toggleNametags', -1, source)
end)

-- 服务器时间更新
CreateThread(function()
    while true do
        local currentTime = os.date("%Y-%m-%d %H:%M:%S")
        TriggerClientEvent('kiriame_rpchat:client:displayServerTime', -1, currentTime)
        Wait(1000)
    end
end)

-- 清理缓存
AddEventHandler('playerDropped', function()
    local source = source
    ChatCache.playerCoords[source] = nil
    ChatCache.lastUpdate[source] = nil
end)