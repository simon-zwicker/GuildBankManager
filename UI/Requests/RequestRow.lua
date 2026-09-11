local GBM = GBM

GBM.UI = GBM.UI or {}
GBM.UI.Requests = GBM.UI.Requests or {}

local RequestsUI = GBM.UI.Requests

local ROW_HEIGHT = 42
local ICON_SIZE = 32

local ITEM_OFFSET = 50
local ITEM_WIDTH = 220

local AMOUNT_OFFSET = 280
local AMOUNT_WIDTH = 70

local STOCK_OFFSET = 355
local STOCK_WIDTH = 70

local REQUESTER_OFFSET = 435
local REQUESTER_WIDTH = 150

local function CreateButton(
    parent,
    texture
)

    local button =
        CreateFrame(
            "Button",
            nil,
            parent
        )

    button:SetSize(
        28,
        28
    )

    button.icon =
        button:CreateTexture(
            nil,
            "ARTWORK"
        )

    button.icon:SetAllPoints()

    button.icon:SetTexture(
        texture
    )

    button:SetHighlightTexture(
        "Interface\\Buttons\\ButtonHilight-Square"
    )

    return button

end

local function GetItemData(
    itemID
)

    if not itemID then
        return nil
    end

    local itemName,
        itemLink,
        itemQuality,
        itemLevel,
        itemMinLevel,
        itemType,
        itemSubType,
        itemStackCount,
        itemEquipLoc,
        itemTexture =
        GetItemInfo(
            itemID
        )

    return {
        name = itemName,
        link = itemLink,
        quality = itemQuality,
        texture = itemTexture,
    }

end

local function GetOwnAmount(
    request
)

    if not request
        or not request.itemID then

        return 0

    end

    local fullName =
        GBM.WoW.GetFullPlayerName()

    if not fullName then
        return 0
    end

    if GBM.BankDB
        and GBM.BankDB.GetAvailableAmount then

        return GBM.BankDB.GetAvailableAmount(
            fullName,
            request.itemID
        ) or 0

    end

    return 0

end

local function GetShortName(
    fullName
)

    if not fullName then
        return ""
    end

    return string.match(
        fullName,
        "^[^-]+"
    ) or fullName

end

local function GetMember(
    fullName
)

    if not fullName then
        return nil
    end

    local db =
        GBM.GuildDB.Get()

    if not db
        or not db.members then

        return nil

    end

    local member =
        db.members[
            fullName
        ]

    if member then
        return member
    end

    local shortName =
        GetShortName(
            fullName
        )

    return db.members[
        shortName
    ]

end

local function SetClassColoredName(
    fontString,
    fullName
)

    local shortName =
        GetShortName(
            fullName
        )

    local member =
        GetMember(
            fullName
        )

    local r,
        g,
        b =
        GBM.Utils.GetClassColor(
            member
            and member.class
        )

    fontString:SetText(
        shortName
    )

    fontString:SetTextColor(
        r,
        g,
        b
    )

end

local function ApplyItemQualityColor(
    fontString,
    quality
)

    if not quality then

        fontString:SetTextColor(
            1,
            1,
            1
        )

        return

    end

    local r,
        g,
        b =
        GetItemQualityColor(
            quality
        )

    if not r then

        r,
        g,
        b =
            1,
            1,
            1

    end

    fontString:SetTextColor(
        r,
        g,
        b
    )

end

local function SetupItemTooltip(
    frame,
    itemID
)

    frame:SetScript(
        "OnEnter",
        function(self)

            GameTooltip:SetOwner(
                self,
                "ANCHOR_RIGHT"
            )

            local itemInfo =
                GetItemData(
                    itemID
                )

            if itemInfo
                and itemInfo.link then

                GameTooltip:SetHyperlink(
                    itemInfo.link
                )

            else

                GameTooltip:SetItemByID(
                    itemID
                )

            end

            GameTooltip:Show()

        end
    )

    frame:SetScript(
        "OnLeave",
        function()

            GameTooltip:Hide()

        end
    )

end

local function GetCurrentBankChar()

    return GBM.WoW.GetFullPlayerName()

end

local function IsCurrentBankChar()

    return GBM.Permissions
        and GBM.Permissions.IsBankChar
        and GBM.Permissions.IsBankChar()

end

local function CanAssignRequests()

    return GBM.Permissions
        and GBM.Permissions.CanAssignRequests
        and GBM.Permissions.CanAssignRequests()

