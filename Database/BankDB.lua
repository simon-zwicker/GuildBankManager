local GBM = GBM

GBM.BankDB = {}
local BankDB = GBM.BankDB

local DEFAULT_DATABASE = {
    version = 1,
    bankChars = {},
    items = {},
    requests = {},
    deposits = {},
    reservations = {},
    sync = {
        revision = 0,
        timestamp = 0,
        bankChars = nil,
    }
}

function BankDB.Initialize()
    if not GBM.Utils.IsTable(GuildBankManager_BankDB) then
        GuildBankManager_BankDB = {}
    end

    local db = GuildBankManager_BankDB

    if db.version == nil then
        db.version = DEFAULT_DATABASE.version
    end

    if not GBM.Utils.IsTable(db.bankChars) then
        db.bankChars = {}
    end

    if not GBM.Utils.IsTable(db.items) then
        db.items = {}
    end

    if not GBM.Utils.IsTable(db.requests) then
        db.requests = {}
    end

    if not GBM.Utils.IsTable(db.deposits) then
        db.deposits = {}
    end

    if not GBM.Utils.IsTable(db.reservations) then
        db.reservations = {}
    end

    if not GBM.Utils.IsTable(db.sync) then
        db.sync = {}
    end

    if db.sync.revision == nil then
        db.sync.revision = 0
    end

    if db.sync.timestamp == nil then
        db.sync.timestamp = 0
    end

    if db.sync.bankChars == nil then
        db.sync.bankChars = nil
    end
end