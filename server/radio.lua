local formattedTime = "[" .. os.date("%H:%M:%S") .. "]"
local QBCore = exports['qb-core']:GetCoreObject()


lib.addCommand('setfrequency', {
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
    for k, v in pairs(Config.restrictchannel) do
        if args.frequency == v then
            isRestrictedFrequency = true
            if jobType == "leo" then
                TriggerClientEvent('rpchat:radio:setfrequency', src, args.slot, args.frequency)
            else
                TriggerClientEvent('QBCore:Notify', source, "你无法加入一个被加密的频道！", 'warn', 5000)
            end
            break
        end
    end

    if not isRestrictedFrequency then
        TriggerClientEvent('rpchat:radio:setfrequency', src, args.slot, args.frequency)
    end
end)
for i = 1, 10 do
    lib.addCommand('r' .. i, {
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
        local src = source
        TriggerClientEvent('rpchat:radio:talkonradio', src, slot, string.sub(raw, 4), source)
    end)
end

lib.addCommand('panic', {
    help = '紧急按钮',
    params = {
    },
}, function(source, args, raw)
    TriggerClientEvent('gtar:rpchat:radiopolicepanic', source)
end)

RegisterServerEvent('radiotalk')

AddEventHandler('radiotalk', function(source, message)
    if message == nil or message == '' then
        return
    end
    local players = GetPlayers()
    for i = 1, #players do
        TriggerClientEvent('radiotalk', players[i], message)
    end
end)
RegisterServerEvent('radioMessage')
AddEventHandler('radioMessage', function(data)
    TriggerClientEvent('radioMessage:receive', -1, data)
end)
RegisterServerEvent('gtarrpchat:radio:messageprint')

-- 添加事件处理程序
AddEventHandler('gtarrpchat:radio:messageprint', function(key, frequency, message, SenderPlayerID)
    for k, v in pairs(Config.restrictchannel) do
        if frequency == v then
            frequency = k
            TriggerClientEvent('chatMessage', source,
                formattedTime .. " ** [S:" .. " " ..
                key .. " | CH:" .. frequency .. "] " .. GetPlayerCharname(SenderPlayerID) .. " :" .. message,
                { 244, 237, 159 })
        end
    end
end)

RegisterServerEvent('gtarrpchat:radio:policepanic')
AddEventHandler('gtarrpchat:radio:policepanic', function(streetName, jobgradelabel, src)
    TriggerClientEvent('chatMessage', source,
        formattedTime .. " " .. jobgradelabel .. " " .. GetPlayerCharname(source) .. " 位于 " .. streetName .. " 触发了紧急按钮！",
        { 255, 0, 0 })
end)
