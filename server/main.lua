-- 获取QBCore框架的核心对象
local QBCore = exports['qb-core']:GetCoreObject()
local function GetPlayerData(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player == nil then return end -- Player not loaded in correctly
    return Player.PlayerData
end

local formattedTime = "[" .. os.date("%H:%M:%S", currentTime) .. "]"




RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    Message = formattedTime .. Config.WelcomeWord

    TriggerClientEvent('chat:addMessage', source, {
        color = { 255, 255, 255 },
        multiline = true,
        args = { Message }
    })
end)

local function Distance(senderid, targeterid)
    local sender = senderid
    local targeter = targeterid
    local senderped = GetPlayerPed(sender)
    local targetped = GetPlayerPed(targeter)
    local senderCoords = GetEntityCoords(senderped)
    local targetCoords = GetEntityCoords(targetped)
    local distance = #(targetCoords - senderCoords)
    return distance
end
----------------------------QBCORE玩家角色名----------------------------------
--我狠这个function，为什么莫名其妙会出现一个奇奇怪怪的名字获取方式，我就纳了闷了
--2024年8月28日23:04:32 我终于知道为什么要function了，打函数名太痛苦了
function GetPlayerCharname(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    return PlayerName
end

--libme
lib.addCommand('me', {
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
                TriggerClientEvent('chatMessage', targetid, formattedTime .. " * " .. playerName .. " " .. message,
                    { 187, 160, 215 })
            end
        end
    end
end)
--libdo
lib.addCommand('do', {
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
                    formattedTime .. message .. "*((" .. playerName .. '(' .. source .. ')' .. "))", { 187, 160, 215 })
                TriggerEvent("qb-log:server:CreateLog", "default", "TestWebhook", "default",
                    "Triggered **a** test webhook :)")
            end
        end
    end
end)
--libb
lib.addCommand('b', {
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
                TriggerClientEvent('chatMessage', targetid, formattedTime ..
                    "((" .. playerName .. "(" ..
                    source .. ")" .. " 说:" .. message .. "))", { 125, 123, 120 })
            end
        end
    end
end)
--libpm
lib.addCommand('pm', {
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

        TriggerClientEvent('chatMessage', senderid_whisper, formattedTime .. "((" ..
            "PM发送给了" .. charactername_target .. ":" .. message .. "))",
            { 191, 182, 82 })

        TriggerClientEvent('chatMessage', targetid_whisper,
            formattedTime ..
            "((" .. charactername_sender .. "(" .. source .. ") " .. ":" .. message .. "))", { 191, 182, 82 })
    else
        QBCore.Functions.Notify("(( 目标id:" .. targetid_whisper .. " 不存在，请核实后重试))", warn, 5000)
    end
end)
--libw
lib.addCommand('w', {
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
        if Distance(senderid_whisper, targetid_whisper) <= 2 then
            -- 如果存在目标玩家，则获取目标玩家的角色姓名
            local charactername_target = GetPlayerCharname(targetid_whisper)
            -- 连接消息和发送者，打印在发送者的聊天界面
            TriggerClientEvent('chatMessage', senderid_whisper, formattedTime ..
                "你对" .. charactername_target .. "说:" .. message, { 179, 134, 62 })
            -- 连接消息和发送者，打印在接收者的聊天界面
            TriggerClientEvent('chatMessage', targetid_whisper, formattedTime ..
                charactername_sender .. "(" .. source .. ") " .. "对你说:" .. message, { 179, 134, 62 })
        else
            TriggerClientEvent('chatMessage', senderid_whisper,
                formattedTime .. "（（这种距离（" .. Distance(senderid_whisper, targetid_whisper) .. "）想说话有点难哦））")
        end
        -- 如果不存在目标玩家，提示检查输入是否正确
    else
        QBCore.Functions.Notify("(( 目标id:" .. targetid_whisper .. " 不存在，请核实后重试))", warn, 5000)
    end
end)


lib.addCommand('ame', {
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
    local message = args.action
    for _, targetid in ipairs(Players) do
        if Distance(source, targetid) <= 10 then
            if DoesPlayerExist(targetid) then
                TriggerClientEvent('3dme:shareDisplay', targetid, '*' .. args.action, source)
            end
        end
    end
end)

RegisterServerEvent('me')
AddEventHandler('me', function(message)
    local src = source
    local Players = GetPlayers()
    local Player = QBCore.Functions.GetPlayer(source)
    -- 检查消息是否为空或者只包含空白字符
    -- if string.match(message, "^%s*$") then
    --     -- 如果消息为空，则不执行任何操作
    --     return
    -- end
    -- 移除消息中的特定字符
    if message ~= nil then
        -- 获取玩家的名字

        local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        local formattedMessage = string.gsub(message, "%^", "^0")

        -- 遍历所有玩家
        for _, targetid in ipairs(Players) do
            if Distance(src, targetid) <= 10 then
                if DoesPlayerExist(targetid) then
                    -- 打印并触发客户端事件
                    print('*' .. PlayerName .. formattedMessage)
                    TriggerClientEvent('chatMessage', targetid,
                        formattedTime .. '*' .. PlayerName .. " " .. formattedMessage,
                        { 187, 160, 215 })
                end
            end
        end
    else
    end
end)

--现实世界私聊指令--

--耳语指令--
RegisterServerEvent('whisper')
AddEventHandler('whisper', function(targetid_whisper, message)
    local charactername_sender = GetPlayerCharname(source)
    -- 获取发送者的游戏id
    local senderid_whisper = source
    -- 测试用，打印发送者id和接收者id到服务端
    print("targetid:" .. targetid_whisper .. "senderid:" .. senderid_whisper)
    -- 判断目标玩家是否存在
    if DoesPlayerExist(targetid_whisper) then
        if Distance(senderid_whisper, targetid_whisper) <= 2 then
            -- 如果存在目标玩家，则获取目标玩家的角色姓名
            local charactername_target = GetPlayerCharname(targetid_whisper)
            -- 连接消息和发送者，打印在发送者的聊天界面
            TriggerClientEvent('chatMessage', senderid_whisper, formattedTime ..
                "你对" .. charactername_target .. "说:" .. message, { 179, 134, 62 })
            -- 连接消息和发送者，打印在接收者的聊天界面
            TriggerClientEvent('chatMessage', targetid_whisper, formattedTime ..
                charactername_sender .. "(" .. source .. ") " .. "对你说:" .. message, { 179, 134, 62 })
        else
            TriggerClientEvent('chatMessage', senderid_whisper,
                formattedTime .. "（（这种距离（" .. Distance(senderid_whisper, targetid_whisper) .. "）想说话有点难哦））")
        end
        -- 如果不存在目标玩家，提示检查输入是否正确
    else
        print("玩家ID:" .. senderid_whisper .. "试图向ID:" .. targetid_whisper .. " 发送耳语:" .. message .. "，但因目标不存在而失败")
        TriggerClientEvent('chatMessage', senderid_whisper,
            formattedTime .. "(( 目标id:" .. targetid_whisper .. " 不存在，请核实后重试))",
            { 179, 134, 58 })
    end
end)

RegisterServerEvent('to')
AddEventHandler('to', function(targetid_whisper, message)
    local charactername_sender = GetPlayerCharname(source)
    -- 获取发送者的游戏id
    local senderid_whisper = source
    -- 测试用，打印发送者id和接收者id到服务端
    print("targetid:" .. targetid_whisper .. "senderid:" .. senderid_whisper)
    -- 判断目标玩家是否存在
    if DoesPlayerExist(targetid_whisper) then
        if Distance(senderid_whisper, targetid_whisper) <= 2 then
            -- 如果存在目标玩家，则获取目标玩家的角色姓名
            local charactername_target = GetPlayerCharname(targetid_whisper)
            -- 连接消息和发送者，打印在发送者的聊天界面
            print("你对" .. charactername_target .. "说:" .. message)
            TriggerClientEvent('chatMessage', senderid_whisper, formattedTime ..
                "你对" .. charactername_target .. "说:" .. message, { 255, 255, 255 })
            -- 连接消息和发送者，打印在接收者的聊天界面
            print(charactername_sender .. "(" .. source .. ") " .. "对你说:" .. message)
            TriggerClientEvent('chatMessage', targetid_whisper, formattedTime ..
                charactername_sender .. "对你说:" .. message, { 255, 255, 255 })
            print("玩家" ..
                charactername_sender ..
                "(" .. senderid_whisper .. ")" .. "对" .. charactername_target .. "(" ..
                targetid_whisper .. ")" .. "说:" .. message)
        else
            print("玩家ID:" .. senderid_whisper .. "试图向ID:" .. targetid_whisper .. " 发送耳语:" .. message .. "，但因距离过远而失败")
            TriggerClientEvent('chatMessage', senderid_whisper,
                formattedTime .. "（（这种距离（" .. distance .. "）想说话有点难哦））")
        end
        -- 如果不存在目标玩家，提示检查输入是否正确
    else
        print("玩家ID:" .. senderid_whisper .. "试图向ID:" .. targetid_whisper .. " 发送耳语:" .. message .. "，但因目标不存在而失败")
        TriggerClientEvent('chatMessage', senderid_whisper,
            formattedTime .. "(( 目标id:" .. targetid_whisper .. " 不存在，请核实后重试))",
            { 179, 134, 58 })
    end
end)
--一般说话指令--
RegisterServerEvent('say')
AddEventHandler('say', function(param)
    local charactername = GetPlayerCharname(source)
    local message = formattedTime .. charactername .. "说:" .. param
    for _, targetid in ipairs(GetPlayers()) do
        if DoesPlayerExist(targetid) then
            if Distance(source, targetid) <= 10 then
                print(charactername .. "说:" .. param)
                TriggerClientEvent('chatMessage', targetid, message, { 255, 255, 255 })
            end
        end
    end
end)
--一般说话指令--
RegisterServerEvent('low')
AddEventHandler('low', function(param)
    local charactername = GetPlayerCharname(source)
    local message = formattedTime .. charactername .. "小声说:" .. param
    for _, targetid in ipairs(GetPlayers()) do
        if DoesPlayerExist(targetid) then
            if Distance(source, targetid) <= 4 then
                print(charactername .. "小声说:" .. param)
                TriggerClientEvent('chatMessage', targetid, message, { 128, 128, 128 })
            end
        end
    end
end)
RegisterServerEvent('s')
AddEventHandler('s', function(param)
    local charactername = GetPlayerCharname(source)
    local message = formattedTime .. charactername .. "大喊:" .. param
    for _, targetid in ipairs(GetPlayers()) do
        if DoesPlayerExist(targetid) then
            if Distance(source, targetid) <= 15 then
                print(charactername .. "大喊:" .. param)
                TriggerClientEvent('chatMessage', targetid, message, { 255, 255, 255 })
            end
        end
    end
end)

AddEventHandler('chatMessage', function(source, name, message)
    if string.sub(message, 1, string.len("/")) == "/" then
    else
        if Config.EnableChatOOC then
            local src = source
            local Players = GetPlayers()
            local Player = QBCore.Functions.GetPlayer(source)
            local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
            local printmessage = formattedTime .. PlayerName .. "说:" .. message
            printmessage = string.gsub(printmessage, "%^", "^6*")

            for k, v in pairs(Players) do
                if v == src then
                    TriggerClientEvent('chat:addMessage', v, {
                        color = Config.PrefixColor,
                        multiline = true,
                        args = { printmessage }
                    })
                    print(printmessage)
                elseif #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(v))) < Config.ChatDistance then
                    TriggerClientEvent('chat:addMessage', v, {
                        color = Config.PrefixColor,
                        multiline = true,
                        args = { printmessage }
                    })
                    print(printmessage)
                end
            end
        end
    end
    CancelEvent()
end)

RegisterServerEvent('rpchat:jobchat')     -- 注册服务器事件
AddEventHandler('rpchat:jobchat', function(source, args, rawCommand)
    local src = source                    -- source 是一个数字，代表触发事件的玩家的源ID
    local playerPed = GetPlayerPed(src)   -- 获取玩家的Ped
    local PlayerData = GetPlayerData(src) -- 获取玩家数据
    if PlayerData then
    else
        return -- 如果没有玩家数据，则退出事件处理函数
    end
    if PlayerData.job and PlayerData.job.name then
        local job = PlayerData.job.name              -- 获取玩家职业名称
        local grade = PlayerData.job.grade.name      -- 获取玩家职业等级
        local charactername = GetPlayerCharname(src) -- 获取玩家角色名称
        local Player = QBCore.Functions.GetPlayer(source)
        local SourceJob = Player.PlayerData.job.name
        local jobName, JobLabel = GetPlayerJob(source)
        local printmessage = formattedTime ..
            grade .. " " .. charactername .. args
        for k, v in pairs(GetPlayers()) do
            local OtherPlayerData = GetPlayerData(source)
            if v == src or job == jobName then
                print(printmessage)
                for _, targetid in ipairs(GetPlayers()) do
                    if OtherPlayerData and OtherPlayerData.job and OtherPlayerData.job.name then
                        print("Message sent to player source: " .. v) -- 打印消息发送信息
                        local sendtable = { printmessage = printmessage, SourceJob = SourceJob }
                        TriggerClientEvent('chatMessage', targetid, sendtable)
                    end
                end
            end
        end
    else
    end
end)

RegisterServerEvent('rpchat:duty')
AddEventHandler('rpchat:duty', function(streetName, crossingRoad)
    local src = source
    local SelfPlayerData = QBCore.Functions.GetPlayer(source)
    -- print(QBCore.Debug(SelfPlayerData))
    if SelfPlayerData.PlayerData.job and SelfPlayerData.PlayerData.job.name then
        local job = SelfPlayerData.PlayerData.job.label
        local grade = SelfPlayerData.PlayerData.job.grade.name
        local charactername = GetPlayerCharname(src)
        local printmessage = formattedTime ..
            " " .. grade .. " " .. charactername .. " 位于 " .. streetName .. " " .. crossingRoad .. " 开始执勤! - " .. job
        print(printmessage)
        local Player = QBCore.Functions.GetPlayer(source)

        local SourceJob = Player.PlayerData.job.name

        for k, targetid in ipairs(GetPlayers()) do
            local OtherPlayerData = QBCore.Functions.GetPlayer(targetid)

            TriggerClientEvent('dutychat', targetid, printmessage, SourceJob)
        end
    else
        print("Error: Player data or job information is missing")
    end
end)
