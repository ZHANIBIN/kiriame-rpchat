print('Loading nametag.lua')

-- 全局变量来存储显示名称标签的状态以及存储已创建的标签
local showNames = true
local gamerTags = {}

-- 函数来更新玩家名称标签
local function updateNametags()
    local players = lib.callback.await('kiriame_rpchat:server:getPlayers', false)
    for _, player in pairs(players) do
        local playerId = GetPlayerFromServerId(player.id)
        if playerId == -1 then goto continue end -- 如果玩家不存在，跳过当前循环
        local ped = GetPlayerPed(playerId)
        local name = player.gamename .. ' [' .. player.id .. ']'

        if showNames then
            if not gamerTags[player.id] then
                -- 如果名称标签不存在，则创建一个新的
                gamerTags[player.id] = CreateFakeMpGamerTag(ped, name, false, false, '', 0)
            end
        else
            if gamerTags[player.id] then
                -- 如果名称标签存在，则移除它
                RemoveMpGamerTag(gamerTags[player.id])
                gamerTags[player.id] = nil
            end
        end
        ::continue::
    end
end

-- 注册事件来显示或隐藏名称标签
RegisterNetEvent('kiriame_rpchat:client:Show', function()
    showNames = not showNames -- 切换显示状态
    updateNametags() -- 更新名称标签
end)
