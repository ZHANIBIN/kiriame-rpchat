-- 全局变量
local QBCore = exports['qb-core']:GetCoreObject()

-- 检查玩家是否为管理员
local function checkAdminStatus()
    local success, result = pcall(function()
        return lib.callback.await('kiriame_rpchat:server:isAdmin', false)
    end)
end

-- 在玩家加载时检查管理员状态
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1000) -- 等待玩家完全加载
    checkAdminStatus()
end)

-- 玩家退出时清理
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
end)

-- 添加定期检查管理员状态的机制
CreateThread(function()
    while true do
        Wait(30000)
        checkAdminStatus()
    end
end)

-- 初始化
CreateThread(function()
    Wait(5000) -- 等待资源完全加载
end)
