local GBM = GBM

GBM.Commands = {}

local Commands = GBM.Commands

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
        "/gbm requests - Zeigt gespeicherte Requests"
    )

    PrintMessage(
        "/gbm bankchars - Zeigt registrierte Bankchars"
    )

    PrintMessage(
        "/gbm db - Zeigt den aktuellen DB-Status"
    )

end

local function PrintRequests()

    local db =
        GBM.BankDB.Get()

    if not db then

        PrintMessage(
            "Bank-Datenbank ist nicht initialisiert."
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
            or ("Item " .. (request.itemID or "?"))

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
            "Keine Requests gespeichert."
        )

        return

    end

    PrintMessage(
        "Requests: "
        .. count
    )

end

local function PrintBankChars()

    local db =
        GBM.GuildDB.Get()

    if not db then

        PrintMessage(
            "Guild-Datenbank ist nicht initialisiert."
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
                "%s | Itemtypen: %d",
                fullName,
                itemTypes
            )
        )

    end

    if count == 0 then

        PrintMessage(
            "Keine Bankchars registriert."
        )

        return

    end

    PrintMessage(
        "Bankchars: "
        .. count
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
            "Guild-Datenbank ist nicht initialisiert."
        )

        return

    end

    if not bankDB then

        PrintMessage(
            "Bank-Datenbank ist nicht initialisiert."
        )

        return

    end

    PrintMessage(
        "GuildDB"
    )

    PrintMessage(
        "  Mitglieder: "
        .. CountEntries(
            guildDB.members
        )
    )

    PrintMessage(
        "  Bankchars: "
        .. CountEntries(
            guildDB.bankChars
        )
    )

    PrintMessage(
        "  Addon-User: "
        .. CountEntries(
            guildDB.addonUsers
        )
    )

    PrintMessage(
        "BankDB"
    )

    PrintMessage(
        "  Bankchars: "
        .. CountEntries(
            bankDB.bankChars
        )
    )

    PrintMessage(
        "  Itemtypen: "
        .. CountEntries(
            bankDB.items
        )
    )

    PrintMessage(
        "  Requests: "
        .. CountEntries(
            bankDB.requests
        )
    )

    PrintMessage(
        "  Deposits: "
        .. CountEntries(
            bankDB.deposits
        )
    )

    PrintMessage(
        "  Reservations: "
        .. CountEntries(
            bankDB.reservations
        )
    )

    PrintMessage(
        "  Revision: "
        .. (
            bankDB.sync.revision
            or 0
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

    PrintMessage(
        "Unbekannter Command: "
        .. command
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