function GuildBankManager:UpdateGuildInfo()
    if not IsInGuild() then
        self.guild = nil
        return
    end

    local guildName, _, _, realmName = GetGuildInfo("player")

    if not guildName then
        self.guild = nil
        return
    end

    realmName = realmName or GetRealmName()

    self.guild = {
        name = guildName
        realm = realmName
    }

    local guildDB = self:GetGuildDB()

    if not guildDB then
        return
    end

    self:UpdateGuildMembers(guildDB)

    local playerName = UnitName("player")

    guildDB.addonUsers[playerName] = guildDB.addonUsers[playerName] or {}
    guildDB.addonUsers[playerName].name = playerName
    guildDB.addonUsers[playerName].version = self.version
    guildDB.addonUsers[playerName].lastSeen = time() 
end

function GuildBankManager:UpdateGuildMembers(guildDB)
    local memberCount = GetGuildMembersCount()
    local currentMembers = {}

    for i = 1, memberCount do
        local name, rankName, rankIndex, level, className = GetGuildRosterInfo(i)

        if name then
            name = Ambiguate(name, "none")

            currentMembers[name] = {
                name = name,
                rankName = rankName,
                rankIndex = rankIndex
                level = level
                className = className,
            }

            guildDB.members[name].name = name
            guildDB.members[name].rankName = rankName
            guildDB.members[name].rankIndex = rankIndex
            guildDB.members[name].level = level
            guildDB.members[name].className = className
        end
    end

    for name in pairs(guildDB.members) do
        if not currentMembers[name] then
            guildDB.members[name] = nil
            
            if guildDB.bankChars[name] then
                guildDB.bankChars[name] = nil
            end

            if guildDB.stats and guildDB.stats.players  then
                guildDB.stats.players[name] = nil
            end

            if guildDB.addonUsers then
                guildDB.addonUsers[name] = nil
            end

            self:ConvertPlayerToUnknown(guildDB, name)
        end
    end

    self.guildMembers = currentMembers
end

function GuildBankManager:IsGuildLeaderOrOfficer()
     if not IsInGuild() then 
        return false
     end

     local rankIndex = select(3, GetGuildInfo("player"))

     if rankIndex == 0 then
        return true
     end

     local canEdit = false

     if GuildControlGetRankFlags then
        local canInvite,
            canRemove,
            canPromote,
            canDemote,
            canSetMOTD,
            canEditPublicNote,
            canEditOfficerNote,
            canViewOfficerNote,
            canGuildBankView,
            canGuildBankWithdraw,
            canGuildBankDeposit,
            canGuildBankUpdateText = GuildControlGetRankFlags(rankIndex)

        if canGuildBankWithdraw then
            canEdit = true
        end
    end

    return canEdit
end

function GuildBankManager:CanManageBankChars()
    return self:IsGuildLeaderOrOfficer()
end

function GuildBankManager:IsBankChar(playerName)
    local guildDB = self:GetCurrentGuildDB()

    if not guildDB then
        return false
    end

    return guildDB.bankChars[playerName] == true
end

function GuildBankManager:AddBankChar(playerName)
    if not self:CanManageBankChars() then
        self:Print("No Permission to manage Bank Characters.")
        return false
    end

    local guildDB = self:GetCurrentGuildDB()

    if not guildDB then
        return false
    end

    if not guildDB.members[playerName] then
        self:Print("This Character is not in your Guild.")
        return false
    end

    guildDB.bankChars[playerName] = true

    self:Print(playerName .. " was added as Bank Character.")

    self:RefreshMainUI()

    return true
end

function GBM:RemoveBankChar(playerName)

    if not self:CanManageBankChars() then
        self:Print("No Permission to manage Bank Characters.")
        return false
    end

    local guildDB = self:GetCurrentGuildDatabase()

    if not guildDB then
        return false
    end

    guildDB.bankChars[playerName] = nil

    self:Print(playerName .. " was removed from Bank Characters.")

    self:RefreshMainUI()

    return true
end
