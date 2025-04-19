IsDisplayingText = false
--____________________________________________________________________________________________
-- @desc Client-side /me handling
-- @author Elio
-- @version 3.0

local peds = {}

-- Localization
local GetGameTimer = GetGameTimer

-- @desc Draw text in 3d
-- @param coords world coordinates to where you want to draw the text
-- @param text the text to display
function Draw3dText(coords, text)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    
    -- Experimental math to scale the text down
    local scale = 100 / (GetGameplayCamFov() * dist)

    -- Format the text
    SetTextColour(187, 160, 215, 255)
    SetTextScale(0.0, scale)
    SetTextFont(0)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    SetTextCentre(true)

    -- Diplay the text
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()

end

-- @desc Display the text above the head of a ped
-- @param ped the target ped
-- @param text the text to display
local c = {
    time = 5000,
    dist = 250,
}
local function displayText(ped, text)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local targetPos = GetEntityCoords(ped)
    local dist = #(playerPos - targetPos)
    local los = HasEntityClearLosToEntity(playerPed, ped, 17)

    if dist <= c.dist and los then
        local exists = peds[ped] ~= nil

        peds[ped] = {
            time = GetGameTimer() + c.time,
            text = text
        }

        if not exists then
            local display = true

            while display do
                Wait(0)
                local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 1.0)
                Draw3dText(pos, peds[ped].text)
                display = GetGameTimer() <= peds[ped].time
            end

            peds[ped] = nil
        end

    end
end

-- @desc Trigger the display of teh text for a player
-- @param text text to display
-- @param target the target server id
local function onShareDisplay(text, target)
    local player = GetPlayerFromServerId(target)
    if player ~= -1 or target == GetPlayerServerId(PlayerId()) then
        local ped = GetPlayerPed(player)
        displayText(ped, text)
    end
end

-- Register the event
RegisterNetEvent('3dme:shareDisplay', onShareDisplay)

--____________________________________________________________________________________________

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function()
    -- local PlayerId = GetPlayerServerId(source) -- 修复获取玩家ID的方式
    local PlayerId = GetPlayerServerId(PlayerId())
    -- 切换安全带的状态
    local newSeatbeltStatus = not seatbeltOn
    seatbeltOn = newSeatbeltStatus

    TriggerServerEvent('gtarpchat:seatbelt', seatbeltOn, PlayerId)
end)




RegisterNetEvent('weapons:client:DrawWeapon', function(weaponName)
    -- 获取当前玩家的ID
    local playerId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('gtarpchat:UseWeapon', playerId, weaponName)
end)

RegisterNetEvent('displayTextToPlayer')
AddEventHandler('displayTextToPlayer', function(text)
    -- 检查是否已经有文本正在显示
    if IsDisplayingText then
        -- 如果是，等待当前显示完成
        Citizen.CreateThread(function()
            while IsDisplayingText do
                Wait(100)
            end
            -- 上一个显示完成后，设置标志并显示新文本
            IsDisplayingText = true
            Wait(100)

            displayTextToPlayer(text)
            IsDisplayingText = false -- 显示完成后重置标志
        end)
    else
        -- 如果没有文本正在显示，直接显示新文本
        IsDisplayingText = true
        displayTextToPlayer(text)
        IsDisplayingText = false
    end
end)

-- 客户端事件监听
RegisterNetEvent('qb-vehiclekeys:client:ToggleEngine', function()
    local ped = PlayerPedId()
    local currVeh = GetVehiclePedIsIn(ped, false)
    local engineRunning = GetIsVehicleEngineRunning(currVeh)
    if engineRunning then
        TriggerServerEvent('gtarrpchat:ToggleEngine', engineRunning, currVeh, PlayerId)
    else
        TriggerServerEvent('gtarrpchat:ToggleEngine', engineRunning, currVeh, PlayerId)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(1)

        -- show blips
        for id = 0, 32 do
            if NetworkIsPlayerActive(id) then -- and GetPlayerPed( id ) ~= GetPlayerPed( -1 )
                ped = GetPlayerPed(id)
                --blip = GetBlipFromEntity( ped )

                -- HEAD DISPLAY STUFF --

                -- Create head display (this is safe to be spammed)
                if GetPlayerPed(id) ~= GetPlayerPed(-1) then
                    headDisplayId = N_0xbfefe3321a3f5015(ped, ".", false, false, "", false)
                end

                if (GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(GetPlayerPed(id))) < 30.0001) and HasEntityClearLosToEntity(GetPlayerPed(-1), GetPlayerPed(id), 17) then
                    N_0x63bb75abedc1f6a0(headDisplayId, 12, true)
                    N_0xd48fe545cd46f857(headDisplayId, 12, 255)
                else
                    N_0x63bb75abedc1f6a0(headDisplayId, 0, false)
                end

                if NetworkIsPlayerTalking(id) then
                    N_0x63bb75abedc1f6a0(headDisplayId, 12, true) -- Speaker
                    N_0xd48fe545cd46f857(headDisplayId, 12, 128) -- Alpha
                else
                    N_0x63bb75abedc1f6a0(headDisplayId, 12, false) -- Speaker Off
                end
            end
        end
    end
end)
