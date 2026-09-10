local GBM = GBM

GBM.Guild = {}
local Guild = GBM.Guild

function Guild.Initialize()
    local guildInfo = Guild.GetInfo()

    if not guildInfo then  
        return nil
    end

    local db = GBM.GuildDB.Get()

    db.identity.name = guildInfo.name
    db.identity.realm = GBM.WoW.GetPlayerRealm()
    db.identity.key = db.identity.name .. "@" .. db.identity.realm

    return db.identity
end

function Guild.GetInfo()
    return GBM.WoW.GetGuildInfo()
end