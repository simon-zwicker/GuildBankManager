local GBM = GBM

GBM.UI = GBM.UI or {}
GBM.UI.Requests = GBM.UI.Requests or {}

local RequestsUI = GBM.UI.Requests

local ROW_HEIGHT = 42
local HEADER_HEIGHT = 34
local SECTION_GAP = 18
local EMPTY_TEXT_SIZE = 18

local function GetLocalization()

    return GBM.L

end

local function CreateSectionHeader(
    parent,
    text
)

    local header =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    header:SetHeight(
        HEADER_HEIGHT
    )

    local title =
        header:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    title:SetPoint(
        "LEFT",
        5,
        0
    )

    title:SetFont(
        "Fonts\\FRIZQT__.TTF",
        18,
        ""
    )

    title:SetTextColor(
        1,
        0.82,
        0
    )

    title:SetText(
        text
    )

    header.title =
        title

    return header

end

local function CreateEmptyText(
    parent,
    text
)

    local label =
        parent:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    local font,
        _,
        flags =
        label:GetFont()

    label:SetFont(
        font,
        EMPTY_TEXT_SIZE,
        flags
    )

    label:SetText(
        text
    )

    label:SetTextColor(
        0.65,
        0.65,
        0.65
    )

    label:SetJustifyH(
        "CENTER"
    )

    return label

end

local function BuildRequestList(
    requests
)

    local list = {}

    for requestID, request in pairs(
        requests or {}
    ) do

        if request then

            if not request.id then
                request.id =
                    requestID
            end

            list[
                #list + 1
            ] =
                request

        end

    end

    return list

end

local function SortRequests(
    requests
)

    table.sort(
        requests,
        function(a, b)

            local aTime =
                a.requestedAt
                or a.createdAt
                or 0

            local bTime =
                b.requestedAt
                or b.createdAt
                or 0

            return aTime < bTime

        end
    )

end

local function GetRequests()

    if not GBM.Requests then
        return {}
    end

    if GBM.Requests.GetAll then

        return GBM.Requests.GetAll()
            or {}

    end

    return {}

end

local function ClearRows(
    rows
)

    for _, row in ipairs(
        rows or {}
    ) do

        row:Hide()
        row:SetParent(nil)

    end

end

local function CreateRows(
    parent,
    requests,
    rowFactory,
    rows
)

    local visibleIndex = 0

    for _, request in ipairs(
        requests
    ) do

        if request then

            visibleIndex =
                visibleIndex + 1

            local row =
                rowFactory(
                    parent,
                    request
                )

            if row then

                row:SetPoint(
                    "TOPLEFT",
                    0,
                    -(
                        (visibleIndex - 1)
                        * ROW_HEIGHT
                    )
                )

                row:SetPoint(
                    "TOPRIGHT",
                    0,
                    -(
                        (visibleIndex - 1)
                        * ROW_HEIGHT
                    )
                )

                row:SetHeight(
                    ROW_HEIGHT
                )

                row:Show()

                rows[
                    #rows + 1
                ] =
                    row

            end

        end

    end

    return visibleIndex

end

function RequestsUI.Initialize(
    parent
)

    if RequestsUI.frame then
        return RequestsUI.frame
    end

    local frame =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    frame:SetAllPoints(
        parent
    )

    RequestsUI.frame =
        frame

    RequestsUI.openHeader =
        CreateSectionHeader(
            frame,
            GetLocalization().REQUESTS_OPEN
        )

    RequestsUI.openHeader:SetPoint(
        "TOPLEFT",
        0,
        0
    )

    RequestsUI.openHeader:SetPoint(
        "TOPRIGHT",
        0,
        0
    )

    RequestsUI.openContainer =
        CreateFrame(
            "Frame",
            nil,
            frame
        )

    RequestsUI.openContainer:SetPoint(
        "TOPLEFT",
        0,
        -HEADER_HEIGHT
    )

    RequestsUI.openContainer:SetPoint(
        "TOPRIGHT",
        0,
        -HEADER_HEIGHT
    )

    RequestsUI.openRows = {}

    RequestsUI.openEmpty =
        CreateEmptyText(
            RequestsUI.openContainer,
            GetLocalization().REQUESTS_EMPTY
        )

    RequestsUI.openEmpty:SetPoint(
        "TOPLEFT",
        0,
        -10
    )

    RequestsUI.openEmpty:SetPoint(
        "TOPRIGHT",
        0,
        -10
    )

    RequestsUI.progressHeader =
        CreateSectionHeader(
            frame,
            GetLocalization().REQUESTS_IN_PROGRESS
        )

    RequestsUI.progressContainer =
        CreateFrame(
            "Frame",
            nil,
            frame
        )

    RequestsUI.progressRows = {}

    RequestsUI.progressEmpty =
        CreateEmptyText(
            RequestsUI.progressContainer,
            GetLocalization().REQUESTS_IN_PROGRESS_EMPTY
        )

    RequestsUI.progressEmpty:SetPoint(
        "TOPLEFT",
        0,
        -10
    )

    RequestsUI.progressEmpty:SetPoint(
        "TOPRIGHT",
        0,
        -10
    )

    return frame

