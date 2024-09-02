-- 获取QBCore框架的核心对象
local QBCore = exports['qb-core']:GetCoreObject()

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

--command part
RegisterServerEvent('me')
AddEventHandler('me', function(message)
    local message = message
    local message = string.gsub(message, "%^", "^0")
    local src = source
    local Players = GetPlayers()
    local Player = QBCore.Functions.GetPlayer(source)
    -- 调用回调函数cb，传递玩家的名字
    local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    for _, targetid in ipairs(GetPlayers()) do
        if Distance(source, targetid) <= 10 then
            if DoesPlayerExist(targetid) then
                --   if Distance(source,targetid) <= 10 then
                print('*' .. PlayerName .. message)
                TriggerClientEvent('chatMessage', targetid, formattedTime .. '*' .. PlayerName ..
                    " " .. message, { 187, 160, 215 })
            end
        end
    end
end)
RegisterServerEvent('do')
AddEventHandler('do', function(message)
    local charactername = GetPlayerCharname(source)
    local message = message
    local src = source
    local Players = GetPlayers()
    local Player = QBCore.Functions.GetPlayer(source)
    -- 调用回调函数cb，传递玩家的名字
    local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    for _, targetid in ipairs(GetPlayers()) do
        if DoesPlayerExist(targetid) then
            if Distance(source, targetid) <= 10 then
                print(message .. "*((" .. PlayerName .. '(' .. source .. ')' .. "))")
                TriggerClientEvent('chatMessage', targetid,
                    formattedTime .. message .. "*((" .. PlayerName .. '(' .. source ..
                    ')' .. "))", { 187, 160, 215 })
            end
        end
    end
end)
--范围现实世界消息--
RegisterServerEvent('b')
AddEventHandler('b', function(message)
    local charactername = GetPlayerCharname(source)
    for _, targetid in ipairs(GetPlayers()) do
        if DoesPlayerExist(targetid) then
            if Distance(source, targetid) <= 10 and targetid ~= 0 then
                print("((" .. charactername .. " 说:" .. message .. "))")
                TriggerClientEvent('chatMessage', targetid, formattedTime ..
                    "((" .. charactername .. "(" ..
                    source .. ")" .. " 说:" .. message .. "))", { 125, 123, 120 })
            end
        end
    end
end)

