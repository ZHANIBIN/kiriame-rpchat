local QBCore = exports['qb-core']:GetCoreObject()

-- 缓存玩家标识符
local playerIdentifiers = {}

-- 获取玩家的标识符（带缓存）
local function getPlayerIdentifier(source)
    if playerIdentifiers[source] then
        return playerIdentifiers[source]
    end
    
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, string.len("license:")) == "license:" then
            playerIdentifiers[source] = id
            return id
        end
    end
    return nil
end

-- 缓存玩家游戏时间
local playTimeCache = {}
local CACHE_DURATION = 300 -- 5分钟缓存时间
local lastCacheUpdate = {}

-- 获取玩家的游戏时间（带缓存）
local function getPlayerPlayTime(identifier)
    local currentTime = os.time()
    
    if playTimeCache[identifier] and lastCacheUpdate[identifier] and 
       (currentTime - lastCacheUpdate[identifier]) < CACHE_DURATION then
        return playTimeCache[identifier]
    end
    
    local response = MySQL.query.await('SELECT `time` FROM `playtime` WHERE `identifier` = ?', { identifier })
    local playTime = 0
    if response and #response > 0 then
        playTime = response[1].time / 3600
    end
    
    playTimeCache[identifier] = playTime
    lastCacheUpdate[identifier] = currentTime
    return playTime
end

-- 预定义消息模板
local MESSAGE_TEMPLATES = {
    header = " %s个人信息",
    separator = " ========================================= ",
    id = " ID: %s",
    playtime = " 游戏时间: %d 小时",
    job = " 工作: %s (级别: %s, 是否在职: %s)",
    noJob = " 工作: None",
    gang = " 帮派: %s (级别: %s)",
    noGang = " 帮派: 没有",
    cash = " 现金: %d",
    bank = " 银行: %d",
    noMoney = " 现金: 0\n 银行: 0"
}

-- 发送玩家信息到聊天（优化版）
local function sendPlayerInfoToChat(source, playerName, playTimeInHours, job, gang, money)
    local messages = {
        string.format(MESSAGE_TEMPLATES.header, playerName),
        MESSAGE_TEMPLATES.separator,
        string.format(MESSAGE_TEMPLATES.id, source),
        string.format(MESSAGE_TEMPLATES.playtime, math.floor(playTimeInHours))
    }

    if job then
        table.insert(messages, string.format(MESSAGE_TEMPLATES.job, 
            job.label, 
            job.grade.name, 
            job.onduty and "是" or "不是"))
    else
        table.insert(messages, MESSAGE_TEMPLATES.noJob)
    end

    if gang then
        table.insert(messages, string.format(MESSAGE_TEMPLATES.gang, 
            gang.label, 
            gang.grade.name))
    else
        table.insert(messages, MESSAGE_TEMPLATES.noGang)
    end

    if money then
        table.insert(messages, string.format(MESSAGE_TEMPLATES.cash, money['cash'] or 0))
        table.insert(messages, string.format(MESSAGE_TEMPLATES.bank, money['bank'] or 0))
    else
        table.insert(messages, MESSAGE_TEMPLATES.noMoney)
    end

    table.insert(messages, MESSAGE_TEMPLATES.separator)

    -- 批量发送消息
    TriggerClientEvent('chat:addMessage', source, {
        color = Config.PrefixColor,
        multiline = true,
        args = { table.concat(messages, "\n") }
    })
end

-- 清理缓存
AddEventHandler('playerDropped', function()
    local source = source
    playerIdentifiers[source] = nil
    local identifier = getPlayerIdentifier(source)
    if identifier then
        playTimeCache[identifier] = nil
        lastCacheUpdate[identifier] = nil
    end
end)

Kiriame_rpchat_addCommand('stats', {
    help = '检查当前角色状态',
}, function(source, args, raw)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        QBCore.Functions.Notify(source, '玩家数据获取失败')
        return
    end

    local identifier = getPlayerIdentifier(source)
    if not identifier then
        QBCore.Functions.Notify(source, '无法获取玩家标识符')
        return
    end

    local playTimeInHours = getPlayerPlayTime(identifier)
    local PlayerData = Player.PlayerData
    if not PlayerData then
        QBCore.Functions.Notify(source, '玩家数据获取失败')
        return
    end

    local playerName = GetPlayerCharname(source)
    sendPlayerInfoToChat(source, playerName, playTimeInHours, PlayerData.job, PlayerData.gang, PlayerData.money)
end)