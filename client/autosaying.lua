local IsDisplayingText = false

local peds = {}

local GetGameTimer = GetGameTimer

function KiriameRPchat_Draw3dText(coords, text)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    
    local scale = 100 / (GetGameplayCamFov() * dist)

    SetTextColour(187, 160, 215, 255)
    SetTextScale(0.0, scale)
    SetTextFont(0)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    SetTextCentre(true)

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local config = {
    time = 5000,
    dist = 250,
}

local function KiriameRPchat_DisplayText(ped, text)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local targetPos = GetEntityCoords(ped)
    local dist = #(playerPos - targetPos)
    local los = HasEntityClearLosToEntity(playerPed, ped, 17)

    if dist <= config.dist and los then
        local exists = peds[ped] ~= nil

        peds[ped] = {
            time = GetGameTimer() + config.time,
            text = text
        }

        if not exists then
            local display = true

            while display do
                Wait(0)
                local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 1.0)
                KiriameRPchat_Draw3dText(pos, peds[ped].text)
                display = GetGameTimer() <= peds[ped].time
            end

            peds[ped] = nil
        end
    end
end

local function KiriameRPchat_DisplayTextLong(ped, text)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local targetPos = GetEntityCoords(ped)
    local dist = #(playerPos - targetPos)
    local los = HasEntityClearLosToEntity(playerPed, ped, 17)

    if dist <= config.dist and los then
        local exists = peds[ped] ~= nil

        peds[ped] = {
            time = GetGameTimer() + config.time,
            text = text
        }

        if not exists then
            local display = true

            while display do
                Wait(0)
                local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 1.0)
                if text and text ~= "" then
                    KiriameRPchat_Draw3dText(pos, peds[ped].text)
                end
                display = GetGameTimer() <= peds[ped].time
            end

            peds[ped] = nil
        end
    end
end


local function KiriameRPchat_OnShareDisplay(text, target)
    local player = GetPlayerFromServerId(target)
    if player ~= -1 or target == GetPlayerServerId(PlayerId()) then
        local ped = GetPlayerPed(player)
        KiriameRPchat_DisplayText(ped, text)
    end
end
local function KiriameRPchat_OnShareDisplayLong(text, target)
    local player = GetPlayerFromServerId(target)
    if player ~= -1 or target == GetPlayerServerId(PlayerId()) then
        local ped = GetPlayerPed(player)
        if text and text ~= "" then
            KiriameRPchat_DisplayTextLong(ped, text)
        else
            if peds[ped] then
                peds[ped] = nil
            end
        end
    end
end
RegisterNetEvent('kiriame_rpchat:client:shareDisplay', KiriameRPchat_OnShareDisplay)

RegisterNetEvent('kiriame_rpchat:client:shareDisplayLong', KiriameRPchat_OnShareDisplayLong)


RegisterNetEvent('kiriame_rpchat:client:toggleSeatbelt', function()
    local playerId = GetPlayerServerId(PlayerId())
    local newSeatbeltStatus = not seatbeltOn
    seatbeltOn = newSeatbeltStatus

    TriggerServerEvent('kiriame_rpchat:server:toggleSeatbelt', seatbeltOn, playerId)
end)

RegisterNetEvent('kiriame_rpchat:client:drawWeapon', function(weaponName)
    local playerId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('kiriame_rpchat:server:useWeapon', playerId, weaponName)
end)

RegisterNetEvent('kiriame_rpchat:client:displayText')
AddEventHandler('kiriame_rpchat:client:displayText', function(text)
    if IsDisplayingText then
        Citizen.CreateThread(function()
            while IsDisplayingText do
                Wait(100)
            end
            IsDisplayingText = true
            Wait(100)

            KiriameRPchat_DisplayText(PlayerPedId(), text)
            IsDisplayingText = false
        end)
    else
        IsDisplayingText = true
        KiriameRPchat_DisplayText(PlayerPedId(), text)
        IsDisplayingText = false
    end
end)

RegisterNetEvent('kiriame_rpchat:client:toggleEngine', function()
    local ped = PlayerPedId()
    local currVeh = GetVehiclePedIsIn(ped, false)
    local engineRunning = GetIsVehicleEngineRunning(currVeh)
    local playerId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('kiriame_rpchat:server:toggleEngine', engineRunning, currVeh, playerId)
end)

Citizen.CreateThread(function()
    while true do
        Wait(1)

        for id = 0, 32 do
            if NetworkIsPlayerActive(id) then
                ped = GetPlayerPed(id)

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
                    N_0x63bb75abedc1f6a0(headDisplayId, 12, true)
                    N_0xd48fe545cd46f857(headDisplayId, 12, 128)
                else
                    N_0x63bb75abedc1f6a0(headDisplayId, 12, false)
                end
            end
        end
    end
end)
