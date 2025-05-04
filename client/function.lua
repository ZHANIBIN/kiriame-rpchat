function KiriameRPchat_DisplayTextToPlayer(text)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local dist = 10.0
    local displayTime = 1000

    if IsDisplayingText then
        IsDisplayingText = false
    end

    if GetDistanceBetweenCoords(playerPos, playerPos, true) < dist then
        local startTime = GetGameTimer()

        IsDisplayingText = true

        while (GetGameTimer() - startTime) < displayTime do
            local camCoords = GetGameplayCamCoord()
            local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.0, 1.0)
            local dist = #(coords - camCoords)
            local scale = 100 / (GetGameplayCamFov() * dist)

            SetTextColour(187, 160, 215, 255)
            SetTextScale(0.0, scale)
            SetTextFont(0)
            SetTextOutline()

            SetTextEdge(2, 0, 0, 0, 150)
            SetTextDropshadow(255, 255, 255, 255, 55)
            SetTextCentre(true)

            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(text)
            SetDrawOrigin(coords)
            EndTextCommandDisplayText(0.0, 0.0)
            ClearDrawOrigin()

            Wait(0)
        end
        IsDisplayingText = false
    end
end
