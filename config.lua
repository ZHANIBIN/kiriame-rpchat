Config = {}

-- Enable OOC Chat, if false all options below won't take effect
Config.EnableChatOOC = true -- Default: true

-- Prefix and color
Config.Prefix = '' -- Default: 'OOC | '
Config.PrefixColor = { 255, 255, 255} -- Default: { 0, 0, 255}

-- Change chat distance or make it global
Config.ChatDistance = 20.0 -- Default: 20.0
Config.EnableGlobalOOC = false -- Default: false
Config.WelcomeWord = "欢迎加入GTAR.CN全时段扮演文字语音混合角色社区,如果您需要新手帮助,请输入/guidebook,如果您有麻烦,请在KOOK或QQ群联系管理员"
Config.Time = "["..os.date("%H:%M:%S").."]"

Config.restrictchannel = {
    ["BASE"] = 911, -- 当频率为 911 时，对应的键为 BASE
    ["SPLX-1"] = 921,
    ["SPLX-2"] = 922,
    ["SPLX-3"] = 923,
    ["SPLX-4"] = 924,
    ["L-TAC1"] = 912,
    ["L-TAC2"] = 909,
    ["CED"] = 918,
    ["DB-METRO"] = 907,

}


