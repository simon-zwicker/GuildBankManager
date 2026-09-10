local GBM = GBM

GBM.GuildDB = {}
local GuildDB = GBM.GuildDB

local DEFAULT_DATABASE = {
    version = 1,
    identity = {
        name = nil,
        realm = nil,
        key = nil,
    },
    members = {},
    bankChars = {},
    addonUsers = {},
}

function GuildDB.Initialize() 

    if not GBM.Utils.IsTable(GuildBankManager_GuildDB) then
        GuildBankManager_GuildDB = {}
    end

    local db = GuildBankManager_GuildDB

    if db.version == nil then
        db.version = DEFAULT_DATABASE.version
    end

    if not GBM.Utils.IsTable(db.identity) then 
        db.identity = {}
    end

    if not GBM.Utils.IsTable(db.members) then 
        db.members = {}
    end

    if not GBM.Utils.IsTable(db.bankChars) then 
        db.bankChars = {}
    end

    if not GBM.Utils.IsTable(db.addonUsers) then 
        db.addonUsers = {}
    end

    GuildDB.Data = db

    return db
end

function GuildDB.Get()
    return GuildDB.Data
end