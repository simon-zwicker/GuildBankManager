local GBM = GBM

GBM.BankDB = {}

local BankDB = GBM.BankDB

local DEFAULT_DATABASE = {
    version = 1,

    bankChars = {},
    items = {},
    requests = {},
    deposits = {},
    reservations = {},

    sync = {
        revision = 0,
        timestamp = 0,
        bankChar = nil,
    },
}

local function IsRequestReservingStock(
    request
)

    if not request then
        return false
    end

    return request.status == "reserved"
        or request.status == "in_progress"

end

function BankDB.Initialize()

    if not GBM.Utils.IsTable(
        GuildBankManager_BankDB
    ) then

        GuildBankManager_BankDB = {}

    end

    local db =
        GuildBankManager_BankDB

    if db.version == nil then
        db.version =
            DEFAULT_DATABASE.version
    end

    if not GBM.Utils.IsTable(
        db.bankChars
    ) then

        db.bankChars = {}

    end

    if not GBM.Utils.IsTable(
        db.items
    ) then

        db.items = {}

    end

    if not GBM.Utils.IsTable(
        db.requests
    ) then

        db.requests = {}

    end

    if not GBM.Utils.IsTable(
        db.deposits
    ) then

        db.deposits = {}

    end

    if not GBM.Utils.IsTable(
        db.reservations
    ) then

        db.reservations = {}

    end

    if not GBM.Utils.IsTable(
        db.sync
    ) then

        db.sync = {}

    end

    if db.sync.revision == nil then
        db.sync.revision =
            DEFAULT_DATABASE.sync.revision
    end

    if db.sync.timestamp == nil then
        db.sync.timestamp =
            DEFAULT_DATABASE.sync.timestamp
    end

    if db.sync.bankChar == nil then
        db.sync.bankChar =
            DEFAULT_DATABASE.sync.bankChar
    end

    BankDB.Data = db

    return db

end

function BankDB.Get()

    return BankDB.Data

end

function BankDB.GetBankChar(
    fullName
)

    local db =
        BankDB.Get()

    if not db then
        return nil
    end

    if not fullName then
        return nil
    end

    return db.bankChars[fullName]

end

function BankDB.SetBankChar(
    fullName,
    data
)

    local db =
        BankDB.Get()

    if not db then
        return false
    end

    if not fullName then
        return false
    end

    if not GBM.Utils.IsTable(
        data
    ) then

        return false

    end

    db.bankChars[fullName] =
        data

    return true

end

function BankDB.RemoveBankChar(
    fullName
)

    local db =
        BankDB.Get()

    if not db then
        return false
    end

    if not fullName then
        return false
    end

    db.bankChars[
        fullName
    ] = nil

    for itemID in pairs(
        db.items
    ) do

        local stillExists =
            false

        for _, bankChar in pairs(
            db.bankChars
        ) do

            if GBM.Utils.IsTable(
                bankChar.items
            )
                and (
                    bankChar.items[itemID]
                    or 0
                ) > 0 then

                stillExists =
                    true

                break

            end

        end

        if not stillExists then

            db.items[itemID] =
                nil

        end

    end

    if db.sync
        and db.sync.bankChar
        == fullName then

        db.sync.bankChar = nil

    end

    return true

end

function BankDB.GetBankCharItemCount(
    fullName,
    itemID
)

    local bankChar =
        BankDB.GetBankChar(
            fullName
        )

    if not bankChar then
        return 0
    end

    if not GBM.Utils.IsTable(
        bankChar.items
    ) then

        return 0

    end

    return bankChar.items[itemID]
        or 0

end

function BankDB.SetBankCharItemCount(
    fullName,
    itemID,
    quantity
)

    if not fullName then
        return false
    end

    if not itemID then
        return false
    end

    if type(quantity) ~= "number" then
        return false
    end

    local bankChar =
        BankDB.GetBankChar(
            fullName
        )

    if not bankChar then

        bankChar = {
            name = fullName,
            bank = {},
            inventory = {},
            items = {},
            gold = 0,
        }

        BankDB.SetBankChar(
            fullName,
            bankChar
        )

    end

    if not GBM.Utils.IsTable(
        bankChar.items
    ) then

        bankChar.items = {}

    end

    bankChar.items[itemID] =
        math.max(
            quantity,
            0
        )

    return true

