local GBM = GBM

GBM.Sync = GBM.Sync or {}
GBM.Sync.Protocol = {}

local Protocol = GBM.Sync.Protocol

Protocol.VERSION = 1

Protocol.HELLO = "HELLO"
Protocol.REQUEST = "REQUEST"
Protocol.SYNC = "SYNC"

Protocol.SEPARATOR = "|"

function Protocol.BuildHello(
    guildKey,
    revision
)

    return table.concat(
        {
            Protocol.HELLO,
            guildKey or "",
            tostring(
                revision or 0
            ),
        },
        Protocol.SEPARATOR
    )

end

function Protocol.BuildRequest(
    guildKey,
    revision
)

    return table.concat(
        {
            Protocol.REQUEST,
            guildKey or "",
            tostring(
                revision or 0
            ),
        },
        Protocol.SEPARATOR
    )

end

function Protocol.BuildSyncChunk(
    guildKey,
    revision,
    chunkIndex,
    chunkTotal,
    data
)

    return table.concat(
        {
            Protocol.SYNC,
            guildKey or "",
            tostring(
                revision or 0
            ),
            tostring(chunkIndex),
            tostring(chunkTotal),
            data or "",
        },
        Protocol.SEPARATOR
    )

end

function Protocol.Parse(message)

    if type(message) ~= "string" then
        return nil
    end

    local command,
        guildKey,
        revision,
        chunkIndex,
        chunkTotal,
        data

    command,
        guildKey,
        revision,
        chunkIndex,
        chunkTotal,
        data =
        string.match(
            message,
            "^([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|(.*)$"
        )

    if command == Protocol.HELLO then

        return {
            command = command,
            guildKey = guildKey,
            revision =
                tonumber(revision)
                or 0,
        }

    elseif command == Protocol.REQUEST then

        return {
            command = command,
            guildKey = guildKey,
            revision =
                tonumber(revision)
                or 0,
        }

    elseif command == Protocol.SYNC then

        return {
            command = command,
            guildKey = guildKey,
            revision =
                tonumber(revision)
                or 0,
            chunkIndex =
                tonumber(chunkIndex)
                or 0,
            chunkTotal =
                tonumber(chunkTotal)
                or 0,
            data = data or "",
        }

    end

    return nil

end