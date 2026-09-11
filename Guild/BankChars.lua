local GBM = GBM

local Guild = GBM.Guild

local ACTIVE_REQUEST_STATUSES = {
    reserved = true,
    in_progress = true,
}

local function HasActiveRequest(
    fullName
)

    local db =
        GBM.BankDB.Get()

    if not db then
        return false
    end

    if not GBM.Utils.IsTable(
        db.requests
    ) then
        return false
    end

    for _, request in pairs(
        db.requests
    ) do

        if request
            and request.acceptedBy == fullName
            and ACTIVE_REQUEST_STATUSES[
                request.status
            ] then

            return true

        end

    end

    return false

end

function Guild.AddBankChar(
    fullName
)

    local db =
        GBM.GuildDB.Get()

    if not db then
        return nil
    end

    if not fullName then
        return nil
    end

    db.bankChars[fullName] = {
        fullName = fullName,
        addedBy = GBM.WoW.GetFullPlayerName(),
        addedAt = time(),
    }

    return true

end

function Guild.CanRemoveBankChar(
    fullName
)

    if not fullName then
        return false,
            "not_found"
    end

    if not GBM.Permissions
        .CanManageBankChars() then

        return false,
            "permission_denied"

    end

    local db =
        GBM.GuildDB.Get()

    if not db then
        return false,
            "database_not_initialized"
    end

    if not db.bankChars[
        fullName
    ] then

        return false,
            "not_found"

    end

    if HasActiveRequest(
        fullName
    ) then

        return false,
            "active_requests"

    end

    return true

end

function Guild.RemoveBankChar(
    fullName
)

    local canRemove,
        reason =
        Guild.CanRemoveBankChar(
            fullName
        )

    if not canRemove then
        return false,
            reason
    end

    local db =
        GBM.GuildDB.Get()

    db.bankChars[
        fullName
    ] = nil

    if GBM.BankDB.RemoveBankChar(
        fullName
    ) == false then

        return false,
            "bankdb_failed"

    end

    return true

end