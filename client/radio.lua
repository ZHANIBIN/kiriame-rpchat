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
local function Setradiofrequency(slot, frequency)
    if slot >= 0 and slot <= 10 then
        -- 设置频率，无论slot是否已经被占用
        RadioChannels[slot] = frequency
        TriggerEvent('QBCore:Notify', "将无线电" .. slot .. " 槽位设置为 " .. frequency, 'success')
    else
        TriggerEvent('QBCore:Notify', "频道不存在!", 'error')
    end
end
local function Talkonradio(slot, message, source)
    if slot >= 1 and slot <= 10 then
        if RadioChannels[slot] ~= nil then
            local data = {
                frequency = RadioChannels[slot],
                message = message,
                source = source
            }

            -- 触发服务器事件并发送数据表
            TriggerServerEvent('radioMessage', data)
        else
        end
    else
    end
end
-- Register the event

RegisterNetEvent('rpchat:radio:setfrequency', Setradiofrequency)
RegisterNetEvent('rpchat:radio:talkonradio', Talkonradio)
-- 客户端代码
RegisterNetEvent('radioMessage:receive')
AddEventHandler('radioMessage:receive', function(data)
    -- 处理接收到的数据
    -- 假设 data 是一个包含 frequency 和 message 字段的表
    if data and data.frequency then
        local frequencyMatched = false
        local matchingKey = nil
        for key, frequency in pairs(RadioChannels) do
            if frequency ~= nil and data.frequency == frequency then
                TriggerServerEvent('gtarrpchat:radio:messageprint', key, data.frequency, data.message, data.source)

                frequencyMatched = true
                matchingKey = key
                break -- 找到匹配的频率后就跳出循环
            end
        end

        if not frequencyMatched then
        else

        end
    else
    end
end)
RegisterNetEvent('gtar:rpchat:radiopolicepanic')
AddEventHandler('gtar:rpchat:radiopolicepanic', function(source)
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
