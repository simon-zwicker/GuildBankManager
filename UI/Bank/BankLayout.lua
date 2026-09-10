local GBM = GBM

local UI = GBM.UI
local Bank = UI.Bank

UI.BankLayout = {}

local BankLayout = UI.BankLayout

local L = GBM.L

local ICON_OFFSET = 5
local ITEM_TEXT_OFFSET = 48

local ITEM_TO_TOTAL_GAP = 10

local TOTAL_X = 520
local TOTAL_WIDTH = 60

local BANKCHAR_X = 590
local BANKCHAR_WIDTH = 190

local RESERVED_X = 790
local RESERVED_WIDTH = 70

local AVAILABLE_X = 870
local AVAILABLE_WIDTH = 60

local REQUEST_X = 940
local REQUEST_WIDTH = 82

local HEADER_HEIGHT = 26

local HEADER_OFFSET = 32

local HEADER_FONT_SIZE = 12

local function GetItemWidth()

    return math.max(
        TOTAL_X
            - ITEM_TEXT_OFFSET
            - ITEM_TO_TOTAL_GAP,
        50
    )

end

local function CreateHeaderText(
    parent,
    text,
    width
)

    local fontString =
        parent:CreateFontString(
            nil,
            "OVERLAY"
        )

    fontString:SetFont(
        STANDARD_TEXT_FONT,
        HEADER_FONT_SIZE,
        "OUTLINE"
    )

    fontString:SetText(
        text
    )

    fontString:SetWidth(
        width
    )

    fontString:SetJustifyV(
        "MIDDLE"
    )

    fontString:SetWordWrap(
        false
    )

    return fontString

end

local function ClearHeaderPoints()

    Bank.Header.Item:ClearAllPoints()
    Bank.Header.Total:ClearAllPoints()
    Bank.Header.BankChars:ClearAllPoints()
    Bank.Header.Reserved:ClearAllPoints()
    Bank.Header.Available:ClearAllPoints()
    Bank.Header.Request:ClearAllPoints()

end

local function ClearRowPoints(
    row
)

    row.Item:ClearAllPoints()
    row.Total:ClearAllPoints()
    row.BankChars:ClearAllPoints()
    row.Reserved:ClearAllPoints()
    row.Available:ClearAllPoints()
    row.Request:ClearAllPoints()

end

local function ApplyLayout(
    container,
    item,
    total,
    bankChars,
    reserved,
    available,
    request
)

    local itemWidth =
        GetItemWidth()

    item:SetPoint(
        "LEFT",
        container,
        "LEFT",
        ITEM_TEXT_OFFSET,
        0
    )

    item:SetWidth(
        itemWidth
    )

    item:SetJustifyH(
        "LEFT"
    )

    total:SetPoint(
        "LEFT",
        container,
        "LEFT",
        TOTAL_X,
        0
    )

    total:SetWidth(
        TOTAL_WIDTH
    )

    total:SetJustifyH(
        "RIGHT"
    )

    bankChars:SetPoint(
        "LEFT",
        container,
        "LEFT",
        BANKCHAR_X,
        0
    )

    bankChars:SetWidth(
        BANKCHAR_WIDTH
    )

    bankChars:SetJustifyH(
        "RIGHT"
    )

    reserved:SetPoint(
        "LEFT",
        container,
        "LEFT",
        RESERVED_X,
        0
    )

    reserved:SetWidth(
        RESERVED_WIDTH
    )

    reserved:SetJustifyH(
        "RIGHT"
    )

    available:SetPoint(
        "LEFT",
        container,
        "LEFT",
        AVAILABLE_X,
        0
    )

    available:SetWidth(
        AVAILABLE_WIDTH
    )

    available:SetJustifyH(
        "RIGHT"
    )

    request:SetPoint(
        "LEFT",
        container,
        "LEFT",
        REQUEST_X,
        0
    )

    request:SetSize(
        REQUEST_WIDTH,
        24
    )

end

function BankLayout.CreateHeader()

    local header =
        CreateFrame(
            "Frame",
            nil,
            Bank.Frame
        )

    header:SetHeight(
        HEADER_HEIGHT
    )

    header:SetPoint(
        "TOPLEFT",
        Bank.ScrollFrame,
        "TOPLEFT",
        0,
        HEADER_OFFSET
    )

    header:SetPoint(
        "TOPRIGHT",
        Bank.ScrollFrame,
        "TOPRIGHT",
        0,
        HEADER_OFFSET
    )

    Bank.Header =
        header

    header.Item =
        CreateHeaderText(
            header,
            L.ITEM,
            GetItemWidth()
        )

    header.Total =
        CreateHeaderText(
            header,
            L.TOTAL,
            TOTAL_WIDTH
        )

    header.BankChars =
        CreateHeaderText(
            header,
            L.BANK_CHARS,
            BANKCHAR_WIDTH
        )

    header.Reserved =
        CreateHeaderText(
            header,
            L.RESERVED,
            RESERVED_WIDTH
        )

    header.Available =
        CreateHeaderText(
            header,
            L.AVAILABLE,
            AVAILABLE_WIDTH
        )

    header.Request =
        CreateHeaderText(
            header,
            L.REQUEST,
            REQUEST_WIDTH
        )

    BankLayout.UpdateHeader()

end

function BankLayout.UpdateHeader()

    if not Bank.Header then
        return
    end

    ClearHeaderPoints()

    ApplyLayout(
        Bank.Header,
        Bank.Header.Item,
        Bank.Header.Total,
        Bank.Header.BankChars,
        Bank.Header.Reserved,
        Bank.Header.Available,
        Bank.Header.Request
    )

end

function BankLayout.UpdateRow(
    row
)

    if not row then
        return
    end

    ClearRowPoints(
        row
    )

    ApplyLayout(
        row,
        row.Item,
        row.Total,
        row.BankChars,
        row.Reserved,
        row.Available,
        row.Request
    )

end

function BankLayout.UpdateListWidth()

    if not Bank.ScrollFrame then
        return
    end

    if not Bank.Content then
        return
    end

    local width =
        Bank.ScrollFrame:GetWidth()

    if not width or width <= 0 then
        return
    end

    local requiredWidth =
        REQUEST_X
        + REQUEST_WIDTH
        + 10

    Bank.Content:SetWidth(
        math.max(
            width,
            requiredWidth
        )
    )

    BankLayout.UpdateHeader()

    for _, row in ipairs(
        Bank.Rows or {}
    ) do

        BankLayout.UpdateRow(
            row
        )

    end

end

function BankLayout.GetItemWidth()

    return GetItemWidth()

end

function BankLayout.GetTotalWidth()

    return TOTAL_WIDTH

end

function BankLayout.GetBankCharWidth()

    return BANKCHAR_WIDTH

end

function BankLayout.GetReservedWidth()

    return RESERVED_WIDTH

end

function BankLayout.GetAvailableWidth()

    return AVAILABLE_WIDTH

end

function BankLayout.GetRequestWidth()

    return REQUEST_WIDTH

end