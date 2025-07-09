-- handlers/lock_commands.lua

local json = require("json")
local database_file = "data/protection_settings.json"

local protection = {}
local data = {}

-- تحميل بيانات الحماية من ملف JSON
local function load_data()
    local file = io.open(database_file, "r")
    if not file then return {} end
    local content = file:read("*a")
    file:close()
    local d = json.decode(content)
    return d or {}
end

-- حفظ بيانات الحماية إلى ملف JSON
local function save_data()
    local file = io.open(database_file, "w+")
    file:write(json.encode(data))
    file:close()
end

data = load_data()

-- تهيئة بيانات الحماية للمجموعة إذا مش موجودة
local function ensure_group(chat_id)
    if not data[tostring(chat_id)] then
        data[tostring(chat_id)] = {
            all = {locked = false, mode = "none"},
            links = {locked = false, mode = "none"},
            tags = {locked = false, mode = "none"},
            edits = {locked = false, mode = "none"},
            gifs = {locked = false, mode = "none"},
            photos = {locked = false, mode = "none"},
            markdown = {locked = false, mode = "none"},
            spam = {locked = false, mode = "none"},
            selfie = {locked = false, mode = "none"},
            inline = {locked = false, mode = "none"},
            whisper = {locked = false, mode = "none"},
            forwarding = {locked = false, mode = "none"},
            audio = {locked = false, mode = "none"},
            notifications = {locked = false, mode = "none"},
            media = {locked = false, mode = "none"},
            premium_media = {locked = false, mode = "none"},
            popcorn = {locked = false, mode = "none"},
            channels = {locked = false, mode = "none"},
            english = {locked = false, mode = "none"},
            persian = {locked = false, mode = "none"},
            kufr = {locked = false, mode = "none"},
            porn = {locked = false, mode = "none"},
            confusion = {locked = false, mode = "none"},
            premium_stickers = {locked = false, mode = "none"},
        }
        save_data()
    end
end

-- تحويل أسماء الحماية العربية إلى مفاتيح البيانات
local protection_map = {
    ["الكل"] = "all",
    ["الروابط"] = "links",
    ["التاك"] = "tags",
    ["التعديل"] = "edits",
    ["المتحركه"] = "gifs",
    ["الصور"] = "photos",
    ["الماركداون"] = "markdown",
    ["التكرار"] = "spam",
    ["السيلفي"] = "selfie",
    ["الانلاين"] = "inline",
    ["الهمسه"] = "whisper",
    ["التوجيه"] = "forwarding",
    ["الصوت"] = "audio",
    ["الاشعارات"] = "notifications",
    ["الوسائط"] = "media",
    ["وسائط المميزين"] = "premium_media",
    ["الفشار"] = "popcorn",
    ["القنوات"] = "channels",
    ["الإنكليزيه"] = "english",
    ["الفارسيه"] = "persian",
    ["الكفر"] = "kufr",
    ["الاباحي"] = "porn",
    ["التشويش"] = "confusion",
    ["الملصقات المميزه"] = "premium_stickers",
}

local modes = {
    ["تقييد"] = "تقييد",
    ["طرد"] = "طرد",
    ["كتم"] = "كتم",
    ["none"] = "none"
}

-- التعامل مع أوامر القفل والفتح
function protection:handle(msg, bot)
    local chat_id = tostring(msg.chat.id)
    local text = msg.text

    ensure_group(chat_id)

    -- نمط الأمر: قفل {اسم الحماية} {بالتقييد|بالطرد|بالكتم} أو فتح {اسم الحماية}
    local action, protection_name, mode = text:match("^(قفل) ([^ ]+)%s*(.*)$")
    if not action then
        action, protection_name = text:match("^(فتح) ([^ ]+)$")
    end

    if action and protection_name then
        local key = protection_map[protection_name]
        if not key then
            bot:sendMessage(msg.chat.id, "هذا النوع من الحماية غير معروف: "..protection_name, msg.message_id)
            return
        end

        if action == "قفل" then
            local selected_mode = "none"
            if mode then
                mode = mode:gsub("بال", "") -- حذف "بال" لو موجودة
                if modes[mode] then
                    selected_mode = modes[mode]
                else
                    bot:sendMessage(msg.chat.id, "طريقة الحماية غير معروفة، استخدم: تقييد، طرد، كتم", msg.message_id)
                    return
                end
            else
                selected_mode = "تقييد" -- افتراضي
            end
            data[chat_id][key].locked = true
            data[chat_id][key].mode = selected_mode
            save_data()
            bot:sendMessage(msg.chat.id, "تم قفل "..protection_name.." بطريقة ("..selected_mode..") ✅", msg.message_id)
            return

        elseif action == "فتح" then
            data[chat_id][key].locked = false
            data[chat_id][key].mode = "none"
            save_data()
            bot:sendMessage(msg.chat.id, "تم فتح "..protection_name.." ✅", msg.message_id)
            return
        end
    end
end

return protection