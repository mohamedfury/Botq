-- handlers/admin_commands.lua

local json = require("dkjson")
local data = require("data")
local utils = require("utils")
local config = require("config")

local M = {}

function M.handle(msg)
  local text = msg.text
  local chat_id = msg.chat.id
  local user_id = msg.from.id

  -- تحقق من صلاحية الأدمن
  if not data:is_admin(chat_id, user_id) then
    return
  end

  -- رفع مميز
  if text:match("^رفع مميز$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:promote_member(chat_id, target_id, "vip")
    utils.send_reply(msg, "↫ تم رفعه مميز ✓")
  end

  -- تنزيل مميز
  if text:match("^تنزيل مميز$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:demote_member(chat_id, target_id)
    utils.send_reply(msg, "↫ تم تنزيله من المميزين ✓")
  end

  -- كتم عضو
  if text:match("^كتم$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:set_restriction(chat_id, target_id, "mute")
    utils.send_reply(msg, "↫ تم كتم العضو ✓")
  end

  -- الغاء الكتم
  if text:match("^الغاء كتم$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:remove_restriction(chat_id, target_id, "mute")
    utils.send_reply(msg, "↫ تم الغاء كتم العضو ✓")
  end

  -- طرد
  if text:match("^طرد$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    utils.kick_user(chat_id, target_id)
    utils.send_reply(msg, "↫ تم طرد العضو ✓")
  end

  -- حظر
  if text:match("^حظر$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:ban_user(chat_id, target_id)
    utils.kick_user(chat_id, target_id)
    utils.send_reply(msg, "↫ تم حظر العضو ✓")
  end

  -- الغاء الحظر
  if text:match("^الغاء حظر$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:unban