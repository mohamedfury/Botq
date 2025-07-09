-- libs/json.lua
-- مكتبة JSON مبسطة بلغة Lua للترميز (encode) والفك (decode)

local json = {}

-- فك ترميز JSON (decode) إلى جدول Lua (باستخدام load)
function json.decode(str)
    local f, err = load("return " .. str, "json_decode", "t", {})
    if not f then
        return nil, err
    end
    local ok, result = pcall(f)
    if not ok then
        return nil, result
    end
    return result
end

-- ترميز جدول Lua إلى JSON (encode) - مبسط جداً
function json.encode(value)
    local t = type(value)
    if t == "nil" then
        return "null"
    elseif t == "boolean" then
        return tostring(value)
    elseif t == "number" then
        return tostring(value)
    elseif t == "string" then
        return string.format("%q", value)
    elseif t == "table" then
        local is_array = (#value > 0)
        local result = {}
        if is_array then
            for i=1, #value do
                table.insert(result, json.encode(value[i]))
            end
            return "[" .. table.concat(result, ",") .. "]"
        else
            for k,v in pairs(value) do
                table.insert(result, string.format("%q:%s", k, json.encode(v)))
            end
            return "{" .. table.concat(result, ",") .. "}"
        end
    else
        error("نوع غير مدعوم في JSON: " .. t)
    end
end

return json