--现实世界私聊指令--
RegisterServerEvent('pm')
AddEventHandler('pm', function(targetid_whisper, message)
    local charactername_sender = GetPlayerCharname(source)
    -- 获取发送者的游戏id
    local senderid_whisper = source
    -- 测试用，打印发送者id和接收者id到服务端
    print("targetid:" .. targetid_whisper .. "senderid:" .. senderid_whisper)
    -- 判断目标玩家是否存在
    if DoesPlayerExist(targetid_whisper) then
        -- 如果存在目标玩家，则获取目标玩家的角色姓名
        local charactername_target = GetPlayerCharname(targetid_whisper)
        -- 连接消息和发送者，打印在发送者的聊天界面
        print("PM来自" .. charactername_target .. "(" .. targetid_whisper .. ")" .. ":" .. message)
        TriggerClientEvent('chatMessage', senderid_whisper, formattedTime .. "((" ..
            "PM发送给了" .. charactername_target .. "(" .. targetid_whisper .. ")" .. ":" .. message .. "))",
            { 191, 182, 82 })
        -- 连接消息和发送者，打印在接收者的聊天界面
        print("PM来自" .. charactername_sender .. "(" .. source .. ") " .. "PM来自:" .. message)
        TriggerClientEvent('chatMessage', targetid_whisper,
            formattedTime ..
            "((" .. charactername_sender .. "(" .. source .. ") " .. ":" .. message .. "))", { 191, 182, 82 })
        print("PM来自" ..
            charactername_sender ..
            "(" .. senderid_whisper .. ")" .. "PM来自" .. charactername_target .. "(" ..
            targetid_whisper .. ")" .. ":" .. message)
    else
        print("玩家ID:" .. senderid_whisper .. "试图向ID:" .. targetid_whisper .. " 发送耳语:" .. message .. "，但因目标不存在而失败")
        TriggerClientEvent('chatMessage', senderid_whisper,
            formattedTime .. "(( 目标id:" .. targetid_whisper .. " 不存在，请核实后重试))",
            { 179, 134, 58 })
    end
end)

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
            print("你对" .. charactername_target .. "(" .. targetid_whisper .. ")" .. "说:" .. message)
            TriggerClientEvent('chatMessage', senderid_whisper, formattedTime ..
                "你对" .. charactername_target .. "(" .. targetid_whisper .. ")" .. "说:" .. message, { 179, 134, 62 })
            -- 连接消息和发送者，打印在接收者的聊天界面
            print(charactername_sender .. "(" .. source .. ") " .. "对你说:" .. message)
            TriggerClientEvent('chatMessage', targetid_whisper, formattedTime ..
                charactername_sender .. "(" .. source .. ") " .. "对你说:" .. message, { 179, 134, 62 })
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
            print("你对" .. charactername_target .. "(" .. targetid_whisper .. ")" .. "说:" .. message)
            TriggerClientEvent('chatMessage', senderid_whisper, formattedTime ..
                "你对" .. charactername_target .. "(" .. targetid_whisper .. ")" .. "说:" .. message, { 179, 134, 62 })
            -- 连接消息和发送者，打印在接收者的聊天界面
            print(charactername_sender .. "(" .. source .. ") " .. "对你说:" .. message)
            TriggerClientEvent('chatMessage', targetid_whisper, formattedTime ..
                charactername_sender .. "(" .. source .. ") " .. "对你说:" .. message, { 179, 134, 62 })
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
            printmessage = string.gsub(printmessage, "%^", "^6")

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
local function GetPlayerData(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player == nil then return end -- Player not loaded in correctly
    return Player.PlayerData
end

RegisterServerEvent('rpchat:jobchat')

-- 定义事件处理函数
AddEventHandler('rpchat:jobchat', function(args, msg)
    local Players = GetPlayers()
    print(msg)
    local src = source
    local Player = QBCore.Functions.GetPlayer()
    -- print(Player.PlayerData.citizenid)
    local PlayerData = GetPlayerData(source)
    local job = PlayerData.job.name
    local printmessage = formattedTime .. "((" .. GetPlayerCharname(source) .. msg .. "))"
    print(printmessage)
    -- 触发客户端事件，发送消息给所有玩家

    for k, v in pairs(GetPlayers()) do
        print(k, v, src)
        local otherjob = GetPlayerData(k) or GetPlayerData(v)
        print(otherjob)
        if v == src or k == src or k == v then
            TriggerClientEvent('chat:addMessage', k, {
                color = Config.PrefixColor,
                multiline = true,
                args = { printmessage }
            })
            print(printmessage)
        elseif job == otherjob then
            TriggerClientEvent('chat:addMessage', k, {
                color = Config.PrefixColor,
                multiline = true,
                args = { printmessage }
            })
            print(printmessage)
        end
    end
end)



RegisterServerEvent('rpchat:duty')

AddEventHandler('rpchat:duty', function(streetName, crossingRoad)
    local src = source
    local playerPed = GetPlayerPed(src)
    local coords = GetEntityCoords(playerPed)
    -- local streetName, crossingRoad, zone, street2 = GetPlayerStreetName(coords.x, coords.y, coords.z)
    print("Coordinates: ", coords.x, coords.y, coords.z)
    print("Street Name: ", streetName)
    print("Crossing Road: ", crossingRoad)
    -- print("Zone: ", zone)
    -- print("Street2: ", street2)
    local charactername = GetPlayerCharname(source)

    local PlayerData = GetPlayerData(src)
    local job = PlayerData.job.name
    local printmessage = formattedTime .. charactername .. "位于" .. streetName .. " - " .. job

    for k, v in pairs(GetPlayers()) do
        if v == src then
            TriggerClientEvent('chat:addMessage', k, {
                color = Config.PrefixColor,
                multiline = true,
                args = { printmessage }
            })
        elseif job == GetPlayerData(k).job.name then
            TriggerClientEvent('chat:addMessage', k, {
                color = Config.PrefixColor,
                multiline = true,
                args = { printmessage }
            })
        end
    end
end)
