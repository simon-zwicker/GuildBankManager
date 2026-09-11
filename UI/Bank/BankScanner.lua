local GBM = GBM

GBM.BankScanner = {}

local BankScanner = GBM.BankScanner

local L = GBM.L

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

    ScanContainer(
        BANK_CONTAINER,
        items,
        statistics
    )

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

    ScanContainer(
        0,
        items,
        statistics
    )

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
            "|cFFFFFF00GBM|r "
            .. L.NO_REGISTERED_BANK_CHAR
        )

        return false

    end

    if BankScanner.IsSyncing then

        print(
            "|cFFFFFF00GBM|r "
            .. L.SYNC_RUNNING
        )

        return false

    end

    BankScanner.IsSyncing = true

    print(
        "|cFF00FF00GBM|r "
        .. L.SYNC_STARTED
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
            "|cFFFF0000GBM|r "
            .. L.SYNC_FAILED
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
        "|cFF00FF00GBM|r "
        .. string.format(
            L.BANK_CHAR_STATUS,
            fullName
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.BANK_BAGS_STATUS,
            bankStatistics.bankBags,
            MAX_BANK_BAGS
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.BANK_SLOTS_STATUS,
            bankStatistics.slots
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.FILLED_BANK_SLOTS_STATUS,
            bankStatistics.filledSlots
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.BANK_ITEMS_STATUS,
            bankItemCount
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.BANK_ITEM_TYPES_STATUS,
            bankItemTypes
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.INVENTORY_BAGS_STATUS,
            inventoryStatistics.bags,
            MAX_INVENTORY_BAGS
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.INVENTORY_SLOTS_STATUS,
            inventoryStatistics.slots
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.FILLED_INVENTORY_SLOTS_STATUS,
            inventoryStatistics.filledSlots
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.INVENTORY_ITEMS_STATUS,
            inventoryItemCount
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.TOTAL_ITEMS_STATUS,
            totalItemCount
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.TOTAL_ITEM_TYPES_STATUS,
            totalItemTypes
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.GOLD_STATUS,
            GetMoneyString(
                gold,
                true
            )
        )
    )

    print(
        "|cFF00FF00GBM|r "
        .. string.format(
            L.SYNC_FINISHED,
            totalItemCount,
            GetMoneyString(
                gold,
                true
            )
        )
    )

    if GBM.Sync
        and GBM.Sync.Comm
        and GBM.Sync.Comm.MarkChanged then

        GBM.Sync.Comm.MarkChanged()

    end

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