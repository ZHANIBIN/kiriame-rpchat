local QBCore = exports['qb-core']:GetCoreObject()

-- 使用表来存储无线电频道信息
local RadioState = {
    channels = {},
    department = nil
}

-- 初始化无线电频道
for i = 1, 10 do
    RadioState.channels[i] = nil
end

-- 缓存玩家数据
local PlayerData = {
    job = nil,
    coords = nil
}

-- 更新玩家数据
local function KiriameRPchat_UpdatePlayerData()
    local player = QBCore.Functions.GetPlayerData()
    if player then
        PlayerData.job = player.job
        local playerPed = PlayerPedId()
        PlayerData.coords = GetEntityCoords(playerPed, true)
    end
end

-- 向特定部门广播消息
local function KiriameRPchat_BroadcastToDepartment(department, message)
    if not department or not message then
        QBCore.Functions.Notify("部门或消息不能为空", 'error')
        return
    end
    
    KiriameRPchat_UpdatePlayerData()
    
    if PlayerData.job and PlayerData.job.name == department then
        local data = {
            department = department,
            message = message,
            source = GetPlayerServerId(PlayerId())
        }
        
        TriggerServerEvent('kiriame_rpchat:server:broadcastToDepartment', data)
    else
        QBCore.Functions.Notify("您不属于该部门，无法发送广播", 'error')
    end
end

-- 接收无线电信息
RegisterNetEvent('kiriame_rpchat:client:receiveRadioInfo')
AddEventHandler('kiriame_rpchat:client:receiveRadioInfo', function(data)
    if data.error then
        QBCore.Functions.Notify(data.error, 'error')
        return
    end
    
    RadioState.department = data.dep
    for _, channel in ipairs(data.channel) do
        RadioState.channels[channel.id] = channel.value
    end
end)

-- 设置无线电频率
local function KiriameRPchat_SetRadioFrequency(slot, frequency)
    if not slot or slot < 1 or slot > 10 then
        QBCore.Functions.Notify("无效的频道槽位!", 'error')
        return
    end
    
    RadioState.channels[slot] = frequency
    QBCore.Functions.Notify(string.format("将无线电 %d 槽位设置为 %d", slot, frequency), 'success')
end

-- 通过无线电发送消息
local function KiriameRPchat_TalkOnRadio(slot, message, source)
    if not slot or slot < 1 or slot > 10 then
        QBCore.Functions.Notify("无效的频道槽位!", 'error')
        return
    end
    
    if not RadioState.channels[slot] then
        QBCore.Functions.Notify("该频道未设置频率!", 'error')
        return
    end
    
    local data = {
        frequency = RadioState.channels[slot],
        message = message,
        source = source,
        slot = slot
    }
    
    TriggerServerEvent('kiriame_rpchat:server:radioMessage', data)
    TriggerEvent('kiriame_rpchat:client:radioMessageReceived', data)
end

-- 接收无线电消息
RegisterNetEvent('kiriame_rpchat:client:radioMessageReceived')
AddEventHandler('kiriame_rpchat:client:radioMessageReceived', function(data)
    if not data or not data.frequency then
        QBCore.Functions.Notify("接收到的数据无效", 'error')
        return
    end
    
    local matchingKey = nil
    for key, frequency in pairs(RadioState.channels) do
        if frequency and data.frequency == frequency then
            TriggerServerEvent('kiriame_rpchat:server:printRadioMessage', key, data.frequency, data.message, data.source, data.slot)
            matchingKey = key
            break
        end
    end
    
    if not matchingKey then
        QBCore.Functions.Notify(string.format("未找到匹配的频率: %d", data.frequency), 'error')
    end
end)

-- 警察紧急按钮
RegisterNetEvent('kiriame_rpchat:client:policePanic')
AddEventHandler('kiriame_rpchat:client:policePanic', function(source)
    KiriameRPchat_UpdatePlayerData()
    
    if PlayerData.job and PlayerData.job.type == "leo" then
        local streetName, crossingRoad = GetStreetNameAtCoord(PlayerData.coords.x, PlayerData.coords.y, PlayerData.coords.z)
        streetName = GetStreetNameFromHashKey(streetName)
        
        TriggerServerEvent('kiriame_rpchat:server:policePanic', streetName, PlayerData.job.grade.name, source)
    end
end)

-- 部门设置
RegisterNetEvent('kiriame_rpchat:client:setDepartment')
AddEventHandler('kiriame_rpchat:client:setDepartment', function(department)
    RadioState.department = department
    QBCore.Functions.Notify(string.format("已设置部门为: %s", department), 'success')
end)

RegisterNetEvent('kiriame_rpchat:client:departmentMessage')
AddEventHandler('kiriame_rpchat:client:departmentMessage', function(message)
    RadioState.department = department
    print(RadioState.department,message)
    KiriameRPchat_BroadcastToDepartment(RadioState.department,message)
end)

-- 接收部门广播消息
RegisterNetEvent('kiriame_rpchat:client:receiveDepartmentBroadcast')
AddEventHandler('kiriame_rpchat:client:receiveDepartmentBroadcast', function(data)
    if not data or not data.department or not data.message then
        return
    end
    
    KiriameRPchat_UpdatePlayerData()
    
    if PlayerData.job and PlayerData.job.name == data.department then
        QBCore.Functions.Notify(string.format("[%s] %s", data.department, data.message), 'primary')
    end
end)

-- 注册事件
RegisterNetEvent('kiriame_rpchat:client:setRadioFrequency', KiriameRPchat_SetRadioFrequency)
RegisterNetEvent('kiriame_rpchat:client:talkOnRadio', KiriameRPchat_TalkOnRadio)

-- 玩家加载时获取无线电信息
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local PlayerID = PlayerId()
    TriggerServerEvent('kiriame_rpchat:server:getPlayerRadioInfo', PlayerID)
end)

-- 定期更新玩家数据
CreateThread(function()
    while true do
        KiriameRPchat_UpdatePlayerData()
        Wait(5000) -- 每5秒更新一次
    end
end)
