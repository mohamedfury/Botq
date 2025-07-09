-- handlers/creator_commands.lua

local json = require("dkjson")
local data = require("data")
local utils = require("utils")
local config = require("config")

local M = {}

function M.handle(msg)
  local text = msg.text
  local chat_id = msg.chat.id
  local user_id = msg.from.id

  -- التحقق من صلاحية المنشئ
  if not data:is_creator(chat_id, user_id) then
    return
  end

  -- رفع مدير
  if text:match("^رفع مدير$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:promote_member(chat_id, target_id, "manager")
    utils.send_reply(msg, "↫ تم رفعه مدير ✓")
  end

  -- تنزيل مدير
  if text:match("^تنزيل مدير$") and msg.reply_to_message then
    local target_id