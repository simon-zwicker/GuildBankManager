local GBM = GBM

GBM.WoW = {}

local WoW = GBM.WoW

local function GetClassToken(
    localizedClass
)

    if not localizedClass then
        return nil
    end

    if RAID_CLASS_COLORS[
        localizedClass
    ] then

        return localizedClass

    end

    if LOCALIZED_CLASS_NAMES_MALE then

        for classToken, className in pairs(
            LOCALIZED_CLASS_NAMES_MALE
        ) do

            if className == localizedClass then

                return classToken

            end

        end

    end

    if LOCALIZED_CLASS_NAMES_FEMALE then

        for classToken, className in pairs(
            LOCALIZED_CLASS_NAMES_FEMALE
        ) do

            if className == localizedClass then

                return classToken

            end

        end

    end

    return nil

end

function WoW.GetPlayerName()

    return UnitName(
        "player"
    )

end

function WoW.GetPlayerRealm()

    return GetRealmName()

end

function WoW.GetGuildInfo()

    local guildName,
        guildRankName,
        guildRankIndex =
        GetGuildInfo(
            "player"
        )

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

    if C_GuildInfo
        and C_GuildInfo.GuildRoster then

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

function WoW.GetGuildMemberInfo(
    index
)

    local name,
        rankName,
        rankIndex,
        level,
        _,
        _,
        _,
        _,
        isOnline,
        _,
        class =
        GetGuildRosterInfo(
            index
        )

    if not name then
        return nil
    end

    return {
        name = name,
        rank = rankName,
        rankIndex = rankIndex,
        level = level,
        class = GetClassToken(
            class
        ),
        online = isOnline,
    }

end

function WoW.GetGuildRankCount()

    if not GuildControlGetNumRanks then
        return 0
    end

    return GuildControlGetNumRanks()

end

function WoW.GetGuildRankName(
    index
)

    if not GuildControlGetRankName then
        return nil
    end

    return GuildControlGetRankName(
        index
    )

end

function WoW.GetFullPlayerName(
    name
)

    local givenName =
        name
        or WoW.GetPlayerName()

    return givenName
        .. "-"
        .. WoW.GetPlayerRealm()

end