local GBM = GBM

GBM.UI = GBM.UI or {}
GBM.UI.Requests = GBM.UI.Requests or {}

local RequestsUI = GBM.UI.Requests

local ROW_HEIGHT = 42
local ICON_SIZE = 32

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

    local menuName =
        "GBMRequestBankCharDropdown"

    local menu =
        CreateFrame(
            "Frame",
            menuName,
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
                    bankChar

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

            OnAccept = function()

                local success =
                    GBM.Requests.Cancel(
                        request.id
                    )

                if success then

                    RequestsUI.Refresh()

                end

            end,

        }

    end

    StaticPopup_Show(
        dialogName,
        request.amount or 0,
        request.itemName or "?"
    )

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

    local itemInfo =
        GetItemData(
            request.itemID
        )

    row.icon:SetTexture(
        itemInfo
        and itemInfo.texture
        or "Interface\\Icons\\INV_Misc_QuestionMark"
    )

    row.itemName =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.itemName:SetPoint(
        "LEFT",
        row.icon,
        "RIGHT",
        8,
        0
    )

    row.itemName:SetWidth(
        220
    )

    row.itemName:SetJustifyH(
        "LEFT"
    )

    row.itemName:SetText(
        itemInfo
        and itemInfo.name
        or (
            "Item "
            .. tostring(
                request.itemID
            )
        )
    )

    row.requestAmount =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.requestAmount:SetWidth(
        70
    )

    row.requestAmount:SetPoint(
        "LEFT",
        row.itemName,
        "RIGHT",
        10,
        0
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

    row.ownAmount:SetWidth(
        70
    )

    row.ownAmount:SetPoint(
        "LEFT",
        row.requestAmount,
        "RIGHT",
        5,
        0
    )

    row.ownAmount:SetJustifyH(
        "CENTER"
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

        local currentItemInfo =
            GetItemData(
                request.itemID
            )

        self.icon:SetTexture(
            currentItemInfo
            and currentItemInfo.texture
            or "Interface\\Icons\\INV_Misc_QuestionMark"
        )

        self.itemName:SetText(
            currentItemInfo
            and currentItemInfo.name
            or (
                "Item "
                .. tostring(
                    request.itemID
                )
            )
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