local QBCore = exports['qb-core']:GetCoreObject()
local API = exports['kiriame_rpchat']:GetAPIInterface()

-- 玩家标识符缓存
local PlayerIdentifierCache = {}

-- 获取玩家标识符
function KiriameRPchat_GetPlayerIdentifier(source)
    if not source then return nil end
    
    if PlayerIdentifierCache[source] then
        return PlayerIdentifierCache[source]
    end
    
    local identifier = KiriameRPchat_API.getPlayerIdentifier(source, 'license')
    if identifier then
        PlayerIdentifierCache[source] = identifier
    end
    
    return identifier
end

-- 获取玩家游戏时间
function KiriameRPchat_GetPlayerPlayTime(source)
    local identifier = KiriameRPchat_GetPlayerIdentifier(source)
    if not identifier then return 0 end
    
    local result = MySQL.Sync.fetchScalar('SELECT time FROM playtime WHERE identifier = ?', {identifier})
    return tonumber(result) or 0
end

-- 预定义消息模板
local MESSAGE_TEMPLATES = {
    header = "^1%s个人信息",
    separator = "^1=========================================",
    id = "^1ID: ^3%s",
    playtime = "^1游戏时间: ^3%d小时",
    job = "^1工作: ^3%s (级别: ^3%s^1, 是否在职: ^3%s^1)",
    noJob = "^1工作: ^3None",
    gang = "^1帮派: ^3%s (级别: ^3%s^1)",
    noGang = "^1帮派: ^3没有",
    money = "^1现金: ^3%d ^1| 银行: ^3%d",
    noMoney = "^1现金: ^30 ^1| 银行: ^30"
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
        table.insert(messages, string.format(MESSAGE_TEMPLATES.money, money['cash'] or 0, money['bank'] or 0))
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
    PlayerIdentifierCache[source] = nil
end)

-- 统计命令
KiriameRPchat_AddCommand('stats', {
    help = '查看玩家统计信息',
    params = {}
}, function(source, args, raw)
    local Player = KiriameRPchat_API.getPlayerData(source)
    if not Player then return end
    
    local charname = KiriameRPchat_API.getPlayerCharname(source)
    local playtime = KiriameRPchat_GetPlayerPlayTime(source)
    local job = KiriameRPchat_API.getPlayerJob(source)
    local gang = KiriameRPchat_API.getPlayerGang(source)
    local money = KiriameRPchat_API.getPlayerMoney(source)
    
    -- 构建消息
    local messages = {
        string.format("^1角色名: ^3%s", charname),
        string.format("^1游戏时间: ^3%d小时", playtime)
    }
    
    if job then
        table.insert(messages, string.format("^1工作: ^3%s (级别: ^3%s^1, 是否在职: ^3%s^1)", 
            job.label, 
            job.grade.name, 
            job.onduty and "是" or "不是"))
    end
    
    if gang then
        table.insert(messages, string.format("^1帮派: ^3%s (级别: ^3%s^1)", 
            gang.label, 
            gang.grade.name))
    end
    
    if money then
        table.insert(messages, string.format("^1现金: ^3%d ^1| 银行: ^3%d", 
            money['cash'] or 0, 
            money['bank'] or 0))
    end
    
    -- 发送到聊天框
    TriggerClientEvent('chat:addMessage', source, {
        color = Config.PrefixColor,
        multiline = true,
        args = { table.concat(messages, "\n") }
    })
end)