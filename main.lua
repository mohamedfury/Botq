-- main.lua
local json = require("dkjson")  -- مكتبة JSON
local https = require("ssl.https") -- طلبات https
local ltn12 = require("ltn12")

local token = "947886484:AAEh5j-gECZEN8BT45FDnPDgAQBEruA2FkE"
local api_url = "https://api.telegram.org/bot"..token.."/"

-- دالة لإرسال رسالة
local function sendMessage(chat_id, text, reply_to_message_id)
  local url = api_url.."sendMessage"
  local data = {
    chat_id = chat_id,
    text = text,
    parse_mode = "Markdown",
    reply_to_message_id = reply_to_message_id or nil
  }
  local payload = json.encode(data)
  local response_body = {}

  local res, code, response_headers = https.request{
    url = url,
    method = "POST",
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = tostring(#payload)
    },
    source = ltn12.source.string(payload),
    sink = ltn12.sink.table(response_body)
  }
  return code == 200
end

-- دالة لجلب التحديثات (الرسائل الجديدة)
local function getUpdates(offset)
  local url = api_url.."getUpdates?timeout=60"
  if offset then
    url = url .. "&offset=" .. offset
  end

  local response_body = {}
  local res, code, response_headers = https.request{
    url = url,
    sink = ltn12.sink.table(response_body)
  }

  if code == 200 then
    local body = table.concat(response_body)
    local data = json.decode(body)
    if data and data.ok then
      return data.result
    end
  end
  return nil
end

-- المتغير لتتبع آخر تحديث
local last_update_id = 0

-- دالة لمعالجة الرسائل
local function processMessage(msg)
  local chat_id = msg.chat.id
  local text = msg.text or ""

  if text:lower() == "/start" then
    sendMessage(chat_id, "هلا بيك! هذا بوت الحماية والإدارة بنظام الرتب. اكتب أمر للمساعدة.")
  elseif text:lower() == "ايدي" then
    local user_id = msg.from.id
    local first_name = msg.from.first_name or ""
    local username = msg.from.username or ""
    local reply_text = string.format(
      "↫ يا %s \nايديك ↫ `%s`\nمعرفك ↫ @%s",
      first_name,
      user_id,
      username ~= "" and username or "لا يوجد"
    )
    sendMessage(chat_id, reply_text, msg.message_id)
  else
    -- هنا تضع باقي أوامر البوت حسب ما سترسل لاحقاً
  end
end

-- حلقة استقبال التحديثات
while true do
  local updates = getUpdates(last_update_id + 1)
  if updates then
    for _, update in ipairs(updates) do
      last_update_id = update.update_id
      if update.message then
        processMessage(update.message)
      end
    end
  end
end