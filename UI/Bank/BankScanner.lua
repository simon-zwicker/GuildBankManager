local GBM = GBM

GBM.BankScanner = {}

local BankScanner = GBM.BankScanner

local MAX_BANK_BAGS = 7
local MAX_INVENTORY_BAGS = 4

local function GetCurrentBankChar()

    local fullName =
        GBM.WoW.GetFullPlayerName()

    local db =
        GBM.GuildDB.Get()

    if not db then
        return nil
    end

    if not db.bankChars[fullName] then
        return nil
    end

    return fullName
end

local function AddItem(
    items,
    itemID,
    quantity
)

    if not itemID then
        return
    end

    if not quantity or quantity <= 0 then
        return
    end

    items[itemID] =
        (items[itemID] or 0)
        + quantity
end

local function ScanContainer(
    containerID,
    items,
    statistics
)

    local slotCount =
        C_Container.GetContainerNumSlots(
            containerID
        )

    if not slotCount or slotCount <= 0 then
        return false
    end

    statistics.containers =
        statistics.containers + 1

    statistics.slots =
        statistics.slots + slotCount

    for slot = 1, slotCount do

        statistics.scannedSlots =
            statistics.scannedSlots + 1

        local info =
            C_Container.GetContainerItemInfo(
                containerID,
                slot
            )

        if info and info.itemID then

            statistics.filledSlots =
                statistics.filledSlots + 1

            local quantity =
                info.stackCount or 0

            AddItem(
                items,
                info.itemID,
                quantity
            )

            statistics.itemCount =
                statistics.itemCount + quantity

        end

    end

    return true
end

local function ScanBank()

    local items = {}

    local statistics = {
        containers = 0,
        slots = 0,
        scannedSlots = 0,
        filledSlots = 0,
        itemCount = 0,
        bankBags = 0,
    }

    -- Hauptbank
    ScanContainer(
        BANK_CONTAINER,
        items,
        statistics
    )

    -- Banktaschen
    --
    -- Classic Era:
    -- 5  = Banktasche 1
    -- 6  = Banktasche 2
    -- ...
    -- 11 = Banktasche 7
    --
    -- Nicht vorhandene Taschen liefern
    -- keine Slots und werden ignoriert.

    for bagID = 5, 4 + MAX_BANK_BAGS do

        local scanned =
            ScanContainer(
                bagID,
                items,
                statistics
            )

        if scanned then

            statistics.bankBags =
                statistics.bankBags + 1

        end

    end

    return items, statistics
end

local function ScanInventory()

    local items = {}

    local statistics = {
        containers = 0,
        slots = 0,
        scannedSlots = 0,
        filledSlots = 0,
        itemCount = 0,
        bags = 0,
    }

    -- Rucksack
    ScanContainer(
        0,
        items,
        statistics
    )

    -- Zusätzliche Inventartaschen
    --
    -- 1 = Tasche 1
    -- 2 = Tasche 2
    -- 3 = Tasche 3
    -- 4 = Tasche 4
    --
    -- Nicht belegte Taschenplätze werden
    -- automatisch ignoriert.

    for bagID = 1, MAX_INVENTORY_BAGS do

        local scanned =
            ScanContainer(
                bagID,
                items,
                statistics
            )

        if scanned then

            statistics.bags =
                statistics.bags + 1

        end

    end

    return items, statistics
end

local function MergeItems(
    bankItems,
    inventoryItems
)

    local items = {}

    for itemID, amount in pairs(
        bankItems
    ) do

        AddItem(
            items,
            itemID,
            amount
        )

    end

    for itemID, amount in pairs(
        inventoryItems
    ) do

        AddItem(
            items,
            itemID,
            amount
        )

    end

    return items
end

local function CountItems(
    items
)

    local itemTypes = 0
    local itemCount = 0

    for _, amount in pairs(
        items
    ) do

        itemTypes =
            itemTypes + 1

        itemCount =
            itemCount + amount

    end

    return itemTypes, itemCount
end

