local formattedTime = "[" .. os.date("%H:%M:%S") .. "]"
local QBCore = exports['qb-core']:GetCoreObject()
local PANIC_COLOR = { 255, 0, 0 }
local MESSAGE_COLOR = { 244, 237, 159 }

Kiriame_rpchat_addCommand('setfrequency', {
    help = 'Sets a radio frequency for the player',
    params = {
        {
            name = 'slot',
            type = 'number',
            help = 'The slot to set the frequency on',
        },
        {
            name = 'frequency',
            type = 'number',
            help = 'The frequency to set',
        }
    },
}, function(source, args, raw)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local jobType = Player.PlayerData.job.type

    local isRestrictedFrequency = false
    for k, v in pairs(Config.RestrictChannel) do
        if args.frequency == v then
            isRestrictedFrequency = true
            if jobType == "leo" then
                TriggerClientEvent('kiriame_rpchat:radio:setfrequency', src, args.slot, args.frequency)
            else
                TriggerClientEvent('QBCore:Notify', source, "你无法加入一个被加密的频道！", 'warn', 5000)
            end
            break
        end
    end

    if not isRestrictedFrequency then
        TriggerClientEvent('kiriame_rpchat:radio:setfrequency', src, args.slot, args.frequency)
    end
end)

for i = 1, 10 do
    Kiriame_rpchat_addCommand('r' .. i, {
        help = '执行玩家操作',
        params = {
            {
                name = 'message',
                type = 'string',
                help = '要执行的操作',
            }
        },
    }, function(source, args, raw)
        local slot = i
        TriggerClientEvent('kiriame_rpchat:radio:talkonradio', source, slot, string.sub(raw, 4), source)
    end)
end

Kiriame_rpchat_addCommand('panic', { help = '紧急按钮', params = {} }, function(source)
    TriggerClientEvent('kiriame_rpchat:radiopolicepanic', source)
end)

RegisterServerEvent('kiriame_rpchat:radio:message_print')
AddEventHandler('kiriame_rpchat:radio:message_print', function(key, frequency, message, SenderPlayerID)
    local isRestricted = IsRestrictedFrequency(frequency)
    local foundKey = nil -- 初始化 foundKey

    -- 查找传入的 frequency 对应的 key
    for k, v in pairs(Config.RestrictChannel) do
        if v == frequency then
            foundKey = k -- 找到匹配的频率时，存储其对应的 key
            break -- 找到匹配项后可以退出循环
        end
    end

    if foundKey then
        if isRestricted then
            TriggerClientEvent('chatMessage', source,
                " ** [S:" ..
                " " .. key .. " | CH:" .. foundKey .. "] " .. GetPlayerCharname(SenderPlayerID) .. " :" .. message, -- 使用 foundKey 代替 frequency
                MESSAGE_COLOR)
        else
            QBCore.Functions.Notify('错误', 'error', 7500)
        end
    else
        QBCore.Functions.Notify('频率未被限制或未找到', 'info', 7500) -- 通知频率未被限制或未找到
    end
end)

RegisterServerEvent('gtarrpchat:radio:police_panic')
AddEventHandler('gtarrpchat:radio:police_panic', function(streetName, jobgradelabel, src)
    TriggerClientEvent('chatMessage', src,
        " " .. jobgradelabel .. " " .. GetPlayerCharname(src) .. " 位于 " .. streetName .. " 触发了紧急按钮！",
        PANIC_COLOR)
end)

RegisterServerEvent('radiotalk')
AddEventHandler('radiotalk', function(source, message)
    if not message or message == '' then return end
    local players = GetPlayers()
    for i = 1, #players do
        TriggerClientEvent('radiotalk', players[i], message)
    end
end)

RegisterServerEvent('radioMessage')
AddEventHandler('radioMessage', function(data)
    TriggerClientEvent('kiriame_rpchat:radio:messagereceived', -1, data)
end)
