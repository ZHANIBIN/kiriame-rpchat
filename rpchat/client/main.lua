---@diagnostic disable: missing-parameter
QBCore = exports['qb-core']:GetCoreObject()

local PlayerName = nil

local Player = QBCore.Functions.GetPlayerData()
-- local jobName = Player.job.name

local playerPed = PlayerPedId()
local AllplayerId = GetPlayerServerId()

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
RegisterCommand("b", function(source, args)
	print(source, args)
	TriggerServerEvent('b', table.concat(args, " "))
end)

RegisterCommand('me', function(source, args, rawCommand)
	TriggerServerEvent('me', table.concat(args, " "))
end)
RegisterCommand('do', function(source, args, rawCommand)
	TriggerServerEvent('do', table.concat(args, " "))
end)
RegisterCommand("w", function(source, args)
	local targetid_whisper = tonumber(args[1]) -- 第一个参数为目标玩家ID
	table.remove(args, 1)                   -- 移除目标玩家ID，获取私信内容
	local message = table.concat(args, " ") -- 连接剩余的参数作为私信内容
	TriggerServerEvent('whisper', targetid_whisper, message)
end)
RegisterCommand("whisper", function(source, args)
	local targetid_whisper = tonumber(args[1]) -- 第一个参数为目标玩家ID
	table.remove(args, 1)                   -- 移除目标玩家ID，获取私信内容
	local message = table.concat(args, " ") -- 连接剩余的参数作为私信内容
	TriggerServerEvent('whisper', targetid_whisper, message)
end)
RegisterCommand("to", function(source, args)
	local targetid_whisper = tonumber(args[1]) -- 第一个参数为目标玩家ID
	table.remove(args, 1)                   -- 移除目标玩家ID，获取私信内容
	local message = table.concat(args, " ") -- 连接剩余的参数作为私信内容
	TriggerServerEvent('to', targetid_whisper, message)
end)
RegisterCommand("pm", function(source, args)
	local targetid_whisper = tonumber(args[1]) -- 第一个参数为目标玩家ID
	table.remove(args, 1)                   -- 移除目标玩家ID，获取私信内容
	local message = table.concat(args, " ") -- 连接剩余的参数作为私信内容
	TriggerServerEvent('pm', targetid_whisper, message)
end)

RegisterCommand("f", function(source,args, rawCommand)
	local msg = rawCommand:sub(2)

    TriggerServerEvent('rpchat:jobchat',args, msg)
	print(msg)
end)

RegisterCommand("duty", function(source)
    -- 获取触发命令的玩家的 ped 对象
    local playerPed = GetPlayerPed(source)
    
    -- 获取玩家的三维坐标
    local coords = GetEntityCoords(playerPed, true)  -- true 表示获取世界坐标
    local x, y, z = coords.x, coords.y, coords.z
    
    -- 打印玩家的三维坐标
    print("Player's coordinates: X = " .. x .. ", Y = " .. y .. ", Z = " .. z)
    
    -- 获取街道名称
    local streetNameHash, crossingRoadHash = GetStreetNameAtCoord(x, y, z)
    local streetName = GetStreetNameFromHashKey(streetNameHash)
    local crossingRoad = GetStreetNameFromHashKey(crossingRoadHash)
    
    -- 打印街道名称
    print("Street Name: " .. streetName)
    print("Crossing Road: " .. crossingRoad)
    
    -- 触发服务器事件，并发送坐标和街道名称
    TriggerServerEvent('rpchat:duty', streetName, crossingRoad)
end, false)

local function GetPlayerStreetName(x, y, z)
    local streetNameHash, crossingRoadHash = GetStreetNameAtCoord(x, y, z)
    local streetName = GetStreetNameFromHashKey(streetNameHash)
    local crossingRoad = GetStreetNameFromHashKey(crossingRoadHash)
    local zone = GetNameOfZone(x, y, z)
    local street2 = crossingRoad == 0 and zone or crossingRoad

    return streetName, crossingRoad, zone, street2
end

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed, true)
        local streetName, crossingRoad, zone, street2 = GetPlayerStreetName(coords.x, coords.y, coords.z)

        -- 更新Rich Presence状态
        if streetName ~= nil then
            if IsPedOnFoot(playerPed) and not IsEntityInWater(playerPed) then
                if IsPedSprinting(playerPed) then
                    SetRichPresence("Sprinting down " .. streetName)
                elseif IsPedRunning(playerPed) then
                    SetRichPresence("Running down " .. streetName)
                elseif IsPedWalking(playerPed) then
                    SetRichPresence("Walking down " .. streetName)
                elseif IsPedStill(playerPed) then
                    SetRichPresence("Standing on " .. streetName)
                end
            elseif IsEntityInWater(playerPed) then
                SetRichPresence("Swimming around")
            end
        end
    end
end)
RegisterCommand('clear', function(source, args)
	TriggerEvent('chat:clear')
end, false)
