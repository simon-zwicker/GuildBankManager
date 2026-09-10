local GBM = GBM

local UI = GBM.UI

UI.BankData = {}

local BankData = UI.BankData

local function GetItemName(itemID)

    if not itemID then
        return nil
    end

    local itemName =
        GetItemInfo(itemID)

    return itemName

end

local function MatchesSearch(
    itemID,
    searchText
)

    if searchText == "" then
        return true
    end

    local itemName =
        GetItemName(itemID)

    if not itemName then
        return false
    end

    return itemName:lower():find(
        searchText:lower(),
        1,
        true
    ) ~= nil

end

function BankData.GetItems()

    local db =
        GBM.BankDB.Get()

    if not db then
        return {}
    end

    local items = {}

    for itemID in pairs(
        db.items
    ) do

        local numericItemID =
            tonumber(itemID)

        if numericItemID then

            table.insert(
                items,
                numericItemID
            )

        end

    end

    table.sort(
        items,
        function(a, b)

            local nameA =
                GetItemName(a)
                or ""

            local nameB =
                GetItemName(b)
                or ""

            return nameA:lower()
                < nameB:lower()

        end
    )

    return items

end

function BankData.GetFilteredItems(
    searchText
)

    local items =
        BankData.GetItems()

    local filteredItems = {}

    searchText =
        searchText
        or ""

    for _, itemID in ipairs(
        items
    ) do

        if MatchesSearch(
            itemID,
            searchText
        ) then

            table.insert(
                filteredItems,
                itemID
            )

        end

    end

    return filteredItems

end