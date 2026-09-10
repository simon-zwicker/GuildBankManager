local GBM = GBM

GBM.Events = {}
local Events = GBM.Events

local frame = CreateFrame("Frame")

local function OnAddonLoaded(_, event, loadedAddonName)

    if loadedAddonName ~= GBM.Name then
        return
    end

    GBM.GuildDB.Initialize()
    GBM.BankDB.Initialize()
    GBM.Guild.Initialize()

    GBM.WoW.RequestGuildRoster()

    GBM.UI.Initialize()
    GBM.UI.Show()

    frame:UnregisterEvent("ADDON_LOADED")
    frame:RegisterEvent("GUILD_ROSTER_UPDATE")

    print("|cFF00FF00GBM|r Addon loaded - Version: " .. GBM.Version)
end

local function OnGuildRosterUpdate()
    GBM.Guild.UpdateMembers()
end

frame:SetScript("OnEvent", function(...)
    local event = select(2, ...)

    if event == "ADDON_LOADED" then
        OnAddonLoaded(...)
    elseif event == "GUILD_ROSTER_UPDATE" then
        OnGuildRosterUpdate()
    end
end)

frame:RegisterEvent("ADDON_LOADED")