-- 获取QBCore框架的核心对象
local QBCore = exports['qb-core']:GetCoreObject()


local formattedTime = ''




RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    Message = Config.WelcomeWord

    TriggerClientEvent('chat:addMessage', source, {
        color = { 255, 255, 255 },
        multiline = true,
        args = { Message }
    })
end)

AddEventHandler('chatMessage', function(source, name, message)
    if string.sub(message, 1, string.len("/")) == "/" then
    else
        local src = source
        local Players = GetPlayers()
        local printmessage = GetPlayerCharname(source) .. " 说: " .. message
        printmessage = string.gsub(printmessage, "%^", "^6*")

        for k, v in pairs(Players) do
            if v == src then
                TriggerClientEvent('chat:addMessage', v, {
                    color = Config.PrefixColor,
                    multiline = true,
                    args = { printmessage }
                })
                -- ServerDebugprint(ServerDebugprintmessage)
            elseif #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(v))) < Config.ChatDistance then
                TriggerClientEvent('chat:addMessage', v, {
                    color = Config.PrefixColor,
                    multiline = true,
                    args = { printmessage }
                })
                -- ServerDebugprint(ServerDebugprintmessage)
            end
        end
    end
    CancelEvent()
end)

--libme
Kiriame_rpchat_addCommand('me', {
    help = 'Performs an action as the player',
    params = {
        {
            name = 'action',
            type = 'string',
            help = 'The action to perform',
        }
    },
}, function(source, args, raw)
    local Players = GetPlayers()
    local playerName = GetPlayerCharname(source) -- 获取玩家的角色名称
    local message = string.sub(raw, 4)
    for _, targetid in ipairs(Players) do
        if Distance(source, targetid) <= 10 then
            if DoesPlayerExist(targetid) then
                TriggerClientEvent('chatMessage', targetid, " * " .. playerName .. " " .. message,
                    { 187, 160, 215 })
            end
        end
    end
end)
--libdo
Kiriame_rpchat_addCommand('low', {
    help = 'Performs an action as the player',
    params = {
        name = 'action',
        type = 'string',
        help = 'The action to perform',
    }
}, function(source, args, raw)
    local charactername = GetPlayerCharname(source)
    local message = charactername .. "小声说:" .. raw
    for _, targetid in ipairs(GetPlayers()) do
        if DoesPlayerExist(targetid) then
            if Distance(source, targetid) <= 4 then
                TriggerClientEvent('chatMessage', targetid, message, { 128, 128, 128 })
            end
        end
    end
end)
Kiriame_rpchat_addCommand('do', {
    help = 'Performs an action as the player',
    params = {
        {
            name = 'action',
            type = 'string',
            help = 'The action to perform',
        }
    },
}, function(source, args, raw)
    local Players = GetPlayers()
    local playerName = GetPlayerCharname(source) -- 获取玩家的角色名称
    local message = string.sub(raw, 4)
    for _, targetid in ipairs(Players) do
        if Distance(source, targetid) <= 10 then
            if DoesPlayerExist(targetid) then
                TriggerClientEvent('chatMessage', targetid,
                    message .. "*((" .. playerName .. '[' .. source .. ']' .. "))", { 187, 160, 215 })
                TriggerEvent("qb-log:server:CreateLog", "default", "TestWebhook", "default",
                    "Triggered **a** test webhook :)")
            end
        end
    end
end)
--libb
Kiriame_rpchat_addCommand('b', {
    help = 'Performs an action as the player',
    params = {
        {
            name = 'action',
            type = 'string',
            help = 'The action to perform',
        }
    },
}, function(source, args, raw)
    local Players = GetPlayers()
    local playerName = GetPlayerCharname(source) -- 获取玩家的角色名称
    local message = string.sub(raw, 2)
    for _, targetid in ipairs(Players) do
        if Distance(source, targetid) <= 10 then
            if DoesPlayerExist(targetid) then
                TriggerClientEvent('chatMessage', targetid,
                    "((" .. playerName .. "[" ..
                    source .. "]" .. " 说:" .. message .. "))", { 125, 123, 120 })
            end
        end
    end
end)

--libb
Kiriame_rpchat_addCommand('s', {
    help = 'Performs an action as the player',
    params = {
        {
            name = 'action',
            type = 'string',
            help = 'The action to perform',
        }
    },
}, function(source, args, raw)
    local Players = GetPlayers()
    local playerName = GetPlayerCharname(source) -- 获取玩家的角色名称
    local message = string.sub(raw, 2)
    for _, targetid in ipairs(Players) do
        if Distance(source, targetid) <= 10 then
            if DoesPlayerExist(targetid) then
                TriggerClientEvent('chatMessage', targetid, playerName .. " 大喊:" .. message, { 255, 255, 255 })
            end
        end
    end
end)

