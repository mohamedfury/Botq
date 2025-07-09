-- handlers/manager_commands.lua

local json = require("dkjson")
local data = require("data")
local utils = require("utils")
local config = require("config")

local M = {}

function M.handle(msg)
  local text = msg.text
  local chat_id = msg.chat.id
  local user_id = msg.from.id

  -- التحقق من صلاحية المدير
  if not data:is_manager(chat_id, user_id) then
    return
  end

  -- رفع أدمن
  if text:match("^رفع ادمن$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:promote_member(chat_id, target_id, "admin")
    utils.send_reply(msg, "↫ تم رفعه أدمن ✓")
  end

  -- تنزيل أدمن
  if text:match("^تنزيل ادمن$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:demote_member(chat_id, target_id)
    utils.send_reply(msg, "↫ تم تنزيله من الأدمنية ✓")
  end

  -- قائمة الأدمنية
  if text == "الادمنيه" then
    local list = data:get_members_by_role(chat_id, "admin")
    local reply = "⌔︙قائمة الأدمنية:\n"
    for _, user in ipairs(list) do
      reply = reply .. "• [" .. user.name .. "](tg://user?id=" .. user.id .. ")\n"
    end
    utils.send_reply_markdown(msg, reply)
  end

  -- مسح الأدمنية
  if text == "مسح الادمنيه" then
    data:clear_role(chat_id, "admin")
    utils.send_reply(msg, "↫ تم مسح الأدمنية ✓")
  end

  -- تنزيل الكل (بالرد فقط)
  if text == "تنزيل الكل" and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:demote_member(chat_id, target_id)
    utils.send_reply(msg, "↫ تم تنزيل جميع رتب العضو ✓")
  end

  -- كشف البوتات
  if text:match("^كشف البوتات$") then
    utils.list_bots(chat_id, msg)
  end

  -- طرد المحذوفين
  if text == "طرد المحذوفين" then
    utils.kick_deleted_accounts(chat_id, msg)
  end

  -- قفل البوتات
  if text == "قفل البوتات" then
    data:set_lock(chat_id, "bots", true)
    utils.send_reply(msg, "↫ تم قفل البوتات ✓")
  end

  if text == "فتح البوتات" then
    data:set_lock(chat_id, "bots", false)
    utils.send_reply(msg, "↫ تم فتح البوتات ✓")
  end

  if text == "قفل البوتات بالطرد" then
    data:set_lock(chat_id, "bots_kick", true)
    utils.send_reply(msg, "↫ تم قفل البوتات بالطرد ✓")
  end

  if text == "فحص البوت" then
    utils.send_reply(msg, "↫ البوت يعمل بنجاح ✓")
  end
end

return M