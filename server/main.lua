local QBCore = exports['qb-core']:GetCoreObject()
local API = exports['kiriame_rpchat']:GetAPIInterface()
print('Loading main.lua\nI Love Galgame and Xiaogao!')

-- 常量定义
local CHAT_COLORS = {
    me = { 187, 160, 215 },
    low = { 128, 128, 128 },
    docommand = { 187, 160, 215 }, --motherfucker lua
    b = { 125, 123, 120 },
    s = { 255, 255, 255 },
    pm = { 236, 224, 21 },
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
    KiriameRPchat_SendChatMessage(source, Config.WelcomeWord)
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
}, function(source, args, raw)
    local message = string.format(" * %s %s", KiriameRPchat_GetPlayerCharname(source), raw:sub(4))
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.me, 10)
end)

-- 小声说话命令
KiriameRPchat_AddCommand('low', {
    help = '小声说话',
    params = { { name = 'action', type = 'text', help = '要说的话' } }
}, function(source, args, raw)
    local message = string.format("%s 小声说:%s", KiriameRPchat_GetPlayerCharname(source), raw:sub(5))
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.low, 4)
end)

-- 动作描述命令
KiriameRPchat_AddCommand('do', {
    help = '描述一个动作',
    params = { { name = 'action', type = 'text', help = '要描述的动作' } }
}, function(source, args, raw)
    local message = string.format("%s*(%s[%d]))", raw:sub(4), KiriameRPchat_GetPlayerCharname(source), source)
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.docommand, 10)
end)

-- 广播命令
KiriameRPchat_AddCommand('b', {
    help = '广播消息',
    params = { { name = 'action', type = 'text', help = '要广播的消息' } }
}, function(source, args, raw)
    local message = string.format("((%s[%d] 说:%s))", KiriameRPchat_GetPlayerCharname(source), source, raw:sub(3))
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.b, 10)
end)

-- 大喊命令
KiriameRPchat_AddCommand('s', {
    help = '大喊',
    params = { { name = 'action', type = 'text', help = '要喊的话' } }
}, function(source, args, raw)
    local message = string.format("%s 大喊:%s", KiriameRPchat_GetPlayerCharname(source), raw:sub(3))
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.s, 10)
end)


