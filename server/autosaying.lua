-- 服务器端代码
local QBCore = exports['qb-core']:GetCoreObject()

-- 显示文本到玩家
RegisterServerEvent('kiriame_rpchat:server:displayText')
AddEventHandler('kiriame_rpchat:server:displayText', function(text)
    TriggerClientEvent('kiriame_rpchat:client:displayText', source, text)
end)

-- 处理安全带事件
RegisterServerEvent('kiriame_rpchat:server:toggleSeatbelt')
AddEventHandler('kiriame_rpchat:server:toggleSeatbelt', function(seatbeltOn, playerId)
    local src = source
    local playerName = GetPlayerCharname(src)
    local message = seatbeltOn and "系上了安全带" or "解开了安全带"
    DisplayMessageToNearbyPlayers(src, playerName .. " " .. message)
end)

-- 处理使用武器事件
RegisterServerEvent('kiriame_rpchat:server:useWeapon')
AddEventHandler('kiriame_rpchat:server:useWeapon', function(playerId, weaponName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerName = GetPlayerCharname(src)
    local weaponItem = Player.Functions.GetItemByName(weaponName)
    if weaponName ~= nil then
        local message = "掏出了一把" .. weaponItem.label
        DisplayMessageToNearbyPlayers(src, playerName .. " " .. message)
    end
end)

-- 处理引擎切换事件
RegisterServerEvent('kiriame_rpchat:server:toggleEngine')
AddEventHandler('kiriame_rpchat:server:toggleEngine', function(engineRunning, currVeh, playerId)
    local src = source
    local playerName = GetPlayerCharname(src)
    local message = engineRunning and "扭动车钥匙,试图发动车辆" or "关闭了引擎"
    DisplayMessageToNearbyPlayers(src, playerName .. " " .. message)
end)

-- 广播消息给相同部门的玩家
RegisterServerEvent('kiriame_rpchat:server:broadcastToDepartment')
AddEventHandler('kiriame_rpchat:server:broadcastToDepartment', function(message)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerName = GetPlayerCharname(src)
    local department = Player.PlayerData.job.name

    -- 获取所有在线玩家
    local players = QBCore.Functions.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetPlayer = QBCore.Functions.GetPlayer(playerId)
        if targetPlayer and targetPlayer.PlayerData.job.name == department then
            -- 发送消息给相同部门的玩家
            TriggerClientEvent('kiriame_rpchat:client:displayText', playerId, string.format("[%s] %s: %s", department, playerName, message))
        end
    end
end)
