-- 服务器端代码
local QBCore = exports['qb-core']:GetCoreObject()



-- 显示文本到玩家
RegisterServerEvent('displayTextToPlayer')
AddEventHandler('displayTextToPlayer', function(text)
    TriggerClientEvent('displayTextToPlayer', source, text)
end)

-- 处理安全带事件
RegisterServerEvent('gtarpchat:seatbelt')
AddEventHandler('gtarpchat:seatbelt', function(seatbeltOn, PlayerId)
    local src = source
    local playerName = GetPlayerCharname(src)
    local message = seatbeltOn and "系上了安全带" or "解开了安全带"
    DisplayMessageToNearbyPlayers(src, playerName .. " " .. message)
end)

-- 处理使用武器事件
RegisterServerEvent('gtarpchat:UseWeapon')
AddEventHandler('gtarpchat:UseWeapon', function(playerId, weaponName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerName = GetPlayerCharname(src)
    local HandweaponName = Player.Functions.GetItemByName(weaponName)
    if weaponName ~= nil then
        local message = "掏出了一把" .. HandweaponName.label
        DisplayMessageToNearbyPlayers(src, playerName .. " " .. message)
    end
end)

-- 处理引擎切换事件
RegisterServerEvent('gtarrpchat:ToggleEngine')
AddEventHandler('gtarrpchat:ToggleEngine', function(engineRunning, currVeh, PlayerId)
    local src = source
    local playerName = GetPlayerCharname(src)
    local message = engineRunning and "扭动车钥匙,试图发动车辆" or "关闭了引擎"
    DisplayMessageToNearbyPlayers(src, playerName .. " " .. message)
end)