end

local function GetAcceptableBankChars(
    request
)

    if not request
        or not GBM.Requests
        or not GBM.Requests.GetAcceptableBankChars then

        return {}

    end

    return GBM.Requests.GetAcceptableBankChars(
        request.id
    )

end

local function CanAccept(
    request
)

    if not request then
        return false
    end

    if IsCurrentBankChar() then

        local bankChar =
            GetCurrentBankChar()

        if not bankChar then
            return false
        end

        if not GBM.BankDB
            or not GBM.BankDB.CanFulfill then

            return false

        end

        return GBM.BankDB.CanFulfill(
            bankChar,
            request.itemID,
            request.amount
        )

    end

    if not CanAssignRequests() then
        return false
    end

    local bankChars =
        GetAcceptableBankChars(
            request
        )

    return #bankChars > 0

end

local function AcceptRequest(
    request,
    bankChar
)

    if not request
        or not bankChar then

        return

    end

    if not GBM.Requests
        or not GBM.Requests.Accept then

        return

    end

    local success =
        GBM.Requests.Accept(
            request.id,
            bankChar
        )

    if success then

        RequestsUI.Refresh()

    end

end

local function ShowBankCharMenu(
    button,
    request
)

    local bankChars =
        GetAcceptableBankChars(
            request
        )

    if #bankChars == 0 then
        return
    end

    local menu =
        CreateFrame(
            "Frame",
            "GBMRequestBankCharDropdown",
            UIParent,
            "UIDropDownMenuTemplate"
        )

    UIDropDownMenu_Initialize(
        menu,
        function(
            self,
            level
        )

            for _, bankChar in ipairs(
                bankChars
            ) do

                local info =
                    UIDropDownMenu_CreateInfo()

                info.text =
                    GetShortName(
                        bankChar
                    )

                info.func =
                    function()

                        AcceptRequest(
                            request,
                            bankChar
                        )

                    end

                UIDropDownMenu_AddButton(
                    info,
                    level
                )

            end

        end
    )

    ToggleDropDownMenu(
        1,
        nil,
        menu,
        button,
        0,
        0
    )

end

local function CanReject()

    local isBankChar =
        GBM.Permissions
        and GBM.Permissions.IsBankChar
        and GBM.Permissions.IsBankChar()

    local canReject =
        GBM.Permissions
        and GBM.Permissions.CanRejectRequests
        and GBM.Permissions.CanRejectRequests()

    return isBankChar
        or canReject

end

local function CanCancel(
    request
)

    if not request then
        return false
    end

    local currentPlayer =
        GBM.WoW.GetFullPlayerName()

    return request.requestedBy
        == currentPlayer

end

local function ShowCancelConfirmation(
    request
)

    if not request then
        return
    end

    local dialogName =
        "GBM_CONFIRM_CANCEL_REQUEST"

    if not StaticPopupDialogs[
        dialogName
    ] then

        StaticPopupDialogs[
            dialogName
        ] = {

            text =
                GBM.L.REQUEST_CANCEL_CONFIRM,

            button1 =
                YES,

            button2 =
                NO,

            timeout = 0,

            whileDead = true,

            hideOnEscape = true,

            preferredIndex = 3,

            OnAccept = function(
                popup
            )

                local currentRequest =
                    popup.request

                if not currentRequest then
                    return
                end

                local success =
                    GBM.Requests.Cancel(
                        currentRequest.id
                    )

                if success then

                    RequestsUI.Refresh()

                end

                popup.request =
                    nil

            end,

            OnHide = function(
                popup
            )

                popup.request =
                    nil

            end,

        }

    end

    local popup =
        StaticPopup_Show(
            dialogName,
            request.amount or 0,
            request.itemName or "?"
        )

    if popup then

        popup.request =
            request

    end

end

