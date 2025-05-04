-- 框架检测
local Framework = nil
local Core = nil

-- 检测当前使用的框架
CreateThread(function()
    -- 尝试加载QBcore
    if GetResourceState('qb-core') == 'started' then
        Framework = 'qb-core'
        Core = exports['qb-core']:GetCoreObject()
    -- 尝试加载QBXcore
    elseif GetResourceState('qbx_core') == 'started' then
        Framework = 'qbx_core'
        Core = exports['qbx_core']:GetCoreObject()
    -- 尝试加载ESX
    elseif GetResourceState('es_extended') == 'started' then
        Framework = 'es_extended'
        Core = exports['es_extended']:getSharedObject()
    end
end)

-- API接口定义
KiriameRPchat_API = {
    -- 获取玩家数据
    getPlayerData = function(source)
        if not Framework then return nil end
        
        if Framework == 'qb-core' or Framework == 'qbx_core' then
            return Core.Functions.GetPlayer(source)
        elseif Framework == 'es_extended' then
            return Core.GetPlayerFromId(source)
        end
        return nil
    end,

    -- 获取玩家角色名
    getPlayerCharname = function(source)
        if not Framework then return "未知玩家" end
        
        local Player = KiriameRPchat_API.getPlayerData(source)
        if not Player then return "未知玩家" end
        
        if Framework == 'qb-core' or Framework == 'qbx_core' then
            if Player.PlayerData and Player.PlayerData.charinfo then
                return string.format("%s %s", 
                    Player.PlayerData.charinfo.firstname, 
                    Player.PlayerData.charinfo.lastname)
            end
        elseif Framework == 'es_extended' then
            if Player.get then
                return Player.get('firstName') .. ' ' .. Player.get('lastName')
            end
        end
        return "未知玩家"
    end,

    -- 获取玩家工作信息
    getPlayerJob = function(source)
        if not Framework then return nil end
        
        local Player = KiriameRPchat_API.getPlayerData(source)
        if not Player then return nil end
        
        if Framework == 'qb-core' or Framework == 'qbx_core' then
            return Player.PlayerData.job
        elseif Framework == 'es_extended' then
            return {
                name = Player.getJob().name,
                label = Player.getJob().label,
                grade = {
                    name = Player.getJob().grade_label,
                    level = Player.getJob().grade
                }
            }
        end
        return nil
    end,

    -- 获取玩家帮派信息
    getPlayerGang = function(source)
        if not Framework then return nil end
        
        local Player = KiriameRPchat_API.getPlayerData(source)
        if not Player then return nil end
        
        if Framework == 'qb-core' or Framework == 'qbx_core' then
            return Player.PlayerData.gang
        elseif Framework == 'es_extended' then
            -- ESX没有帮派系统，返回nil
            return nil
        end
        return nil
    end,

    -- 获取玩家金钱信息
    getPlayerMoney = function(source)
        if not Framework then return nil end
        
        local Player = KiriameRPchat_API.getPlayerData(source)
        if not Player then return nil end
        
        if Framework == 'qb-core' or Framework == 'qbx_core' then
            return Player.PlayerData.money
        elseif Framework == 'es_extended' then
            return {
                cash = Player.getMoney(),
                bank = Player.getAccount('bank').money
            }
        end
        return nil
    end,

    -- 获取玩家坐标
    getPlayerCoords = function(source)
        local playerPed = GetPlayerPed(source)
        return GetEntityCoords(playerPed)
    end,

    -- 获取玩家标识符
    getPlayerIdentifier = function(source, type)
        return GetPlayerIdentifierByType(source, type)
    end,

    -- 获取所有玩家
    getPlayers = function()
        return GetPlayers()
    end,

    -- 检查玩家是否存在
    doesPlayerExist = function(source)
        return DoesPlayerExist(source)
    end,

    -- 检查玩家是否有权限
    isPlayerAceAllowed = function(source, permission)
        return IsPlayerAceAllowed(source, permission)
    end,

    -- 发送通知
    sendNotification = function(source, message, type, duration)
        if not Framework then return end
        
        if Framework == 'qb-core' then
            TriggerClientEvent('QBCore:Notify', source, message, type, duration or 5000)
        elseif Framework == 'qbx_core' then
            exports.qbx_core:Notify(source, message, type, duration or 5000)
        elseif Framework == 'es_extended' then
            TriggerClientEvent('esx:showNotification', source, message)
        end
    end
}

-- 允许覆盖API实现
function KiriameRPchat_OverrideAPI(newAPI)
    for k, v in pairs(newAPI) do
        if KiriameRPchat_API[k] then
            KiriameRPchat_API[k] = v
        end
    end
end

-- 导出API接口
exports('GetAPIInterface', function()
    return KiriameRPchat_API
end)

-- 允许覆盖API接口
exports('OverrideAPI', function(newAPI)
    KiriameRPchat_API = newAPI
end) 