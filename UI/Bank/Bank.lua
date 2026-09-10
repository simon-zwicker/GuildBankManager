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

local function EnsureRows(
    count
)

    for index = 1, count do

        if not Bank.Rows[index] then

            Bank.Rows[index] =
                Bank.RowsModule.Create()

            local row =
                Bank.Rows[index]

            row:SetPoint(
                "TOPLEFT",
                Bank.Content,
                "TOPLEFT",
                0,
                -(index - 1)
                    * ROW_HEIGHT
            )

            row:SetPoint(
                "TOPRIGHT",
                Bank.Content,
                "TOPRIGHT",
                0,
                -(index - 1)
                    * ROW_HEIGHT
            )

        end

    end

end

local function HideRows()

    for _, row in ipairs(
        Bank.Rows
    ) do

        row:Hide()

    end

end

local function UpdateContentHeight(
    count
)

    Bank.Content:SetHeight(
        math.max(
            count * ROW_HEIGHT,
            1
        )
    )

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

    UpdateContentHeight(
        #itemIDs
    )

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

    Bank.Layout.CreateHeader()

    Bank.Layout.UpdateListWidth()

    Bank.Refresh()

end