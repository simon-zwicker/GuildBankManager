local GBM = GBM

GBM.Sync = GBM.Sync or {}
GBM.Sync.Serializer = {}

local Serializer = GBM.Sync.Serializer

local function EscapeString(value)

    value = string.gsub(
        value,
        "\\",
        "\\\\"
    )

    value = string.gsub(
        value,
        "\"",
        "\\\""
    )

    value = string.gsub(
        value,
        "\n",
        "\\n"
    )

    return value

end

local function SerializeValue(value)

    local valueType = type(value)

    if valueType == "nil" then

        return "nil"

    elseif valueType == "boolean" then

        return value and "true" or "false"

    elseif valueType == "number" then

        return tostring(value)

    elseif valueType == "string" then

        return "\""
            .. EscapeString(value)
            .. "\""

    elseif valueType == "table" then

        local result = {
            "{"
        }

        for key, entry in pairs(value) do

            result[#result + 1] =
                "["
                .. SerializeValue(key)
                .. "]="
                .. SerializeValue(entry)
                .. ","

        end

        result[#result + 1] = "}"

        return table.concat(
            result
        )

    end

    return "nil"

end

function Serializer.Serialize(data)

    return SerializeValue(
        data
    )

end

function Serializer.Deserialize(data)

    if type(data) ~= "string" then
        return nil
    end

    local chunk =
        "return "
        .. data

    local loader =
        loadstring(chunk)

    if not loader then
        return nil
    end

    local success, result =
        pcall(loader)

    if not success then
        return nil
    end

    return result

end