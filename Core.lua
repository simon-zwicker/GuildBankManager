local ADDON_NAME = "GuildBankManager"
local ADDON_VERSION = "0.1.0"

GuildBankManager = {}
GuildBankManager.version = ADDON_VERSION
GuildBankManager.name = ADDON_NAME

function GuildBankManager:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|GuildBankManager|"..toString(message))
end

function GuildBankManager:Init()
    self:InitDatabase()
    self:UpdateGuildInfo()
    self:CreateMainFrame()

    self:Print("Version"..self.version.."loaded")

    if self.guild then
        self:Print("Current Guild: "..self.guild.name)
    else
        self:Print("You have no Guild currently.")
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == ADDON_NAME then
        GuildBankManager:Init()
    end
end)

SLASH_GUILDBANKMANAGER1 = "/gbm"
SLASH_GUILDBANKMANAGER2 = "/guildbank"

SlashCmdList["GUILDBANKMANAGER"] = function(message)
    message = string.lower(message or "")

    if message == "" or message == "open" then
        GuildBankManager:ToggleMainFrame()
        return
    end

    if message == "h" or message == "help" then 
        GuildBankManager:Print("Addon Commands:")
        GuildBankManager:Print("/gbm - Opens the Window")
        GuildBankManager:Print("/gbm h | /gbm help - Show commands")
        GuildBankManager:Print("/gbm bank - Show Bank")
        GuildBankManager:Print("/gbm requests - Show Requests")
        GuildBankManager:Print("/gbm stats - Show Statistics")
        GuildBankManager:Print("/gbm usage - Show my usage")
        GuildBankManager:Print("/gbm settings - Show Setting (Guildleader & Offis)")
    end

    if message == "bank" then
        GuildBankManager:ShowTab("BANK")
        return
    end

    if message == "requests" then
        GuildBankManager:ShowTab("REQUESTS")
        return
    end

    if message == "stats" then
        GuildBankManager:ShowTab("STATS")
        return
    end

    if message == "usage" then
        GuildBankManager:ShowTab("USAGE")
        return
    end

    if message == "settings" then
        GuildBankManager:ShowTab("SETTINGS")
        return
    end
end