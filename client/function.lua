function displayTextToPlayer(text)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local dist = 10.0        -- 假设最大显示距离为10米
    local displayTime = 1000 -- 显示时间为5000毫秒（5秒）

    if IsDisplayingText then
        -- 停止当前的文本显示
        IsDisplayingText = false
    end

    -- 检查玩家是否在指定的距离内
    if GetDistanceBetweenCoords(playerPos, playerPos, true) < dist then
        local startTime = GetGameTimer()

        -- 设置正在显示文本的标志
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


            Wait(0) -- 让出时间给其他脚本操作
        end
        -- 显示完成后重置标志
        IsDisplayingText = false
    end
end

-- -- 设置无线电频率
-- function SetRadioFrequency(slot, frequency)
--     if slot >= 0 and slot <= 10 then
--         -- 设置频率，无论slot是否已经被占用
--         RadioChannels[slot] = frequency
--         TriggerEvent('QBCore:Notify', "将无线电" .. slot .. " 槽位设置为 " .. frequency, 'success')
--     else
--         TriggerEvent('QBCore:Notify', "频道不存在!", 'error')
--     end
-- end

-- -- 定义无线电频道数量常量
-- local MAX_RADIO_CHANNELS = 10

-- -- 初始化无线电频道表
-- local RadioChannels = {}
-- for i = 1, MAX_RADIO_CHANNELS do
--     RadioChannels[i] = nil
-- end


-- -- 通过无线电发送消息的函数
-- function TalkOnRadio(slot, message, source)
--     if slot >= 1 and slot <= 10 then
--         if RadioChannels[slot] ~= nil then
--             local data = {
--                 frequency = RadioChannels[slot],
--                 message = message,
--                 source = source
--             }

--             -- 触发服务器事件并发送数据表
--             TriggerServerEvent('radioMessage', data)
--         else
--         end
--     else
--     end
-- end

function ClientDebugPrint(message)
    local Debug = false
    if Debug then
        print(message)
    else
        return
    end
end

