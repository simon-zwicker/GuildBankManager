local GBM = GBM

GBM.UI = GBM.UI or {}
GBM.UI.Requests = GBM.UI.Requests or {}

local RequestsUI = GBM.UI.Requests

local ROW_HEIGHT = 42

local ICON_SIZE = 32

local function CreateButton(parent, texture)
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

    button.icon:SetTexture(texture)

    button:SetHighlightTexture(
        "Interface\\Buttons\\ButtonHilight-Square"
    )

    return button
end

local function SetButtonEnabled(button, enabled)
    if enabled then
        button:SetAlpha(1)
        button:Enable()
    else
        button:SetAlpha(0.35)
        button:Disable()
    end
end

local function GetItemInfo(itemID)
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
        GetItemInfo(itemID)

    return {
        name = itemName,
        link = itemLink,
        quality = itemQuality,
        texture = itemTexture,
    }
end

local function GetOwnAmount(request)
    if not request
        or not request.itemID then

        return 0
    end

    local playerName =
        UnitName("player")

    if not playerName then
        return 0
    end

    local realm =
        GetRealmName()

    local fullName =
        playerName
        .. "-"
        .. realm

    if GBM.BankDB
        and GBM.BankDB.GetAvailableAmount then

        return GBM.BankDB.GetAvailableAmount(
            fullName,
            request.itemID
        ) or 0
    end

    return 0
end

local function CanAccept(request)
    if not request then
        return false
    end

    if not GBM.Permissions then
        return false
    end

    if GBM.Permissions.CanAssignRequests
        and GBM.Permissions.CanAssignRequests() then

        return true
    end

    if not GBM.Permissions.IsBankChar
        or not GBM.Permissions.IsBankChar() then

        return false
    end

    local playerName =
        UnitName("player")

    local realm =
        GetRealmName()

    if not playerName
        or not realm then

        return false
    end

    local bankChar =
        playerName
        .. "-"
        .. realm

    if GBM.BankDB
        and GBM.BankDB.CanFulfill then

        return GBM.BankDB.CanFulfill(
            bankChar,
            request.itemID,
            request.amount
        )
    end

    return false
end

local function CanReject()
    return GBM.Permissions
        and GBM.Permissions.CanRejectRequests
        and GBM.Permissions.CanRejectRequests()
end

local function CanRemove(request)
    if not request then
        return false
    end

    local playerName =
        UnitName("player")

    local realm =
        GetRealmName()

    if not playerName
        or not realm then

        return false
    end

    local fullName =
        playerName
        .. "-"
        .. realm

    if request.requestedBy == fullName then
        return true
    end

    return GBM.Permissions
        and GBM.Permissions.CanManageRequests
        and GBM.Permissions.CanManageRequests()
end

local function GetCurrentBankChar()
    local playerName =
        UnitName("player")

    local realm =
        GetRealmName()

    if not playerName
        or not realm then

        return nil
    end

    return playerName
        .. "-"
        .. realm
end

function RequestsUI.CreateRequestRow(
    parent,
    request
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

    -- Item icon

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
        GetItemInfo(
            request.itemID
        )

    if itemInfo
        and itemInfo.texture then

        row.icon:SetTexture(
            itemInfo.texture
        )
    else
        row.icon:SetTexture(
            "Interface\\Icons\\INV_Misc_QuestionMark"
        )
    end

    -- Item name

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
        or ("Item " .. tostring(request.itemID))
    )

    -- Request amount

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

    row.requestAmount:SetText(
        tostring(
            request.amount
            or 0
        )
    )

    -- Own amount

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

    row.ownAmount:SetText(
        tostring(
            GetOwnAmount(
                request
            )
        )
    )

    -- Accept

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

            if not GBM.Requests
                or not GBM.Requests.Accept then

                return
            end

            local bankChar =
                GetCurrentBankChar()

            if not bankChar then
                return
            end

            local success =
                GBM.Requests.Accept(
                    request.id,
                    bankChar
                )

            if success
                and RequestsUI.Refresh then

                RequestsUI.Refresh()

            end

        end
    )

    -- Reject

    row.rejectButton =
        CreateButton(
            row,
            "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
        )

    row.rejectButton:SetPoint(
        "RIGHT",
        -70,
        0
    )

    row.rejectButton:SetScript(
        "OnClick",
        function()

            if RequestsUI.ShowRejectDialog then

                RequestsUI.ShowRejectDialog(
                    request
                )

            end

        end
    )

    -- Remove / Cancel

    row.removeButton =
        CreateButton(
            row,
            "Interface\\Buttons\\UI-GroupLoot-Pass-Down"
        )

    row.removeButton:SetPoint(
        "RIGHT",
        -35,
        0
    )

    row.removeButton:SetScript(
        "OnClick",
        function()

            if not GBM.Requests then
                return
            end

            if request.requestedBy
                == GetCurrentBankChar() then

                if GBM.Requests.Cancel then

                    GBM.Requests.Cancel(
                        request.id
                    )

                end

            elseif GBM.Requests.Delete then

                GBM.Requests.Delete(
                    request.id
                )

            end

            if RequestsUI.Refresh then
                RequestsUI.Refresh()
            end

        end
    )

    function row:Refresh()

        self.request =
            request

        local currentItemInfo =
            GetItemInfo(
                request.itemID
            )

        if currentItemInfo
            and currentItemInfo.texture then

            self.icon:SetTexture(
                currentItemInfo.texture
            )

        end

        self.itemName:SetText(
            currentItemInfo
            and currentItemInfo.name
            or ("Item " .. tostring(request.itemID))
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

        local status =
            request.status

        local open =
            status == "reserved"

        local accepted =
            status == "accepted"

        local canAccept =
            open
            and CanAccept(
                request
            )

        local canReject =
            open
            and CanReject()

        local canRemove =
            open
            and CanRemove(
                request
            )

        SetButtonEnabled(
            self.acceptButton,
            canAccept
        )

        SetButtonEnabled(
            self.rejectButton,
            canReject
        )

        SetButtonEnabled(
            self.removeButton,
            canRemove
        )

        self.acceptButton:Hide()
        self.rejectButton:Hide()
        self.removeButton:Hide()

        if open then

            if canAccept then
                self.acceptButton:Show()
            end

            if canReject then
                self.rejectButton:Show()
            end

            if canRemove then
                self.removeButton:Show()
            end

        elseif accepted then

            if canRemove then
                self.removeButton:Show()
            end

        end

    end

    row:Refresh()

    return row
end