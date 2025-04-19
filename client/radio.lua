local RadioChannels = {
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
    [6] = nil,
    [7] = nil,
    [8] = nil,
    [9] = nil,
    [10] = nil,
}

-- Register the event
-- 设置无线电频率
local function SetRadioFrequency(slot, frequency)
    if slot >= 0 and slot <= 10 then
        -- 设置频率，无论slot是否已经被占用
        RadioChannels[slot] = frequency
        TriggerEvent('QBCore:Notify', "将无线电" .. slot .. " 槽位设置为 " .. frequency, 'success')
    else
        TriggerEvent('QBCore:Notify', "频道不存在!", 'error')
    end
end
-- 通过无线电发送消息的函数
local function TalkOnRadio(slot, message, source)
    if slot >= 1 and slot <= 10 then
        if RadioChannels[slot] ~= nil then
            local data = {
                frequency = RadioChannels[slot],
                message = message,
                source = source,
                slot = slot
            }

            -- 触发服务器事件并发送数据表
            TriggerServerEvent('radioMessage', data)
        else
        end
    else
    end
end

RegisterNetEvent('kiriame_rpchat:radio:setfrequency', SetRadioFrequency)
RegisterNetEvent('kiriame_rpchat:radio:talkonradio', TalkOnRadio)
-- 客户端代码
RegisterNetEvent('kiriame_rpchat:radio:messagereceived')
AddEventHandler('kiriame_rpchat:radio:messagereceived', function(data)
    print(data.frequency, data.message, data.source,data.slot)

    if data and data.frequency then
        local matchingKey = nil
        for key, frequency in pairs(RadioChannels) do
            if frequency ~= nil and data.frequency == frequency then
                TriggerServerEvent('kiriame_rpchat:radio:message_print', key, data.frequency, data.message, data.source,data.slot)
                matchingKey = key
                break
            end
        end

        if not matchingKey then
            -- 处理未匹配频率的情况
            print("未找到匹配的频率: " .. data.frequency)
            -- 可以在这里添加更多逻辑，比如通知客户端用户
        end
    else
        -- 处理数据不包含频率的情况
        print("接收到的数据不包含频率信息")
        -- 可以在这里添加更多逻辑，比如通知客户端用户
    end
end)

RegisterNetEvent('kiriame_rpchat:radiopolicepanic')
AddEventHandler('kiriame_rpchat:radiopolicepanic', function(source)
    local src =source
    local Player = QBCore.Functions.GetPlayerData()
    local jobName = Player.job.name
    local jobType = Player.job.type
    local jobgradelabel = Player.job.grade.name
    local joblabel = Player.job.label
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed, true)
    local x, y, z = coords.x, coords.y, coords.z
    local streetNameHash, crossingRoadHash = GetStreetNameAtCoord(x, y, z)
    local streetName = GetStreetNameFromHashKey(streetNameHash)
    local crossingRoad = GetStreetNameFromHashKey(crossingRoadHash)
    if Player.job.type == "leo" then
        TriggerServerEvent('gtarrpchat:radio:policepanic', streetName,jobgradelabel,src)
    else
    end
end)