--libpm
Kiriame_rpchat_addCommand('pm', {
    help = 'Performs an action as the player',
    params = {
        {
            name = 'targetid',
            type = 'playerId',
            help = 'The action to perform',
        },
        {
            name = 'action',
            type = 'string',
            help = 'The action to perform',
        }
    },
}, function(source, args, raw)
    local Players = GetPlayers()
    local playerName = GetPlayerCharname(source)
    local message = args.action
    local charactername_sender = GetPlayerCharname(source)
    local targetid_whisper = args.targetid
    local senderid_whisper = source
    -- 测试用，打印发送者id和接收者id到服务端
    -- 判断目标玩家是否存在
    if DoesPlayerExist(targetid_whisper) then
        -- 如果存在目标玩家，则获取目标玩家的角色姓名
        local charactername_target = GetPlayerCharname(targetid_whisper)

        TriggerClientEvent('chatMessage', senderid_whisper, "((" ..
            "PM发送给了" .. charactername_target .. ":" .. message .. "))",
            { 191, 182, 82 })

        TriggerClientEvent('chatMessage', targetid_whisper,
            "((" .. charactername_sender .. "(" .. source .. ") " .. ":" .. message .. "))", { 191, 182, 82 })
    else
        QBCore.Functions.Notify("(( 目标id:" .. targetid_whisper .. " 不存在，请核实后重试))", warn, 5000)
    end
end)
--libw
Kiriame_rpchat_addCommand('w', {
    help = 'Performs an action as the player',
    params = {
        {
            name = 'targetid',
            type = 'playerId',
            help = 'The action to perform',
        },
        {
            name = 'action',
            type = 'string',
            help = 'The action to perform',
        }
    },
}, function(source, args, raw)
    local message = args.action
    local charactername_sender = GetPlayerCharname(source)
    local targetid_whisper = args.targetid
    local senderid_whisper = source
    -- 测试用，打印发送者id和接收者id到服务端
    -- 判断目标玩家是否存在
    if DoesPlayerExist(targetid_whisper) then
        if Distance(senderid_whisper, targetid_whisper) <= 2 then
            -- 如果存在目标玩家，则获取目标玩家的角色姓名
            local charactername_target = GetPlayerCharname(targetid_whisper)
            -- 连接消息和发送者，打印在发送者的聊天界面
            TriggerClientEvent('chatMessage', senderid_whisper,
                "你对" .. charactername_target .. "说:" .. message, { 179, 134, 62 })
            -- 连接消息和发送者，打印在接收者的聊天界面
            TriggerClientEvent('chatMessage', targetid_whisper,
                charactername_sender .. "[" .. source .. "] " .. "对你说:" .. message, { 179, 134, 62 })
        else
            TriggerClientEvent('chatMessage', senderid_whisper,
                "（（这种距离（" .. Distance(senderid_whisper, targetid_whisper) .. "）想说话有点难哦））")
        end
        -- 如果不存在目标玩家，提示检查输入是否正确
    else
        QBCore.Functions.Notify("(( 目标id:" .. targetid_whisper .. " 不存在，请核实后重试))", warn, 5000)
    end
end)

--libwhisper
Kiriame_rpchat_addCommand('whisper', {
    help = 'Performs an action as the player',
    params = {
        {
            name = 'targetid',
            type = 'playerId',
            help = 'The action to perform',
        },
        {
            name = 'action',
            type = 'string',
            help = 'The action to perform',
        }
    },
}, function(source, args, raw)

    local message = args.action
    local charactername_sender = GetPlayerCharname(source)
    local targetid_whisper = args.targetid
    local senderid_whisper = source
    -- 测试用，打印发送者id和接收者id到服务端
    -- 判断目标玩家是否存在
    if DoesPlayerExist(targetid_whisper) then
        if Distance(senderid_whisper, targetid_whisper) <= 2 then
            -- 如果存在目标玩家，则获取目标玩家的角色姓名
            local charactername_target = GetPlayerCharname(targetid_whisper)
            -- 连接消息和发送者，打印在发送者的聊天界面
            TriggerClientEvent('chatMessage', senderid_whisper,
                "你对" .. charactername_target .. "说:" .. message, { 179, 134, 62 })
            -- 连接消息和发送者，打印在接收者的聊天界面
            TriggerClientEvent('chatMessage', targetid_whisper,
                charactername_sender .. "(" .. source .. ") " .. "对你说:" .. message, { 179, 134, 62 })
        else
            TriggerClientEvent('chatMessage', senderid_whisper,
                "（（这种距离（" .. Distance(senderid_whisper, targetid_whisper) .. "）想说话有点难哦））")
        end
        -- 如果不存在目标玩家，提示检查输入是否正确
    else
        QBCore.Functions.Notify("(( 目标id:" .. targetid_whisper .. " 不存在，请核实后重试))", warn, 5000)
    end
end)


Kiriame_rpchat_addCommand('ame', {
    help = 'Performs an action as the player',
    params = {
        {
            name = 'action',
            type = 'string',
            help = 'The action to perform',
        }
    },
}, function(source, args, raw)
    local Players = GetPlayers()

    for _, targetid in ipairs(Players) do
        if Distance(source, targetid) <= 10 then
            if DoesPlayerExist(targetid) then
                TriggerClientEvent('3dme:shareDisplay', targetid, '*' .. args.action, source)
            end
        end
    end
end)
Kiriame_rpchat_addCommand('showtags', {
    help = '显示玩家名称标签',
}, function(source, args, raw)
    TriggerClientEvent('kiriame_rpchat:client:Show', -1, source)
    -- print('显示玩家名称标签')
end)

-- 服务器端代码
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)                                       -- 每秒更新一次时间
        local currentTime = os.date("%Y-%m-%d %H:%M:%S")         -- 获取当前时间，格式为年-月-日 时:分:秒
        TriggerClientEvent('displayServerTime', -1, currentTime) -- 发送到所有客户端
    end
end)
