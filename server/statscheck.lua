local QBCore = exports['qb-core']:GetCoreObject()

-- 获取格式化的时间
local function getFormattedTime()
    return "[" .. os.date("%H:%M:%S") .. "]"
end

-- 获取玩家的标识符
local function getPlayerIdentifier(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, string.len("license:")) == "license:" then
            return id
        end
    end
    return nil
end

-- 获取玩家的游戏时间
local function getPlayerPlayTime(identifier)
    local response = MySQL.query.await('SELECT `time` FROM `playtime` WHERE `identifier` = ?', { identifier })
    if response and #response > 0 then
        return response[1].time / 3600
    end
    return 0
end

-- 发送玩家信息到聊天
local function sendPlayerInfoToChat(source, formattedTime, playerName, playTimeInHours, job, gang, money)
    local messages = {
         " " .. playerName .. "个人信息",
         " ========================================= ",
         " ID: " .. source,
         " 游戏时间: " .. math.floor(playTimeInHours) .. " 小时"
    }

    if job then
        table.insert(messages,  " 工作: " .. job.label .. " (级别: " .. job.grade.name .. ", 是否在职: " .. (job.onduty and "是" or "不是") .. ")")
    else
        table.insert(messages,  " 工作: None")
    end

    if gang then
        table.insert(messages,  " 帮派: " .. gang.label .. " (级别: " .. gang.grade.name .. ")")
    else
        table.insert(messages,  " 帮派: 没有")
    end

    if money then
        table.insert(messages,  " 现金: " .. (money['cash'] or 0))
        table.insert(messages,  " 银行: " .. (money['bank'] or 0))
    else
        table.insert(messages,  " 现金: 0")
        table.insert(messages,  " 银行: 0")
    end

    table.insert(messages,  " ========================================= ")

    for _, msg in ipairs(messages) do
        TriggerClientEvent('chat:addMessage', source, {
            color = Config.PrefixColor,
            multiline = true,
            args = { msg }
        })
    end
end

QBCore.Commands.Add('stats', "检查状态", {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        QBCore.Functions.Notify(source, '玩家数据获取失败')
        return
    end

    local identifier = getPlayerIdentifier(source)
    if not identifier then
        return
    end

    local playTimeInHours = getPlayerPlayTime(identifier)
    local PlayerData = Player.PlayerData
    if not PlayerData then
        QBCore.Functions.Notify(source, '玩家数据获取失败')
        return
    end

    local playerName = GetPlayerCharname(source)
    local formattedTime = getFormattedTime()

    sendPlayerInfoToChat(source, formattedTime, playerName, playTimeInHours, PlayerData.job, PlayerData.gang, PlayerData.money)
end, 'user')
