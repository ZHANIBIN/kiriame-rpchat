local QBCore = exports['qb-core']:GetCoreObject()
local PANIC_COLOR = { 255, 0, 0 }
local MESSAGE_COLOR = { 244, 237, 159 }
local CACHE_DURATION = 300 -- 5分钟缓存时间

-- 缓存系统
local RadioCache = {
    playerInfo = {},
    lastUpdate = {}
}

-- 检查是否是限制频率
local function KiriameRPchat_IsRestrictedFrequency(frequency)
    for k, v in pairs(Config.RestrictChannel) do
        if v == frequency then
            return true, k
        end
    end
    return false, nil
end

-- 获取缓存的无线电信息
local function KiriameRPchat_GetCachedRadioInfo(citizenid)
    local currentTime = os.time()
    if RadioCache.playerInfo[citizenid] and RadioCache.lastUpdate[citizenid] and 
       (currentTime - RadioCache.lastUpdate[citizenid]) < CACHE_DURATION then
        return RadioCache.playerInfo[citizenid]
    end
    return nil
end

-- 更新缓存
local function KiriameRPchat_UpdateCache(citizenid, radioInfo)
    RadioCache.playerInfo[citizenid] = radioInfo
    RadioCache.lastUpdate[citizenid] = os.time()
end

-- 初始化或更新无线电信息
local function KiriameRPchat_InitializeOrUpdateRadioInfo(radioInfo, slot, frequency, citizenid, src, jobType)
    if not radioInfo.radiochannel then
        radioInfo.radiochannel = {}
        for i = 1, 10 do
            table.insert(radioInfo.radiochannel, { id = i, value = -1 })
        end
    end
    
    local slotUpdated = false
    for _, channel in ipairs(radioInfo.radiochannel) do
        if channel.id == slot then
            channel.value = frequency
            slotUpdated = true
            break
        end
    end
    
    if not slotUpdated then
        table.insert(radioInfo.radiochannel, { id = slot, value = frequency })
    end
    
    local isRestricted, foundKey = KiriameRPchat_IsRestrictedFrequency(frequency)
    if isRestricted then
        if jobType == "leo" then
            MySQL.update('UPDATE players SET RadioInfo = ? WHERE citizenid = ?', {
                json.encode(radioInfo),
                citizenid
            }, function(affectedRows)
                if affectedRows > 0 then
                    KiriameRPchat_UpdateCache(citizenid, radioInfo)
                    TriggerClientEvent('kiriame_rpchat:client:setRadioFrequency', src, slot, frequency)
                end
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, "你无法加入一个被加密的频道！", 'warn', 5000)
        end
    else
        MySQL.update('UPDATE players SET RadioInfo = ? WHERE citizenid = ?', {
            json.encode(radioInfo),
            citizenid
        }, function(affectedRows)
            if affectedRows > 0 then
                KiriameRPchat_UpdateCache(citizenid, radioInfo)
                TriggerClientEvent('kiriame_rpchat:client:setRadioFrequency', src, slot, frequency)
            end
        end)
    end
end

KiriameRPchat_AddCommand('setfrequency', {
    help = '设置无线电频率',
    params = {
        { name = 'slot', type = 'number', help = '频道槽位' },
        { name = 'frequency', type = 'number', help = '频率值' }
    },
}, function(source, args)
    -- local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local jobType = Player.PlayerData.job.type
    local citizenid = Player.PlayerData.citizenid
    
    -- 检查缓存
    local cachedInfo = KiriameRPchat_GetCachedRadioInfo(citizenid)
    if cachedInfo then
        KiriameRPchat_InitializeOrUpdateRadioInfo(cachedInfo, args.slot, args.frequency, citizenid, source, jobType)
        return
    end
    
    MySQL.query('SELECT RadioInfo FROM players WHERE `citizenid` = ?', { citizenid }, function(results)
        if results and #results > 0 then
            local radioInfo = json.decode(results[1].RadioInfo or '{}')
            KiriameRPchat_InitializeOrUpdateRadioInfo(radioInfo, args.slot, args.frequency, citizenid, source, jobType)
        else
            local defaultRadioInfo = {
                radiochannel = { { id = args.slot, value = args.frequency } },
                radiodepartment = { { id = 1, value = "none" } }
            }
            MySQL.insert('INSERT INTO players (citizenid, RadioInfo) VALUES (?, ?)', {
                citizenid,
                json.encode(defaultRadioInfo)
            }, function(insertId)
                if insertId then
                    KiriameRPchat_UpdateCache(citizenid, defaultRadioInfo)
                    TriggerClientEvent('kiriame_rpchat:client:setRadioFrequency', source, args.slot, args.frequency)
                end
            end)
        end
    end)
end)

