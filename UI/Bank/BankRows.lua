local GBM = GBM

local UI = GBM.UI
local Bank = UI.Bank

UI.BankRows = {}

local BankRows = UI.BankRows

local ROW_HEIGHT = 42

local function GetExtendedRow(
    row
)

    if not row then
        return nil
    end

    return row.ExtendedRow

end

local function CloseRow(
    row
)

    if not row then
        return
    end

    row.RequestOpen =
        false

    local extendedRow =
        GetExtendedRow(
            row
        )

    if extendedRow then

        UI.BankExtendedRow.Hide(
            extendedRow
        )

    end

end

local function OpenRow(
    row
)

    if not row then
        return
    end

    if Bank.ExpandedRow
        and Bank.ExpandedRow ~= row then

        CloseRow(
            Bank.ExpandedRow
        )

    end

    Bank.ExpandedRow =
        row

    row.RequestOpen =
        true

    local extendedRow =
        GetExtendedRow(
            row
        )

    if not extendedRow then
        return
    end

    UI.BankExtendedRow.Update(
        extendedRow,
        row.ItemID,
        row.ItemName
    )

    UI.BankExtendedRow.Show(
        extendedRow
    )

end

local function ToggleRow(
    row
)

    if not row then
        return
    end

    if row.RequestOpen then

        CloseRow(
            row
        )

        if Bank.ExpandedRow == row then

            Bank.ExpandedRow =
                nil

        end

    else

        OpenRow(
            row
        )

    end

    Bank.Refresh()

end

local function CreateRows(
    parent
)

    local normalRow =
        UI.BankNormalRow.Create(
            parent
        )

    local extendedRow =
        UI.BankExtendedRow.Create(
            parent
        )

    normalRow.ExtendedRow =
        extendedRow

    UI.BankNormalRow.SetRequestHandler(
        normalRow,
        ToggleRow
    )

    UI.BankExtendedRow.SetRequestCreatedHandler(
        extendedRow,
        function()

            CloseRow(
                normalRow
            )

            if Bank.ExpandedRow
                == normalRow then

                Bank.ExpandedRow =
                    nil

            end

            Bank.Refresh()

        end
    )

    UI.BankExtendedRow.SetCancelHandler(
        extendedRow,
        function()

            CloseRow(
                normalRow
            )

            if Bank.ExpandedRow
                == normalRow then

                Bank.ExpandedRow =
                    nil

            end

            Bank.Refresh()

        end
    )

    return normalRow

end

function BankRows.Create()

    return CreateRows(
        Bank.Content
    )

end

function BankRows.Update(
    row,
    itemID,
    overview
)

    if not row then
        return
    end

    UI.BankNormalRow.Update(
        row,
        itemID,
        overview
    )

    local extendedRow =
        GetExtendedRow(
            row
        )

    if extendedRow
        and row.RequestOpen then

        UI.BankExtendedRow.Update(
            extendedRow,
            itemID,
            row.ItemName
        )

        UI.BankExtendedRow.Show(
            extendedRow
        )

    end

end

function BankRows.SetPosition(
    row,
    offset
)

    if not row then
        return
    end

    row:ClearAllPoints()

    row:SetPoint(
        "TOPLEFT",
        Bank.Content,
        "TOPLEFT",
        0,
        -offset
    )

    row:SetPoint(
        "TOPRIGHT",
        Bank.Content,
        "TOPRIGHT",
        0,
        -offset
    )

    local extendedRow =
        GetExtendedRow(
            row
        )

    if not extendedRow then
        return
    end

    extendedRow:ClearAllPoints()

    extendedRow:SetPoint(
        "TOPLEFT",
        Bank.Content,
        "TOPLEFT",
        0,
        -(offset + ROW_HEIGHT)
    )

    extendedRow:SetPoint(
        "TOPRIGHT",
        Bank.Content,
        "TOPRIGHT",
        0,
        -(offset + ROW_HEIGHT)
    )

end

function BankRows.GetHeight(
    row
)

    if not row then
        return ROW_HEIGHT
    end

    local height =
        ROW_HEIGHT

    if row.RequestOpen then

        height =
            height
            + UI.BankExtendedRow.GetHeight()

    end

    return height

end

function BankRows.Hide(
    row
)

    if not row then
        return
    end

    row:Hide()

    local extendedRow =
        GetExtendedRow(
            row
        )

    if extendedRow then

        UI.BankExtendedRow.Hide(
            extendedRow
        )

    end

end

BankRows.ROW_HEIGHT =
    ROW_HEIGHT