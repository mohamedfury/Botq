local json = require("dkjson")
local https = require("ssl.https")
local ltn12 = require("ltn12")

local token = "947886484:AAEh5j-gECZEN8BT45FDnPDgAQBEruA2FkE"
local api_url = "https://api.telegram.org/bot"..token.."/"

local last_update_id = 0

local function sendMessage(chat_id, text, reply_to_message_id, reply_markup)
  local url = api_url.."sendMessage"
  local data = {
    chat_id = chat_id,
    text = text,
    parse_mode = "Markdown",
    reply_to_message_id = reply_to_message_id or nil,
    reply_markup = reply_markup or nil
  }
  local payload = json.encode(data)
  local response_body = {}

  local res, code = https.request{
    url = url,
    method = "POST",
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = tostring(#payload)
    },
    source = ltn12.source.string(payload),
    sink = ltn12.sink.table(response_body)
  }

  if code ~= 200 then
    print("Error sending message, HTTP code:", code)
  end
  return code == 200
end

local function editMessageText(chat_id, message_id, text, reply_markup)
  local url = api_url.."editMessageText"
  local data = {
    chat_id = chat_id,
    message_id = message_id,
    text = text,
    parse_mode = "Markdown",
    reply_markup = reply_markup or nil
  }
  local payload = json.encode(data)
  local response_body = {}

  local res, code = https.request{
    url = url,
    method = "POST",
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = tostring(#payload)
    },
    source = ltn12.source.string(payload),
    sink = ltn12.sink.table(response_body)
  }

  if code ~= 200 then
    print("Error editing message, HTTP code:", code)
  end
  return code == 200
end

local function answerCallbackQuery(callback_query_id, text)
  local url = api_url.."answerCallbackQuery"
  local data = {
    callback_query_id = callback_query_id,
    text = text,
    show_alert = false
  }
  local payload = json.encode(data)
  local response_body = {}
  https.request{
    url = url,
    method = "POST",
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = tostring(#payload)
    },
    source = ltn12.source.string(payload),
    sink = ltn12.sink.table(response_body)
  }
end

local function getUpdates(offset)
  local url = api_url.."getUpdates?timeout=60"
  if offset then
    url = url .. "&offset=" .. offset
  end

  local response_body = {}
  local res, code = https.request{
    url = url,
    sink = ltn12.sink.table(response_body)
  }

  if code == 200 then
    local body = table.concat(response_body)
    local data, pos, err = json.decode(body, 1, nil)
    if data and data.ok then
      return data.result
    else
      print("Error decoding JSON:", err)
    end
  else
    print("Failed to get updates, HTTP code:", code)
  end
  return nil
end

-- تعريف أوامر كل قسم كنص
local command_details = {
  admin = "أوامر الأدمن:\n- قفل وفتح\n- طرد\n- كتم\n- تثبيت\n- المزيد...",
  manager = "أوامر المدراء:\n- رفع مميز\n- تنزيل مميز\n- إدارة المنشئين\n- المزيد...",
  fun = "أوامر التسليه:\n- غنيلي\n- شعر\n- قصيده حسينية\n- العاب\n- المزيد...",
  bank = "أوامر البنك:\n- انشاء حساب\n- راتب\n- تحويل\n- قرض\n- المزيد...",
}

local main_keyboard = {
  inline_keyboard = {
    {
      { text = "أوامر الأدمن", callback_data = "cmd_admin" },
      { text = "أوامر المدراء", callback_data = "cmd_manager" }
    },
    {
      { text = "أوامر التسليه", callback_data = "cmd_fun" },
      { text = "أوامر البنك", callback_data = "cmd_bank" }
    }
  }
}

local function processMessage(msg)
  local chat_id = msg.chat.id
  local text = msg.text or ""

  if text:lower() == "/start" then
    sendMessage(chat_id, "هلا بيك! هذا بوت الحماية والإدارة بنظام الرتب. اكتب /الاوامر لعرض الأوامر.")
  elseif text:lower() == "/الاوامر" then
    sendMessage(chat_id, "اختر نوع الأوامر التي تريد عرضها:", nil, main_keyboard)
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
    -- باقي أوامر البوت
  end
end

local function processCallbackQuery(callback_query)
  local data = callback_query.data
  local chat_id = callback_query.message.chat.id
  local message_id = callback_query.message.message_id

  if command_details[data:sub(5)] then -- يقطع 'cmd_' من data ويدور النص المناسب
    local key = data:sub(5)
    editMessageText(chat_id, message_id, command_details[key], nil)
  else
    answerCallbackQuery(callback_query.id, "خطأ: أمر غير معروف.")
  end
end

while true do
  local success, err = pcall(function()
    local updates = getUpdates(last_update_id + 1)
    if updates then
      for _, update in ipairs(updates) do
        last_update_id = update.update_id
        if update.message then
          processMessage(update.message)
        elseif update.callback_query then
          processCallbackQuery(update.callback_query)
        end
      end
    end
  end)
  
  if not success then
    print("Error in main loop:", err)
  end
  
  os.execute("sleep 1")
end