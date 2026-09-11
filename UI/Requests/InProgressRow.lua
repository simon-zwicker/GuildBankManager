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

local function IsOwner(
    request
)

    return request.acceptedBy
        == GBM.WoW.GetFullPlayerName()

end

local function CanReopen(
    request
)

    if IsOwner(
        request
    ) then

        return true

    end

    return GBM.Permissions
        and GBM.Permissions.CanManageRequests
        and GBM.Permissions.CanManageRequests()

end

function RequestsUI.CreateInProgressRow(
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

    row.amount =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.amount:SetWidth(
        70
    )

    row.amount:SetPoint(
        "LEFT",
        row.itemName,
        "RIGHT",
        10,
        0
    )

    row.amount:SetJustifyH(
        "CENTER"
    )

    row.amount:SetText(
        tostring(
            request.amount
            or 0
        )
    )

    row.acceptedBy =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.acceptedBy:SetPoint(
        "LEFT",
        row.amount,
        "RIGHT",
        5,
        0
    )

    row.acceptedBy:SetWidth(
        150
    )

    row.acceptedBy:SetJustifyH(
        "LEFT"
    )

    row.acceptedBy:SetText(
        request.acceptedBy
        or ""
    )

    -- Fulfill / Package

    row.fulfillButton =
        CreateButton(
            row,
            "Interface\\Buttons\\UI-GroupLoot-Dice-Up"
        )

    row.fulfillButton:SetPoint(
        "RIGHT",
        -105,
        0
    )

    row.fulfillButton:SetScript(
        "OnClick",
        function()

            if not IsOwner(
                request
            ) then

                return

            end

            local success =
                GBM.Requests.Fulfill(
                    request.id,
                    request.acceptedBy
                )

            if success then

                RequestsUI.Refresh()

            end

        end
    )

    -- Reopen

    row.reopenButton =
        CreateButton(
            row,
            "Interface\\Buttons\\UI-RefreshButton"
        )

    row.reopenButton:SetPoint(
        "RIGHT",
        -70,
        0
    )

    row.reopenButton:SetScript(
        "OnClick",
        function()

            local success =
                GBM.Requests.Reopen(
                    request.id
                )

            if success then

                RequestsUI.Refresh()

            end

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

        self.amount:SetText(
            tostring(
                request.amount
                or 0
            )
        )

        self.acceptedBy:SetText(
            request.acceptedBy
            or ""
        )

        self.fulfillButton:Hide()
        self.reopenButton:Hide()

        if request.status
            ~= "in_progress" then

            return

        end

        if IsOwner(
            request
        )
        and GBM.Permissions
        and GBM.Permissions.IsBankChar
        and GBM.Permissions.IsBankChar() then

            self.fulfillButton:Show()

        end

        if CanReopen(
            request
        ) then

            self.reopenButton:Show()

        end

    end

    row:Refresh()

    return row

end