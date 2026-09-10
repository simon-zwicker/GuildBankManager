local GBM = GBM

local UI = GBM.UI
local Bank = UI.Bank

UI.BankNormalRow = {}

local BankNormalRow = UI.BankNormalRow

local L = GBM.L

local ROW_HEIGHT = 42
local ICON_SIZE = 36

local ITEM_FONT_SIZE = 14
local BANKCHAR_FONT_SIZE = 14

local function SetRowFont(
    row
)

    row.Item:SetFont(
        STANDARD_TEXT_FONT,
        ITEM_FONT_SIZE,
        "OUTLINE"
    )

    row.Total:SetFont(
        STANDARD_TEXT_FONT,
        ITEM_FONT_SIZE,
        "OUTLINE"
    )

    row.BankChars:SetFont(
        STANDARD_TEXT_FONT,
        BANKCHAR_FONT_SIZE,
        "OUTLINE"
    )

    row.Reserved:SetFont(
        STANDARD_TEXT_FONT,
        ITEM_FONT_SIZE,
        "OUTLINE"
    )

    row.Available:SetFont(
        STANDARD_TEXT_FONT,
        ITEM_FONT_SIZE,
        "OUTLINE"
    )

end

local function CreateText(
    row
)

    local text =
        row:CreateFontString(
            nil,
            "OVERLAY"
        )

    text:SetJustifyV(
        "MIDDLE"
    )

    return text

end

local function ShowTooltip(
    row
)

    if not row.ItemLink then
        return
    end

    GameTooltip:SetOwner(
        row,
        "ANCHOR_RIGHT"
    )

    GameTooltip:SetHyperlink(
        row.ItemLink
    )

    GameTooltip:Show()

end

local function HideTooltip()

    GameTooltip:Hide()

end

local function CreateRequestButton(
    row
)

    local button =
        CreateFrame(
            "Button",
            nil,
            row,
            "UIPanelButtonTemplate"
        )

    button:SetSize(
        82,
        24
    )

    button:SetText(
        L.REQUEST
    )

    button:SetScript(
        "OnClick",
        function()

            if not row.ItemID then
                return
            end

            if row.OnRequestClick then

                row.OnRequestClick(
                    row
                )

            end

        end
    )

    return button

end

local function SetBankCharText(
    row,
    overview
)

    local parts = {}

    for _, bankChar in ipairs(
        overview.bankChars or {}
    ) do

        local name =
            bankChar.name
            or ""

        local amount =
            bankChar.amount
            or 0

        local r, g, b =
            GBM.Utils.GetClassColor(
                nil
            )

        local guildDB =
            GBM.GuildDB.Get()

        local member =
            guildDB
            and guildDB.members
            and guildDB.members[name]

        if member then

            r, g, b =
                GBM.Utils.GetClassColor(
                    member.class
                )

        end

        local plainName =
            name:match(
                "^[^-]+"
            )

        local coloredName =
            string.format(
                "|cff%02x%02x%02x%s|r",
                r * 255,
                g * 255,
                b * 255,
                plainName or name
            )

        table.insert(
            parts,
            coloredName
            .. " ("
            .. amount
            .. ")"
        )

    end

    row.BankChars:SetText(
        table.concat(
            parts,
            ", "
        )
    )

end

function BankNormalRow.Create(
    parent
)

    local row =
        CreateFrame(
            "Button",
            nil,
            parent
        )

    row:SetHeight(
        ROW_HEIGHT
    )

    row:RegisterForClicks(
        "LeftButtonUp"
    )

    row.Icon =
        row:CreateTexture(
            nil,
            "ARTWORK"
        )

    row.Icon:SetSize(
        ICON_SIZE,
        ICON_SIZE
    )

    row.Icon:SetPoint(
        "LEFT",
        row,
        "LEFT",
        5,
        0
    )

    row.Item =
        CreateText(
            row
        )

    row.Item:SetJustifyH(
        "LEFT"
    )

    row.Item:SetWordWrap(
        false
    )

    row.Total =
        CreateText(
            row
        )

    row.Total:SetJustifyH(
        "RIGHT"
    )

    row.BankChars =
        CreateText(
            row
        )

    row.BankChars:SetJustifyH(
        "RIGHT"
    )

    row.BankChars:SetWordWrap(
        false
    )

    row.Reserved =
        CreateText(
            row
        )

    row.Reserved:SetJustifyH(
        "RIGHT"
    )

    row.Available =
        CreateText(
            row
        )

    row.Available:SetJustifyH(
        "RIGHT"
    )

    row.Request =
        CreateRequestButton(
            row
        )

    row:SetScript(
        "OnEnter",
        function(self)

            if not self.RequestOpen then

                ShowTooltip(
                    self
                )

            end

        end
    )

    row:SetScript(
        "OnLeave",
        function()

            HideTooltip()

        end
    )

    SetRowFont(
        row
    )

    return row

end

function BankNormalRow.Update(
    row,
    itemID,
    overview
)

    if not row then
        return
    end

    row.ItemID =
        itemID

    local itemName,
        link,
        quality,
        _,
        _,
        _,
        _,
        _,
        _,
        texture =
        GetItemInfo(
            itemID
        )

    row.ItemName =
        itemName

    row.ItemLink =
        link

    row.Icon:SetTexture(
        texture
    )

    row.Item:SetText(
        itemName
        or ("Item " .. itemID)
    )

    if quality then

        local color =
            ITEM_QUALITY_COLORS[
                quality
            ]

        if color then

            row.Item:SetTextColor(
                color.r,
                color.g,
                color.b
            )

        else

            row.Item:SetTextColor(
                1,
                1,
                1
            )

        end

    else

        row.Item:SetTextColor(
            1,
            1,
            1
        )

    end

    row.Total:SetText(
        overview.total
        or 0
    )

    SetBankCharText(
        row,
        overview
    )

    row.Reserved:SetText(
        overview.reserved
        or 0
    )

    row.Available:SetText(
        overview.available
        or 0
    )

    row:Show()

end

function BankNormalRow.SetRequestHandler(
    row,
    callback
)

    if not row then
        return
    end

    row.OnRequestClick =
        callback

end

BankNormalRow.ROW_HEIGHT =
    ROW_HEIGHT