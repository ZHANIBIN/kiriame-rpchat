-- 服务器端代码
local QBCore = exports['qb-core']:GetCoreObject()
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
local function GetPlayerCharname(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    return PlayerName
end
RegisterServerEvent('displayTextToPlayer')
AddEventHandler('displayTextToPlayer', function(text)
    TriggerClientEvent('displayTextToPlayer', source, text)
end)
RegisterServerEvent('gtarpchat:seatbelt')
AddEventHandler('gtarpchat:seatbelt', function(seatbeltOn, PlayerId)
    local src = source
    local Players = GetPlayers()
    local Player = QBCore.Functions.GetPlayer(src)
    local playerName = GetPlayerCharname(src) -- 修复获取玩家名称的方式
    local message = seatbeltOn and "系上了安全带" or "解开了安全带"
    local Outputmessage = Config.Time .. '*' .. playerName .. " " .. message
    for _, targetid in ipairs(Players) do
        if Distance(src, targetid) <= 10 then
            if DoesPlayerExist(targetid) then
                    TriggerClientEvent('3dme:shareDisplay', targetid, '*' .. message,src)
            end
        end
    end
end)
RegisterServerEvent('gtarpchat:UseWeapon')
AddEventHandler('gtarpchat:UseWeapon', function(playerId, weaponName)
    local src = source
    local Players = GetPlayers()
    local Player = QBCore.Functions.GetPlayer(src)
    local playerName = GetPlayerCharname(src) -- 修复获取玩家名称的方式
    local HandweaponName = Player.Functions.GetItemByName(weaponName)
    if weaponName ~= nil then
        local Outputmessage = Config.Time .. '*' .. playerName .. " 掏出了一把" .. HandweaponName.label
        for _, targetid in ipairs(Players) do
            if Distance(src, targetid) <= 10 then
                if DoesPlayerExist(targetid) then
                    TriggerClientEvent('3dme:shareDisplay', targetid, '*' .. "掏出了一把" .. HandweaponName.label,src)
                end
            end
        end
    else
    end
end)

RegisterServerEvent('gtarrpchat:ToggleEngine')
AddEventHandler('gtarrpchat:ToggleEngine', function(engineRunning, currVeh, PlayerId)
    local src = source
    local Players = GetPlayers()
    local Player = QBCore.Functions.GetPlayer(src)
    local playerName = GetPlayerCharname(src) -- 修复获取玩家名称的方式
    local message = engineRunning and "扭动车钥匙,试图发动车辆" or "关闭了引擎"
    local Outputmessage = Config.Time .. '*' .. playerName .. " " .. message
    -- 遍历所有玩家
    for _, targetid in ipairs(Players) do
        if Distance(src, targetid) <= 10 then
            if DoesPlayerExist(targetid) then
                TriggerClientEvent('3dme:shareDisplay', targetid, '*' .. message,src)
            end
        end
    end
end)