local function SaveBankCharData(
    fullName,
    bankItems,
    inventoryItems,
    items,
    gold
)

    local db =
        GBM.BankDB.Get()

    if not db then
        return false
    end

    db.bankChars[fullName] = {

        name = fullName,

        bank = bankItems,

        inventory = inventoryItems,

        items = items,

        gold = gold,

        lastSync = time(),

    }

    return true
end

function BankScanner.IsAvailable()

    return GetCurrentBankChar() ~= nil
end

function BankScanner.Sync()

    local fullName =
        GetCurrentBankChar()

    if not fullName then

        print(
            "|cFFFFFF00GBM|r Kein registrierter Bankchar."
        )

        return false
    end

    if BankScanner.IsSyncing then

        print(
            "|cFFFFFF00GBM|r Synchronisierung läuft bereits."
        )

        return false
    end

    BankScanner.IsSyncing = true

    print(
        "|cFF00FF00GBM|r Synchronisierung gestartet..."
    )

    local bankItems,
        bankStatistics =
        ScanBank()

    local inventoryItems,
        inventoryStatistics =
        ScanInventory()

    local items =
        MergeItems(
            bankItems,
            inventoryItems
        )

    local gold =
        GetMoney() or 0

    local success =
        SaveBankCharData(
            fullName,
            bankItems,
            inventoryItems,
            items,
            gold
        )

    BankScanner.IsSyncing = false

    if not success then

        print(
            "|cFFFF0000GBM|r Synchronisierung fehlgeschlagen."
        )

        return false
    end

    local db =
        GBM.BankDB.Get()

    db.sync.revision =
        db.sync.revision + 1

    db.sync.timestamp =
        time()

    db.sync.bankChar =
        fullName

    BankScanner.RebuildItemIndex()

    if GBM.UI.Bank then
        GBM.UI.Bank.Refresh()
    end

    local bankItemTypes,
        bankItemCount =
        CountItems(
            bankItems
        )

    local inventoryItemTypes,
        inventoryItemCount =
        CountItems(
            inventoryItems
        )

    local totalItemTypes,
        totalItemCount =
        CountItems(
            items
        )

    print(
        "|cFF00FF00GBM|r Bankchar:",
        fullName
    )

    print(
        "|cFF00FF00GBM|r Banktaschen:",
        bankStatistics.bankBags,
        "von",
        MAX_BANK_BAGS
    )

    print(
        "|cFF00FF00GBM|r Bankslots gesamt:",
        bankStatistics.slots
    )

    print(
        "|cFF00FF00GBM|r Belegte Bankslots:",
        bankStatistics.filledSlots
    )

    print(
        "|cFF00FF00GBM|r Bank-Items:",
        bankItemCount
    )

    print(
        "|cFF00FF00GBM|r Bank-Itemtypen:",
        bankItemTypes
    )

    print(
        "|cFF00FF00GBM|r Inventartaschen:",
        inventoryStatistics.bags,
        "von",
        MAX_INVENTORY_BAGS
    )

    print(
        "|cFF00FF00GBM|r Inventarslots:",
        inventoryStatistics.slots
    )

    print(
        "|cFF00FF00GBM|r Belegte Inventarslots:",
        inventoryStatistics.filledSlots
    )

    print(
        "|cFF00FF00GBM|r Inventar-Items:",
        inventoryItemCount
    )

    print(
        "|cFF00FF00GBM|r Gesamt-Items:",
        totalItemCount
    )

    print(
        "|cFF00FF00GBM|r Gesamt-Itemtypen:",
        totalItemTypes
    )

    print(
        "|cFF00FF00GBM|r Gold:",
        GetMoneyString(
            gold,
            true
        )
    )

    return true
end

function BankScanner.RebuildItemIndex()

    local db =
        GBM.BankDB.Get()

    if not db then
        return
    end

    local items = {}

    for _, bankChar in pairs(
        db.bankChars
    ) do

        if GBM.Utils.IsTable(
            bankChar.items
        ) then

            for itemID in pairs(
                bankChar.items
            ) do

                items[itemID] = true

            end

        end

    end

    db.items = items
end