KiriameRPchat_AddCommand('m', {
    help = '喊话器',
    params = { { name = 'action', type = 'text', help = '要喊的话' } }
}, function(source, args, raw)
    local message = string.format("[喊话器] %s : %s", KiriameRPchat_GetPlayerCharname(source), raw:sub(3))
    KiriameRPchat_SendMessageToNearbyPlayers(source, message, CHAT_COLORS.pm, 40)
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

    local senderName = KiriameRPchat_GetPlayerCharname(source)
    local targetName = KiriameRPchat_GetPlayerCharname(args.targetid)

    -- 提取消息内容
    local message = raw:match("%d+%s+(.+)")
    if not message then
        KiriameRPchat_SendChatMessage(source, "((私信格式错误))", CHAT_COLORS.pm)
        return
    end

    KiriameRPchat_SendChatMessage(source,
        string.format("((私信发送给了%s:%s))", targetName, message),
        CHAT_COLORS.pm)

    KiriameRPchat_SendChatMessage(args.targetid,
        string.format('((私信来自于%s[%d] :%s))', senderName, source, message),
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

    local srcCoords = KiriameRPchat_GetCachedPlayerCoords(source)
    local targetCoords = KiriameRPchat_GetCachedPlayerCoords(args.targetid)
    local distance = #(srcCoords - targetCoords)
    
    if distance > 5 then
        KiriameRPchat_SendChatMessage(source,
            string.format("((这种距离(%.1f)想说话有点难哦))", distance))
        return
    end

    local senderName = KiriameRPchat_GetPlayerCharname(source)
    local targetName = KiriameRPchat_GetPlayerCharname(args.targetid)

    -- 提取消息内容
    local message = raw:match("%d+%s+(.+)")
    if not message then
        KiriameRPchat_SendChatMessage(source, "((格式错误))", CHAT_COLORS.whisper)
        return
    end

    KiriameRPchat_SendChatMessage(source,
        string.format("你对%s [%d] 小声的说:%s", targetName, args.targetid, message),
        CHAT_COLORS.whisper)

    KiriameRPchat_SendChatMessage(args.targetid,
        string.format('%s [%d] 小声的对你说:%s', senderName, source, message),
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

    local srcCoords = KiriameRPchat_GetCachedPlayerCoords(source)
    local targetCoords = KiriameRPchat_GetCachedPlayerCoords(args.targetid)
    local distance = #(srcCoords - targetCoords)
    
    if distance > 10 then
        KiriameRPchat_SendChatMessage(source,
            string.format("((这种距离(%.1f)想说话有点难哦))", distance))
        return
    end

    local senderName = KiriameRPchat_GetPlayerCharname(source)
    local targetName = KiriameRPchat_GetPlayerCharname(args.targetid)

    -- 提取消息内容
    local message = raw:match("%d+%s+(.+)")
    if not message then
        KiriameRPchat_SendChatMessage(source, "((格式错误))", CHAT_COLORS.to)
        return
    end

    KiriameRPchat_SendChatMessage(source,
        string.format("你对%s [%d] 说:%s", targetName, args.targetid, message),
        CHAT_COLORS.to)

    KiriameRPchat_SendChatMessage(args.targetid,
        string.format('^8[!]^0 %s [%d] 对你说:%s', senderName, source, message),
        CHAT_COLORS.to)
end)

KiriameRPchat_AddCommand('sto', {
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

    local srcCoords = KiriameRPchat_GetCachedPlayerCoords(source)
    local targetCoords = KiriameRPchat_GetCachedPlayerCoords(args.targetid)
    local distance = #(srcCoords - targetCoords)
    
    if distance > 15 then
        KiriameRPchat_SendChatMessage(source,
            string.format("((这种距离(%.1f)想说话有点难哦))", distance))
        return
    end

    local senderName = KiriameRPchat_GetPlayerCharname(source)
    local targetName = KiriameRPchat_GetPlayerCharname(args.targetid)

    -- 提取消息内容
    local message = raw:match("%d+%s+(.+)")
    if not message then
        KiriameRPchat_SendChatMessage(source, "((格式错误))", CHAT_COLORS.s)
        return
    end

    KiriameRPchat_SendChatMessage(source,
        string.format("你对%s [%d] 大喊道: %s", targetName, args.targetid, message),
        CHAT_COLORS.s)

    KiriameRPchat_SendChatMessage(args.targetid,
        string.format('^8[!]^0 %s [%d] 对你大喊道: %s', senderName, source, message),
        CHAT_COLORS.s)
end)

-- 3D动作命令
KiriameRPchat_AddCommand('ame', {
    help = '3D动作',
    params = { { name = 'action', type = 'text', help = '要执行的动作' } }
}, function(source, args, raw)
    local Players = GetPlayers()
    for _, targetid in ipairs(Players) do
        if KiriameRPchat_CalculateDistance(source, targetid) <= 10 and DoesPlayerExist(targetid) then
            TriggerClientEvent('kiriame_rpchat:client:shareDisplay', targetid, '*' .. raw:sub(5), source)
        end
    end
end)

KiriameRPchat_AddCommand('meing', {
    help = '3D动作',
    params = { { name = 'action', type = 'text', help = '要执行的动作' } }
}, function(source, args, raw)
    local Players = GetPlayers()
    local actionMessage = args.action ~= 'off' and ('*' .. raw:sub(7)) or nil

    for _, targetid in ipairs(Players) do
        if DoesPlayerExist(targetid) then
            local srcCoords = KiriameRPchat_GetCachedPlayerCoords(source)
            local targetCoords = KiriameRPchat_GetCachedPlayerCoords(targetid)
            local distance = #(srcCoords - targetCoords)
            
            if distance <= 10 then
                if actionMessage then
                    TriggerClientEvent('kiriame_rpchat:client:shareDisplayLong', targetid, actionMessage, source)
                else
                    TriggerClientEvent('kiriame_rpchat:client:shareDisplayLong', targetid, "", source)
                end
            end
        end
    end
end)



KiriameRPchat_AddCommand('f', {
    help = '向相同职业的玩家发送消息',
    params = { { name = 'message', type = 'text', help = '消息内容' } }
}, function(source, args, raw)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local jobName = Player.PlayerData.job.name
    local jobGrade = Player.PlayerData.job.grade.name
    local playerName = KiriameRPchat_GetPlayerCharname(source)

    local message = string.sub(raw, 3) -- 移除命令前缀 "job "

    -- 获取所有玩家
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local targetPlayer = QBCore.Functions.GetPlayer(playerId)
        if targetPlayer and targetPlayer.PlayerData.job.name == jobName then
            KiriameRPchat_SendChatMessage(playerId,
                string.format("(( %s %s: %s))",

                    jobGrade,
                    playerName,
                    message
                ),
                { 86, 135, 183 } -- 黄色消息
            )
        end
    end
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

-- 处理txAdmin封禁事件
RegisterNetEvent('txAdmin:events:playerBanned')
AddEventHandler('txAdmin:events:playerBanned', function(eventData)
    -- 验证事件数据
    if not eventData or not eventData.author or not eventData.targetName or not eventData.reason then
        return
    end

    -- 从targetIds中获取license
    local license = nil
    for _, id in ipairs(eventData.targetIds) do
        if string.find(id, "license:") then
            license = string.sub(id, 9) -- 移除 "license:" 前缀
            break
        end
    end

    -- 从数据库获取角色信息
    local charName = nil
    if license then
        local result = MySQL.query.await('SELECT charinfo FROM players WHERE name = ? LIMIT 1', { eventData.targetName })
        if result and result[1] and result[1].charinfo then
            local success, charinfo = pcall(function() return json.decode(result[1].charinfo) end)
            if success and charinfo and charinfo.firstname and charinfo.lastname then
                charName = charinfo.firstname .. ' ' .. charinfo.lastname
            end
        end
    end

    -- 如果无法获取角色名，使用默认名字
    if not charName then
        charName = eventData.targetName
    end

    local banMessage

    -- 处理永久封禁和临时封禁
    if eventData.durationTranslated == nil then
        banMessage = string.format("管理员 %s 永久封禁了 %s 原因：%s",
            eventData.author,
            charName,
            eventData.reason
        )
    else
        banMessage = string.format("管理员 %s 封禁了 %s 原因：%s 结束时间：%s",
            eventData.author,
            charName,
            eventData.reason,
            eventData.durationTranslated
        )
    end

    -- 替换踢出消息中的名字
    if eventData.kickMessage then
        eventData.kickMessage = string.gsub(eventData.kickMessage, eventData.targetName, charName)
    end

    -- 向所有玩家广播封禁消息
    local Players = GetPlayers()
    for _, playerId in ipairs(Players) do
        TriggerClientEvent('chat:addMessage', playerId, {
            color = { 255, 0, 0 }, -- 红色消息
            multiline = true,
            args = { banMessage }
        })
    end

    -- 记录封禁信息到服务器日志
    print(string.format('^3[txAdmin] ^0Ban issued by %s - Target: %s (License: %s) - Reason: %s - Duration: %s',
        eventData.author,
        charName,
        license or 'Unknown',
        eventData.reason,
        eventData.durationTranslated or 'Permanent'
    ))
end)

-- 检查玩家是否为管理员
lib.callback.register('kiriame_rpchat:server:isAdmin', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    return Player.PlayerData.job.name == 'admin' or Player.PlayerData.job.name == 'mod'
end)

-- 获取管理员名称
lib.callback.register('kiriame_rpchat:server:getAdminName', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return "" end
    
    -- 检查玩家是否有管理员权限
    if Player.PlayerData.job.name == 'admin' or Player.PlayerData.job.name == 'mod' then
        local name = string.format("[管理员] %s", Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname)
        return name
    end
    
    return ""
end)

-- 获取玩家角色名称
lib.callback.register('kiriame_rpchat:server:getPlayerCharname', function(source, targetId)
    local Player = QBCore.Functions.GetPlayer(targetId)
    if not Player then return GetPlayerName(targetId) end
    
    return Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
end)

-- 辅助函数：检查表中是否包含某个值
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end



-- 复活命令
KiriameRPchat_AddCommand('fixrevive', {
    help = '复活玩家',
    params = {}
}, function(source, args, raw)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    -- 触发客户端复活事件
    TriggerClientEvent('hospital:client:Revive', source)
    
    -- 发送通知消息
    local playerName = KiriameRPchat_GetPlayerCharname(source)
    local message = string.format("((角色扮演须知：此命令用于死亡时没有医护/死在极其奇怪的地方/扮演结束后在场玩家一直同意使用命令，在扮演过程中擅自使用此命令导致扮演出现异常可视为超人扮演))", playerName)
    
    -- 只向使用命令的玩家发送通知
    TriggerClientEvent('chat:addMessage', source, {
        color = { 0, 255, 0 }, -- 绿色消息
        multiline = true,
        args = { message }
    })
end)

-- -- 删除调试信息
-- RegisterNetEvent('kiriame_rpchat:server:printRadioMessage')
-- AddEventHandler('kiriame_rpchat:server:printRadioMessage', function(key, frequency, message, SenderTargetPlayerID)
--     local printmessage = string.format("(无线电) %s 说: %s", KiriameRPchat_GetPlayerCharname(source), message)
--     printmessage = string.gsub(printmessage, "%^", "^6*")
--     KiriameRPchat_SendChatMessageToPlayers(source, printmessage)
-- end)

-- 获取所有玩家
lib.callback.register('kiriame_rpchat:server:getPlayers', function(source)
    local players = {}
    local Players = GetPlayers()
    
    for _, playerId in ipairs(Players) do
        if DoesPlayerExist(playerId) then
            table.insert(players, {
                id = playerId
            })
        end
    end
    
    return players
end)
