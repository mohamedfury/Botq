local json = require("json")
local database_file = "data/bank_data.json"

-- تحميل البيانات من ملف JSON
local function load_data()
    local file = io.open(database_file, "r")
    if not file then return {} end
    local content = file:read("*a")
    file:close()
    local data = json.decode(content)
    return data or {}
end

-- حفظ البيانات إلى ملف JSON
local function save_data(data)
    local file = io.open(database_file, "w+")
    file:write(json.encode(data))
    file:close()
end

local bank = {}
local data = load_data()

-- تأكد من وجود حساب للمستخدم
local function ensure_account(user_id)
    if not data[user_id] then
        data[user_id] = {
            balance = 0,
            loan = 0,
            points = 0,
            messages = 0,
            gifts = 0,
        }
        save_data(data)
    end
end

-- أوامر البنك الأساسية
function bank:handle(msg, bot)
    local text = msg.text
    local user_id = tostring(msg.from.id)

    ensure_account(user_id)

    if text:match("^انشاء حساب$") then
        bot:sendMessage(msg.chat.id, "تم إنشاء حسابك البنكي بنجاح!", msg.message_id)
    
    elseif text:match("^راتب$") then
        local salary = 100 -- راتب ثابت، تقدر تعدل
        data[user_id].balance = data[user_id].balance + salary
        save_data(data)
        bot:sendMessage(msg.chat.id, "تم إضافة راتب قدره " .. salary .. " إلى حسابك.\nالرصيد الحالي: " .. data[user_id].balance, msg.message_id)
    
    elseif text:match("^حسابي$") then
        local balance = data[user_id].balance
        local loan = data[user_id].loan
        local points = data[user_id].points
        local messages = data[user_id].messages
        bot:sendMessage(msg.chat.id, 
            ("رصيدك: %d\nالقرض: %d\nالنقاط: %d\nعدد الرسائل: %d"):format(balance, loan, points, messages), 
            msg.message_id)

    elseif text:match("^تحويل (.-)$") then
        local target_id = text:match("^تحويل (%d+)$")
        if not target_id then
            bot:sendMessage(msg.chat.id, "يرجى كتابة معرف صالح للتحويل.", msg.message_id)
            return
        end
        local amount = tonumber(text:match("(%d+)$"))
        if not amount or amount <= 0 then
            bot:sendMessage(msg.chat.id, "يرجى كتابة مبلغ صحيح للتحويل.", msg.message_id)
            return
        end

        ensure_account(target_id)
        if data[user_id].balance < amount then
            bot:sendMessage(msg.chat.id, "ليس لديك رصيد كافي للتحويل.", msg.message_id)
            return
        end

        data[user_id].balance = data[user_id].balance - amount
        data[target_id].balance = (data[target_id].balance or 0) + amount
        save_data(data)

        bot:sendMessage(msg.chat.id, ("تم تحويل %d إلى الحساب %s\nرصيدك الحالي: %d"):format(amount, target_id, data[user_id].balance), msg.message_id)
    
    elseif text:match("^قرض$") then
        local loan_amount = 500 -- مبلغ القرض الثابت، تقدر تعدل
        data[user_id].loan = data[user_id].loan + loan_amount
        data[user_id].balance = data[user_id].balance + loan_amount
        save_data(data)
        bot:sendMessage(msg.chat.id, ("تم منحك قرضاً بقيمة %d. يرجى تسديد القرض لاحقاً." ):format(loan_amount), msg.message_id)
    
    elseif text:match("^تسديد القرض (.-)$") then
        local repay = tonumber(text:match("^تسديد القرض (%d+)$"))
        if not repay or repay <= 0 then
            bot:sendMessage(msg.chat.id, "يرجى كتابة مبلغ صحيح لتسديد القرض.", msg.message_id)
            return
        end
        if data[user_id].balance < repay then
            bot:sendMessage(msg.chat.id, "ليس لديك رصيد كافي لتسديد القرض.", msg.message_id)
            return
        end
        if data[user_id].loan < repay then
            repay = data[user_id].loan
        end

        data[user_id].balance = data[user_id].balance - repay
        data[user_id].loan = data[user_id].loan - repay
        save_data(data)

        bot:sendMessage(msg.chat.id, ("تم تسديد %d من قرضك.\nالقرض المتبقي: %d\nالرصيد الحالي: %d"):format(repay, data[user_id].loan, data[user_id].balance), msg.message_id)
    else
        -- اوامر اخرى ممكن تضيفها لاحقاً
    end
end

return bank