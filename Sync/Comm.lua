local GBM = GBM

GBM.Sync = GBM.Sync or {}
GBM.Sync.Comm = {}

local Comm = GBM.Sync.Comm
local Protocol = GBM.Sync.Protocol
local Serializer = GBM.Sync.Serializer

local PREFIX = "GBM"

local MAX_MESSAGE_SIZE = 240

local chunks = {}

local initialized = false

local function GetGuildKey()

    local guildDB =
        GBM.GuildDB.Get()

    if not guildDB then
        return nil
    end

    return guildDB.identity.key

end

local function GetRevision()

    local db =
        GBM.BankDB.Get()

    if not db then
        return 0
    end

    return db.sync.revision
        or 0

end

local function Send(message)

    if not message then
        return false
    end

    if not IsInGuild() then
        return false
    end

    C_ChatInfo.SendAddonMessage(
        PREFIX,
        message,
        "GUILD"
    )

    return true

end

local function SplitMessage(
    message,
    size
)

    local result = {}

    local length =
        string.len(message)

    local position = 1

    while position <= length do

        result[#result + 1] =
            string.sub(
                message,
                position,
                position + size - 1
            )

        position =
            position + size

    end

    return result

end

local function BuildSnapshot()

    local db =
        GBM.BankDB.Get()

    if not db then
        return nil
    end

    return {
        version = db.version,

        bankChars =
            db.bankChars,

        items =
            db.items,

        requests =
            db.requests,

        deposits =
            db.deposits,

        reservations =
            db.reservations,

        sync = {
            revision =
                db.sync.revision,

            timestamp =
                db.sync.timestamp,

            bankChar =
                db.sync.bankChar,
        },
    }

end

local function SendFullSync()

    local guildKey =
        GetGuildKey()

    if not guildKey then
        return false
    end

    local snapshot =
        BuildSnapshot()

    if not snapshot then
        return false
    end

    local serialized =
        Serializer.Serialize(
            snapshot
        )

    local chunksToSend =
        SplitMessage(
            serialized,
            MAX_MESSAGE_SIZE
        )

    local revision =
        GetRevision()

    local total =
        #chunksToSend

    for index, chunk in ipairs(
        chunksToSend
    ) do

        local message =
            Protocol.BuildSyncChunk(
                guildKey,
                revision,
                index,
                total,
                chunk
            )

        Send(message)

    end

    return true

end

local function RequestSync()

    local guildKey =
        GetGuildKey()

    if not guildKey then
        return false
    end

    local message =
        Protocol.BuildRequest(
            guildKey,
            GetRevision()
        )

    return Send(message)

end

local function HandleHello(data)

    local guildKey =
        GetGuildKey()

    if not guildKey then
        return
    end

    if data.guildKey ~= guildKey then
        return
    end

    local localRevision =
        GetRevision()

    if data.revision > localRevision then

        RequestSync()

    end

end

local function HandleRequest(data)

    local guildKey =
        GetGuildKey()

    if not guildKey then
        return
    end

    if data.guildKey ~= guildKey then
        return
    end

    local localRevision =
        GetRevision()

    if localRevision > data.revision then

        SendFullSync()

    end

end

local function ApplySync()

    local complete = true

    for index = 1, chunks.total do

        if not chunks.data[index] then
            complete = false
            break
        end

    end

    if not complete then
        return
    end

    local serialized = {}

    for index = 1, chunks.total do

        serialized[#serialized + 1] =
            chunks.data[index]

    end

    local snapshot =
        Serializer.Deserialize(
            table.concat(serialized)
        )

    if not snapshot then

        chunks = {}

        return

    end

    local db =
        GBM.BankDB.Get()

    if not db then

        chunks = {}

        return

    end

    db.version =
        snapshot.version
        or db.version

    db.bankChars =
        snapshot.bankChars
        or {}

    db.items =
        snapshot.items
        or {}

    db.requests =
        snapshot.requests
        or {}

    db.deposits =
        snapshot.deposits
        or {}

    db.reservations =
        snapshot.reservations
        or {}

    if snapshot.sync then

        db.sync.revision =
            snapshot.sync.revision
            or 0

        db.sync.timestamp =
            snapshot.sync.timestamp
            or 0

        db.sync.bankChar =
            snapshot.sync.bankChar

    end

    chunks = {}

    if GBM.BankScanner
        and GBM.BankScanner.RebuildItemIndex then

        GBM.BankScanner.RebuildItemIndex()

    end

    if GBM.UI
        and GBM.UI.Bank
        and GBM.UI.Bank.Refresh then

        GBM.UI.Bank.Refresh()

    end

    print(
        "|cFF00FF00GBM|r "
        .. "Guild-Daten synchronisiert."
    )

end

local function HandleSync(data)

    local guildKey =
        GetGuildKey()

    if not guildKey then
        return
    end

    if data.guildKey ~= guildKey then
        return
    end

    if data.chunkTotal <= 0 then
        return
    end

    if data.chunkIndex <= 0 then
        return
    end

    if data.chunkIndex >
        data.chunkTotal then

        return

    end

    chunks.revision =
        data.revision

    chunks.total =
        data.chunkTotal

    chunks.data =
        chunks.data
        or {}

    chunks.data[
        data.chunkIndex
    ] =
        data.data

    ApplySync()

end

local function OnAddonMessage(
    prefix,
    message,
    channel,
    sender
)

    if prefix ~= PREFIX then
        return
    end

    if channel ~= "GUILD" then
        return
    end

    if not message then
        return
    end

    if sender ==
        GBM.WoW.GetFullPlayerName() then

        return
    end

    local data =
        Protocol.Parse(
            message
        )

    if not data then
        return
    end

    if data.command ==
        Protocol.HELLO then

        HandleHello(data)

    elseif data.command ==
        Protocol.REQUEST then

        HandleRequest(data)

    elseif data.command ==
        Protocol.SYNC then

        HandleSync(data)

    end

end

function Comm.Initialize()

    if initialized then
        return
    end

    if not C_ChatInfo
        or not C_ChatInfo.RegisterAddonMessagePrefix then

        print(
            "|cFFFF0000GBM|r "
            .. "Addon-Kommunikation nicht verfügbar."
        )

        return false

    end

    C_ChatInfo.RegisterAddonMessagePrefix(
        PREFIX
    )

    initialized = true

    return true

end

function Comm.OnEvent(
    event,
    ...
)

    if event ~= "CHAT_MSG_ADDON" then
        return
    end

    OnAddonMessage(
        ...
    )

end

function Comm.Hello()

    local guildKey =
        GetGuildKey()

    if not guildKey then
        return false
    end

    return Send(
        Protocol.BuildHello(
            guildKey,
            GetRevision()
        )
    )

end

function Comm.RequestSync()

    return RequestSync()

end

function Comm.Broadcast()

    return SendFullSync()

end

function Comm.MarkChanged()

    return Comm.Broadcast()

end