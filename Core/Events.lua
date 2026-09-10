local GBM = GBM

GBM.Events = {}

local Events = GBM.Events

local L = GBM.L

local frame = CreateFrame(
    "Frame"
)

local syncPending = false

local function OnAddonLoaded(
    frame,
    event,
    loadedAddonName
)

    if event ~= "ADDON_LOADED" then
        return
    end

    if loadedAddonName ~= GBM.Name then
        return
    end

    GBM.GuildDB.Initialize()
    GBM.BankDB.Initialize()
    GBM.Commands.Initialize()

    GBM.Guild.Initialize()
    GBM.WoW.RequestGuildRoster()

    GBM.UI.Initialize()

    frame:UnregisterEvent(
        "ADDON_LOADED"
    )

    frame:RegisterEvent(
        "GUILD_ROSTER_UPDATE"
    )

    frame:RegisterEvent(
        "BANKFRAME_OPENED"
    )

    frame:RegisterEvent(
        "BANKFRAME_CLOSED"
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.LOADED,
            GBM.Version
        )
    )

end

local function OnGuildRosterUpdate()

    GBM.Guild.UpdateMembers()

end

local function OnBankFrameOpened()

    if syncPending then
        return
    end

    if not GBM.BankScanner.IsAvailable() then
        return
    end

    syncPending = true

    C_Timer.After(
        0.3,
        function()

            syncPending = false

            GBM.BankScanner.Sync()

        end
    )

end

local function OnBankFrameClosed()

    syncPending = false

end

frame:SetScript(
    "OnEvent",
    function(
        frame,
        event,
        loadedAddonName
    )

        if event == "ADDON_LOADED" then

            OnAddonLoaded(
                frame,
                event,
                loadedAddonName
            )

        elseif event == "GUILD_ROSTER_UPDATE" then

            OnGuildRosterUpdate()

        elseif event == "BANKFRAME_OPENED" then

            OnBankFrameOpened()

        elseif event == "BANKFRAME_CLOSED" then

            OnBankFrameClosed()

        end

    end
)

frame:RegisterEvent(
    "ADDON_LOADED"
)