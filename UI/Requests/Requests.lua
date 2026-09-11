local GBM = GBM

GBM.UI = GBM.UI or {}
GBM.UI.Requests = GBM.UI.Requests or {}

local RequestsUI = GBM.UI.Requests

local ROW_HEIGHT = 42
local HEADER_HEIGHT = 32

local EMPTY_TEXT_SIZE = 22

local function GetLocalization()
    return GBM.L
end

local function CreateHeader(parent)

    local L = GetLocalization()

    local header =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    header:SetHeight(
        HEADER_HEIGHT
    )

    header.icon =
        header:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    header.icon:SetPoint(
        "LEFT",
        5,
        0
    )

    header.icon:SetText(
        ""
    )

    header.item =
        header:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    header.item:SetPoint(
        "LEFT",
        45,
        0
    )

    header.item:SetWidth(
        220
    )

    header.item:SetText(
        L.REQUESTS_ITEM
        or "Item"
    )

    header.amount =
        header:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    header.amount:SetPoint(
        "LEFT",
        275,
        0
    )

    header.amount:SetWidth(
        70
    )

    header.amount:SetJustifyH(
        "CENTER"
    )

    header.amount:SetText(
        L.REQUESTS_AMOUNT
        or "Request"
    )

    header.own =
        header:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    header.own:SetPoint(
        "LEFT",
        350,
        0
    )

    header.own:SetWidth(
        70
    )

    header.own:SetJustifyH(
        "CENTER"
    )

    header.own:SetText(
        L.REQUESTS_OWN_AMOUNT
        or "Own"
    )

    return header
end

local function CreateEmptyText(parent)

    local L = GetLocalization()

    local text =
        parent:CreateFontString(
            nil,
            "OVERLAY"
        )

    text:SetPoint(
        "TOPLEFT",
        0,
        -20
    )

    text:SetPoint(
        "TOPRIGHT",
        0,
        -20
    )

    text:SetJustifyH(
        "CENTER"
    )

    text:SetJustifyV(
        "MIDDLE"
    )

    text:SetText(
        L.REQUESTS_EMPTY
        or "No open requests"
    )

    text:SetTextColor(
        1,
        1,
        1
    )

    local font,
        size,
        flags =
        text:GetFont()

    text:SetFont(
        font,
        EMPTY_TEXT_SIZE,
        flags
    )

    return text
end

local function GetRequests()

    if not GBM.Requests then
        return {}
    end

    if GBM.Requests.GetAll then

        return GBM.Requests.GetAll()
            or {}

    end

    if GBM.Requests.GetRequests then

        return GBM.Requests.GetRequests()
            or {}

    end

    return {}
end

local function SortRequests(requests)

    table.sort(
        requests,
        function(a, b)

            local aTime =
                a.createdAt
                or 0

            local bTime =
                b.createdAt
                or 0

            return aTime < bTime

        end
    )

end

function RequestsUI.Initialize(parent)

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

    RequestsUI.header =
        CreateHeader(
            frame
        )

    RequestsUI.header:SetPoint(
        "TOPLEFT",
        0,
        0
    )

    RequestsUI.header:SetPoint(
        "TOPRIGHT",
        0,
        0
    )

    RequestsUI.container =
        CreateFrame(
            "Frame",
            nil,
            frame
        )

    RequestsUI.container:SetPoint(
        "TOPLEFT",
        0,
        -HEADER_HEIGHT
    )

    RequestsUI.container:SetPoint(
        "TOPRIGHT",
        0,
        -HEADER_HEIGHT
    )

    RequestsUI.container:SetHeight(
        1
    )

    RequestsUI.emptyText =
        CreateEmptyText(
            RequestsUI.container
        )

    RequestsUI.emptyText:SetPoint(
        "TOPLEFT",
        0,
        -20
    )

    RequestsUI.emptyText:SetPoint(
        "TOPRIGHT",
        0,
        -20
    )

    RequestsUI.rows = {}

    return frame
end

function RequestsUI.ClearRows()

    for _, row in ipairs(
        RequestsUI.rows or {}
    ) do

        row:Hide()
        row:SetParent(nil)

    end

    RequestsUI.rows = {}

end

function RequestsUI.Refresh()

    if not RequestsUI.frame
        or not RequestsUI.container then

        return
    end

    RequestsUI.ClearRows()

    local requests =
        GetRequests()

    SortRequests(
        requests
    )

    local visibleIndex = 0

    for _, request in ipairs(
        requests
    ) do

        if request
            and request.status
            and request.status ~= "fulfilled"
            and request.status ~= "cancelled" then

            visibleIndex =
                visibleIndex + 1

            local row =
                RequestsUI.CreateRequestRow(
                    RequestsUI.container,
                    request
                )

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

            RequestsUI.rows[
                #RequestsUI.rows + 1
            ] =
                row

        end

    end

    if visibleIndex == 0 then

        RequestsUI.emptyText:Show()

    else

        RequestsUI.emptyText:Hide()

    end

    RequestsUI.container:SetHeight(
        math.max(
            1,
            visibleIndex
            * ROW_HEIGHT
        )
    )

end

function RequestsUI.ShowRejectDialog(request)

    -- Wird im nächsten Schritt ergänzt.

end