KiriameRPchat_AddCommand('dep', { 
    help = '部门呼叫',
    params = { { name = 'chat', type = 'text', help = '部门名称' } } 
}, function(source, args, raw)
    TriggerClientEvent('kiriame_rpchat:client:departmentMessage', source, string.sub(raw, 4))
end)

for i = 1, 10 do
    KiriameRPchat_AddCommand('r' .. i, { 
        help = '无线电通信',
        params = { { name = 'message', type = 'text', help = '消息内容' } } 
    }, function(source, args, raw)
        TriggerClientEvent('kiriame_rpchat:client:talkOnRadio', source, i, string.sub(raw, 4), source)
    end)
end

KiriameRPchat_AddCommand('panic', { 
    help = '紧急按钮',
    params = {} 
}, function(source)
    TriggerClientEvent('kiriame_rpchat:client:policePanic', source)
end)

KiriameRPchat_AddCommand('setdep', {
    help = '设置部门',
    params = { { name = 'department', type = 'string', help = '部门名称' } }
}, function(source, args)
    TriggerClientEvent('kiriame_rpchat:client:setDepartment', source, args.department)
end)

RegisterServerEvent('kiriame_rpchat:server:printRadioMessage')
AddEventHandler('kiriame_rpchat:server:printRadioMessage', function(key, frequency, message, SenderTargetPlayerID)
    local isRestricted, foundKey = KiriameRPchat_IsRestrictedFrequency(frequency)
    local messageFormat = isRestricted and 
        " ** [S:%d | CH:%s] %s :%s" or 
        " ** [S:%d | CH:%d] %s :%s"
    
    TriggerClientEvent('chatMessage', source,
        string.format(messageFormat, key, foundKey or frequency, KiriameRPchat_GetPlayerCharname(SenderTargetPlayerID), message),
        MESSAGE_COLOR)
end)

RegisterServerEvent('kiriame_rpchat:server:policePanic')
AddEventHandler('kiriame_rpchat:server:policePanic', function(streetName, jobgradelabel, src)
    TriggerClientEvent('chatMessage', src,
        string.format(" %s %s 位于 %s 触发了紧急按钮！", 
            jobgradelabel, KiriameRPchat_GetPlayerCharname(src), streetName),
        PANIC_COLOR)
end)

RegisterServerEvent('kiriame_rpchat:server:radioTalk')
AddEventHandler('kiriame_rpchat:server:radioTalk', function(source, message)
    if not message or message == '' then return end
    local players = GetPlayers()
    for _, player in ipairs(players) do
        TriggerClientEvent('kiriame_rpchat:client:radioTalk', player, message)
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded')
AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    TriggerEvent('kiriame_rpchat:server:getPlayerRadioInfo', src)
end)

RegisterCommand('radioinfo', function(source)
    TriggerEvent('kiriame_rpchat:server:getPlayerRadioInfo', source, source)
end)

RegisterServerEvent('kiriame_rpchat:server:getPlayerRadioInfo')
AddEventHandler('kiriame_rpchat:server:getPlayerRadioInfo', function(TargetPlayerID)
    local requesterId = source
    local Player = QBCore.Functions.GetPlayer(TargetPlayerID)
    
    if not Player then 
        TriggerClientEvent('kiriame_rpchat:client:receiveRadioInfo', requesterId, { error = "未找到玩家数据" })
        return 
    end

    local citizenid = Player.PlayerData.citizenid
    
    -- 检查缓存
    local cachedInfo = KiriameRPchat_GetCachedRadioInfo(citizenid)
    if cachedInfo then
        local simplifiedData = {
            id = TargetPlayerID,
            channel = cachedInfo.radiochannel,
            dep = cachedInfo.radiodepartment[1].value
        }
        TriggerClientEvent('kiriame_rpchat:client:receiveRadioInfo', requesterId, simplifiedData)
        return
    end
    
    MySQL.query('SELECT RadioInfo FROM players WHERE `citizenid` = ?', { citizenid }, function(results)
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

            MySQL.insert('INSERT INTO players (citizenid, RadioInfo) VALUES (?, ?)', {
                citizenid,
                json.encode(defaultRadioInfo)
            }, function(insertId)
                if insertId then
                    KiriameRPchat_UpdateCache(citizenid, defaultRadioInfo)
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
            
            KiriameRPchat_UpdateCache(citizenid, radioInfo)
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
    local Player = QBCore.Functions.GetPlayer(source)
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
    
    -- 获取所有玩家
    local players = QBCore.Functions.GetPlayers()
    
    -- 遍历所有玩家并发送消息给对应部门的玩家
    for _, playerId in ipairs(players) do
        local player = QBCore.Functions.GetPlayer(playerId)
        if player and player.PlayerData.job.name == data.department then
            TriggerClientEvent('kiriame_rpchat:client:receiveDepartmentBroadcast', playerId, data)
        end
    end
end)
