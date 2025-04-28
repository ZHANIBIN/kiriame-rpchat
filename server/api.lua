local Core = exports['qb-core']:GetCoreObject()

function KiriameRPchat_GetPlayerData(source)
    if type(source) == 'number' then
        return Core.Players[source]
    else
        return Core.Players[QBCore.Functions.GetSource(source)]
    end
end