local GBM = GBM
local UI = GBM.UI

UI.Bank = {}
local Bank = UI.Bank

local function CreateTitle(parent)

    local title = parent:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalLarge"
    )

    title:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        -10
    )

    title:SetText("Bank")

    return title
end

local function CreateSearch(parent)

    local search = CreateFrame(
        "EditBox",
        nil,
        parent,
        "InputBoxTemplate"
    )

    search:SetSize(350, 30)

    search:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        -45
    )

    search:SetAutoFocus(false)

    search:SetTextInsets(8, 8, 0, 0)

    search:SetScript("OnTextChanged", function()

        Bank.Refresh()

    end)

    Bank.Search = search

    return search
end

local function CreateBankCharLabel(parent)

    local label = parent:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    label:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        -140,
        -55
    )

    label:SetText("Bankchar:")

    Bank.BankCharLabel = label

    return label
end

local function CreateBankCharSelector(parent)

    local selector = CreateFrame(
        "Button",
        nil,
        parent,
        "UIPanelButtonTemplate"
    )

    selector:SetSize(120, 26)

    selector:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        -10,
        -45
    )

    selector:SetText("Alle")

    Bank.BankCharSelector = selector

    return selector
end

local function CreateHeader(parent)

    local header = CreateFrame(
        "Frame",
        nil,
        parent
    )

    header:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        -85
    )

    header:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        -10,
        -85
    )

    header:SetHeight(28)

    local item = header:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    item:SetPoint(
        "LEFT",
        10,
        0
    )

    item:SetText("Item")

    local total = header:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    total:SetPoint(
        "RIGHT",
        -260,
        0
    )

    total:SetText("Gesamt")

    local reserved = header:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    reserved:SetPoint(
        "RIGHT",
        -130,
        0
    )

    reserved:SetText("Reserviert")

    local available = header:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    available:SetPoint(
        "RIGHT",
        -10,
        0
    )

    available:SetText("Frei")

    Bank.Header = header

    return header
end

local function CreateDivider(parent)

    local divider = parent:CreateTexture(
        nil,
        "ARTWORK"
    )

    divider:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        -113
    )

    divider:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        -10,
        -113
    )

    divider:SetHeight(1)

    divider:SetColorTexture(
        1,
        1,
        1,
        0.15
    )

    Bank.Divider = divider

    return divider
end

local function CreateList(parent)

    local list = CreateFrame(
        "Frame",
        nil,
        parent
    )

    list:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        -120
    )

    list:SetPoint(
        "BOTTOMRIGHT",
        parent,
        "BOTTOMRIGHT",
        -10,
        10
    )

    Bank.List = list

    return list
end

function Bank.Refresh()

    if not Bank.List then
        return
    end

    -- Die eigentliche Item-Liste kommt später
    -- über den BankScanner und die BankDB.

end

function Bank.Initialize()

    local view = UI.Views.bank

    if not view then
        return
    end

    CreateTitle(view)
    CreateSearch(view)
    CreateBankCharLabel(view)
    CreateBankCharSelector(view)
    CreateHeader(view)
    CreateDivider(view)
    CreateList(view)

end