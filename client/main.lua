---@diagnostic disable: missing-parameter
QBCore = exports['qb-core']:GetCoreObject()

local PlayerName = nil

local Player = QBCore.Functions.GetPlayerData()

local playerPed = PlayerPedId()
local AllplayerId = GetPlayerServerId()

RegisterCommand("texttest", function(source, args)
    local text = table.concat(args, " ")
    -- print("Displaying text: " .. text)
    displayTextToPlayer(text)
end, false)
-- 获取除当前玩家外的其他玩家的Ped，这里-1代表除当前玩家外的第一个玩家
-- 注意:这段代码可能不会按预期工作，因为它没有遍历所有玩家
local ped = GetPlayerPed(-1)

-- 获取当前玩家的Ped标识符
local ped2 = PlayerPedId()

-- 获取其他玩家的坐标
local playerCoords = GetEntityCoords(ped)

-- 获取当前玩家的坐标
local playerCoords2 = GetEntityCoords(ped2)
local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, playerCoords2.x, playerCoords2.y, playerCoords2.z)

if PlayerName == nil then
    QBCore.Functions.TriggerCallback('rpchat:getPlayerName', function(cb)
        PlayerName = cb
    end)
end


RegisterCommand("say", function(source, args)
    TriggerServerEvent('say', table.concat(args, " "))
    print(source, args)
end)
RegisterCommand("low", function(source, args)
    TriggerServerEvent('low', table.concat(args, " "))
    print(source, args)
end)
RegisterCommand("s", function(source, args)
    TriggerServerEvent('s', table.concat(args, " "))
    print(source, args)
end)
-- RegisterCommand("b", function(source, args)
--     print(source, args)
--     TriggerServerEvent('b', table.concat(args, " "))
-- end)

-- RegisterCommand('me', function(source, args, rawCommand)
--     if rawCommand == "/me" then
--     else
--         TriggerServerEvent('me', table.concat(args, " "))
--         displayTextToPlayer(table.concat(args, " "))
--     end
-- end)
-- RegisterCommand('do', function(source, args, rawCommand)
--     TriggerServerEvent('do', table.concat(args, " "))
-- end)
-- RegisterCommand("w", function(source, args)
--     local targetid_whisper = tonumber(args[1]) -- 第一个参数为目标玩家ID
--     table.remove(args, 1)                      -- 移除目标玩家ID，获取私信内容
--     local message = table.concat(args, " ")    -- 连接剩余的参数作为私信内容
--     TriggerServerEvent('whisper', targetid_whisper, message)
-- end)
RegisterCommand("whisper", function(source, args)
    local targetid_whisper = tonumber(args[1]) -- 第一个参数为目标玩家ID
    table.remove(args, 1)                      -- 移除目标玩家ID，获取私信内容
    local message = table.concat(args, " ")    -- 连接剩余的参数作为私信内容
    TriggerServerEvent('whisper', targetid_whisper, message)
end)
RegisterCommand("to", function(source, args)
    local targetid_whisper = tonumber(args[1]) -- 第一个参数为目标玩家ID
    table.remove(args, 1)                      -- 移除目标玩家ID，获取私信内容
    local message = table.concat(args, " ")    -- 连接剩余的参数作为私信内容
    TriggerServerEvent('to', targetid_whisper, message)
end)
-- RegisterCommand("pm", function(source, args)
--     local targetid_whisper = tonumber(args[1]) -- 第一个参数为目标玩家ID
--     table.remove(args, 1)                      -- 移除目标玩家ID，获取私信内容
--     local message = table.concat(args, " ")    -- 连接剩余的参数作为私信内容
--     TriggerServerEvent('pm', targetid_whisper, message)
-- end)

RegisterCommand("f", function(source, args, rawCommand)
    local msg = rawCommand:sub(2)
    local Player = QBCore.Functions.GetPlayerData()
    local jobName = Player.job.name
    TriggerServerEvent('rpchat:jobchat', args, msg, jobName)
end)

RegisterCommand("duty", function(source)
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed, true)
    local x, y, z = coords.x, coords.y, coords.z
    local streetNameHash, crossingRoadHash = GetStreetNameAtCoord(x, y, z)
    local streetName = GetStreetNameFromHashKey(streetNameHash)
    local crossingRoad = GetStreetNameFromHashKey(crossingRoadHash)
    TriggerServerEvent('rpchat:duty', streetName, crossingRoad)
end, false)

RegisterCommand('clear', function(source, args)
    TriggerEvent('chat:clear')
end, false)

-- RegisterNetEvent('dutychat') --, function(job, printmessage)
-- AddEventHandler('dutychat', function(job, printmessage)
--     -- 获取当前玩家的ID
--     print(job)
--     local playerId = GetPlayerServerId(PlayerId())
--     local Player = QBCore.Functions.GetPlayerData()
--     local jobName = Player.job.name
--     print(printmessage)
--     TriggerEvent('chatMessage', source {
--         color = { 84, 113, 175 },
--         multiline = true,
--         args = { printmessage }
--     })
-- end)
-- 注册网络事件
RegisterNetEvent('dutychat')

-- 添加事件处理程序
AddEventHandler('dutychat', function(data, SourceJob)
    Citizen.Wait(10)
    local playerId = GetPlayerServerId(PlayerId())
    local SelfPlayer = QBCore.Functions.GetPlayerData()
    local jobName = SelfPlayer.job.name
    if jobName == SourceJob then
        TriggerEvent('chat:addMessage', {
            color = { 84, 113, 175 },
            multiline = true,
            args = { data }
        })
    else
        CancelEvent()
    end
end)
