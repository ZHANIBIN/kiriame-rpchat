-- 服务器端代码
local QBCore = exports['qb-core']:GetCoreObject()

-- 显示文本到玩家
RegisterNetEvent('kiriame_rpchat:server:displayText')
AddEventHandler('kiriame_rpchat:server:displayText', function(text)
    TriggerClientEvent('kiriame_rpchat:client:displayText', source, text)
end)

-- 处理安全带事件
RegisterNetEvent('kiriame_rpchat:server:toggleSeatbelt')
AddEventHandler('kiriame_rpchat:server:toggleSeatbelt', function(seatbeltOn, playerId)
    local src = source
    local playerName = KiriameRPchat_GetPlayerCharname(src)
    local message = seatbeltOn and "系上了安全带" or "解开了安全带"
    DisplayMessageToNearbyPlayers(src, playerName .. " " .. message)
end)

-- 处理使用武器事件
RegisterNetEvent('kiriame_rpchat:server:useWeapon')
AddEventHandler('kiriame_rpchat:server:useWeapon', function(playerId, weaponName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerName = KiriameRPchat_GetPlayerCharname(src)
    local weaponItem = Player.Functions.GetItemByName(weaponName)
    if weaponName ~= nil then
        local message = "掏出了一把" .. weaponItem.label
        DisplayMessageToNearbyPlayers(src, playerName .. " " .. message)
    end
end)

-- 处理引擎切换事件
RegisterNetEvent('kiriame_rpchat:server:toggleEngine')
AddEventHandler('kiriame_rpchat:server:toggleEngine', function(engineRunning, currVeh, playerId)
    local src = source
    local playerName = KiriameRPchat_GetPlayerCharname(src)
    local message = engineRunning and "扭动车钥匙,试图发动车辆" or "关闭了引擎"
    DisplayMessageToNearbyPlayers(src, playerName .. " " .. message)
end)

