local GBM = GBM

local UI = GBM.UI

UI.BankExtendedRow = {}

local BankExtendedRow = UI.BankExtendedRow

local L = GBM.L

local HEIGHT = 64

local PADDING = 12

local FONT_SIZE = 14
local ERROR_FONT_SIZE = 12

local BUTTON_HEIGHT = 28

local ERROR_WIDTH = 300

local function CreateText(
    parent
)

    local text =
        parent:CreateFontString(
            nil,
            "OVERLAY"
        )

    text:SetFont(
        STANDARD_TEXT_FONT,
        FONT_SIZE,
        "OUTLINE"
    )

    text:SetJustifyV(
        "MIDDLE"
    )

    return text

end

local function ShowError(
    row
)

    if not row.Error then
        return
    end

    row.Error:SetText(
        string.format(
            L.REQUEST_AMOUNT_ERROR,
            1,
            row.MaxAmount or 0
        )
    )

    row.Error:Show()

end

local function HideError(
    row
)

    if not row.Error then
        return
    end

    row.Error:SetText(
        ""
    )

    row.Error:Hide()

end

local function SetAmount(
    row,
    amount
)

    local maxAmount =
        row.MaxAmount
        or 0

    amount =
        math.floor(
            tonumber(amount)
            or 1
        )

    if maxAmount <= 0 then

        amount = 1

    else

        amount =
            math.max(
                1,
                amount
            )

        amount =
            math.min(
                maxAmount,
                amount
            )

    end

    row.Amount =
        amount

    row.AmountInput:SetText(
        amount
    )

end

local function GetValidatedAmount(
    row
)

    local maxAmount =
        row.MaxAmount
        or 0

    local text =
        row.AmountInput:GetText()

    local amount =
        tonumber(
            text
        )

    if not amount then

        ShowError(
            row
        )

        return nil

    end

    amount =
        math.floor(
            amount
        )

    if amount < 1
        or amount > maxAmount then

        ShowError(
            row
        )

        return nil

    end

    HideError(
        row
    )

    return amount

end

local function CreateBackground(
    row
)

    local background =
        row:CreateTexture(
            nil,
            "BACKGROUND"
        )

    background:SetAllPoints()

    background:SetColorTexture(
        1,
        1,
        1,
        0.035
    )

    row.Background =
        background

    local divider =
        row:CreateTexture(
            nil,
            "ARTWORK"
        )

    divider:SetColorTexture(
        1,
        1,
        1,
        0.10
    )

    divider:SetHeight(
        1
    )

    divider:SetPoint(
        "TOPLEFT",
        row,
        "TOPLEFT",
        0,
        0
    )

    divider:SetPoint(
        "TOPRIGHT",
        row,
        "TOPRIGHT",
        0,
        0
    )

end

