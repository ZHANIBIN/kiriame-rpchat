local QBCore = exports['qb-core']:GetCoreObject()

local formattedTime = "[" .. os.date("%H:%M:%S", currentTime) .. "]"


QBCore.Commands.Add('stats', "检查状态", {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        QBCore.Functions.Notify(source, '玩家数据获取失败')
        return
    end

    local identifiers = GetPlayerIdentifiers(source)
    local identifier = nil
    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, string.len("license:")) == "license:" then
            identifier = id
            break
        end
    end

    if not identifier then
        return
    else
    end

    local response = MySQL.query.await('SELECT `time` FROM `playtime` WHERE `identifier` = ?', { identifier })

    local hourtime = 0

    if response and #response > 0 then
        hourtime = response[1].time / 3600
    end

    local PlayerData = Player.PlayerData
    if not PlayerData then
        QBCore.Functions.Notify(source, '玩家数据获取失败')
        return
    end

    local PlayerJob = PlayerData.job
    local PlayerGang = PlayerData.gang
    local money = PlayerData.money

    -- 触发 chat:addMessage 事件
    TriggerClientEvent('chat:addMessage', source, {
        color = Config.PrefixColor,
        multiline = true,
        args = { formattedTime .. " " .. GetPlayerCharname(source) .. "个人信息" }
    })
    TriggerClientEvent('chat:addMessage', source, {
        color = Config.PrefixColor,
        multiline = true,
        args = { formattedTime .. " ========================================= " }
    })
    TriggerClientEvent('chat:addMessage', source, {
        color = Config.PrefixColor,
        multiline = true,
        args = { formattedTime .. " ID: " .. source }
    })
    -- TriggerClientEvent('chat:addMessage', source, {
    --     color = Config.PrefixColor,
    --     multiline = true,
    --     args = { formattedTime ..  " " ..  "个人信息" .. GetPlayerCharname(source) .. " 性别:"..gender..' 公民身份证ID:'..citizenid }
    -- })
    -- TriggerClientEvent('chat:addMessage', source, {
    --     color = Config.PrefixColor,
    --     multiline = true,
    --     args = { formattedTime .. '国籍:'..nationality..' 出生日期:'..birthdate}
    -- })
    TriggerClientEvent('chat:addMessage', source, {
        color = Config.PrefixColor,
        multiline = true,
        args = { formattedTime .. " 时间分: " .. math.floor(hourtime) }
    })

    if PlayerJob then
        TriggerClientEvent('chat:addMessage', source, {
            color = Config.PrefixColor,
            multiline = true,
            args = { formattedTime .. " 工作: " .. PlayerJob.label .. " (级别: " .. PlayerJob.grade.name .. ", 是否在职: " .. (PlayerJob.onduty and "是" or "不是") .. ")" }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = Config.PrefixColor,
            multiline = true,
            args = { formattedTime .. " 工作: None" }
        })
    end

    if PlayerGang then
        TriggerClientEvent('chat:addMessage', source, {
            color = Config.PrefixColor,
            multiline = true,
            args = { formattedTime .. " 帮派: " .. PlayerGang.label .. " (级别: " .. PlayerGang.grade.name .. ")" }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = Config.PrefixColor,
            multiline = true,
            args = { formattedTime .. " 帮派: 没有" }
        })
    end

    if money and money['cash'] then
        TriggerClientEvent('chat:addMessage', source, {
            color = Config.PrefixColor,
            multiline = true,
            args = { formattedTime .. " 现金: " .. money['cash'] }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = Config.PrefixColor,
            multiline = true,
            args = { formattedTime .. " 现金: 0" }
        })
    end

    if money and money['bank'] then
        TriggerClientEvent('chat:addMessage', source, {
            color = Config.PrefixColor,
            multiline = true,
            args = { formattedTime .. " 银行: " .. money['bank'] }
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = Config.PrefixColor,
            multiline = true,
            args = { formattedTime .. " 银行: 0" }
        })
    end
    TriggerClientEvent('chat:addMessage', source, {
        color = Config.PrefixColor,
        multiline = true,
        args = { formattedTime .. " ========================================= " }
    })
end, 'user')
