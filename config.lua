Config = {}
Config.Core = 'QBCore'
-- 开启OOC聊天，如果为false，以下所有选项将无效
Config.EnableChatOOC = false -- 默认: true

-- 前缀及颜色设置
Config.Prefix = 'OOC | ' -- 默认: 'OOC | '
Config.PrefixColor = { 255, 255, 255} -- 默认: { 0, 0, 255}

-- 聊天距离及全局聊天设置
Config.ChatDistance = 20.0 -- 默认: 20.0
Config.EnableGlobalOOC = false -- 默认: false
Config.ServerName = "GTA:Pine Needle"

Config.WelcomeWord = "欢迎加入"..Config.ServerName.."全时段扮演文字语音混合角色社区,如果您需要新手帮助,请输入/guidebook,如果您有麻烦,请在KOOK或QQ群联系管理员"
-- 初始化时间格式化


-- 限制频道设置
Config.RestrictChannel = {
    ["BASE"] = 911, -- 对应频率 911 的频道键
    ["SPLX-1"] = 921, -- 特定频道
    ["SPLX-2"] = 922, -- 特定频道
    ["SPLX-3"] = 923, -- 特定频道
    ["SPLX-4"] = 924, -- 特定频道
    ["L-TAC1"] = 912, -- 特定频道
    ["L-TAC2"] = 909, -- 特定频道
    ["CED"] = 918, -- 特定频道
    ["DB-METRO"] = 907, -- 特定频道
}

Config.MAX_RADIO_CHANNELS = 10

Config.Debug = true -- 默认: false