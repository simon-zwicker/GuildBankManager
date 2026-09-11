local GBM = GBM

local UI = GBM.UI

UI.SettingsBankChars = {}

local BankCharsUI =
    UI.SettingsBankChars

local L = GBM.L

local ROW_HEIGHT = 38

local function GetBankChars()

    local db =
        GBM.GuildDB.Get()

    if not db then
        return {}
    end

    local bankChars = {}

    for fullName in pairs(
        db.bankChars
    ) do

        table.insert(
            bankChars,
            fullName
        )

    end

    table.sort(
        bankChars,
        function(a, b)
            return a:lower()
                < b:lower()
        end
    )

    return bankChars

end

local function GetClass(
    fullName
)

    local db =
        GBM.GuildDB.Get()

    if not db
        or not db.members then

        return nil

    end

    local member =
        db.members[fullName]

    if not member then
        return nil
    end

    return member.class

end

local function CreateRow(
    parent,
    index
)

    local row =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    row:SetHeight(
        ROW_HEIGHT
    )

    row:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        0,
        -(index - 1)
            * ROW_HEIGHT
    )

    row:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        0,
        -(index - 1)
            * ROW_HEIGHT
    )

    row.Name =
        row:CreateFontString(
            nil,
            "OVERLAY"
        )

    row.Name:SetPoint(
        "LEFT",
        row,
        "LEFT",
        8,
        0
    )

    row.Name:SetFont(
        "Fonts\\FRIZQT__.TTF",
        16,
        ""
    )

    row.RemoveButton =
        CreateFrame(
            "Button",
            nil,
            row,
            "UIPanelCloseButton"
        )

    row.RemoveButton:SetSize(
        24,
        24
    )

    row.RemoveButton:SetPoint(
        "RIGHT",
        row,
        "RIGHT",
        -4,
        0
    )

    row.RemoveButton:SetScript(
        "OnClick",
        function()
            if not row.FullName then
                return
            end

            local popup =
                StaticPopup_Show(
                    "GBM_REMOVE_BANKCHAR",
                    row.FullName
                )

            if popup then
                popup.data = row.FullName
            end
        end
    )

    row.Divider =
        row:CreateTexture(
            nil,
            "BACKGROUND"
        )

    row.Divider:SetHeight(
        1
    )

    row.Divider:SetPoint(
        "BOTTOMLEFT",
        row,
        "BOTTOMLEFT",
        8,
        0
    )

    row.Divider:SetPoint(
        "BOTTOMRIGHT",
        row,
        "BOTTOMRIGHT",
        -8,
        0
    )

    row.Divider:SetColorTexture(
        1,
        1,
        1,
        0.08
    )

    return row

end

local function RefreshRows()

    if not BankCharsUI.Frame then
        return
    end

    local bankChars =
        GetBankChars()

    for index, row in ipairs(
        BankCharsUI.Rows
    ) do

        local fullName =
            bankChars[index]

        if fullName then

            row.FullName =
                fullName

            local r, g, b =
                GBM.Utils.GetClassColor(
                    GetClass(
                        fullName
                    )
                )

            row.Name:SetTextColor(
                r,
                g,
                b
            )

            row.Name:SetText(
                fullName
            )

            row:Show()

        else

            row.FullName = nil
            row.Name:SetText("")
            row:Hide()

        end

    end

    if #bankChars == 0 then

        BankCharsUI.EmptyText:Show()

    else

        BankCharsUI.EmptyText:Hide()

    end

end

local function CreateSectionTitle(
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
        0,
        0
    )

    title:SetFont(
        "Fonts\\FRIZQT__.TTF",
        18,
        ""
    )

    title:SetTextColor(
        1,
        0.82,
        0
    )

    title:SetText(
        L.BANK_CHARS
    )

    return title

end

local function CreateDescription(
    parent
)

    local description =
        parent:CreateFontString(
            nil,
            "OVERLAY"
        )

    description:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        0,
        -30
    )

    description:SetFont(
        "Fonts\\FRIZQT__.TTF",
        14,
        ""
    )

    description:SetText(
        L.BANK_CHARS_DESCRIPTION
    )

    description:SetWidth(
        480
    )

    description:SetJustifyH(
        "LEFT"
    )

    return description

end

local function CreateAddButton(
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
        0,
        -70
    )

    button:SetText(
        L.ADD_BANK_CHAR
    )

    button:SetScript(
        "OnClick",
        function()

            if not GBM.Permissions
                .CanManageBankChars() then

                return

            end

            if GBM.AddCharUI then
                GBM.AddCharUI.Show()
            end

        end
    )

    BankCharsUI.AddButton =
        button

    return button

end

local function CreateList(
    parent
)

    local list =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    list:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        0,
        -115
    )

    list:SetPoint(
        "BOTTOMRIGHT",
        parent,
        "BOTTOMRIGHT",
        0,
        0
    )

    BankCharsUI.List =
        list

    BankCharsUI.Rows = {}

    local rowCount =
        math.floor(
            440 / ROW_HEIGHT
        )

    for index = 1,
        rowCount do

        BankCharsUI.Rows[index] =
            CreateRow(
                list,
                index
            )

    end

    local emptyText =
        list:CreateFontString(
            nil,
            "OVERLAY"
        )

    emptyText:SetPoint(
        "TOPLEFT",
        list,
        "TOPLEFT",
        8,
        -5
    )

    emptyText:SetFont(
        "Fonts\\FRIZQT__.TTF",
        14,
        ""
    )

    emptyText:SetTextColor(
        0.65,
        0.65,
        0.65
    )

    emptyText:SetText(
        L.NO_REGISTERED_BANK_CHAR
    )

    BankCharsUI.EmptyText =
        emptyText

end

local function CreateRemoveDialog()

    StaticPopupDialogs[
        "GBM_REMOVE_BANKCHAR"
    ] = {

        text =
            L.REMOVE_BANK_CHAR_CONFIRM,

        button1 =
            L.REMOVE,

        button2 =
            L.CANCEL,

        OnShow =
            function(
                popup,
                data
            )

                popup.data =
                    data

            end,

        OnAccept =
            function(
                popup
            )

                local fullName =
                    popup.data

                if not fullName then
                    return
                end

                local success,
                    reason =
                    GBM.Guild.RemoveBankChar(
                        fullName
                    )

                if success then

                    print(
                        "|cFF00FF00GBM|r "
                        .. L.BANK_CHAR_REMOVED
                        .. " "
                        .. fullName
                    )

                    popup.data = nil

                    BankCharsUI.Refresh()

                    return

                end

                popup.data = nil

                if reason == "active_requests" then

                    print(
                        "|cFFFF0000GBM|r "
                        .. L.BANK_CHAR_REMOVE_BLOCKED
                    )

                end

            end,

        OnHide =
            function(
                popup
            )

                popup.data = nil

            end,

        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,

    }

end

function BankCharsUI.Refresh()

    RefreshRows()

end

function BankCharsUI.Initialize(
    parent
)

    if BankCharsUI.Frame then
        return BankCharsUI.Frame
    end

    local frame =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    frame:SetAllPoints(
        parent
    )

    BankCharsUI.Frame =
        frame

    CreateSectionTitle(
        frame
    )

    CreateDescription(
        frame
    )

    CreateAddButton(
        frame
    )

    CreateList(
        frame
    )

    CreateRemoveDialog()

    BankCharsUI.Refresh()

    return frame

end