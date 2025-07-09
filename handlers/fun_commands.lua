-- handlers/fun_commands.lua

local json = require("json")
local http = require("socket.http")
local ltn12 = require("ltn12")

local fun_commands = {}

-- دالة مساعدة لاختيار رقم عشوائي ضمن مدى معين
local function random_range(min, max)
    math.randomseed(os.time())
    return math.random(min, max)
end

-- إرسال ملف صوتي بناء على الرقم (مثلاً من الملفات المحلية أو من قناة @trrgg)
local function send_audio(chat_id, audio_number, bot)
    -- هنا نفترض عندك مسار الملفات الصوتية محلياً ./audios/{audio_number}.ogg
    local file_path = "./audios/" .. audio_number .. ".ogg"

    -- إذا تريد ترسل من رابط قناتك @trrgg على تيليجرام (هذا مثال عام)
    -- local url = "https://t.me/trrgg/" .. audio_number

    -- إرسال الملف الصوتي كـ Voice أو Audio حسب نوع الملف
    bot:sendAudio(chat_id, file_path)
end

-- أمر اغاني 1-100
function fun_commands:send_random_song(msg, bot)
    local chat_id = msg.chat.id
    local audio_number = random_range(1, 100)
    send_audio(chat_id, audio_number, bot)
end

-- أمر شعر 101-200
function fun_commands:send_random_poem(msg, bot)
    local chat_id = msg.chat.id
    local audio_number = random_range(101, 200)
    send_audio(chat_id, audio_number, bot)
end

-- أمر قصائد حسينية 201-300
function fun_commands:send_random_husseini_poem(msg, bot)
    local chat_id = msg.chat.id
    local audio_number = random_range(201, 300)
    send_audio(chat_id, audio_number, bot)
end

-- دوال إضافية للتسلية (ميمز، أنمي، اقتباس، اذكار)
function fun_commands:send_azkar(msg, bot)
    local azkar_list = {
        "اللهم صل على محمد وآل محمد",
        "سبحان الله وبحمده سبحان الله العظيم",
        -- أضف أذكار أكثر هنا
    }
    local index = random_range(1, #azkar_list)
    bot:sendMessage(msg.chat.id, azkar_list[index])
end

function fun_commands:send_quote(msg, bot)
    local quotes = {
        "لا تيأس من رحمة الله.",
        "العقل زينة الإنسان.",
        -- أضف اقتباسات أكثر هنا
    }
    local index = random_range(1, #quotes)
    bot:sendMessage(msg.chat.id, quotes[index])
end

-- ربط الأوامر بالنصوص التي يستخدمها المستخدم
function fun_commands:handle(msg, bot)
    local text = msg.text
    if not text then return end

    if text == "غنيلي" or text == "اغنيه" or text == "ريمكس" then
        self:send_random_song(msg, bot)
    elseif text == "شعر" or text == "اشعار" then
        self:send_random_poem(msg, bot)
    elseif text == "قصيده حسينيه" then
        self:send_random_husseini_poem(msg, bot)
    elseif text == "اذكار" then
        self:send_azkar(msg, bot)
    elseif text == "اقتباس" then
        self:send_quote(msg, bot)
    end
end

return fun_commands