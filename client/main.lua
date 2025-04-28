---@diagnostic disable: missing-parameter
print("kiriame-rpchat loaded successfully\nGo to, let us go down, and there confound their language, that they may not understand one another's speech.")

QBCore = exports['qb-core']:GetCoreObject()

local Player = QBCore.Functions.GetPlayerData()
local playerPed = PlayerPedId()
local playerId = GetPlayerServerId(playerPed)

-- 客户端代码
local currentTime = ""

RegisterNetEvent('kiriame_rpchat:client:displayServerTime')
AddEventHandler('kiriame_rpchat:client:displayServerTime', function(time)
    currentTime = time
end)

local function KiriameRPchat_DrawServerInformation()
    -- 获取当前服务器上的玩家数量
    local currentPlayers = #GetActivePlayers()

    -- 获取总可加入人数
    local maxPlayers = GetConvarInt('maxPlayers', wA) -- 默认最大人数为32

    -- 设置文本的位置
    local x, y = 0.5, 0.97 -- 屏幕中心水平，接近底部垂直

    -- 开始绘制文本
    SetTextFont(1) -- 设置字体
    SetTextProportional(1)
    SetTextScale(0.0, 0.3) -- 设置文本大小
    SetTextColour(255, 255, 255, 255) -- 设置文本颜色为白色
    SetTextDropshadow(0, 0, 0, 0, 255) -- 设置文本阴影
    SetTextEdge(2, 0, 0, 0, 150) -- 设置文本边缘
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true) -- 设置文本居中

    -- 添加文本内容
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("GTA:Pine Needle "..string.format("玩家数: %d/%d 时间: %s", currentPlayers, maxPlayers, currentTime))
    EndTextCommandDisplayText(x, y)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- 每帧调用一次
        KiriameRPchat_DrawServerInformation()
    end
end)

RegisterCommand('clear', function()
    TriggerEvent('chat:clear')
end, false)

