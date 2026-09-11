local GBM = GBM

GBM.Utils = {}
local Utils = GBM.Utils

function Utils.IsTable(value)
    return type(value) == "table"
end

function Utils.isString(value)
    return type(value) == "string"
end

function Utils.isNumber(value)
    return type(value) == "number"
end

function Utils.GetClassColor(class)
    if not class then
        return 1, 1, 1
    end

    local color = RAID_CLASS_COLORS[class]

    if not color then
        return 1, 1, 1
    end

    return color.r, color.g, color.b
end

function Utils.GetGuildMember(
    fullName
)

    if not fullName then
        return nil
    end

    local db =
        GBM.GuildDB.Get()

    if not db
        or not db.members then

        return nil

    end

    return db.members[fullName]

end

function Utils.GetShortName(
    fullName
)

    if not fullName then
        return ""
    end

    return string.match(
        fullName,
        "^[^-]+"
    ) or fullName

end

function Utils.GetGuildMemberClass(
    fullName
)

    local member =
        Utils.GetGuildMember(
            fullName
        )

    if not member then
        return nil
    end

    return member.class

end