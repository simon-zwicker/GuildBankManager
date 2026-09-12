local GBM = GBM

local UI = GBM.UI

UI.Bank = {}

local Bank = UI.Bank

local L = GBM.L

local ROW_HEIGHT = 42

local WINDOW_PADDING = 20

local LIST_TOP = -116

local function CreateTitle()

    local title =
        Bank.Frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    title:SetPoint(
        "TOPLEFT",
        Bank.Frame,
        "TOPLEFT",
        WINDOW_PADDING,
        -45
    )

    title:SetText(
        L.BANK
    )

    Bank.Title =
        title

end

local function CreateSearch()

    local search =
        CreateFrame(
            "EditBox",
            nil,
            Bank.Frame,
            "InputBoxTemplate"
        )

    search:SetSize(
        300,
        30
    )

    search:SetPoint(
        "TOPRIGHT",
        Bank.Frame,
        "TOPRIGHT",
        -WINDOW_PADDING,
        -42
    )

    search:SetAutoFocus(
        false
    )

    search:SetTextInsets(
        8,
        8,
        0,
        0
    )

    search:SetScript(
        "OnTextChanged",
        function()

            Bank.Refresh()

        end
    )

    Bank.Search =
        search

end

local function CreateDivider()

    local divider =
        Bank.Frame:CreateTexture(
            nil,
            "ARTWORK"
        )

    divider:SetColorTexture(
        1,
        1,
        1,
        0.08
    )

    divider:SetHeight(
        1
    )

    divider:SetPoint(
        "TOPLEFT",
        Bank.Frame,
        "TOPLEFT",
        WINDOW_PADDING,
        -78
    )

    divider:SetPoint(
        "TOPRIGHT",
        Bank.Frame,
        "TOPRIGHT",
        -WINDOW_PADDING,
        -78
    )

    Bank.Divider =
        divider

end

local function CreateList()

    local scrollFrame =
        CreateFrame(
            "ScrollFrame",
            nil,
            Bank.Frame,
            "UIPanelScrollFrameTemplate"
        )

    scrollFrame:SetPoint(
        "TOPLEFT",
        Bank.Frame,
        "TOPLEFT",
        WINDOW_PADDING,
        LIST_TOP
    )

    scrollFrame:SetPoint(
        "BOTTOMRIGHT",
        Bank.Frame,
        "BOTTOMRIGHT",
        -35,
        WINDOW_PADDING
    )

    local content =
        CreateFrame(
            "Frame",
            nil,
            scrollFrame
        )

    content:SetSize(
        1,
        1
    )

    scrollFrame:SetScrollChild(
        content
    )

    Bank.ScrollFrame =
        scrollFrame

    Bank.Content =
        content

    Bank.Rows =
        {}

    scrollFrame:SetScript(
        "OnSizeChanged",
        function()

            if Bank.Layout then

                Bank.Layout.UpdateListWidth()

            end

        end
    )

end

local function CreateEmptyMessage()

    local message =
        Bank.Content:CreateFontString(
            nil,
            "OVERLAY"
        )

    message:SetFont(
        "Fonts\\FRIZQT__.TTF",
        22,
        ""
    )

    message:SetPoint(
        "TOP",
        Bank.Content,
        "TOP",
        0,
        -20
    )

    message:SetWidth(
        500
    )

    message:SetJustifyH(
        "CENTER"
    )

    message:SetJustifyV(
        "TOP"
    )

    message:Hide()

    Bank.EmptyMessage =
        message

end

local function ShowEmptyMessage(
    text
)

    if not Bank.EmptyMessage then
        return
    end

    Bank.EmptyMessage:SetText(
        text
    )

    Bank.EmptyMessage:Show()

end

local function HideEmptyMessage()

    if Bank.EmptyMessage then

        Bank.EmptyMessage:Hide()

    end

end

local function EnsureRows(
    count
)

    for index = 1, count do

        if not Bank.Rows[index] then

            Bank.Rows[index] =
                Bank.RowsModule.Create()

        end

    end

end

local function HideRows()

    for _, row in ipairs(
        Bank.Rows
    ) do

        Bank.RowsModule.Hide(
            row
        )

    end

end

local function IsItemVisible(
    itemIDs,
    itemID
)

    if not itemID then
        return false
    end

    for _, visibleItemID in ipairs(
        itemIDs
    ) do

        if visibleItemID == itemID then

            return true

        end

    end

    return false

end

local function CalculateLayout(
    itemCount
)

    local offset = 0

    for index = 1, itemCount do

        local row =
            Bank.Rows[index]

        Bank.RowsModule.SetPosition(
            row,
            offset
        )

        offset =
            offset
            + Bank.RowsModule.GetHeight(
                row
            )

    end

    return offset

end

local function UpdateContentHeight(
    height
)

    Bank.Content:SetHeight(
        math.max(
            height,
            1
        )
    )

end

local function HasBankChars()

    local db =
        GBM.GuildDB.Get()

    if not db
        or not db.bankChars then

        return false

    end

    return next(
        db.bankChars
    ) ~= nil

end

function Bank.Refresh()

    if not Bank.Search then
        return
    end

    local searchText =
        Bank.Search:GetText()

    local itemIDs =
        Bank.Data.GetFilteredItems(
            searchText
        )

    HideEmptyMessage()

    if Bank.ExpandedRow
        and not IsItemVisible(
            itemIDs,
            Bank.ExpandedRow.ItemID
        ) then

        Bank.RowsModule.Hide(
            Bank.ExpandedRow
        )

        Bank.ExpandedRow =
            nil

    end

    HideRows()

    EnsureRows(
        #itemIDs
    )

    for index, itemID in ipairs(
        itemIDs
    ) do

        local overview =
            GBM.BankDB.GetItemOverview(
                itemID
            )

        if overview then

            local row =
                Bank.Rows[index]

            Bank.RowsModule.Update(
                row,
                itemID,
                overview
            )

        end

    end

    local contentHeight =
        CalculateLayout(
            #itemIDs
        )

    UpdateContentHeight(
        contentHeight
    )

    if #itemIDs == 0 then

        if searchText ~= "" then

            ShowEmptyMessage(
                L.BANK_NO_SEARCH_RESULTS
            )

        elseif not HasBankChars() then

            ShowEmptyMessage(
                L.BANK_NO_BANKCHARS
            )

        else

            ShowEmptyMessage(
                L.BANK_EMPTY
            )

        end

    end

    if Bank.Layout then

        Bank.Layout.UpdateListWidth()

    end

end

function Bank.Initialize()

    Bank.Frame =
        UI.Views.bank

    Bank.Data =
        UI.BankData

    Bank.Layout =
        UI.BankLayout

    Bank.RowsModule =
        UI.BankRows

    CreateTitle()

    CreateSearch()

    CreateDivider()

    CreateList()

    CreateEmptyMessage()

    Bank.Layout.CreateHeader()

    Bank.Layout.UpdateListWidth()

    Bank.Refresh()

end