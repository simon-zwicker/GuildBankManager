local GBM = GBM

GBM.AddCharUI = {}

local AddCharUI = GBM.AddCharUI

local L = GBM.L

local ROW_HEIGHT = 28
local WINDOW_WIDTH = 440
local WINDOW_HEIGHT = 520

local function SortMembers(
    members
)

    table.sort(
        members,
        function(
            a,
            b
        )

            return a.name:lower()
                < b.name:lower()

        end
    )

    return members
end

local function GetAvailableMembers()

    local db =
        GBM.GuildDB.Get()

    if not db then
        return {}
    end

    local members = {}

    for fullName, member in pairs(
        db.members
    ) do

        if not db.bankChars[
            fullName
        ] then

            table.insert(
                members,
                {
                    name = fullName,
                    class = member.class,
                }
            )

        end

    end

    return SortMembers(
        members
    )
end

local function MatchesSearch(
    fullName,
    searchText
)

    if searchText == "" then
        return true
    end

    return fullName:lower():find(
        searchText:lower(),
        1,
        true
    ) ~= nil
end

local function RefreshList()

    if not AddCharUI.List then
        return
    end

    local searchText =
        AddCharUI.Search:GetText()

    local members =
        GetAvailableMembers()

    local filteredMembers = {}

    for _, member in ipairs(
        members
    ) do

        if MatchesSearch(
            member.name,
            searchText
        ) then

            table.insert(
                filteredMembers,
                member
            )

        end

    end

    AddCharUI.Members =
        filteredMembers

    FauxScrollFrame_Update(
        AddCharUI.ScrollFrame,
        #filteredMembers,
        AddCharUI.VisibleRows,
        ROW_HEIGHT
    )

    local offset =
        FauxScrollFrame_GetOffset(
            AddCharUI.ScrollFrame
        )

    for rowIndex = 1,
        AddCharUI.VisibleRows do

        local row =
            AddCharUI.Rows[rowIndex]

        local memberIndex =
            offset + rowIndex

        local member =
            filteredMembers[
                memberIndex
            ]

        if member then

            row.FullName =
                member.name

            local r, g, b =
                GBM.Utils.GetClassColor(
                    member.class
                )

            row.Text:SetTextColor(
                r,
                g,
                b
            )

            row.Text:SetText(
                member.name
            )

            if AddCharUI.SelectedName
                == member.name then

                row.Highlight:Show()

            else

                row.Highlight:Hide()

            end

            row:Show()

        else

            row.FullName = nil

            row.Highlight:Hide()

            row:Hide()

        end

    end
end

local function CreateRow(
    parent,
    index
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

    row:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        0,
        -(index - 1) * ROW_HEIGHT
    )

    row:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        0,
        -(index - 1) * ROW_HEIGHT
    )

    row.Text =
        row:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    row.Text:SetPoint(
        "LEFT",
        10,
        0
    )

    row.Text:SetJustifyH(
        "LEFT"
    )

    row.Highlight =
        row:CreateTexture(
            nil,
            "BACKGROUND"
        )

    row.Highlight:SetAllPoints()

    row.Highlight:SetColorTexture(
        1,
        1,
        1,
        0.08
    )

    row.Highlight:Hide()

    row:SetHighlightTexture(
        "Interface\\QuestFrame\\UI-QuestTitleHighlight"
    )

    row:SetScript(
        "OnClick",
        function(self)

            if not self.FullName then
                return
            end

            AddCharUI.SelectedName =
                self.FullName

            for _, otherRow in ipairs(
                AddCharUI.Rows
            ) do

                otherRow.Highlight:Hide()

            end

            self.Highlight:Show()

            AddCharUI.AddButton:Enable()

        end
    )

    return row
end

local function CreateWindow()

    local frame =
        CreateFrame(
            "Frame",
            "GBMBankCharsFrame",
            UIParent,
            "BasicFrameTemplateWithInset"
        )
    
    frame:SetFrameStrata(
        "DIALOG"
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
        L.ADD_BANK_CHAR
    )

    frame:Hide()

    return frame
