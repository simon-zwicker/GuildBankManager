local GBM = GBM
local Guild = GBM.Guild

function Guild.AddBankChar(fullName)
    local db = GBM.GuildDB.Get()

    if not db then
        return nil
    end

    db.bankChars[fullName] = {
        fullName = fullName,
        addedBy = GBM.WoW.GetFullPlayerName(),
        addedAt = time(),
    }

    return true
end