--[[ 
    Simplified Message Translator
--]]

local DefaultLanguage = "en"

local googlev = isfile("googlev.txt") and readfile("googlev.txt") or ""

local Translator = {}

local function googleConsent(Body)
    local args = {}
    for match in Body:gmatch('<input type="hidden" name=".-" value=".-">') do
        local k,v = match:match('<input type="hidden" name="(.-)" value="(.-)">')
        args[k] = v
    end
    googlev = args.v
    writefile("googlev.txt", googlev)
end

local function got(url, Method, Body)
    Method = Method or "GET"
    local res = request({
        Url = url,
        Method = Method,
        Headers = {cookie = "CONSENT=YES+"..googlev},
        Body = Body
    })
    if res.Body:match("https://consent.google.com/s") then
        googleConsent(res.Body)
        res = request({
            Url = url,
            Method = "GET",
            Headers = {cookie = "CONSENT=YES+"..googlev}
        })
    end
    return res
end

local languages = {
	auto = "Automatic",
	af = "Afrikaans",
	sq = "Albanian",
	am = "Amharic",
	ar = "Arabic",
	hy = "Armenian",
	az = "Azerbaijani",
	eu = "Basque",
	be = "Belarusian",
	bn = "Bengali",
	bs = "Bosnian",
	bg = "Bulgarian",
	ca = "Catalan",
	ceb = "Cebuano",
	ny = "Chichewa",
	['zh-cn'] = "Chinese Simplified",
	['zh-tw'] = "Chinese Traditional",
	co = "Corsican",
	hr = "Croatian",
	cs = "Czech",
	da = "Danish",
	nl = "Dutch",
	en = "English",
	eo = "Esperanto",
	et = "Estonian",
	tl = "Filipino",
	fi = "Finnish",
	fr = "French",
	fy = "Frisian",
	gl = "Galician",
	ka = "Georgian",
	de = "German",
	el = "Greek",
	gu = "Gujarati",
	ht = "Haitian Creole",
	ha = "Hausa",
	haw = "Hawaiian",
	iw = "Hebrew",
	hi = "Hindi",
	hmn = "Hmong",
	hu = "Hungarian",
	is = "Icelandic",
	ig = "Igbo",
	id = "Indonesian",
	ga = "Irish",
	it = "Italian",
	ja = "Japanese",
	jw = "Javanese",
	kn = "Kannada",
	kk = "Kazakh",
	km = "Khmer",
	ko = "Korean",
	ku = "Kurdish (Kurmanji)",
	ky = "Kyrgyz",
	lo = "Lao",
	la = "Latin",
	lv = "Latvian",
	lt = "Lithuanian",
	lb = "Luxembourgish",
	mk = "Macedonian",
	mg = "Malagasy",
	ms = "Malay",
	ml = "Malayalam",
	mt = "Maltese",
	mi = "Maori",
	mr = "Marathi",
	mn = "Mongolian",
	my = "Myanmar (Burmese)",
	ne = "Nepali",
	no = "Norwegian",
	ps = "Pashto",
	fa = "Persian",
	pl = "Polish",
	pt = "Portuguese",
	pa = "Punjabi",
	ro = "Romanian",
	ru = "Russian",
	sm = "Samoan",
	gd = "Scots Gaelic",
	sr = "Serbian",
	st = "Sesotho",
	sn = "Shona",
	sd = "Sindhi",
	si = "Sinhala",
	sk = "Slovak",
	sl = "Slovenian",
	so = "Somali",
	es = "Spanish",
	su = "Sundanese",
	sw = "Swahili",
	sv = "Swedish",
	tg = "Tajik",
	ta = "Tamil",
	te = "Telugu",
	th = "Thai",
	tr = "Turkish",
	uk = "Ukrainian",
	ur = "Urdu",
	uz = "Uzbek",
	vi = "Vietnamese",
	cy = "Welsh",
	xh = "Xhosa",
	yi = "Yiddish",
	yo = "Yoruba",
	zu = "Zulu"
};

local function find(lang)
    for code, name in pairs(languages) do
        if lang:lower() == code:lower() or lang:lower() == name:lower() then
            return code
        end
    end
end

local function getISOCode(lang)
    return find(lang or "auto") or "auto"
end

local function stringifyQuery(dataFields)
    local str = ""
    for k, v in pairs(dataFields) do
        if type(v) == "table" then
            for _, val in pairs(v) do
                str = str .. ("&%s=%s"):format(
                    game.HttpService:UrlEncode(k),
                    game.HttpService:UrlEncode(val)
                )
            end
        else
            str = str .. ("&%s=%s"):format(
                game.HttpService:UrlEncode(k),
                game.HttpService:UrlEncode(v)
            )
        end
    end
    return str:sub(2)
end

local reqid = math.random(1000, 9999)
local rpcidsTranslate = "MkEWBc"
local rootURL = "https://translate.google.com/"
local executeURL = "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute"

local fsid, bl
if isfile("fsid.txt") and isfile("bl.txt") then
    fsid = readfile("fsid.txt")
    bl = readfile("bl.txt")
else
    local init = got(rootURL)
    fsid = init.Body:match('"FdrFJe":"(.-)"')
    bl = init.Body:match('"cfb2h":"(.-)"')
    writefile("fsid.txt", fsid)
    writefile("bl.txt", bl)
end

local HttpService = game:GetService("HttpService")
local function jsonE(o) return HttpService:JSONEncode(o) end
local function jsonD(o) return HttpService:JSONDecode(o) end

function Translator.translate(text, toLang, fromLang)
    reqid += 10000
    fromLang = getISOCode(fromLang)
    toLang = getISOCode(toLang or DefaultLanguage)

    local data = {{text, fromLang, toLang, true}, {nil}}
    local payload = {{{rpcidsTranslate, jsonE(data), nil, "generic"}}}
    local url = executeURL .. "?" .. stringifyQuery({
        rpcids = rpcidsTranslate,
        ["f.sid"] = fsid,
        bl = bl,
        hl = "en",
        _reqid = reqid - 10000,
        rt = "c"
    })
    local body = stringifyQuery({["f.req"] = jsonE(payload)})
    local res = got(url, "POST", body)
    local parsed = jsonD(res.Body:match("%[.-%]\n"))
    local resultData = jsonD(parsed[1][3])

    local result = {
        text = resultData[2][1][1][6][1][1],
        from = {
            language = resultData[3],
            text = resultData[2][5][1]
        },
        raw = resultData
    }

    return result
end

return Translator