function RequestsUI.CreateRequestRow(
    parent,
    request
)

    local row =
        CreateFrame(
            "Frame",
            nil,
            parent,
            "BackdropTemplate"
        )

    row:SetHeight(
        ROW_HEIGHT
    )

    row.request =
        request

    row:SetBackdrop({
        bgFile =
            "Interface\\Tooltips\\UI-Tooltip-Background",

        edgeFile =
            "Interface\\Tooltips\\UI-Tooltip-Border",

        edgeSize = 1,
    })

    row:SetBackdropColor(
        0,
        0,
        0,
        0.20
    )

    row.icon =
        row:CreateTexture(
            nil,
            "ARTWORK"
        )

    row.icon:SetSize(
        ICON_SIZE,
        ICON_SIZE
    )

    row.icon:SetPoint(
        "LEFT",
        5,
        0
    )

    row.itemName =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.itemName:SetPoint(
        "LEFT",
        ITEM_OFFSET,
        0
    )

    row.itemName:SetWidth(
        ITEM_WIDTH
    )

    row.itemName:SetJustifyH(
        "LEFT"
    )

    row.itemTooltip =
        CreateFrame(
            "Frame",
            nil,
            row
        )

    row.itemTooltip:SetPoint(
        "LEFT",
        5,
        0
    )

    row.itemTooltip:SetSize(
        ITEM_WIDTH + 40,
        ROW_HEIGHT
    )

    row.itemTooltip:EnableMouse(
        true
    )

    SetupItemTooltip(
        row.itemTooltip,
        request.itemID
    )

    row.requestAmount =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.requestAmount:SetPoint(
        "LEFT",
        AMOUNT_OFFSET,
        0
    )

    row.requestAmount:SetWidth(
        AMOUNT_WIDTH
    )

    row.requestAmount:SetJustifyH(
        "CENTER"
    )

    row.ownAmount =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.ownAmount:SetPoint(
        "LEFT",
        STOCK_OFFSET,
        0
    )

    row.ownAmount:SetWidth(
        STOCK_WIDTH
    )

    row.ownAmount:SetJustifyH(
        "CENTER"
    )

    row.requestedBy =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.requestedBy:SetPoint(
        "LEFT",
        REQUESTER_OFFSET,
        0
    )

    row.requestedBy:SetWidth(
        REQUESTER_WIDTH
    )

    row.requestedBy:SetJustifyH(
        "LEFT"
    )

    row.acceptButton =
        CreateButton(
            row,
            "Interface\\Buttons\\UI-CheckBox-Check"
        )

    row.acceptButton:SetPoint(
        "RIGHT",
        -105,
        0
    )

    row.acceptButton:SetScript(
        "OnClick",
        function()

            if IsCurrentBankChar() then

                local bankChar =
                    GetCurrentBankChar()

                if not bankChar then
                    return
                end

                AcceptRequest(
                    request,
                    bankChar
                )

                return

            end

            if not CanAssignRequests() then
                return
            end

            ShowBankCharMenu(
                row.acceptButton,
                request
            )

        end
    )

    row.rejectButton =
        CreateButton(
            row,
            "Interface\\RaidFrame\\ReadyCheck-NotReady"
        )

    row.rejectButton:SetPoint(
        "RIGHT",
        -70,
        0
    )

    row.rejectButton:SetScript(
        "OnClick",
        function()

            RequestsUI.ShowRejectDialog(
                request
            )

        end
    )

    row.cancelButton =
        CreateButton(
            row,
            "Interface\\Buttons\\UI-GroupLoot-Pass-Down"
        )

    row.cancelButton:SetPoint(
        "RIGHT",
        -35,
        0
    )

    row.cancelButton:SetScript(
        "OnClick",
        function()

            ShowCancelConfirmation(
                request
            )

        end
    )

    function row:Refresh()

        local itemInfo =
            GetItemData(
                request.itemID
            )

        self.icon:SetTexture(
            itemInfo
            and itemInfo.texture
            or "Interface\\Icons\\INV_Misc_QuestionMark"
        )

        self.itemName:SetText(
            itemInfo
            and itemInfo.name
            or string.format(
                GBM.L.REQUESTS_UNKNOWN_ITEM,
                request.itemID
            )
        )

        ApplyItemQualityColor(
            self.itemName,
            itemInfo
            and itemInfo.quality
        )

        self.requestAmount:SetText(
            tostring(
                request.amount
                or 0
            )
        )

        self.ownAmount:SetText(
            tostring(
                GetOwnAmount(
                    request
                )
            )
        )

        SetClassColoredName(
            self.requestedBy,
            request.requestedBy
        )

        local open =
            request.status
            == "reserved"

        self.acceptButton:Hide()
        self.rejectButton:Hide()
        self.cancelButton:Hide()

        if not open then
            return
        end

        if CanAccept(
            request
        ) then

            self.acceptButton:Show()

        end

        if CanReject() then

            self.rejectButton:Show()

        end

        if CanCancel(
            request
        ) then

            self.cancelButton:Show()

        end

    end

    row:Refresh()

    return row

end