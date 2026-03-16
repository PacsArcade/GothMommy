Locale = {}

function _U(str, ...)
    if Locale[Config.Locale] and Locale[Config.Locale][str] then
        return string.format(Locale[Config.Locale][str], ...)
    end
    return str
end
