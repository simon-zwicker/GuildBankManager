local GBM = GBM

GBM.WoW = {}
local WoW = GBM.WoW

function WoW.GetPlayerName()
    return UnitName("player")
end

function WoW.GetPlayerRealm()
    return GetRealmName()
end

function WoW.GetGuildInfo()
    local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")

    if not guildName then
        return nil
    end

    return {
        name = guildName,
        rankName = guildRankName,
        rankIndex = guildRankIndex,
    }
end

function WoW.RequestGuildRoster()
    GuildRoster()
end

function WoW.GetGuildMemberCount()
    return GetNumGuildMembers()
end

function WoW.GetGuildMemberInfo(index)
    local name, rankName, rankIndex, level, _, _, _, _, isOnline, _, class = GetGuildRosterInfo(index)

    if not name then 
        return nil
    end

    return {
        name = name, 
        rank = rankName,
        rankIndex = rankIndex,
        level = level,
        class = class,
        online = isOnline,
    }
end