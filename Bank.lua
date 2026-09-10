function GuildBankManager:GetBankItems()

    local guildDB = self:GetCurrentGuildDatabase()

    if not guildDB then
        return {}
    end

    return guildDB.items
end

function GuildBankManager:GetItemData(itemID)

    local guildDB = self:GetCurrentGuildDatabase()

    if not guildDB then
        return nil
    end

    return guildDB.items[tostring(itemID)]
end

function GuildBankManager:SetItemData(itemID, data)

    local guildDB = self:GetCurrentGuildDatabase()

    if not guildDB then
        return false
    end

    guildDB.items[tostring(itemID)] = data

    return true
end

function GuildBankManager:GetItemAvailable(itemID)

    local data = self:GetItemData(itemID)

    if not data then
        return 0
    end

    local total = data.amount or 0
    local reserved = data.reserved or 0

    return math.max(0, total - reserved)
end

function GuildBankManager:GetItemReserved(itemID)

    local data = self:GetItemData(itemID)

    if not data then
        return 0
    end

    return data.reserved or 0
end

function GuildBankManager:AddReservation(itemID, amount)

    local guildDB = self:GetCurrentGuildDatabase()

    if not guildDB then
        return false
    end

    local key = tostring(itemID)

    guildDB.items[key] = guildDB.items[key] or {
        amount = 0,
        reserved = 0,
        contributors = {},
    }

    local itemData = guildDB.items[key]

    local available =
        (itemData.amount or 0) -
        (itemData.reserved or 0)

    if amount > available then
        return false
    end

    itemData.reserved =
        (itemData.reserved or 0) + amount

    return true
end

function GuildBankManager:RemoveReservation(itemID, amount)

    local itemData = self:GetItemData(itemID)

    if not itemData then
        return false
    end

    itemData.reserved =
        math.max(
            0,
            (itemData.reserved or 0) - amount
        )

    return true
end