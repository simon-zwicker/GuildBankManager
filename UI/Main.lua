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

    local frame =
        CreateFrame(
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

        UI.Views[
            viewName
        ] =
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
        0,
        0
    )

    tab.Active:SetPoint(
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

local function CanShowView(
    viewName
)

    if viewName == "bank"
        or viewName == "usage" then

        return true

    end

    if viewName == "requests" then

        return GBM.Permissions
            and GBM.Permissions.CanViewRequests
            and GBM.Permissions.CanViewRequests()

    end

    if viewName == "settings" then

        return GBM.Permissions
            and GBM.Permissions.CanViewSettings
            and GBM.Permissions.CanViewSettings()

    end

    return false

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

    UI.RefreshTabs =
        function()

            for _, tab in pairs(
                UI.TabButtons
            ) do

                tab:Hide()

            end

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
                    id = "usage",
                    text = L.USAGE,
                },

                {
                    id = "settings",
                    text = L.SETTINGS,
                },

            }

            local visibleTabs = {}

            for _, data in ipairs(
                tabData
            ) do

                if CanShowView(
                    data.id
                ) then

                    visibleTabs[
                        #visibleTabs + 1
                    ] =
                        data

                end

            end

            local tabWidth =
                WINDOW_WIDTH
                / math.max(
                    1,
                    #visibleTabs
                )

            for index, data in ipairs(
                visibleTabs
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
                    (index - 1)
                    * tabWidth,
                    0
                )

                UI.TabButtons[
                    data.id
                ] =
                    tab

                tab:Show()

            end

            tabs:Show()

        end

    UI.RefreshTabs()

end

local function UpdateTabs(
    activeView
)

    for id, tab in pairs(
        UI.TabButtons or {}
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

local function RefreshView(
    viewName
)

    if not UI.Refreshers then
        return
    end

    local controller =
        UI.Refreshers[
            viewName
        ]

    if not controller then
        return
    end

    if not controller.Refresh then
        return
    end

    controller.Refresh()

end

function UI.ShowView(
    viewName
)

    if not CanShowView(
        viewName
    ) then

        return

    end

    local view =
        UI.Views[
            viewName
        ]

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

    RefreshView(
        viewName
    )

end

function UI.Initialize()

    if UI.MainFrame then
        return
    end

    local frame =
        CreateMainFrame()

    UI.MainFrame =
        frame

    CreateContent(
        frame
    )

    CreateViews()

    UI.Bank.Initialize()

    if UI.Requests
        and UI.Requests.Initialize then

        UI.Requests.Initialize(
            UI.Views.requests
        )

    end

    if UI.Usage
        and UI.Usage.Initialize then

        UI.Usage.Initialize(
            UI.Views.usage
        )

    end

    UI.Settings.Initialize()

    UI.Refreshers = {

        bank =
            UI.Bank,

        requests =
            UI.Requests,

        usage =
            UI.Usage,

        settings =
            UI.Settings,

    }

    CreateTabs(
        frame
    )

    UI.ShowView(
        "bank"
    )

end

function UI.Toggle()

    if not UI.MainFrame then
        UI.Initialize()
    end

    if UI.MainFrame:IsShown() then

        UI.MainFrame:Hide()

    else

        UI.RefreshTabs()

        local activeView =
            UI.ActiveView

        if not activeView
            or not CanShowView(
                activeView
            ) then

            activeView = "bank"

        end

        UI.MainFrame:Show()

        if UI.Tabs then
            UI.Tabs:Show()
        end

        UI.ShowView(
            activeView
        )

    end

end