local GBM = GBM

GBM.Requests = {}

local Requests = GBM.Requests

local STATUS_PENDING = "pending"
local STATUS_ACCEPTED = "accepted"
local STATUS_REJECTED = "rejected"
local STATUS_FULFILLED = "fulfilled"

local REQUEST_PREFIX = "REQ-"

local function GenerateRequestID()

    local db =
        GBM.BankDB.Get()

    if not db then
        return nil
    end

    local highestNumber = 0

    for requestID in pairs(
        db.requests
    ) do

        local number =
            tonumber(
                string.match(
                    requestID,
                    "^REQ%-(%d+)$"
                )
            )

        if number
            and number > highestNumber then

            highestNumber = number

        end

    end

    return string.format(
        "%s%05d",
        REQUEST_PREFIX,
        highestNumber + 1
    )
end

local function GetPlayerFullName()

    return GBM.WoW.GetFullPlayerName()

end

local function GetItemName(itemID)

    if not itemID then
        return nil
    end

    return GetItemInfo(
        itemID
    )

end

local function IsValidAmount(amount)

    return type(amount) == "number"
        and amount > 0
        and amount == math.floor(amount)

end

local function GetRequest(
    requestID
)

    local db =
        GBM.BankDB.Get()

    if not db then
        return nil
    end

    if not requestID then
        return nil
    end

    return db.requests[
        requestID
    ]

end

local function IsOfficer()

    local guildInfo =
        GBM.WoW.GetGuildInfo()

    if not guildInfo then
        return false
    end

    return guildInfo.rankIndex == 0
        or guildInfo.rankIndex == 1

end

function Requests.GetStatusPending()

    return STATUS_PENDING

end

function Requests.GetStatusAccepted()

    return STATUS_ACCEPTED

end

function Requests.GetStatusRejected()

    return STATUS_REJECTED

end

function Requests.GetStatusFulfilled()

    return STATUS_FULFILLED

end

function Requests.Get(
    requestID
)

    return GetRequest(
        requestID
    )

end

function Requests.GetAll()

    local db =
        GBM.BankDB.Get()

    if not db then
        return {}
    end

    return db.requests

end

function Requests.GetByStatus(
    status
)

    local requests = {}

    if not status then
        return requests
    end

    for _, request in pairs(
        Requests.GetAll()
    ) do

        if request.status == status then

            table.insert(
                requests,
                request
            )

        end

    end

    table.sort(
        requests,
        function(a, b)

            return (a.requestedAt or 0)
                < (b.requestedAt or 0)

        end
    )

    return requests

end

function Requests.Create(
    itemID,
    amount
)

    local db =
        GBM.BankDB.Get()

    if not db then

        return nil,
            "database_not_initialized"

    end

    if not itemID then

        return nil,
            "missing_item"

    end

    if not IsValidAmount(
        amount
    ) then

        return nil,
            "invalid_amount"

    end

    local requestID =
        GenerateRequestID()

    if not requestID then

        return nil,
            "could_not_generate_id"

    end

    local request = {

        id = requestID,

        itemID = itemID,

        itemName =
            GetItemName(
                itemID
            ),

        amount = amount,

        requestedBy =
            GetPlayerFullName(),

        requestedAt = time(),

        status =
            STATUS_PENDING,

        acceptedBy = nil,

        acceptedAt = nil,

        fulfilledBy = nil,

        fulfilledAt = nil,

    }

    db.requests[
        requestID
    ] = request

    return request

end

function Requests.CanAccept(
    requestID,
    bankChar
)

    local request =
        GetRequest(
            requestID
        )

    if not request then

        return false,
            "request_not_found"

    end

    if request.status
        ~= STATUS_PENDING then

        return false,
            "request_not_pending"

    end

    if not bankChar then

        return false,
            "missing_bankchar"

    end

    local registered =
        GBM.GuildDB.Get()

    if not registered then

        return false,
            "guild_database_not_initialized"

    end

    if not registered.bankChars[
        bankChar
    ] then

        return false,
            "not_registered_bankchar"

    end

    local available =
        GBM.BankDB.GetAvailableAmount(
            bankChar,
            request.itemID
        )

    if available
        < request.amount then

        return false,
            "insufficient_stock"

    end

    return true

end

function Requests.Accept(
    requestID,
    bankChar
)

    local canAccept,
        reason =
        Requests.CanAccept(
            requestID,
            bankChar
        )

    if not canAccept then

        return nil,
            reason

    end

    local request =
        GetRequest(
            requestID
        )

    request.status =
        STATUS_ACCEPTED

    request.acceptedBy =
        bankChar

    request.acceptedAt =
        time()

    return request

end

function Requests.CanReject(
    requestID
)

    local request =
        GetRequest(
            requestID
        )

    if not request then

        return false,
            "request_not_found"

    end

    if request.status
        ~= STATUS_PENDING then

        return false,
            "request_not_pending"

    end

    if not IsOfficer() then

        return false,
            "permission_denied"

    end

    return true

end

function Requests.Reject(
    requestID
)

    local canReject,
        reason =
        Requests.CanReject(
            requestID
        )

    if not canReject then

        return nil,
            reason

    end

    local request =
        GetRequest(
            requestID
        )

    request.status =
        STATUS_REJECTED

    return request

end

function Requests.CanFulfill(
    requestID,
    bankChar
)

    local request =
        GetRequest(
            requestID
        )

    if not request then

        return false,
            "request_not_found"

    end

    if request.status
        ~= STATUS_ACCEPTED then

        return false,
            "request_not_accepted"

    end

    if not request.acceptedBy then

        return false,
            "missing_accepting_bankchar"

    end

    if bankChar
        ~= request.acceptedBy then

        return false,
            "wrong_bankchar"

    end

    local available =
        GBM.BankDB.GetAvailableAmount(
            bankChar,
            request.itemID
        )

    if available
        < request.amount then

        return false,
            "insufficient_stock"

    end

    return true

end

function Requests.Fulfill(
    requestID,
    bankChar
)

    local canFulfill,
        reason =
        Requests.CanFulfill(
            requestID,
            bankChar
        )

    if not canFulfill then

        return nil,
            reason

    end

    local request =
        GetRequest(
            requestID
        )

    local currentAmount =
        GBM.BankDB.GetBankCharItemCount(
            bankChar,
            request.itemID
        )

    local newAmount =
        currentAmount
        - request.amount

    if newAmount < 0 then

        return nil,
            "insufficient_stock"

    end

    local success =
        GBM.BankDB.SetBankCharItemCount(
            bankChar,
            request.itemID,
            newAmount
        )

    if not success then

        return nil,
            "could_not_update_stock"

    end

    request.status =
        STATUS_FULFILLED

    request.fulfilledBy =
        bankChar

    request.fulfilledAt =
        time()

    GBM.BankScanner.RebuildItemIndex()

    if GBM.UI
        and GBM.UI.Bank then

        GBM.UI.Bank.Refresh()

    end

    return request

end

function Requests.Delete(
    requestID
)

    local request =
        GetRequest(
            requestID
        )

    if not request then

        return false,
            "request_not_found"

    end

    if not IsOfficer() then

        return false,
            "permission_denied"

    end

    if request.status
        == STATUS_ACCEPTED then

        return false,
            "accepted_request_cannot_be_deleted"

    end

    db =
        GBM.BankDB.Get()

    db.requests[
        requestID
    ] = nil

    return true

end