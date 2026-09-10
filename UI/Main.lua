local GBM = GBM

GBM.UI = {}

local UI = GBM.UI

local L = GBM.L

local WINDOW_WIDTH = 1100
local WINDOW_HEIGHT = 700

local TAB_HEIGHT = 38
local TAB_GAP = 4

local TAB_FONT_SIZE = 14

local function CreateMainFrame()

    local frame = CreateFrame(
        "Frame",
        "GBMMainFrame",
        UIParent,
        "BasicFrameTemplateWithInset"
    )

    frame:SetSize(
        WINDOW_WIDTH,
        WINDOW_HEIGHT
    )

    frame:SetPoint(
        "CENTER"
    )

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag(
        "LeftButton"
    )

    frame:SetScript(
        "OnDragStart",
        frame.StartMoving
    )

    frame:SetScript(
        "OnDragStop",
        frame.StopMovingOrSizing
    )

    frame:SetScript(
        "OnHide",
        function()

            if UI.Tabs then
                UI.Tabs:Hide()
            end

        end
    )

    frame.TitleText:SetText(
        L.ADDON_NAME
    )

    frame:Hide()

    return frame
end

local function CreateContent(
    frame
)

    local content =
        CreateFrame(
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
        10
    )

    UI.Content =
        content

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

    for _, viewName in ipairs(
        viewNames
    ) do

        local view =
            CreateFrame(
                "Frame",
                nil,
                UI.Content
            )

        view:SetAllPoints()

        view:Hide()

        UI.Views[viewName] =
            view

    end
end

local function CreateTab(
    parent,
    text,
    id
)

    local tab =
        CreateFrame(
            "Button",
            nil,
            parent
        )

    tab:SetHeight(
        TAB_HEIGHT
    )

    tab.Text =
        tab:CreateFontString(
            nil,
            "OVERLAY"
        )

    tab.Text:SetPoint(
        "CENTER"
    )

    tab.Text:SetFont(
        STANDARD_TEXT_FONT,
        TAB_FONT_SIZE,
        "OUTLINE"
    )

    tab.Text:SetText(
        text
    )

    tab.Background =
        tab:CreateTexture(
            nil,
            "BACKGROUND"
        )

    tab.Background:SetAllPoints()

    tab.Background:SetColorTexture(
        0.12,
        0.12,
        0.12,
        0.95
    )

    tab.Highlight =
        tab:CreateTexture(
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

    tab.Active =
        tab:CreateTexture(
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

    tab.Active:SetHeight(
        3
    )

    tab.Active:SetColorTexture(
        0.8,
        0.6,
        0.1,
        1
    )

    tab.Active:Hide()

    tab:SetScript(
        "OnClick",
        function()

            UI.ShowView(
                id
            )

        end
    )

    return tab
end

local function CreateTabs(
    frame
)

    local tabs =
        CreateFrame(
            "Frame",
            nil,
            frame
        )

    tabs:SetPoint(
        "TOPLEFT",
        frame,
        "BOTTOMLEFT",
        0,
        -TAB_GAP
    )

    tabs:SetWidth(
        WINDOW_WIDTH
    )

    tabs:SetHeight(
        TAB_HEIGHT
    )

    tabs:SetFrameStrata(
        frame:GetFrameStrata()
    )

    tabs:SetFrameLevel(
        frame:GetFrameLevel() + 1
    )

    UI.Tabs =
        tabs

    UI.TabButtons = {}

    local tabData = {
        {
            id = "bank",
            text = L.BANK,
        },
        {
            id = "requests",
            text = L.REQUESTS,
        },
        {
            id = "statistics",
            text = L.STATISTICS,
        },
        {
            id = "usage",
            text = L.USAGE,
        },
        {
            id = "settings",
            text = L.SETTINGS,
        },
    }

    local tabWidth =
        WINDOW_WIDTH
        / #tabData

    for index, data in ipairs(
        tabData
    ) do

        local tab =
            CreateTab(
                tabs,
                data.text,
                data.id
            )

        tab:SetWidth(
            tabWidth
        )

        tab:SetPoint(
            "TOPLEFT",
            tabs,
            "TOPLEFT",
            (index - 1) * tabWidth,
            0
        )

        UI.TabButtons[
            data.id
        ] = tab

    end
end

local function UpdateTabs(
    activeView
)

    for id, tab in pairs(
        UI.TabButtons
    ) do

        if id == activeView then
            tab.Active:Show()
        else
            tab.Active:Hide()
        end

        tab.Text:SetFont(
            STANDARD_TEXT_FONT,
            TAB_FONT_SIZE,
            "OUTLINE"
        )

    end
end

function UI.ShowView(
    viewName
)

    local view =
        UI.Views[viewName]

    if not view then
        return
    end

    for _, otherView in pairs(
        UI.Views
    ) do

        otherView:Hide()

    end

    view:Show()

    UI.ActiveView =
        viewName

    UpdateTabs(
        viewName
    )

end

function UI.Show()

    if not UI.MainFrame then
        return
    end

    UI.MainFrame:Show()

    UI.Tabs:Show()

    UI.ShowView(
        "bank"
    )

end

function UI.Hide()

    if not UI.MainFrame then
        return
    end

    UI.MainFrame:Hide()

    UI.Tabs:Hide()

end

function UI.Initialize()

    local frame =
        CreateMainFrame()

    UI.MainFrame =
        frame

    CreateContent(
        frame
    )

    CreateViews()

    CreateTabs(
        frame
    )

    UI.Tabs:Hide()

    UI.Bank.Initialize()
    -- UI.Requests.Initialize()
    -- UI.Statistics.Initialize()
    -- UI.Usage.Initialize()
    UI.Settings.Initialize()

end