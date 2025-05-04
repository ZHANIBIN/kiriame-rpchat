local API = exports['kiriame_rpchat']:GetAPIInterface()
local PANIC_COLOR = { 255, 0, 0 }
local MESSAGE_COLOR = { 244, 237, 159 }

-- 定义无线电缓存
local RadioCache = {
    playerInfo = {},
    lastUpdate = {}
}

-- 无线电信息缓存
local RadioInfoCache = {}

-- 获取缓存的无线电信息
local function KiriameRPchat_GetCachedRadioInfo(citizenid)
    if not citizenid then return nil end
    
    -- 检查缓存是否有效（5分钟）
    if RadioInfoCache[citizenid] and 
       (os.time() - RadioInfoCache[citizenid].timestamp) < 300 then
        return RadioInfoCache[citizenid].data
    end
    
    -- 从数据库获取
    local result = exports.oxmysql:query_async('SELECT RadioInfo FROM players WHERE citizenid = ?', {citizenid})
    if result and result[1] then
        local radioInfo = json.decode(result[1].RadioInfo)
        RadioInfoCache[citizenid] = {
            data = radioInfo,
            timestamp = os.time()
        }
        return radioInfo
    end
    return nil
end

-- 检查频率是否受限
local function KiriameRPchat_IsRestrictedFrequency(frequency)
    local restrictedFrequencies = Config.RestrictedFrequencies or {}
    return restrictedFrequencies[frequency] or false
end

