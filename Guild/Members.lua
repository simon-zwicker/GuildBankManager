local GBM = GBM

local Guild = GBM.Guild

function Guild.UpdateMembers()

    local db =
        GBM.GuildDB.Get()

    if not db then
        return nil
    end

    local members = {}

    local memberCount =
        GBM.WoW.GetGuildMemberCount()

    for index = 1, memberCount do

        local member =
            GBM.WoW.GetGuildMemberInfo(
                index
            )

        if member
            and member.name then

            members[member.name] =
                member

        end

    end

    db.members =
        members

    return members

end