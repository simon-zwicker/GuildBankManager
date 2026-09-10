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

function Guild.UpdateMembers()
    local db = GBM.GuildDB.Get()

    if not db then
        return nil
    end

    GBM.WoW.RequestGuildRoster()

    local members = {}
    local memberCount = GBM.WoW.GetGuildMemberCount()

    for index = 1, memberCount do
        local member = GBM.WoW.GetGuildMemberInfo(index)

        if member then 
            members[member.name] = member
        end
    end

    db.members = members
    return members
end