local GBM = GBM

local UI = GBM.UI

UI.SettingsPermissions = {}

local PermissionsUI =
    UI.SettingsPermissions

local L = GBM.L

local PERMISSIONS = {

    {
        key = "viewRequests",
        label =
            L.PERMISSION_VIEW_REQUESTS,
    },

    {
        key = "viewInProgressRequests",
        label =
            L.PERMISSION_VIEW_IN_PROGRESS_REQUESTS,
    },

    {
        key = "manageRequests",
        label =
            L.PERMISSION_MANAGE_REQUESTS,
    },

    {
        key = "assignRequests",
        label =
            L.PERMISSION_ASSIGN_REQUESTS,
    },

    {
        key = "rejectRequests",
        label =
            L.PERMISSION_REJECT_REQUESTS,
    },

    {
        key = "manageBankChars",
        label =
            L.PERMISSION_MANAGE_BANK_CHARS,
    },

    {
        key = "syncBank",
        label =
            L.PERMISSION_SYNC_BANK,
    },

    {
        key = "viewSettings",
        label =
            L.PERMISSION_VIEW_SETTINGS,
    },

}

local ROW_HEIGHT = 46

local function GetRanks()

    local ranks = {}

    local count =
        GBM.WoW.GetGuildRankCount()

    for index = 0, count - 1 do

        local name =
            GBM.WoW.GetGuildRankName(
                index
            )

        if name then

            table.insert(
                ranks,
                {
                    index = index,
                    name = name,
                }
            )

        end

    end

    return ranks

end

local function GetSelectedRank(
    permission
)

    return GBM.Permissions.GetPermissionRank(
        permission
    )

end

local function UpdateDropdownText(
    dropdown,
    permission
)

    local rankIndex =
        GetSelectedRank(
            permission
        )

    local rankName =
        tostring(
            rankIndex
            or 0
        )

    local count =
        GBM.WoW.GetGuildRankCount()

    for index = 0, count - 1 do

        if index == rankIndex then

            local name =
                GBM.WoW.GetGuildRankName(
                    index
                )

            if name then

                rankName = name

            end

            break

        end

    end

    UIDropDownMenu_SetText(
        dropdown,
        rankName
    )

end

local function UpdateDropdownState(
    dropdown
)

    if GBM.Permissions.IsGuildLeader() then

        UIDropDownMenu_EnableDropDown(
            dropdown
        )

    else

        UIDropDownMenu_DisableDropDown(
            dropdown
        )

    end

end

local function CreateDropdown(
    parent,
    permission
)

    local dropdownName =
        "GBMPermissionsDropdown_"
        .. permission.key

    local dropdown =
        CreateFrame(
            "Frame",
            dropdownName,
            parent,
            "UIDropDownMenuTemplate"
        )

    dropdown:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        -5,
        0
    )

    UIDropDownMenu_SetWidth(
        dropdown,
        210
    )

    UIDropDownMenu_Initialize(
        dropdown,
        function(
            self,
            level
        )

            local ranks =
                GetRanks()

            for _, rank in ipairs(
                ranks
            ) do

                local info =
                    UIDropDownMenu_CreateInfo()

                info.text =
                    rank.name

                info.value =
                    rank.index

                info.func =
                    function()

                        local success =
                            GBM.Permissions.SetPermissionRank(
                                permission.key,
                                rank.index
                            )

                        if success then

                            UpdateDropdownText(
                                dropdown,
                                permission.key
                            )

                        end

                    end

                info.checked =
                    GetSelectedRank(
                        permission.key
                    )
                    == rank.index

                info.disabled =
                    not GBM.Permissions.IsGuildLeader()

                UIDropDownMenu_AddButton(
                    info,
                    level
                )

            end

        end
    )

    UpdateDropdownText(
        dropdown,
        permission.key
    )

    UpdateDropdownState(
        dropdown
    )

    return dropdown

end

local function CreateRow(
    parent,
    permission,
    index,
    yOffset
)

    local row =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    row:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        yOffset
    )

    row:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        -10,
        yOffset
    )

    row:SetHeight(
        ROW_HEIGHT
    )

    local label =
        row:CreateFontString(
            nil,
            "OVERLAY"
        )

    label:SetPoint(
        "LEFT",
        5,
        0
    )

    label:SetFont(
        "Fonts\\FRIZQT__.TTF",
        16,
        ""
    )

    label:SetText(
        permission.label
    )

    row.Dropdown =
        CreateDropdown(
            row,
            permission
        )

    row.Label =
        label

    return row

end

function PermissionsUI.Refresh()

    if not PermissionsUI.Frame then

        return

    end

    for _, permission in ipairs(
        PERMISSIONS
    ) do

        if permission.dropdown then

            UpdateDropdownText(
                permission.dropdown,
                permission.key
            )

            UpdateDropdownState(
                permission.dropdown
            )

        end

    end

end

function PermissionsUI.Initialize(
    parent
)

    if PermissionsUI.Frame then

        return PermissionsUI.Frame

    end

    local frame =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    frame:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        0,
        0
    )

    frame:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        0,
        0
    )

    frame:SetHeight(
        520
    )

    PermissionsUI.Frame =
        frame

    local title =
        frame:CreateFontString(
            nil,
            "OVERLAY"
        )

    title:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        10,
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
        L.PERMISSIONS
    )

    local description =
        frame:CreateFontString(
            nil,
            "OVERLAY"
        )

    description:SetPoint(
        "TOPLEFT",
        title,
        "BOTTOMLEFT",
        0,
        -8
    )

    description:SetFont(
        "Fonts\\FRIZQT__.TTF",
        14,
        ""
    )

    description:SetText(
        L.PERMISSIONS_DESCRIPTION
    )

    for index, permission in ipairs(
        PERMISSIONS
    ) do

        local row =
            CreateRow(
                frame,
                permission,
                index,
                -62
                - (
                    (index - 1)
                    * ROW_HEIGHT
                )
            )

        permission.row =
            row

        permission.dropdown =
            row.Dropdown

    end

    return frame

end