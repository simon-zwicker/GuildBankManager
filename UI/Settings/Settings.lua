local GBM = GBM

local UI = GBM.UI

UI.Settings = {}

local Settings = UI.Settings

local L = GBM.L

local function CreateTitle(
    parent
)

    local title =
        parent:CreateFontString(
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

    title:SetText(
        L.SETTINGS
    )

    return title

end

local function CreateBankCharSection(
    parent
)

    local title =
        parent:CreateFontString(
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

    title:SetText(
        L.BANK_CHARS
    )

    local description =
        parent:CreateFontString(
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
        L.BANK_CHARS_DESCRIPTION
    )

    return title

end

local function CreateAddBankCharButton(
    parent
)

    local button =
        CreateFrame(
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
        L.ADD_BANK_CHAR
    )

    button:SetScript(
        "OnClick",
        function()

            if UI.Settings.ShowAddChar then

                UI.Settings.ShowAddChar()

            end

        end
    )

    Settings.AddBankCharButton =
        button

    return button

end

local function CreateResetBankCharsButton(
    parent
)

    local button =
        CreateFrame(
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
        L.RESET_BANK_CHARS
    )

    button:SetScript(
        "OnClick",
        function()

            StaticPopup_Show(
                "GBM_RESET_BANKCHARS"
            )

        end
    )

    Settings.ResetBankCharsButton =
        button

    return button

end

local function CreateResetDialog()

    StaticPopupDialogs[
        "GBM_RESET_BANKCHARS"
    ] = {

        text =
            L.RESET_CONFIRMATION,

        button1 =
            L.RESET,

        button2 =
            L.CANCEL,

        OnAccept =
            function()

                if not GBM.Permissions
                    .CanManageBankChars() then

                    return

                end

                local db =
                    GBM.GuildDB.Get()

                if not db then
                    return
                end

                db.bankChars = {}

                print(
                    "|cFF00FF00GBM|r "
                    .. L.RESET_BANK_CHARS
                )

                Settings.Refresh()

            end,

        timeout = 0,

        whileDead = true,

        hideOnEscape = true,

        preferredIndex = 3,

    }

end

local function CreatePermissionsSection(
    parent
)

    local frame =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    frame:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        0,
        -145
    )

    frame:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        0,
        -145
    )

    frame:SetHeight(
        300
    )

    Settings.PermissionsFrame =
        frame

    if UI.SettingsPermissions then

        UI.SettingsPermissions.Initialize(
            frame
        )

    end

    return frame

end

function Settings.ShowAddChar()

    if not GBM.Permissions
        .CanManageBankChars() then

        return

    end

    if GBM.AddCharUI then

        GBM.AddCharUI.Show()

    end

end

function Settings.Refresh()

    if UI.SettingsPermissions then

        UI.SettingsPermissions.Refresh()

    end

end

function Settings.Initialize()

    local view =
        UI.Views.settings

    if not view then
        return
    end

    CreateTitle(
        view
    )

    CreateBankCharSection(
        view
    )

    CreateAddBankCharButton(
        view
    )

    CreateResetBankCharsButton(
        view
    )

    CreateResetDialog()

    CreatePermissionsSection(
        view
    )

    GBM.AddCharUI.Initialize()

end