function BankExtendedRow.Create(
    parent
)

    local row =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    row:SetHeight(
        HEIGHT
    )

    row:EnableMouse(
        true
    )

    CreateBackground(
        row
    )

    row.Title =
        CreateText(
            row
        )

    row.Title:SetPoint(
        "LEFT",
        row,
        "LEFT",
        PADDING,
        0
    )

    row.Title:SetJustifyH(
        "LEFT"
    )

    row.Available =
        CreateText(
            row
        )

    row.Available:SetPoint(
        "LEFT",
        row.Title,
        "RIGHT",
        18,
        0
    )

    row.Available:SetJustifyH(
        "LEFT"
    )

    row.AmountLabel =
        CreateText(
            row
        )

    row.AmountLabel:SetText(
        L.TOTAL .. ":"
    )

    row.AmountLabel:SetPoint(
        "LEFT",
        row.Available,
        "RIGHT",
        28,
        0
    )

    row.AmountLabel:SetJustifyH(
        "LEFT"
    )

    local minus =
        CreateFrame(
            "Button",
            nil,
            row,
            "UIPanelButtonTemplate"
        )

    minus:SetSize(
        30,
        BUTTON_HEIGHT
    )

    minus:SetPoint(
        "LEFT",
        row.AmountLabel,
        "RIGHT",
        8,
        0
    )

    minus:SetText(
        "-"
    )

    minus:SetScript(
        "OnClick",
        function()

            HideError(
                row
            )

            SetAmount(
                row,
                (row.Amount or 1) - 1
            )

        end
    )

    row.Minus =
        minus

    local input =
        CreateFrame(
            "EditBox",
            nil,
            row,
            "InputBoxTemplate"
        )

    input:SetSize(
        58,
        BUTTON_HEIGHT
    )

    input:SetPoint(
        "LEFT",
        minus,
        "RIGHT",
        5,
        0
    )

    input:SetAutoFocus(
        false
    )

    input:SetNumeric(
        true
    )

    input:SetJustifyH(
        "CENTER"
    )

    input:SetFont(
        STANDARD_TEXT_FONT,
        FONT_SIZE,
        "OUTLINE"
    )

    input:SetTextInsets(
        5,
        5,
        0,
        0
    )

    input:SetScript(
        "OnTextChanged",
        function()

            HideError(
                row
            )

        end
    )

    input:SetScript(
        "OnEnterPressed",
        function(self)

            local amount =
                tonumber(
                    self:GetText()
                )

            if amount then

                SetAmount(
                    row,
                    amount
                )

            else

                SetAmount(
                    row,
                    row.Amount or 1
                )

            end

            self:ClearFocus()

        end
    )

    input:SetScript(
        "OnEscapePressed",
        function(self)

            SetAmount(
                row,
                row.Amount or 1
            )

            HideError(
                row
            )

            self:ClearFocus()

        end
    )

    row.AmountInput =
        input

    local plus =
        CreateFrame(
            "Button",
            nil,
            row,
            "UIPanelButtonTemplate"
        )

    plus:SetSize(
        30,
        BUTTON_HEIGHT
    )

    plus:SetPoint(
        "LEFT",
        input,
        "RIGHT",
        5,
        0
    )

    plus:SetText(
        "+"
    )

    plus:SetScript(
        "OnClick",
        function()

            HideError(
                row
            )

            SetAmount(
                row,
                (row.Amount or 1) + 1
            )

        end
    )

    row.Plus =
        plus

    local cancel =
        CreateFrame(
            "Button",
            nil,
            row,
            "UIPanelButtonTemplate"
        )

    cancel:SetSize(
        95,
        BUTTON_HEIGHT
    )

    cancel:SetPoint(
        "RIGHT",
        row,
        "RIGHT",
        -PADDING,
        0
    )

    cancel:SetText(
        L.CANCEL
    )

    cancel:SetScript(
        "OnClick",
        function()

            if row.OnCancel then

                row.OnCancel(
                    row
                )

            end

        end
    )

    row.Cancel =
        cancel

    local submit =
        CreateFrame(
            "Button",
            nil,
            row,
            "UIPanelButtonTemplate"
        )

    submit:SetSize(
        95,
        BUTTON_HEIGHT
    )

    submit:SetPoint(
        "RIGHT",
        cancel,
        "LEFT",
        -8,
        0
    )

    submit:SetText(
        L.REQUEST
    )

    submit:SetScript(
        "OnClick",
        function()

            if not row.ItemID then
                return
            end

            local amount =
                GetValidatedAmount(
                    row
                )

            if not amount then
                return
            end

            local request,
                reason =
                GBM.Requests.Create(
                    row.ItemID,
                    amount
                )

            if not request then

                ShowError(
                    row
                )

                return

            end

            HideError(
                row
            )

            if row.OnRequestCreated then

                row.OnRequestCreated(
                    row,
                    request
                )

            end

        end
    )

    row.Submit =
        submit

    row.Error =
        row:CreateFontString(
            nil,
            "OVERLAY"
        )

    row.Error:SetFont(
        STANDARD_TEXT_FONT,
        ERROR_FONT_SIZE,
        "OUTLINE"
    )

    row.Error:SetTextColor(
        1,
        0.2,
        0.2
    )

    row.Error:SetWidth(
        ERROR_WIDTH
    )

    row.Error:SetJustifyH(
        "RIGHT"
    )

    row.Error:SetJustifyV(
        "MIDDLE"
    )

    row.Error:SetWordWrap(
        true
    )

    row.Error:SetMaxLines(
        2
    )

    row.Error:SetPoint(
        "RIGHT",
        submit,
        "LEFT",
        -12,
        0
    )

    row.Error:Hide()

    row:Hide()

    return row

end

function BankExtendedRow.SetRequestCreatedHandler(
    row,
    callback
)

    if not row then
        return
    end

    row.OnRequestCreated =
        callback

end

function BankExtendedRow.SetCancelHandler(
    row,
    callback
)

    if not row then
        return
    end

    row.OnCancel =
        callback

end

function BankExtendedRow.Update(
    row,
    itemID,
    itemName
)

    if not row then
        return
    end

    row.ItemID =
        itemID

    row.Title:SetText(
        L.REQUEST
        .. ": "
        .. (
            itemName
            or GetItemInfo(
                itemID
            )
            or ("Item " .. itemID)
        )
    )

    local available =
        GBM.Requests.GetAvailableAmount(
            itemID
        )

    row.MaxAmount =
        available
        or 0

    row.Available:SetText(
        L.AVAILABLE
        .. ": "
        .. row.MaxAmount
    )

    HideError(
        row
    )

    row.Submit:Enable()
    row.Minus:Enable()
    row.Plus:Enable()

    local amount =
        row.Amount
        or 1

    SetAmount(
        row,
        amount
    )

end

function BankExtendedRow.Show(
    row
)

    if not row then
        return
    end

    row:Show()

end

function BankExtendedRow.Hide(
    row
)

    if not row then
        return
    end

    HideError(
        row
    )

    row:Hide()

end

function BankExtendedRow.GetHeight()

    return HEIGHT

end