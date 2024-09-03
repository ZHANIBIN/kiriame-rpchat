local formattedTime = "["..os.date("%H:%M:%S").."]"
local function GetPlayerCharname(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local PlayerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    return PlayerName
end
-- 使用表来存储无线电频道
---不是哥们真有傻逼把我们服当文字服玩啊
---
local RadioChannels = {
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil
}

RegisterServerEvent('setfrequency')
AddEventHandler('setfrequency', function(slot, frequency)
    RadioChannels[slot] = frequency
end)
RegisterServerEvent('part')
AddEventHandler('part', function(slot, frequency)
    if slot == 1 then
        RadioChannels[slot] = nil
    end
end)
RegisterServerEvent('partall')
AddEventHandler('partall', function()
    for k, v in pairs(RadioChannels) do
        RadioChannels[k] = nil
    end
end)
RegisterServerEvent('radio')
AddEventHandler('radio', function(slot, args)
    Radiochannel1 = args
    local PlayerName = GetPlayerCharname()
    GetAllPlayerFrequencies()
    if frequency == Radiochannel[slot] then
        print()
    end
end)

-- 函数：获取所有玩家的频率数据并返回
function GetAllPlayerFrequencies()
    -- 创建一个表来存储所有玩家的频率数据
    local allPlayerFrequencies = {}

    -- 获取当前所有玩家的列表
    local players = QBCore.Functions.GetPlayers()
    
    -- 遍历所有玩家
    for playerId, player in pairs(players) do
        -- 检查玩家是否有频率数据
        local playerFrequencies = RadioChannels[playerId]
        if playerFrequencies then
            -- 将玩家的频率数据添加到 allPlayerFrequencies 表中
            allPlayerFrequencies[playerId] = playerFrequencies
        else
            -- 如果没有频率数据，标记为 nil
            allPlayerFrequencies[playerId] = nil
        end
    end

    -- 返回包含所有玩家频率数据的表
    return allPlayerFrequencies
end
-- 调用函数以输出所有玩家的频率数据
