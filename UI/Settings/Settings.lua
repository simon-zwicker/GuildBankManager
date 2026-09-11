local GBM = GBM

local UI = GBM.UI

UI.Settings = {}

local Settings =
    UI.Settings

local L = GBM.L

local function CreateTitle(
    parent
)

    local title =
        parent:CreateFontString(
            nil,
            "OVERLAY"
        )

    title:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        -10
    )

    title:SetFont(
        "Fonts\\FRIZQT__.TTF",
        20,
        ""
    )

    title:SetText(
        L.SETTINGS
    )

    return title

end

local function CreateContent(
    parent
)

    local content =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    content:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        20,
        -55
    )

    content:SetPoint(
        "BOTTOMRIGHT",
        parent,
        "BOTTOMRIGHT",
        -20,
        15
    )

    Settings.Content =
        content

    return content

end

local function CreateBankCharsSection(
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
        0
    )

    frame:SetPoint(
        "BOTTOMLEFT",
        parent,
        "BOTTOMLEFT",
        0,
        0
    )

    frame:SetWidth(
        510
    )

    Settings.BankCharsFrame =
        frame

    if UI.SettingsBankChars then

        UI.SettingsBankChars.Initialize(
            frame
        )

    end

    return frame

end

local function CreateSeparator(
    parent
)

    local separator =
        parent:CreateTexture(
            nil,
            "ARTWORK"
        )

    separator:SetWidth(
        1
    )

    separator:SetPoint(
        "TOP",
        parent,
        "TOP",
        0,
        0
    )

    separator:SetPoint(
        "BOTTOM",
        parent,
        "BOTTOM",
        0,
        0
    )

    separator:SetColorTexture(
        1,
        1,
        1,
        0.12
    )

    return separator

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
        530,
        0
    )

    frame:SetPoint(
        "BOTTOMRIGHT",
        parent,
        "BOTTOMRIGHT",
        0,
        0
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

    if UI.SettingsBankChars then

        UI.SettingsBankChars.Refresh()

    end

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

    local content =
        CreateContent(
            view
        )

    CreateBankCharsSection(
        content
    )

    CreateSeparator(
        content
    )

    CreatePermissionsSection(
        content
    )

    if GBM.AddCharUI then
        GBM.AddCharUI.Initialize()
    end

end