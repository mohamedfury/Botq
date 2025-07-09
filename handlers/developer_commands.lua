-- handlers/developer_commands.lua

local json = require("dkjson") local data = require("data") local utils = require("utils") local keyboard = require("keyboard")

local M = {}

function M.handle(msg) local text = msg.text local chat_id = msg.chat.id local user_id = msg.from.id

-- تحقق من صلاحيات المطور الأساسي if not data:is_sudo(user_id) then return end

-- عرض لوحة اوامر المطور if text == "اوامر المطور" then local keys = { { { text = "اذاعة" }, { text = "الاحصائيات" } }, { { text = "اذاعة بالتوجيه" }, { text = "اذاعه خاص" } }, { { text = "تفعيل الاشتراك الاجباري" }, { text = "تعطيل الاشتراك الاجباري" } }, { { text = "رفع مطور" }, { text = "تنزيل مطور" } }, { { text = "المطورين" }, { text = "مسح المطورين" } }, { { text = "حظر عام" }, { text = "الغاء حظر عام" } }, { { text = "كتم عام" }, { text = "الغاء كتم عام" } }, { { text = "قائمه العام" }, { text = "المكتومين عام" } }, { { text = "تصفير العدادات" }, { text = "تحديث السورس" } } } utils.send_keyboard(chat_id, "⌔︙اختر من اوامر المطور 👇", keys) return end

-- باقي أوامر المطور يمكن تنفيذها هنا مثل: if text:match("^رفع مطور$") and msg.reply_to_message then local target = msg.reply_to_message.from.id data:promote_developer(target) utils.send_reply(msg, "↫ تم رفعه مطور بنجاح ✓") return end

if text:match("^تنزيل مطور$") and msg.reply_to_message then local target = msg.reply_to_message.from.id data:demote_developer(target) utils.send_reply(msg, "↫ تم تنزيله من المطورين ✓") return end

if text == "المطورين" then local list = data:get_developers() local reply = "⌔︙قائمة المطورين:\n" for _, dev in ipairs(list) do reply = reply .. "• [" .. dev.name .. "](tg://user?id=" .. dev.id .. ")\n" end utils.send_reply_markdown(msg, reply) return end end

return M

