local GBM = GBM

GBM.Events = {}

local Events = GBM.Events

local L = GBM.L

local frame = CreateFrame(
    "Frame"
)

local syncPending = false
local guildMembersLoaded = false

local function PrintStatus(
    message
)

    print(
        "|cFF00FF00GBM|r "
        .. message
    )

end

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

    if GBM.Permissions
        and GBM.Permissions.Initialize then

        GBM.Permissions.Initialize()

    end

    GBM.Guild.Initialize()

    if GBM.Sync
        and GBM.Sync.Comm
        and GBM.Sync.Comm.Initialize then

        GBM.Sync.Comm.Initialize()

    end

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

    if GBM.Sync
        and GBM.Sync.Comm then

        frame:RegisterEvent(
            "CHAT_MSG_ADDON"
        )

    end

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.LOADED,
            GBM.Version
        )
    )

end

local function OnGuildRosterUpdate()

    local members =
        GBM.Guild.UpdateMembers()

    if not members then
        return
    end

    if guildMembersLoaded then
        return
    end

    local count = 0

    for _ in pairs(
        members
    ) do

        count = count + 1

    end

    if count <= 0 then
        return
    end

    guildMembersLoaded = true

    PrintStatus(
        string.format(
            L.GUILD_MEMBERS_LOADED,
            count
        )
    )

    if GBM.Sync
        and GBM.Sync.Comm
        and GBM.Sync.Comm.Hello then

        C_Timer.After(
            0.5,
            function()

                GBM.Sync.Comm.Hello()

            end
        )

    end

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

local function OnChatMessageAddon(
    prefix,
    message,
    channel,
    sender,
    target,
    zoneChannelID,
    localID,
    name,
    instanceID
)

    if not GBM.Sync
        or not GBM.Sync.Comm
        or not GBM.Sync.Comm.OnEvent then

        return

    end

    GBM.Sync.Comm.OnEvent(
        "CHAT_MSG_ADDON",
        prefix,
        message,
        channel,
        sender,
        target,
        zoneChannelID,
        localID,
        name,
        instanceID
    )

end

frame:SetScript(
    "OnEvent",
    function(
        frame,
        event,
        ...
    )

        if event == "ADDON_LOADED" then

            local loadedAddonName = ...

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

        elseif event == "CHAT_MSG_ADDON" then

            OnChatMessageAddon(
                ...
            )

        end

    end
)

frame:RegisterEvent(
    "ADDON_LOADED"
)