end

local function CreateSearch(
    frame
)

    local search =
        CreateFrame(
            "EditBox",
            nil,
            frame,
            "InputBoxTemplate"
        )

    search:SetSize(
        300,
        30
    )

    search:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        20,
        -45
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

            RefreshList()

        end
    )

    AddCharUI.Search =
        search
end

local function CreateList(
    frame
)

    local list =
        CreateFrame(
            "Frame",
            nil,
            frame
        )

    list:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        20,
        -85
    )

    list:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        -45,
        55
    )

    AddCharUI.List =
        list

    local scrollFrame =
        CreateFrame(
            "ScrollFrame",
            nil,
            frame,
            "FauxScrollFrameTemplate"
        )

    scrollFrame:SetPoint(
        "TOPLEFT",
        list,
        "TOPLEFT",
        0,
        0
    )

    scrollFrame:SetPoint(
        "BOTTOMRIGHT",
        list,
        "BOTTOMRIGHT",
        25,
        0
    )

    scrollFrame:SetScript(
        "OnVerticalScroll",
        function(
            self,
            offset
        )

            FauxScrollFrame_OnVerticalScroll(
                self,
                offset,
                ROW_HEIGHT,
                RefreshList
            )

        end
    )

    AddCharUI.ScrollFrame =
        scrollFrame

    local visibleRows =
        math.floor(
            list:GetHeight()
            / ROW_HEIGHT
        )

    AddCharUI.VisibleRows =
        visibleRows

    AddCharUI.Rows =
        {}

    for index = 1,
        visibleRows do

        AddCharUI.Rows[index] =
            CreateRow(
                list,
                index
            )

    end
end

local function CreateButtons(
    frame
)

    local cancelButton =
        CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

    cancelButton:SetSize(
        100,
        24
    )

    cancelButton:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        -15,
        15
    )

    cancelButton:SetText(
        L.CANCEL
    )

    cancelButton:SetScript(
        "OnClick",
        function()

            frame:Hide()

        end
    )

    local addButton =
        CreateFrame(
            "Button",
            nil,
            frame,
            "UIPanelButtonTemplate"
        )

    addButton:SetSize(
        100,
        24
    )

    addButton:SetPoint(
        "RIGHT",
        cancelButton,
        "LEFT",
        -10,
        0
    )

    addButton:SetText(
        L.ADD
    )

    addButton:Disable()

    addButton:SetScript(
        "OnClick",
        function()

            local fullName =
                AddCharUI.SelectedName

            if not fullName then
                return
            end

            if GBM.Guild.AddBankChar(
                fullName
            ) then

                print(
                    "|cFF00FF00GBM|r "
                    .. L.BANK_CHAR_ADDED,
                    fullName
                )

                AddCharUI.SelectedName =
                    nil

                AddCharUI.AddButton:
                    Disable()

                AddCharUI.Search:
                    SetText("")

                RefreshList()

                if GBM.UI
                    and GBM.UI.Settings then

                    GBM.UI.Settings.Refresh()

                end

                if GBM.UI
                    and GBM.UI.Bank then

                    GBM.UI.Bank.Refresh()

                end

            end

        end
    )

    AddCharUI.AddButton =
        addButton
end

function AddCharUI.Initialize()

    local frame =
        CreateWindow()

    CreateSearch(
        frame
    )

    CreateList(
        frame
    )

    CreateButtons(
        frame
    )

    AddCharUI.Frame =
        frame

    RefreshList()

end

function AddCharUI.Show()

    if not AddCharUI.Frame then
        return
    end

    AddCharUI.SelectedName =
        nil

    AddCharUI.Search:SetText(
        ""
    )

    AddCharUI.AddButton:Disable()

    RefreshList()

    AddCharUI.Frame:Show()

end

function AddCharUI.Hide()

    if not AddCharUI.Frame then
        return
    end

    AddCharUI.Frame:Hide()

end