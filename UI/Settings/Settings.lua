local GBM = GBM
local UI = GBM.UI

UI.Settings = {}
local Settings = UI.Settings

local function CreateTitle(parent)

    local title = parent:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalLarge"
    )

    title:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        -10
    )

    title:SetText("Einstellungen")

    return title
end

local function CreateBankCharSection(parent)

    local title = parent:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    title:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        -50
    )

    title:SetText("Bankchars")

    local description = parent:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontHighlightSmall"
    )

    description:SetPoint(
        "TOPLEFT",
        title,
        "BOTTOMLEFT",
        0,
        -8
    )

    description:SetText(
        "Verwalte die Charaktere, die als Bankchars registriert sind."
    )

    return title
end

local function CreateAddBankCharButton(parent)

    local button = CreateFrame(
        "Button",
        nil,
        parent,
        "UIPanelButtonTemplate"
    )

    button:SetSize(
        180,
        30
    )

    button:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        -95
    )

    button:SetText(
        "Bankchar hinzufügen"
    )

    button:SetScript(
        "OnClick",
        function()

            if UI.Settings.ShowAddChar then
                UI.Settings.ShowAddChar()
            end

        end
    )

    Settings.AddBankCharButton = button

    return button
end

local function CreateResetBankCharsButton(parent)

    local button = CreateFrame(
        "Button",
        nil,
        parent,
        "UIPanelButtonTemplate"
    )

    button:SetSize(
        180,
        30
    )

    button:SetPoint(
        "LEFT",
        Settings.AddBankCharButton,
        "RIGHT",
        10,
        0
    )

    button:SetText(
        "Bankchars zurücksetzen"
    )

    button:SetScript(
        "OnClick",
        function()

            StaticPopup_Show(
                "GBM_RESET_BANKCHARS"
            )

        end
    )

    Settings.ResetBankCharsButton = button

    return button
end

local function CreateResetDialog()

    StaticPopupDialogs["GBM_RESET_BANKCHARS"] = {

        text = "Möchtest du wirklich alle registrierten Bankchars zurücksetzen?",

        button1 = "Zurücksetzen",
        button2 = "Abbrechen",

        OnAccept = function()

            local db = GBM.GuildDB.Get()

            if not db then
                return
            end

            db.bankChars = {}

            print(
                "|cFF00FF00GBM|r Alle Bankchars wurden zurückgesetzt."
            )

            if UI.Settings.Refresh then
                UI.Settings.Refresh()
            end

        end,

        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,

    }

end

function Settings.ShowAddChar()

    if GBM.AddCharUI then
        GBM.AddCharUI.Show()
    end

end

function Settings.Refresh()

    -- Wird später verwendet,
    -- um die aktuelle Bankchar-Liste
    -- in den Einstellungen zu aktualisieren.

end

function Settings.Initialize()

    local view = UI.Views.settings

    if not view then
        return
    end

    CreateTitle(view)
    CreateBankCharSection(view)

    CreateAddBankCharButton(view)
    CreateResetBankCharsButton(view)

    CreateResetDialog()

    GBM.AddCharUI.Initialize()
end