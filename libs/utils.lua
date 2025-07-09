-- libs/utils.lua
local utils = {}

-- دالة لقراءة محتوى ملف نصي كامل
function utils.read_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return content
end

-- دالة لكتابة نص كامل إلى ملف (تستبدل المحتوى)
function utils.write_file(path, content)
    local file = io.open(path, "w+")
    if not file then return false end
    file:write(content)
    file:close()
    return true
end

-- دالة لفحص إذا كان جدول يحتوي عنصر معين (value)
function utils.table_contains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

-- دالة لتوليد رقم عشوائي بين min و max
function utils.random_int(min, max)
    return math.random(min, max)
end

-- دالة لفصل نص إلى كلمات (باستخدام المسافات)
function utils.split(str, sep)
    local sep = sep or "%s"
    local t = {}
    for word in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, word)
    end
    return t
end

return utils