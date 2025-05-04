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

-- 职业名称转换配置表
local JobNameConfig = {
    ["police"] = "LSPD",
    ["ambulance"] = "LSFD",
    -- ["mechanic"] = "机修部",
    -- ["taxi"] = "出租车公司"
    -- 在这里添加更多职业配置
    -- ["job_name"] = "显示名称"
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
    
    -- 重置频道状态
    for i = 1, 10 do
        RadioState.channels[i] = nil
    end
    
    -- 更新部门信息
    RadioState.department = data.dep
    
    -- 更新频道信息
    for _, channel in ipairs(data.channel) do
        RadioState.channels[channel.id] = channel.value
    end
    
    -- 通知玩家同步完成
    QBCore.Functions.Notify("无线电信息已同步", 'success')
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
            if data.messageType == "radio" then
                -- 无线电消息格式 [S:]
                TriggerServerEvent('kiriame_rpchat:server:printRadioMessage', key, data.frequency, data.message, data.source,
                    data.slot, data.senderName)
            elseif data.messageType == "proximity" then
                -- 说话消息格式 (无线电)
                -- TriggerEvent('chat:addMessage', {
                --     color = {255, 255, 255},
                --     multiline = true,
                --     args = {string.format("(无线电) %s: %s", data.senderName, data.message)}
                -- })
            end
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
        local streetName, crossingRoad = GetStreetNameAtCoord(PlayerData.coords.x, PlayerData.coords.y,
            PlayerData.coords.z)
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
    KiriameRPchat_BroadcastToDepartment(RadioState.department, message)
end)

-- 转换职业名称
local function KiriameRPchat_ConvertJobName(jobName)
    return JobNameConfig[jobName] or jobName
end

-- 接收部门广播消息
RegisterNetEvent('kiriame_rpchat:client:receiveDepartmentBroadcast')
AddEventHandler('kiriame_rpchat:client:receiveDepartmentBroadcast', function(data)
    if not data or not data.department or not data.message then
        return
    end

    KiriameRPchat_UpdatePlayerData()
    local isSender = GetPlayerServerId(PlayerId()) == data.source

    -- 如果是目标部门的玩家或者是发送者自己，都显示消息
    if (PlayerData.job and PlayerData.job.name == data.department) or isSender then
        local senderJobDisplay = KiriameRPchat_ConvertJobName(data.senderJob)
        local targetJobDisplay = KiriameRPchat_ConvertJobName(data.department)
        local message = string.format("[%s -> %s] %s: %s", senderJobDisplay, targetJobDisplay, data.senderName, data.message)
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0}, -- 黄色
            multiline = true,
            args = {message}
        })
    end
end)

-- 注册事件
RegisterNetEvent('kiriame_rpchat:client:setRadioFrequency', KiriameRPchat_SetRadioFrequency)
RegisterNetEvent('kiriame_rpchat:client:talkOnRadio', KiriameRPchat_TalkOnRadio)

-- 玩家加载时获取无线电信息
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local serverId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('kiriame_rpchat:server:getPlayerRadioInfo', serverId)
end)

-- 资源启动时获取无线电信息
AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    local serverId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('kiriame_rpchat:server:getPlayerRadioInfo', serverId)
end)

-- RegisterCommand('clientradioinfo', function(source)
--     local data = RadioState
--     for _, channels in ipairs(data.channels) do
--         print(channels.id, channels.value)
--     end
-- end)

-- RegisterCommand('jobhelp', function()
--     QBCore.Functions.Notify("使用 /job [消息] 向相同职业的玩家发送消息", 'primary')
-- end)

-- -- 部门呼叫命令
-- RegisterCommand('dep', function(source, args, raw)
--     if not args[1] then
--         QBCore.Functions.Notify("请指定目标部门", 'error')
--         return
--     end
    
--     local message = table.concat(args, " ", 2)
--     if not message or message == "" then
--         QBCore.Functions.Notify("请输入要发送的消息", 'error')
--         return
--     end
    
--     if not RadioState.department then
--         QBCore.Functions.Notify("请先使用 /setdep 设置目标部门", 'error')
--         return
--     end
    
--     local data = {
--         department = RadioState.department,
--         message = message,
--         source = GetPlayerServerId(PlayerId())
--     }
    
--     TriggerServerEvent('kiriame_rpchat:server:broadcastToDepartment', data)
-- end)

-- -- 部门设置命令
-- RegisterCommand('setdep', function(source, args)
--     if not args[1] then
--         QBCore.Functions.Notify("请指定部门名称", 'error')
--         return
--     end
    
--     local department = args[1]
--     RadioState.department = department
--     QBCore.Functions.Notify(string.format("已设置目标部门为: %s", department), 'success')
-- end)

-- 广播消息给相同部门的玩家
RegisterNetEvent('kiriame_rpchat:server:broadcastToDepartment')
AddEventHandler('kiriame_rpchat:server:broadcastToDepartment', function(message)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerName = KiriameRPchat_GetPlayerCharname(src)
    local department = Player.PlayerData.job.name

    -- 获取所有在线玩家
    local players = QBCore.Functions.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetPlayer = QBCore.Functions.GetPlayer(playerId)
        if targetPlayer and targetPlayer.PlayerData.job.name == department then
            -- 发送消息给相同部门的玩家
            TriggerClientEvent('kiriame_rpchat:client:displayText', playerId, string.format("[%s] %s: %s", department, playerName, message))
        end
    end
end)