-- 初始化或更新无线电信息
local function KiriameRPchat_InitializeOrUpdateRadioInfo(source, channelSlot, frequency)
    local Player = API.getPlayerData(source)
    if not Player then return false end
    
    local citizenid = API.getPlayerIdentifier(source, 'license')
    if not citizenid then return false end
    
    local radioInfo = KiriameRPchat_GetCachedRadioInfo(citizenid) or {
        radiochannel = {},
        radiodepartment = { { id = 1, value = "none" } }
    }
    
    -- 检查频率是否受限
    if KiriameRPchat_IsRestrictedFrequency(frequency) then
        local job = API.getPlayerJob(source)
        if not job or not Config.AllowedJobs[job.name] then
            API.sendNotification(source, '你没有权限使用这个频率', 'error')
            return false
        end
    end
    
    -- 更新频道信息
    if not radioInfo.radiochannel then
        radioInfo.radiochannel = {}
    end
    
    -- 确保频道槽位存在
    while #radioInfo.radiochannel < channelSlot do
        table.insert(radioInfo.radiochannel, { id = #radioInfo.radiochannel + 1, value = -1 })
    end
    
    -- 更新指定频道的频率
    radioInfo.radiochannel[channelSlot].value = frequency
    
    -- 更新缓存
    RadioInfoCache[citizenid] = {
        data = radioInfo,
        timestamp = os.time()
    }
    
    -- 更新数据库
    exports.oxmysql:update('UPDATE players SET RadioInfo = ? WHERE citizenid = ?', {
        json.encode(radioInfo),
        citizenid
    })
    
    return true
end

-- 设置频率命令
KiriameRPchat_AddCommand('setfrequency', {
    help = '设置无线电频率',
    params = {
        { name = 'channelSlot', type = 'number', help = '频道槽位' },
        { name = 'frequency', type = 'number', help = '频率值' }
    }
}, function(source, args)
    if not args.channelSlot or not args.frequency then
        API.sendNotification(source, '用法: /setfrequency [频道槽位] [频率]', 'error')
        return
    end
    
    if KiriameRPchat_InitializeOrUpdateRadioInfo(source, args.channelSlot, args.frequency) then
        API.sendNotification(source, '频率设置成功', 'success')
    end
end)

-- 部门呼叫命令
KiriameRPchat_AddCommand('dep', {
    help = '部门呼叫',
    params = {
        { name = 'message', type = 'text', help = '要发送的消息' }
    }
}, function(source, args, raw)
    local Player = API.getPlayerData(source)
    if not Player then return end

    local message = string.sub(raw, 5) -- 移除 "/dep " 前缀
    if not message or message == "" then
        TriggerClientEvent('QBCore:Notify', source, "请输入要发送的消息", 'error')
        return
    end

    -- 获取发送者的目标部门
    local targetDepartment = Player.PlayerData.metadata.targetDepartment
    if not targetDepartment then
        TriggerClientEvent('QBCore:Notify', source, "请先使用 /setdep 设置目标部门", 'error')
        return
    end

    local data = {
        department = targetDepartment, -- 使用目标部门而不是发送者的职业
        message = message,
        source = source,
        senderJob = Player.PlayerData.job.name -- 添加发送者的职业信息
    }

    TriggerEvent('kiriame_rpchat:server:broadcastToDepartment', data)
end)

for i = 1, 10 do
    KiriameRPchat_AddCommand('r' .. i, {
        help = '无线电通信',
        params = { { name = 'message', type = 'text', help = '消息内容' } }
    }, function(source, args, raw)
        TriggerClientEvent('kiriame_rpchat:client:talkOnRadio', source, i, string.sub(raw, 4), source)

        local message = string.sub(raw, 4)
        local sourcePlayer = API.getPlayerData(source)
        if not sourcePlayer then return end
        
        local sourceCoords = sourcePlayer.PlayerData.position
        local sourceName = sourcePlayer.PlayerData.charinfo.firstname .. " " .. sourcePlayer.PlayerData.charinfo.lastname
        
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            if playerId ~= source then
                local Player = API.getPlayerData(playerId)
                if Player then
                    local playerCoords = Player.PlayerData.position
                    local distance = #(vector3(sourceCoords.x, sourceCoords.y, sourceCoords.z) - vector3(playerCoords.x, playerCoords.y, playerCoords.z))
                    
                    if distance <= 30.0 then
                        TriggerClientEvent('chat:addMessage', playerId, {
                            color = MESSAGE_COLOR,
                            multiline = true,
                            args = {string.format("(无线电) %s 说: %s", sourceName, message)}
                        })
                    end
                end
            end
        end
    end)
end

KiriameRPchat_AddCommand('panic', {
    help = '紧急按钮',
    params = {{ name = 'message', type = 'text', help = '消息内容' }}
}, function(source, args, raw)
    local message = string.sub(raw, 4)
    local sourcePlayer = API.getPlayerData(source)
    if not sourcePlayer then return end
    
    local sourceCoords = sourcePlayer.PlayerData.position
    local sourceName = sourcePlayer.PlayerData.charinfo.firstname .. " " .. sourcePlayer.PlayerData.charinfo.lastname
    
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        if playerId ~= source then
            local Player = API.getPlayerData(playerId)
            if Player then
                local playerCoords = Player.PlayerData.position
                local distance = #(vector3(sourceCoords.x, sourceCoords.y, sourceCoords.z) - vector3(playerCoords.x, playerCoords.y, playerCoords.z))
                
                if distance <= 30.0 then
                    TriggerClientEvent('chat:addMessage', playerId, {
                        color = PANIC_COLOR,
                        multiline = true,
                        args = {"紧急", string.format("[%s] 触发了紧急按钮: %s", sourceName, message)}
                    })
                end
            end
        end
    end
end)

-- 部门设置命令
KiriameRPchat_AddCommand('setdep', {
    help = '设置目标部门',
    params = {
        { name = 'department', type = 'string', help = '部门名称' }
    }
}, function(source, args)
    local Player = API.getPlayerData(source)
    if not Player then return end

    if not args.department then
        TriggerClientEvent('QBCore:Notify', source, "请指定部门名称", 'error')
        return
    end

    -- 将目标部门保存到玩家的元数据中
    Player.Functions.SetMetaData('targetDepartment', args.department)
    TriggerClientEvent('QBCore:Notify', source, string.format("已设置目标部门为: %s", args.department), 'success')
end)

RegisterNetEvent('kiriame_rpchat:server:printRadioMessage')
AddEventHandler('kiriame_rpchat:server:printRadioMessage', function(key, frequency, message, SenderTargetPlayerID, slot, senderName)
    local foundKey = nil
    -- 检查频率是否在配置中有对应的键
    for configKey, configFreq in pairs(Config.RestrictChannel or {}) do
        if configFreq == frequency then
            foundKey = configKey
            break
        end
    end

    local displayValue = foundKey or frequency
    local messageFormat = " ** [S:%d | CH:%s] %s :%s"

    TriggerClientEvent('chatMessage', source,
        string.format(messageFormat, key, displayValue, senderName or API.getPlayerCharname(SenderTargetPlayerID),
            message),
        MESSAGE_COLOR)
end)

RegisterNetEvent('kiriame_rpchat:server:policePanic')
AddEventHandler('kiriame_rpchat:server:policePanic', function(streetName, jobgradelabel, src)
    TriggerClientEvent('chatMessage', src,
        string.format(" %s %s 位于 %s 触发了紧急按钮！",
            jobgradelabel, API.getPlayerCharname(src), streetName),
        PANIC_COLOR)
end)

RegisterNetEvent('kiriame_rpchat:server:radioTalk')
AddEventHandler('kiriame_rpchat:server:radioTalk', function(source, message)
    if not message or message == '' then return end
    local players = GetPlayers()
    for _, player in ipairs(players) do
        TriggerClientEvent('kiriame_rpchat:client:radioTalk', player, message)
    end
end)

-- RegisterCommand('radioinfo', function(source)
--     TriggerEvent('kiriame_rpchat:server:getPlayerRadioInfo', source, source)
-- end)
KiriameRPchat_AddCommand('radioinfo', {
    help = 'radioinfotest',
    params = {}
}, function(source)
    TriggerEvent('kiriame_rpchat:server:getPlayerRadioInfo', source, source)
end)
RegisterNetEvent('QBCore:Server:OnPlayerLoaded')
AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    TriggerEvent('kiriame_rpchat:server:getPlayerRadioInfo', src, src)
end)

RegisterNetEvent('kiriame_rpchat:server:getPlayerRadioInfo')
AddEventHandler('kiriame_rpchat:server:getPlayerRadioInfo', function(TargetPlayerID)
    local requesterId = source
    local Player = API.getPlayerData(TargetPlayerID)
    
    if not Player then 
        TriggerClientEvent('kiriame_rpchat:client:receiveRadioInfo', requesterId, { error = "未找到玩家数据" })
        return 
    end

    local citizenid = Player.PlayerData.citizenid
    
    exports.oxmysql:query('SELECT RadioInfo FROM players WHERE `citizenid` = ?', { citizenid }, function(results)
        if not results then
            TriggerClientEvent('kiriame_rpchat:client:receiveRadioInfo', requesterId, { error = "数据库查询失败" })
            return
        end
        
        if #results == 0 then
            local defaultRadioInfo = {
                radiochannel = {},
                radiodepartment = { { id = 1, value = "none" } }
            }
            for i = 1, 10 do
                table.insert(defaultRadioInfo.radiochannel, { id = i, value = -1 })
            end

            exports.oxmysql:insert('INSERT INTO players (citizenid, RadioInfo) VALUES (?, ?)', {
                citizenid,
                json.encode(defaultRadioInfo)
            }, function(insertId)
                if insertId then
                    local simplifiedData = {
                        id = TargetPlayerID,
                        channel = defaultRadioInfo.radiochannel,
                        dep = defaultRadioInfo.radiodepartment[1].value
                    }
                    TriggerClientEvent('kiriame_rpchat:client:receiveRadioInfo', requesterId, simplifiedData)
                end
            end)
        else
            local radioInfo = json.decode(results[1].RadioInfo or '{}')
            
            if not radioInfo.radiochannel then
                radioInfo.radiochannel = {}
                for i = 1, 10 do
                    table.insert(radioInfo.radiochannel, { id = i, value = -1 })
                end
            end
            
            if not radioInfo.radiodepartment then
                radioInfo.radiodepartment = { { id = 1, value = "none" } }
            end
            
            local simplifiedData = {
                id = TargetPlayerID,
                channel = radioInfo.radiochannel,
                dep = radioInfo.radiodepartment[1].value
            }
            
            TriggerClientEvent('kiriame_rpchat:client:receiveRadioInfo', requesterId, simplifiedData)
        end
    end)
end)

-- 清理缓存
AddEventHandler('playerDropped', function()
    local source = source
    local Player = API.getPlayerData(source)
    if Player then
        local citizenid = Player.PlayerData.citizenid
        RadioCache.playerInfo[citizenid] = nil
        RadioCache.lastUpdate[citizenid] = nil
    end
end)

-- 玩家切换角色时清理缓存
AddEventHandler('QBCore:Server:OnPlayerUnload', function()
    local source = source
    local Player = API.getPlayerData(source)
    if Player then
        local citizenid = Player.PlayerData.citizenid
        RadioCache.playerInfo[citizenid] = nil
        RadioCache.lastUpdate[citizenid] = nil
    end
end)

-- 处理部门广播
RegisterNetEvent('kiriame_rpchat:server:broadcastToDepartment')
AddEventHandler('kiriame_rpchat:server:broadcastToDepartment', function(data)
    if not data or not data.department or not data.message then
        return
    end

    -- 获取发送者信息
    local sourcePlayer = API.getPlayerData(data.source)
    if not sourcePlayer then return end

    -- 获取所有玩家
    local players = API.getPlayers()

    -- 遍历所有玩家并发送消息给对应部门的玩家
    for _, playerId in ipairs(players) do
        local player = API.getPlayerData(playerId)
        if player then
            local messageData = {
                department = data.department,
                message = data.message,
                source = data.source,
                senderName = sourcePlayer.PlayerData.charinfo.firstname .. " " .. sourcePlayer.PlayerData.charinfo.lastname,
                senderJob = sourcePlayer.PlayerData.job.name -- 使用发送者的实际职业
            }
            
            -- 如果是目标部门的玩家或者是发送者自己，都发送消息
            if player.PlayerData.job.name == data.department or playerId == data.source then
                TriggerClientEvent('kiriame_rpchat:client:receiveDepartmentBroadcast', playerId, messageData)
            end
        end
    end
end)

RegisterNetEvent('kiriame_rpchat:server:radioMessage')
AddEventHandler('kiriame_rpchat:server:radioMessage', function(data)
    if not data or not data.frequency or not data.message then return end
    
    local players = GetPlayers()
    local sourcePlayer = API.getPlayerData(data.source)
    if not sourcePlayer then return end
    
    local sourceCoords = sourcePlayer.PlayerData.position
    local sourceName = sourcePlayer.PlayerData.charinfo.firstname .. " " .. sourcePlayer.PlayerData.charinfo.lastname
    
    for _, playerId in ipairs(players) do
        -- 忽略发送者自己
        if playerId ~= data.source then
            local Player = API.getPlayerData(playerId)
            if Player then
                local citizenid = Player.PlayerData.citizenid
                local cachedInfo = KiriameRPchat_GetCachedRadioInfo(citizenid)
                local playerCoords = Player.PlayerData.position
                
                -- 检查玩家是否在附近（30单位范围内）
                local distance = #(vector3(sourceCoords.x, sourceCoords.y, sourceCoords.z) - vector3(playerCoords.x, playerCoords.y, playerCoords.z))
                local isNearby = distance <= 30.0
                
                -- 检查玩家是否在相同频率上
                local isOnSameFrequency = false
                if cachedInfo then
                    for _, channel in ipairs(cachedInfo.radiochannel) do
                        if channel.value == data.frequency then
                            isOnSameFrequency = true
                            break
                        end
                    end
                end
                
                -- 如果在相同频率上，只发送无线电消息
                if isOnSameFrequency then
                    TriggerClientEvent('kiriame_rpchat:client:radioMessageReceived', playerId, {
                        frequency = data.frequency,
                        message = data.message,
                        source = data.source,
                        slot = data.slot,
                        senderName = sourceName,
                        messageType = "radio" -- 标记为无线电消息
                    })
                -- 如果不在相同频率上但在30米范围内，发送说话消息
                -- elseif isNearby then
                --     TriggerClientEvent('kiriame_rpchat:client:radioMessageReceived', playerId, {
                --         frequency = data.frequency,
                --         message = data.message,
                --         source = data.source,
                --         slot = data.slot,
                --         senderName = sourceName,
                --         messageType = "proximity" -- 标记为说话消息
                --     })
                end
            end
        end
    end
end)


