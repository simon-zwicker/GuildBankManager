local GBM = GBM

GBM.L = {}

local L = GBM.L

local locale = GetLocale()

local ENGLISH = {

    ADDON_NAME = "GuildBankManager",

    BANK = "Bank",
    REQUESTS = "Requests",
    STATISTICS = "Statistics",
    USAGE = "Usage",
    SETTINGS = "Settings",

    ITEM = "Item",
    TOTAL = "Amount",
    BANK_CHARS = "Bank Character",
    RESERVED = "Requested",
    AVAILABLE = "Available",
    REQUEST = "Request",
    ADD_BANK_CHAR = "Add Bank Character",
    RESET_BANK_CHARS = "Reset Bank Characters",
    RESET_CONFIRMATION = "Reset all registered bank characters?",
    ADD = "Add",
    CANCEL = "Cancel",
    RESET = "Reset",
    SEARCH = "Search",

    LOADED = "loaded - Version %s",

    GUILD_MEMBERS_LOADED =
        "Guild members loaded: %d",

    BANK_CHAR_ADDED =
        "Bank character added:",

    NO_REGISTERED_BANK_CHAR =
        "No registered bank character.",

    SYNC_STARTED =
        "Bank sync started...",

    SYNC_RUNNING =
        "Bank sync already running.",

    SYNC_FAILED =
        "Bank sync failed.",

    SYNC_FINISHED =
        "Bank sync finished: %d items, %s",

    SYNC_RECEIVED =
        "Guild data synchronized: %d items, %s",

    BANK_BAGS =
        "Bank bags:",

    BANK_SLOTS_TOTAL =
        "Bank slots:",

    FILLED_BANK_SLOTS =
        "Filled bank slots:",

    BANK_ITEMS =
        "Bank items:",

    BANK_ITEM_TYPES =
        "Bank item types:",

    INVENTORY_BAGS =
        "Inventory bags:",

    INVENTORY_SLOTS =
        "Inventory slots:",

    FILLED_INVENTORY_SLOTS =
        "Filled inventory slots:",

    INVENTORY_ITEMS =
        "Inventory items:",

    TOTAL_ITEMS =
        "Total items:",

    TOTAL_ITEM_TYPES =
        "Total item types:",

    GOLD =
        "Gold:",

    REQUEST_WINDOW_UNAVAILABLE =
        "Request window is not available yet.",

    REQUEST_AMOUNT_ERROR =
        "You should choose an amount\nbetween %d and %d.",

    PERMISSIONS =
        "Permissions",

    PERMISSIONS_DESCRIPTION =
        "Set the minimum guild rank required to use each function.",

    PERMISSION_MANAGE_REQUESTS =
        "Manage Requests",

    PERMISSION_ASSIGN_REQUESTS =
        "Assign Requests",

    PERMISSION_REJECT_REQUESTS =
        "Reject Requests",

    PERMISSION_MANAGE_BANK_CHARS =
        "Manage Bank Characters",

    PERMISSION_SYNC_BANK =
        "Synchronize Bank",

    BANK_CHARS_DESCRIPTION =
        "Manage the characters registered as bank characters.",

    RESET_BANK_CHARS =
        "Reset Bank Characters",

    BANK_CHAR_STATUS =
        "Bank character: %s",

    BANK_BAGS_STATUS =
        "Bank bags: %d of %d",

    BANK_SLOTS_STATUS =
        "Total bank slots: %d",

    FILLED_BANK_SLOTS_STATUS =
        "Filled bank slots: %d",

    BANK_ITEMS_STATUS =
        "Bank items: %d",

    BANK_ITEM_TYPES_STATUS =
        "Bank item types: %d",

    INVENTORY_BAGS_STATUS =
        "Inventory bags: %d of %d",

    INVENTORY_SLOTS_STATUS =
        "Inventory slots: %d",

    FILLED_INVENTORY_SLOTS_STATUS =
        "Filled inventory slots: %d",

    INVENTORY_ITEMS_STATUS =
        "Inventory items: %d",

    TOTAL_ITEMS_STATUS =
        "Total items: %d",

    TOTAL_ITEM_TYPES_STATUS =
        "Total item types: %d",

    GOLD_STATUS =
        "Gold: %s",

    SYNC_FINISHED =
        "Bank sync finished: %d items, %s",

}

local function ApplyLocale(
    translations
)

    for key, value in pairs(
        translations
    ) do

        L[key] = value

    end

end

ApplyLocale(
    ENGLISH
)

GBM.Locale = locale