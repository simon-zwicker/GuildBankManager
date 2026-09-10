local MAIN_WIDTH = 900
local MAIN_HEIGHT = 600

local TABS = {
    {
        id = "BANK",
        text = "Bank",
    },
    {
        id = "REQUESTS",
        text = "Requests",
    },
    {
        id = "STATS",
        text = "Statistik",
    },
    {
        id = "USAGE",
        text = "Nutzung",
        restricted = true,
    },
    {
        id = "SETTINGS",
        text = "Einstellungen",
    },
}

function GuildBankManager:CreateMainFrame()

    if self.mainFrame then
        return
    end

    local frame = CreateFrame(
        "Frame",
        "GuildBankManagerMainFrame",
        UIParent,
        "BackdropTemplate"
    )

    frame:SetSize(MAIN_WIDTH, MAIN_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")

    frame:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4,
        },
    })

    frame:Hide()

    self.mainFrame = frame

    -- Titel

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")

    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("GuildBankManager")

    self.titleText = title

    -- Close Button

    local closeButton = CreateFrame(
        "Button",
        nil,
        frame,
        "UIPanelCloseButton"
    )

    closeButton:SetPoint("TOPRIGHT", 2, 2)

    -- Content

    local content = CreateFrame(
        "Frame",
        nil,
        frame
    )

    content:SetPoint("TOPLEFT", 15, -55)
    content:SetPoint("BOTTOMRIGHT", -15, 50)

    self.contentFrame = content

    -- Bottom tabs

    self.tabs = {}

    local previousTab

    for _, tabData in ipairs(TABS) do

        local button = CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

        button:SetSize(145, 28)

        if previousTab then
            button:SetPoint(
                "LEFT",
                previousTab,
                "RIGHT",
                4,
                0
            )
        else
            button:SetPoint(
                "BOTTOMLEFT",
                15,
                12
            )
        end

        button:SetText(tabData.text)

        button:SetScript("OnClick", function()
            GBM:ShowTab(tabData.id)
        end)

        self.tabs[tabData.id] = button

        previousTab = button
    end

    self:ShowTab("BANK")
end

function GuildBankManager:ToggleMainFrame()

    if not self.mainFrame then
        self:CreateMainFrame()
    end

    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
    else
        self:ShowMainFrame()
    end
end

function GuildBankManager:ShowMainFrame()

    if not self.mainFrame then
        self:CreateMainFrame()
    end

    GuildBankManager:UpdateGuildInfo()

    self.mainFrame:Show()

    self:ShowTab("BANK")
end

function GuildBankManager:ShowTab(tabID)

    if not self.mainFrame then
        return
    end

    self:ClearContent()

    for id, button in pairs(self.tabs) do

        if id == tabID then
            button:Disable()
        else
            button:Enable()
        end
    end

    if tabID == "BANK" then
        self:DrawBankTab()

    elseif tabID == "REQUESTS" then
        self:DrawRequestsTab()

    elseif tabID == "STATISTICS" then
        self:DrawStatisticsTab()

    elseif tabID == "USAGE" then

        if self:CanManageBankChars() then
            self:DrawUsageTab()
        else
            self:DrawPermissionDenied("Nur Gildenleiter und Offiziere können die Nutzung sehen.")
        end

    elseif tabID == "SETTINGS" then
        self:DrawSettingsTab()
    end
end

function GuildBankManager:ClearContent()

    if not self.contentFrame then
        return
    end

    local children = {
        self.contentFrame:GetChildren()
    }

    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end
end

function GuildBankManager:CreateContentText(text, size)

    local font = size or "GameFontNormal"

    local label =
        self.contentFrame:CreateFontString(
            nil,
            "OVERLAY",
            font
        )

    label:SetPoint("TOPLEFT", 15, -15)
    label:SetJustifyH("LEFT")
    label:SetText(text)

    return label
end

