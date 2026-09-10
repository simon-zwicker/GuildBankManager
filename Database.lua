function GuildBankManager:InitDatabase()
    GuildBankManagerDB = GuildBankManagerDB = {}
    local db = GuildBankManagerDB

    db.version = db.version or 1
    db.guilds = db.guilds or {}
    db.currentGuild = db.currentGuild or nil
    db.settings = db.setings or {
        guildChatMessages = true,
    }

    self.db = db
end

function GuildBankManager:GetGuildDB()
    if not self.guild then
        return nil
    end

    local guildKey = self:GetGuildKey()

    if not guildKey then
        return nil
    end

    self.db.guilds[guildKey] = self.db.guilds[guildKey] or {
        identity = {
            name = self.guild.name
            realm = self.guild.realm
        },
        members = {},
        bankChars = {},
        items = {},
        requests = {},
        stats = {
            players = {},
        },
        addonUsers = {},
        lastBankUpdate = nil,
    }

    return self.db.guilds[guildKey]
end

function GuildBankManager:GetGuildKey()
    if not self.guild then
        return nil
    end

    return self.guild.name.."@"..self.guild.realm
end

function GuildBankManager:GetCurrentDB()
    return self:GetGuildDB()
end