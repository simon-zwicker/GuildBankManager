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

    BANK_CHAR_ADDED = "Bank character added:",
    NO_REGISTERED_BANK_CHAR =
        "No registered bank character.",

    SYNC_STARTED =
        "Synchronization started...",

    SYNC_RUNNING =
        "Synchronization already running.",

    SYNC_FAILED =
        "Synchronization failed.",

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

    REQUEST_AMOUNT_ERROR = "You should choose an amount\nbetween %d and %d.",

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