function GuildBankManager:DrawBankTab()

    if not self.guild then
        self:CreateContentText(
            "Keine Gilde erkannt.\n\nDu musst Mitglied einer Gilde sein, um GuildBankManager zu verwenden."
        )
        return
    end

    local guildDB = self:GetCurrentGuildDatabase()

    if not guildDB then
        return
    end

    local header = self:CreateContentText(
        "Gildenbank: " .. self.guild.name
        .. "\nRealm: " .. self.guild.realm,
        "GameFontHighlight"
    )

    -- Suchfeld

    local searchBox = CreateFrame(
        "EditBox",
        nil,
        self.contentFrame,
        "InputBoxTemplate"
    )

    searchBox:SetSize(350, 30)
    searchBox:SetPoint(
        "TOPLEFT",
        15,
        -65
    )

    searchBox:SetAutoFocus(false)
    searchBox:SetText("")

    searchBox:SetScript("OnTextChanged", function()
        GBM:RefreshBankList(searchBox:GetText())
    end)

    local searchLabel =
        self.contentFrame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    searchLabel:SetPoint(
        "LEFT",
        searchBox,
        "RIGHT",
        10,
        0
    )

    searchLabel:SetText("Items durchsuchen")

    self.bankListFrame = CreateFrame(
        "ScrollFrame",
        nil,
        self.contentFrame,
        "UIPanelScrollFrameTemplate"
    )

    self.bankListFrame:SetPoint(
        "TOPLEFT",
        15,
        -110
    )

    self.bankListFrame:SetPoint(
        "BOTTOMRIGHT",
        -30,
        10
    )

    self.bankListContent = CreateFrame(
        "Frame",
        nil,
        self.bankListFrame
    )

    self.bankListContent:SetSize(800, 400)

    self.bankListFrame:SetScrollChild(
        self.bankListContent
    )

    self:RefreshBankList("")
end

function GuildBankManager:RefreshBankList(searchText)

    if not self.bankListContent then
        return
    end

    local children = {
        self.bankListContent:GetChildren()
    }

    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end

    local guildDB = self:GetCurrentGuildDatabase()

    if not guildDB then
        return
    end

    searchText = string.lower(searchText or "")

    local y = -5

    for itemID, itemData in pairs(guildDB.items) do

        local itemName = itemData.name or ("Item " .. itemID)

        if searchText == ""
            or string.find(
                string.lower(itemName),
                searchText,
                1,
                true
            ) then

            local row = CreateFrame(
                "Frame",
                nil,
                self.bankListContent
            )

            row:SetSize(760, 38)
            row:SetPoint(
                "TOPLEFT",
                5,
                y
            )

            local text =
                row:CreateFontString(
                    nil,
                    "OVERLAY",
                    "GameFontNormal"
                )

            text:SetPoint(
                "LEFT",
                5,
                0
            )

            local total = itemData.amount or 0
            local reserved = itemData.reserved or 0
            local available = total - reserved

            text:SetText(
                itemName
                .. "    "
                .. total
                .. "    "
                .. reserved
                .. "    "
                .. math.max(0, available)
            )

            y = y - 42
        end
    end
end

function GuildBankManager:DrawRequestsTab()

    local label = self:CreateContentText(
        "Requests\n\nDas Request-System wird hier angeschlossen."
    )

    if not self:CanManageBankChars() then
        label:SetText(
            "Meine Requests\n\n"
            .. "Hier werden später deine eigenen Gildenbank-Anfragen angezeigt."
        )
    else
        label:SetText(
            "Requestverwaltung\n\n"
            .. "Als Gildenleiter, Offizier oder Bankchar siehst du hier später alle Requests."
        )
    end
end

function GuildBankManager:DrawStatisticsTab()

    self:CreateContentText(
        "Statistik\n\n"
        .. "Hier werden später Einlagerungen, Händlerwert und Highscore angezeigt."
    )
end

function GuildBankManager:DrawUsageTab()

    local guildDB = self:GetCurrentGuildDatabase()

    if not guildDB then
        return
    end

    self:CreateContentText(
        "Addon-Nutzung\n\n"
        .. "Installierte Mitglieder werden später über die Addon-Kommunikation erkannt."
    )

    local y = -100

    for name, member in pairs(guildDB.members) do

        local row =
            self.contentFrame:CreateFontString(
                nil,
                "OVERLAY",
                "GameFontNormal"
            )

        row:SetPoint(
            "TOPLEFT",
            20,
            y
        )

        local installed =
            guildDB.addonUsers[name] ~= nil

        local status =
            installed
            and "|cff00ff00Addon aktiv|r"
            or "|cffff0000Nicht erkannt|r"

        row:SetText(
            name .. " - " .. status
        )

        y = y - 25
    end
end

function GuildBankManager:DrawSettingsTab()

    self:CreateContentText(
        "Einstellungen\n\n"
        .. "Hier kommen später die Addon-Einstellungen hin."
    )
end

function GuildBankManager:DrawPermissionDenied(message)

    self:CreateContentText(
        "|cffff4444Keine Berechtigung|r\n\n"
        .. message
    )
end

function GuildBankManager:RefreshMainUI()

    if self.mainFrame and self.mainFrame:IsShown() then
        self:ShowTab("BANK")
    end
end