end

function BankDB.AddBankCharItemCount(
    fullName,
    itemID,
    amount
)

    if not amount then
        return false
    end

    local current =
        BankDB.GetBankCharItemCount(
            fullName,
            itemID
        )

    return BankDB.SetBankCharItemCount(
        fullName,
        itemID,
        current + amount
    )

end

function BankDB.GetReservedAmount(
    fullName,
    itemID
)

    local db =
        BankDB.Get()

    if not db then
        return 0
    end

    if not fullName then
        return 0
    end

    if not itemID then
        return 0
    end

    local reserved = 0

    for _, request in pairs(
        db.requests
    ) do

        if request.acceptedBy == fullName
            and request.itemID == itemID
            and IsRequestReservingStock(request) then

            reserved =
                reserved
                + (request.amount or 0)

        end

    end

    return reserved

end

function BankDB.GetAvailableAmount(
    fullName,
    itemID
)

    local physicalAmount =
        BankDB.GetBankCharItemCount(
            fullName,
            itemID
        )

    local reservedAmount =
        BankDB.GetReservedAmount(
            fullName,
            itemID
        )

    local availableAmount =
        physicalAmount
        - reservedAmount

    if availableAmount < 0 then
        return 0
    end

    return availableAmount

end

function BankDB.CanFulfill(
    fullName,
    itemID,
    amount
)

    if not fullName then
        return false
    end

    if not itemID then
        return false
    end

    if not amount or amount <= 0 then
        return false
    end

    local available =
        BankDB.GetAvailableAmount(
            fullName,
            itemID
        )

    return available >= amount

end

function BankDB.GetTotalReservedAmount(
    itemID
)

    local db =
        BankDB.Get()

    if not db then
        return 0
    end

    if not itemID then
        return 0
    end

    local reserved = 0

    for _, request in pairs(
        db.requests
    ) do

        if request.itemID == itemID
            and IsRequestReservingStock(request) then

            reserved =
                reserved
                + (request.amount or 0)

        end

    end

    return reserved

end

function BankDB.GetTotalAmount(
    itemID
)

    local db =
        BankDB.Get()

    if not db then
        return 0
    end

    if not itemID then
        return 0
    end

    local total = 0

    for _, bankChar in pairs(
        db.bankChars
    ) do

        if GBM.Utils.IsTable(
            bankChar.items
        ) then

            total =
                total
                + (bankChar.items[itemID] or 0)

        end

    end

    return total

end

function BankDB.GetAvailableTotalAmount(
    itemID
)

    local total =
        BankDB.GetTotalAmount(
            itemID
        )

    local reserved =
        BankDB.GetTotalReservedAmount(
            itemID
        )

    local available =
        total - reserved

    if available < 0 then
        return 0
    end

    return available

end

function BankDB.GetItemOverview(
    itemID
)

    if not itemID then
        return nil
    end

    local db =
        BankDB.Get()

    if not db then
        return nil
    end

    local total = 0
    local bankChars = {}

    for fullName, bankChar in pairs(
        db.bankChars
    ) do

        if GBM.Utils.IsTable(
            bankChar.items
        ) then

            local amount =
                bankChar.items[itemID]
                or 0

            if amount > 0 then

                total =
                    total + amount

                table.insert(
                    bankChars,
                    {
                        name = fullName,
                        amount = amount,
                        reserved =
                            BankDB.GetReservedAmount(
                                fullName,
                                itemID
                            ),
                        available =
                            BankDB.GetAvailableAmount(
                                fullName,
                                itemID
                            ),
                    }
                )

            end

        end

    end

    local reserved =
        BankDB.GetTotalReservedAmount(
            itemID
        )

    local available =
        total - reserved

    if available < 0 then
        available = 0
    end

    return {
        itemID = itemID,
        total = total,
        reserved = reserved,
        available = available,
        bankChars = bankChars,
    }

end