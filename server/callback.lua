--沟槽的qbox获取 什么鸡吧获取方式，怎么IC名字还能和社区名字混在一起的司马代码都写的出来的

lib.callback.register('kiriame_rpchat:server:getPlayers', function(source)
    local players = {}
    local core = nil
    
    -- 尝试获取核心对象
    if GetResourceState('qb-core') == 'started' then
        core = exports['qb-core']:GetCoreObject()
    elseif GetResourceState('qbx_core') == 'started' then
        core = exports['qbx_core']:GetCoreObject()
    end
    
    if not core then return players end
    
    -- 获取玩家列表
    local playerList = core.Functions.GetQBPlayers()
    for k, v in pairs(playerList) do
        players[#players + 1] = {
            id = k,
            cid = v.PlayerData.citizenid,
            name = v.PlayerData.charinfo.firstname .. ' ' .. v.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(k) .. ')',
            gamename = v.PlayerData.charinfo.firstname .. ' ' .. v.PlayerData.charinfo.lastname,
            food = Player(v.PlayerData.source).state.hunger,
            water = Player(v.PlayerData.source).state.thirst,
            stress = Player(v.PlayerData.source).state.stress,
            armor = v.PlayerData.metadata.armor,
            phone = v.PlayerData.charinfo.phone,
            craftingrep = v.PlayerData.metadata.craftingrep,
            dealerrep = v.PlayerData.metadata.dealerrep,
            cash = v.PlayerData.money.cash,
            bank = v.PlayerData.money.bank,
            job = v.PlayerData.job.label .. ' | ' .. v.PlayerData.job.grade.level,
            gang = v.PlayerData.gang.label,
            license = GetPlayerIdentifierByType(k, 'license') or 'Unknown',
            discord = GetPlayerIdentifierByType(k, 'discord') or 'Not Linked',
            steam = GetPlayerIdentifierByType(k, 'steam') or 'Not Linked',
        }
    end
    table.sort(players, function(a, b) return a.id < b.id end)
    return players
end)