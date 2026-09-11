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

local BANK_CHAR_OFFSET = 355
local BANK_CHAR_WIDTH = 150

local REQUESTER_OFFSET = 510
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

    row.amount =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.amount:SetPoint(
        "LEFT",
        AMOUNT_OFFSET,
        0
    )

    row.amount:SetWidth(
        AMOUNT_WIDTH
    )

    row.amount:SetJustifyH(
        "CENTER"
    )

    row.acceptedBy =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    row.acceptedBy:SetPoint(
        "LEFT",
        BANK_CHAR_OFFSET,
        0
    )

    row.acceptedBy:SetWidth(
        BANK_CHAR_WIDTH
    )

    row.acceptedBy:SetJustifyH(
        "LEFT"
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

    row.fulfillButton =
        CreateButton(
            row,
            "Interface\\Icons\\INV_Misc_Bag_08"
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

            if not GBM.Permissions
                or not GBM.Permissions.IsBankChar
                or not GBM.Permissions.IsBankChar() then

                return

            end

            local success =
                GBM.Requests.Fulfill(
                    request.id,
                    request.acceptedBy
                )

            if not success then
                return
            end

            RequestsUI.Refresh()

            if GBM.Bank
                and GBM.Bank.Sync then

                GBM.Bank.Sync()

            end

        end
    )

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
            or (
                "Item "
                .. tostring(
                    request.itemID
                )
            )
        )

        ApplyItemQualityColor(
            self.itemName,
            itemInfo
            and itemInfo.quality
        )

        self.amount:SetText(
            tostring(
                request.amount
                or 0
            )
        )

        SetClassColoredName(
            self.acceptedBy,
            request.acceptedBy
        )

        SetClassColoredName(
            self.requestedBy,
            request.requestedBy
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