end

function RequestsUI.ClearRows()

    ClearRows(
        RequestsUI.openRows
    )

    ClearRows(
        RequestsUI.progressRows
    )

    RequestsUI.openRows = {}
    RequestsUI.progressRows = {}

end

function RequestsUI.Refresh()

    if not RequestsUI.frame then
        return
    end

    RequestsUI.ClearRows()

    local permissions =
        GBM.Permissions

    if not permissions
        or not permissions.CanViewRequests
        or not permissions.CanViewRequests() then

        RequestsUI.frame:Hide()

        return

    end

    RequestsUI.frame:Show()

    local allRequests =
        BuildRequestList(
            GetRequests()
        )

    SortRequests(
        allRequests
    )

    local openRequests = {}
    local progressRequests = {}

    local canViewProgress =
        permissions.CanViewInProgressRequests
        and permissions.CanViewInProgressRequests()

    local currentPlayer =
        GBM.WoW.GetFullPlayerName()

    for _, request in ipairs(
        allRequests
    ) do

        if request.status
            == "reserved" then

            openRequests[
                #openRequests + 1
            ] =
                request

        elseif request.status
            == "in_progress" then

            if canViewProgress then

                progressRequests[
                    #progressRequests + 1
                ] =
                    request

            elseif request.acceptedBy
                == currentPlayer then

                progressRequests[
                    #progressRequests + 1
                ] =
                    request

            end

        end

    end

    local openCount =
        CreateRows(
            RequestsUI.openContainer,
            openRequests,
            RequestsUI.CreateRequestRow,
            RequestsUI.openRows
        )

    local progressCount = 0

    if canViewProgress then

        progressCount =
            CreateRows(
                RequestsUI.progressContainer,
                progressRequests,
                RequestsUI.CreateInProgressRow,
                RequestsUI.progressRows
            )

    end

    if openCount == 0 then

        RequestsUI.openEmpty:Show()

    else

        RequestsUI.openEmpty:Hide()

    end

    if progressCount == 0 then

        RequestsUI.progressEmpty:Show()

    else

        RequestsUI.progressEmpty:Hide()

    end

    RequestsUI.openContainer:SetHeight(
        math.max(
            1,
            openCount * ROW_HEIGHT
        )
    )

    RequestsUI.progressHeader:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        0,
        -(
            HEADER_HEIGHT
            + math.max(
                1,
                openCount * ROW_HEIGHT
            )
            + SECTION_GAP
        )
    )

    RequestsUI.progressHeader:SetPoint(
        "TOPRIGHT",
        frame,
        "TOPRIGHT",
        0,
        -(
            HEADER_HEIGHT
            + math.max(
                1,
                openCount * ROW_HEIGHT
            )
            + SECTION_GAP
        )
    )

    RequestsUI.progressContainer:SetPoint(
        "TOPLEFT",
        RequestsUI.progressHeader,
        "BOTTOMLEFT",
        0,
        0
    )

    RequestsUI.progressContainer:SetPoint(
        "TOPRIGHT",
        RequestsUI.progressHeader,
        "BOTTOMRIGHT",
        0,
        0
    )

    RequestsUI.progressContainer:SetHeight(
        math.max(
            1,
            progressCount * ROW_HEIGHT
        )
    )

end

function RequestsUI.ShowRejectDialog(
    request
)

    if not request then
        return
    end

    local dialogName =
        "GBM_REQUEST_REJECT_DIALOG"

    if not StaticPopupDialogs[
        dialogName
    ] then

        StaticPopupDialogs[
            dialogName
        ] = {

            text =
                GetLocalization().REQUEST_REJECT_REASON,

            button1 =
                GetLocalization().REJECT,

            button2 =
                GetLocalization().CANCEL,

            hasEditBox = true,

            editBoxWidth = 300,

            timeout = 0,

            whileDead = true,

            hideOnEscape = true,

            preferredIndex = 3,

            OnShow = function(
                popup
            )

                popup.editBox:SetText(
                    ""
                )

                popup.editBox:SetFocus()

            end,

            OnAccept = function(
                popup
            )

                local reasonText =
                    popup.editBox:GetText()

                reasonText =
                    string.gsub(
                        reasonText
                        or "",
                        "^%s+",
                        ""
                    )

                reasonText =
                    string.gsub(
                        reasonText,
                        "%s+$",
                        ""
                    )

                if reasonText == "" then

                    reasonText =
                        GetLocalization().REQUEST_REJECT_NO_REASON

                end

                local success =
                    GBM.Requests.Reject(
                        request.id,
                        reasonText
                    )

                if success then

                    RequestsUI.Refresh()

                end

            end,

        }

    end

    StaticPopup_Show(
        dialogName
    )

end