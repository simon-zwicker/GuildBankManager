local GBM = GBM

GBM.Commands = {}

local Commands = GBM.Commands
local L = GBM.L

local function PrintMessage(
    message
)

    print(
        "|cFF00FF00GBM|r "
        .. message
    )

end

local function PrintHelp()

    PrintMessage(
        L.COMMAND_TOGGLE
    )

    PrintMessage(
        L.COMMAND_HELP
    )

    PrintMessage(
        L.COMMAND_REQUESTS
    )

    PrintMessage(
        L.COMMAND_BANKCHARS
    )

    PrintMessage(
        L.COMMAND_DB
    )

    PrintMessage(
        L.COMMAND_CLEAR_REQUESTS
    )

end

local function PrintRequests()

    local db =
        GBM.BankDB.Get()

    if not db then

        PrintMessage(
            L.BANK_DATABASE_NOT_INITIALIZED
        )

        return

    end

    local count = 0

    for requestID, request in pairs(
        db.requests or {}
    ) do

        count =
            count + 1

        local itemName =
            request.itemName

        if not itemName
            and request.itemID then

            itemName =
                GetItemInfo(
                    request.itemID
                )

        end

        itemName =
            itemName
            or (
                "Item "
                .. (
                    request.itemID
                    or "?"
                )
            )

        PrintMessage(
            string.format(
                "%s | %s | x%d | %s | %s",
                requestID,
                itemName,
                request.amount or 0,
                request.status or "?",
                request.requestedBy or "?"
            )
        )

    end

    if count == 0 then

        PrintMessage(
            L.NO_REQUESTS_STORED
        )

        return

    end

    PrintMessage(
        string.format(
            L.REQUESTS_COUNT,
            count
        )
    )

end

local function PrintBankChars()

    local db =
        GBM.GuildDB.Get()

    if not db then

        PrintMessage(
            L.GUILD_DATABASE_NOT_INITIALIZED
        )

        return

    end

    local count = 0

    for fullName, bankChar in pairs(
        db.bankChars or {}
    ) do

        count =
            count + 1

        local bankDB =
            GBM.BankDB.Get()

        local bankData =
            bankDB
            and bankDB.bankChars
            and bankDB.bankChars[fullName]

        local itemTypes = 0

        if bankData
            and GBM.Utils.IsTable(
                bankData.items
            ) then

            for _ in pairs(
                bankData.items
            ) do

                itemTypes =
                    itemTypes + 1

            end

        end

        PrintMessage(
            string.format(
                L.BANK_CHAR_ITEM_TYPES,
                fullName,
                itemTypes
            )
        )

    end

    if count == 0 then

        PrintMessage(
            L.NO_BANK_CHARS_REGISTERED
        )

        return

    end

    PrintMessage(
        string.format(
            L.BANK_CHARS_COUNT,
            count
        )
    )

end

local function CountEntries(
    value
)

    local count = 0

    if not GBM.Utils.IsTable(
        value
    ) then

        return count

    end

    for _ in pairs(
        value
    ) do

        count =
            count + 1

    end

    return count

end

local function PrintDatabaseStatus()

    local guildDB =
        GBM.GuildDB.Get()

    local bankDB =
        GBM.BankDB.Get()

    if not guildDB then

        PrintMessage(
            L.GUILD_DATABASE_NOT_INITIALIZED
        )

        return

    end

    if not bankDB then

        PrintMessage(
            L.BANK_DATABASE_NOT_INITIALIZED
        )

        return

    end

    PrintMessage(
        L.GUILD_DB
    )

    PrintMessage(
        string.format(
            L.DB_MEMBERS,
            CountEntries(
                guildDB.members
            )
        )
    )

    PrintMessage(
        string.format(
            L.DB_BANK_CHARS,
            CountEntries(
                guildDB.bankChars
            )
        )
    )

    PrintMessage(
        string.format(
            L.DB_ADDON_USERS,
            CountEntries(
                guildDB.addonUsers
            )
        )
    )

    PrintMessage(
        L.BANK_DB
    )

    PrintMessage(
        string.format(
            L.DB_BANK_CHARS,
            CountEntries(
                bankDB.bankChars
            )
        )
    )

    PrintMessage(
        string.format(
            L.DB_ITEM_TYPES,
            CountEntries(
                bankDB.items
            )
        )
    )

    PrintMessage(
        string.format(
            L.DB_REQUESTS,
            CountEntries(
                bankDB.requests
            )
        )
    )

    PrintMessage(
        string.format(
            L.DB_DEPOSITS,
            CountEntries(
                bankDB.deposits
            )
        )
    )

    PrintMessage(
        string.format(
            L.DB_RESERVATIONS,
            CountEntries(
                bankDB.reservations
            )
        )
    )

    PrintMessage(
        string.format(
            L.DB_REVISION,
            bankDB.sync.revision or 0
        )
    )

end

local function ClearRequests()

    local db =
        GBM.BankDB.Get()

    if not db then

        PrintMessage(
            L.BANK_DATABASE_NOT_INITIALIZED
        )

        return

    end

    local count =
        CountEntries(
            db.requests
        )

    db.requests = {}

    PrintMessage(
        string.format(
            L.REQUEST_CLEARED_COUNT,
            count
        )
    )

end

local function HandleCommand(
    message
)

    local command =
        string.lower(
            message
            or ""
        )

    command =
        string.match(
            command,
            "^%s*(.-)%s*$"
        )

    if command == "" then

        GBM.UI.Toggle()

        return

    end

    if command == "help" then

        PrintHelp()

        return

    end

    if command == "requests" then

        PrintRequests()

        return

    end

    if command == "bankchars" then

        PrintBankChars()

        return

    end

    if command == "db" then

        PrintDatabaseStatus()

        return

    end

    if command == "clearrequests" then

        ClearRequests()

        return

    end

    PrintMessage(
        string.format(
            L.UNKNOWN_COMMAND,
            command
        )
    )

    PrintHelp()

end

function Commands.Initialize()

    SLASH_GUILDBANKMANAGER1 =
        "/gbm"

    SlashCmdList.GUILDBANKMANAGER =
        function(message)

            HandleCommand(
                message
            )

        end

end