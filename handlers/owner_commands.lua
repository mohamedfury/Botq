-- handlers/owner_commands.lua

local json = require("dkjson")
local data = require("data")
local utils = require("utils")

local M = {}

function M.handle(msg)
  local text = msg.text
  local chat_id = msg.chat.id
  local user_id = msg.from.id

  -- التحقق من صلاحية المالك
  if not data:is_owner(chat_id, user_id) then
    return
  end

  -- رفع مالك
  if text:match("^رفع مالك$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:promote_member(chat_id, target_id, "owner")
    utils.send_reply(msg, "↫ تم رفعه مالك ✓")
  end

  -- تنزيل مالك
  if text:match("^تنزيل مالك$") and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:demote_member(chat_id, target_id)
    utils.send_reply(msg, "↫ تم تنزيله من المالكيه ✓")
  end

  -- قائمة المالكين
  if text == "المالكين" then
    local list = data:get_members_by_role(chat_id, "owner")
    local reply = "⌔︙قائمة المالكين:\n"
    for _, user in ipairs(list) do
      reply = reply .. "• [" .. user.name .. "](tg://user?id=" .. user.id .. ")\n"
    end
    utils.send_reply_markdown(msg, reply)
  end

  -- مسح المالكين
  if text == "مسح المالكين" then
    data:clear_role(chat_id, "owner")
    utils.send_reply(msg, "↫ تم مسح كل المالكين ✓")
  end

  -- ارفعني مالك (منح نفسه صلاحية المالك)
  if text == "ارفعني مالك" then
    data:promote_member(chat_id, user_id, "owner")
    utils.send_reply(msg, "↫ تم رفعك مالك ✓")
  end

  -- تنزيل جميع الرتب
  if text == "تنزيل جميع الرتب" and msg.reply_to_message then
    local target_id = msg.reply_to_message.from.id
    data:remove_all_roles(chat_id, target_id)
    utils.send_reply(msg, "↫ تم تنزيل كل الرتب ✓")
  end

  -- مسح الرتب الوهمية (غير المشرفين)
  if text == "مسح الرتب الوهميه" then
    data:remove_fake_roles(chat_id)
    utils.send_reply(msg, "↫ تم مسح الرتب الوهمية ✓")
  end

  -- تفعيل / تعطيل المضاد
  if text == "تفعيل المضاد" then
    data:set_antiflood(chat_id, true)
    utils.send_reply(msg, "↫ تم تفعيل نظام المضاد ✓")
  elseif text == "تعطيل المضاد" then
    data:set_antiflood(chat_id, false)
    utils.send_reply(msg, "↫ تم تعطيل نظام المضاد ✓")
  end

  -- منع أمر
  if text:match("^منع امر ") then
    local cmd = text:match("^منع امر (.+)$")
    data:block_command(chat_id, cmd)
    utils.send_reply(msg, "↫ تم منع الأمر: " .. cmd)
  end

  -- الغاء منع امر
  if text:match("^الغاء منع امر ") then
    local cmd = text:match("^الغاء منع امر (.+)$")
    data:unblock_command(chat_id, cmd)
    utils.send_reply(msg, "↫ تم الغاء منع الأمر: " .. cmd)
  end

  -- عرض قائمة الاوامر الممنوعة
  if text == "قائمه الاوامر الممنوعه" then
    local cmds = data:get_blocked_commands(chat_id)
    local reply = "⌔︙الاوامر الممنوعة:\n"
    for _, cmd in ipairs(cmds) do
      reply = reply .. "• " .. cmd .. "\n"
    end
    utils.send_reply(msg, reply)
  end

  -- مسح قائمة الاوامر الممنوعة
  if text == "مسح الاوامر الممنوعه" then
    data:clear_blocked_commands(chat_id)
    utils.send_reply(msg, "↫ تم مسح قائمة الاوامر الممنوعة ✓")
  end

  -- تفعيل / تعطيل الأحداث
  if text == "تفعيل الاحداث" then
    data:set_event_logs(chat_id, true)
    utils.send_reply(msg, "↫ تم تفعيل احداث المجموعة ✓")
  elseif text == "تعطيل الاحداث" then
    data:set_event_logs(chat_id, false)
    utils.send_reply(msg, "↫ تم تعطيل احداث المجموعة ✓")
  end

end

return M