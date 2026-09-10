local GBM = GBM

GBM.UI = {}
local UI = GBM.UI

local WINDOW_WIDTH = 900
local WINDOW_HEIGHT = 600

local TAB_WIDTH = 160
local TAB_HEIGHT = 32

local function CreateMainFrame()

    local frame = CreateFrame(
        "Frame",
        "GBMMainFrame",
        UIParent,
        "BasicFrameTemplateWithInset"
    )

    frame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    frame:SetPoint("CENTER")

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.TitleText:SetText("GuildBankManager")

    frame:Hide()

    return frame
end

local function CreateContent(frame)

    local content = CreateFrame(
        "Frame",
        nil,
        frame
    )

    content:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        10,
        -35
    )

    content:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        -10,
        TAB_HEIGHT + 10
    )

    UI.Content = content

    return content
end

local function CreateViews()

    UI.Views = {}

    local viewNames = {
        "bank",
        "requests",
        "statistics",
        "usage",
        "settings",
    }

    for _, viewName in ipairs(viewNames) do

        local view = CreateFrame(
            "Frame",
            nil,
            UI.Content
        )

        view:SetAllPoints()

        view:Hide()

        UI.Views[viewName] = view
    end
end

local function CreateTab(parent, text, id)

    local tab = CreateFrame(
        "Button",
        nil,
        parent
    )

    tab:SetHeight(TAB_HEIGHT)

    tab.Text = tab:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    tab.Text:SetPoint("CENTER")
    tab.Text:SetText(text)

    tab.Background = tab:CreateTexture(
        nil,
        "BACKGROUND"
    )

    tab.Background:SetAllPoints()

    tab.Background:SetColorTexture(
        0.12,
        0.12,
        0.12,
        0.9
    )

    tab.Highlight = tab:CreateTexture(
        nil,
        "HIGHLIGHT"
    )

    tab.Highlight:SetAllPoints()

    tab.Highlight:SetColorTexture(
        1,
        1,
        1,
        0.08
    )

    tab.Active = tab:CreateTexture(
        nil,
        "ARTWORK"
    )

    tab.Active:SetPoint(
        "BOTTOMLEFT",
        tab,
        "BOTTOMLEFT",
        0,
        0
    )

    tab.Active:SetPoint(
        "BOTTOMRIGHT",
        tab,
        "BOTTOMRIGHT",
        0,
        0
    )

    tab.Active:SetHeight(3)

    tab.Active:SetColorTexture(
        0.8,
        0.6,
        0.1,
        1
    )

    tab.Active:Hide()

    tab:SetScript("OnClick", function()

        UI.ShowView(id)

    end)

    return tab
end

local function CreateTabs(frame)

    local tabs = CreateFrame(
        "Frame",
        nil,
        frame
    )

    tabs:SetPoint(
        "BOTTOMLEFT",
        frame,
        "BOTTOMLEFT",
        10,
        0
    )

    tabs:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        -10,
        0
    )

    tabs:SetHeight(TAB_HEIGHT)

    UI.Tabs = tabs
    UI.TabButtons = {}

    local tabData = {
        {
            id = "bank",
            text = "Bank",
        },
        {
            id = "requests",
            text = "Anfragen",
        },
        {
            id = "statistics",
            text = "Statistik",
        },
        {
            id = "usage",
            text = "Nutzung",
        },
        {
            id = "settings",
            text = "Einstellungen",
        },
    }

    local tabWidth = tabs:GetWidth() / #tabData

    for index, data in ipairs(tabData) do

        local tab = CreateTab(
            tabs,
            data.text,
            data.id
        )

        tab:SetWidth(tabWidth)

        tab:SetPoint(
            "BOTTOMLEFT",
            tabs,
            "BOTTOMLEFT",
            (index - 1) * tabWidth,
            0
        )

        UI.TabButtons[data.id] = tab

    end
end

local function UpdateTabs(activeView)

    for id, tab in pairs(UI.TabButtons) do

        if id == activeView then

            tab.Active:Show()
            tab.Text:SetFontObject("GameFontHighlight")

        else

            tab.Active:Hide()
            tab.Text:SetFontObject("GameFontNormal")

        end
    end
end

function UI.ShowView(viewName)

    local view = UI.Views[viewName]

    if not view then
        return
    end

    for _, otherView in pairs(UI.Views) do
        otherView:Hide()
    end

    view:Show()

    UI.ActiveView = viewName

    UpdateTabs(viewName)

end

function UI.Show()

    if not UI.MainFrame then
        return
    end

    UI.MainFrame:Show()

    UI.ShowView("bank")

end

function UI.Hide()

    if not UI.MainFrame then
        return
    end

    UI.MainFrame:Hide()

end

function UI.Initialize()

    local frame = CreateMainFrame()

    UI.MainFrame = frame

    CreateContent(frame)
    CreateViews()
    CreateTabs(frame)

    UI.Bank.Initialize()
end