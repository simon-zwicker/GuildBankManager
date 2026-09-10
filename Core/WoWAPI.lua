local GBM = GBM

GBM.WoW = {}
local WoW = GBM.WoW

function WoW.GetPlayerName()
    return UnitName("player")
end

function WoW.GetFullPlayerName(name)
    name = name or WoW.GetPlayerName()
    return name .. "-" .. WoW.GetPlayerRealm()
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
    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
        return
    end

    if GuildRoster then
        GuildRoster()
    end
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
        fullName = name,
        rank = rankName,
        rankIndex = rankIndex,
        level = level,
        class = class,
        online = isOnline,
    }
end