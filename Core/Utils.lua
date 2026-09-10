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
