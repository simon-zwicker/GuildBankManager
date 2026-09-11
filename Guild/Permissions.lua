local GBM = GBM

GBM.Permissions = {}

local Permissions = GBM.Permissions

local DEFAULT_PERMISSIONS = {
    manageRequests = 1,
    assignRequests = 1,
    rejectRequests = 1,
    manageBankChars = 1,
    syncBank = 1,
}

local function GetGuildDatabase()

    return GBM.GuildDB.Get()

end

local function GetGuildRankIndex()

    local guildInfo =
        GBM.WoW.GetGuildInfo()

    if not guildInfo then
        return nil
    end

    return guildInfo.rankIndex

end

local function IsGuildLeader()

    local rankIndex =
        GetGuildRankIndex()

    return rankIndex == 0

end

local function GetPermissionRank(
    permission
)

    local db =
        GetGuildDatabase()

    if not db then
        return nil
    end

    if not GBM.Utils.IsTable(
        db.permissions
    ) then

        db.permissions = {}

    end

    local rankIndex =
        db.permissions[permission]

    if rankIndex == nil then

        rankIndex =
            DEFAULT_PERMISSIONS[permission]

    end

    return rankIndex

end

local function HasPermission(
    permission
)

    if IsGuildLeader() then
        return true
    end

    local playerRank =
        GetGuildRankIndex()

    if playerRank == nil then
        return false
    end

    local requiredRank =
        GetPermissionRank(
            permission
        )

    if requiredRank == nil then
        return false
    end

    return playerRank <= requiredRank

end

local function IsRegisteredBankChar()

    local db =
        GetGuildDatabase()

    if not db then
        return false
    end

    local fullName =
        GBM.WoW.GetFullPlayerName()

    return db.bankChars[fullName] ~= nil

end

function Permissions.Initialize()

    local db =
        GetGuildDatabase()

    if not db then
        return
    end

    if not GBM.Utils.IsTable(
        db.permissions
    ) then

        db.permissions = {}

    end

    for permission, rankIndex in pairs(
        DEFAULT_PERMISSIONS
    ) do

        if db.permissions[permission] == nil then

            db.permissions[permission] =
                rankIndex

        end

    end

end

function Permissions.IsGuildLeader()

    return IsGuildLeader()

end

function Permissions.IsBankChar()

    return IsRegisteredBankChar()

end

function Permissions.HasPermission(
    permission
)

    return HasPermission(
        permission
    )

end

function Permissions.GetPermissionRank(
    permission
)

    return GetPermissionRank(
        permission
    )

end

function Permissions.SetPermissionRank(
    permission,
    rankIndex
)

    local db =
        GetGuildDatabase()

    if not db then
        return false
    end

    if not IsGuildLeader() then
        return false
    end

    if type(permission) ~= "string" then
        return false
    end

    if type(rankIndex) ~= "number" then
        return false
    end

    if rankIndex < 0 then
        return false
    end

    db.permissions[permission] =
        math.floor(
            rankIndex
        )

    return true

end

function Permissions.CanManageRequests()

    return HasPermission(
        "manageRequests"
    )

end

function Permissions.CanAssignRequests()

    return HasPermission(
        "assignRequests"
    )

end

function Permissions.CanRejectRequests()

    return HasPermission(
        "rejectRequests"
    )

end

function Permissions.CanManageBankChars()

    return HasPermission(
        "manageBankChars"
    )

end

function Permissions.CanSyncBank()

    return HasPermission(
        "syncBank"
    )

end

function Permissions.GetDefaults()

    return DEFAULT_PERMISSIONS

end