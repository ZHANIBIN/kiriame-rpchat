-- 计算两个玩家之间的距离
local QBCore = exports['qb-core']:GetCoreObject()

local MAX_DISTANCE = 10 -- 定义一个常量来表示最大距离

function Distance(senderid, targeterid)
    local senderPed = GetPlayerPed(senderid)
    local senderCoords = GetEntityCoords(senderPed) -- 使用局部变量存储结果
    local targetPed = GetPlayerPed(targeterid)
    local distance = #(GetEntityCoords(targetPed) - senderCoords)
    return distance
end

-- 获取玩家的全名
function GetPlayerCharname(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    else
        return "未知玩家" -- 返回一个默认值或者错误信息
    end
end

-- 触发客户端事件给附近玩家
function DisplayMessageToNearbyPlayers(src, message)
    local Players = GetPlayers()
    for _, targetid in ipairs(Players) do
        if Distance(src, targetid) <= MAX_DISTANCE and DoesPlayerExist(targetid) then
            TriggerClientEvent('3dme:shareDisplay', targetid, '*' .. message, src)
        end
    end
end

-- 获取玩家数据
function GetPlayerData(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player == nil then
        ServerDebugServerDebugprint("玩家数据加载失败，玩家ID: " .. source) -- 添加错误信息
        return nil
    end
    return Player.PlayerData
end

function IsRestrictedFrequency(frequency)
    for k, v in pairs(Config.RestrictChannel) do
        if frequency == v then
            return true, k
        end
    end
    return false
end

function SetRadioFrequency(source, slot, frequency)
    local isRestricted, channelKey = IsRestrictedFrequency(frequency)
    local Player = QBCore.Functions.GetPlayer(source)
    local jobType = Player.PlayerData.job.type

    if isRestricted and jobType == "leo" then
        TriggerClientEvent('kiriame_rpchat:radio:setfrequency', source, slot, frequency)
        TriggerClientEvent('chatMessage', source,
            " ** [S:" .. " " .. channelKey .. " | CH:" .. frequency .. "] " .. "你已加入加密频道", MESSAGE_COLOR)
    elseif isRestricted then
        TriggerClientEvent('QBCore:Notify', source, "你无法加入一个被加密的频道！", 'warn', 5000)
    else
        TriggerClientEvent('kiriame_rpchat:radio:setfrequency', source, slot, frequency)
    end
end

function ServerDebugServerDebugprint(message)
    if Config.Debug then
        print(message)
    else
        return
    end
end

---@class OxCommandParams
---@field name string
---@field help string
---@field type? 'number' | 'playerId' | 'string' | 'longString'
---@field optional? boolean

---@class OxCommandProperties
---@field help string?
---@field params OxCommandParams[]?

---@type OxCommandProperties[]
local registeredCommands = {}

---@param source number
---@param args table
---@param raw string
---@param params OxCommandParams[]?
---@return table?
local function parseArguments(source, args, raw, params)
    if not params then return args end

    local paramsNum = #params
    for i = 1, paramsNum do
        local arg, param = args[i], params[i]
        local value

        if param.type == 'number' then
            value = tonumber(arg)
        elseif param.type == 'string' then
            value = not tonumber(arg) and arg
        elseif param.type == 'playerId' then
            value = arg == 'me' and source or tonumber(arg)

            if not value or not DoesPlayerExist(value) then
                value = false
            end
        elseif param.type == 'longString' and i == paramsNum then
            if arg then
                local start = raw:find(arg, 1, true)
                value = start and raw:sub(start)
            else
                value = nil
            end
        else
            value = arg
        end

        if not value and not param.optional then
            return Citizen.Trace(("^1command '%s' received an invalid %s for argument %s (%s), received '%s'^0\n"):format(string.strsplit(' ', raw) or raw, param.type, i, param.name, arg))
        end

        arg = value

        args[param.name] = arg
        args[i] = nil
    end

    return args
end

---@param commandName string | string[]
---@param properties OxCommandProperties | false
---@param cb fun(source: number, args: table, raw: string)
function Kiriame_rpchat_addCommand(commandName, properties, cb)
    local params = properties and properties.params

    if params then
        for i = 1, #params do
            local param = params[i]

            if param.type then
                param.help = param.help and ('%s (type: %s)'):format(param.help, param.type) or ('(type: %s)'):format(param.type)
            end
        end
    end

    local commands = type(commandName) ~= 'table' and { commandName } or commandName
    local numCommands = #commands
    local totalCommands = #registeredCommands

    local function commandHandler(source, args, raw)
        args = parseArguments(source, args, raw, params)

        if not args then return end

        local success, resp = pcall(cb, source, args, raw)

        if not success then
            Citizen.Trace(("^1command '%s' failed to execute!\n%s"):format(string.strsplit(' ', raw) or raw, resp))
        end
    end

    for i = 1, numCommands do
        totalCommands += 1
        commandName = commands[i]

        RegisterCommand(commandName, commandHandler)

        if properties then
            ---@diagnostic disable-next-line: inject-field
            properties.name = ('/%s'):format(commandName)
            registeredCommands[totalCommands] = properties

            if i ~= numCommands and numCommands ~= 1 then
                properties = table.clone(properties)
            end
        end
    end

    if #registeredCommands > 0 then
        TriggerClientEvent('chat:addSuggestions', -1, registeredCommands)
    end

    AddEventHandler('playerJoining', function()
        TriggerClientEvent('chat:addSuggestions', source, registeredCommands)
    end)
end

