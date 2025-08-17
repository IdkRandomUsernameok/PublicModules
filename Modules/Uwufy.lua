local utils = {}

function utils.split(str, delim)
	local out = {}
	if not delim or delim == " " then
		for w in str:gmatch("%S+") do out[#out+1] = w end
	else
		local esc = delim:gsub("(%W)","%%%1")
		local pat = "[^" .. esc .. "]+"
		for w in str:gmatch(pat) do out[#out+1] = w end
	end
	return out
end

function utils.isUri(word)
	return word:match("^https?://") and true or false
end

local Simple = {
	FACES = { "owo", "uwu", ">w<", ":3", "x3" },
	EXCLAMATIONS = { "!?", "?!!", "?!?1", "!!11", "?!?!" },
	STUTTER_CHANCE = 0.35,
	FACE_CHANCE = 0.45,
	EXCLAMATION_CHANCE = 0.9
}

function Simple.uwufy(text)
	if type(text) ~= "string" then return text end
	text = text:gsub("[rl]", "w"):gsub("[RL]", "W")
	text = text:gsub("ove", "uv"):gsub("OVE", "UV")
	local words = utils.split(text, " ")
	for i, w in ipairs(words) do
		if not utils.isUri(w) then
			if math.random() < Simple.STUTTER_CHANCE then
				local first = w:sub(1,1)
				local reps = math.random(1,2)
				w = (first .. "-"):rep(reps) .. w
			end
			if math.random() < Simple.FACE_CHANCE then
				w = w .. " " .. Simple.FACES[math.random(#Simple.FACES)]
			end
			if w:find("[%!%?]$") and math.random() < Simple.EXCLAMATION_CHANCE then
				w = w:gsub("[%!%?]+$", "") .. Simple.EXCLAMATIONS[math.random(#Simple.EXCLAMATIONS)]
			end
		end
		words[i] = w
	end
	return table.concat(words, " ")
end

local Advanced = {}
Advanced.__index = Advanced

local ADV_DEFAULTS = {
	spaces = { faces = 0.05, actions = 0.075, stutters = 0.1 },
	words = 1,
	exclamations = 1
}

function Advanced:new(cfg)
	local cfg = cfg or {}
	local inst = setmetatable({}, self)
	inst._spaces = cfg.spaces or ADV_DEFAULTS.spaces
	inst._words = cfg.words or ADV_DEFAULTS.words
	inst._exclamations = cfg.exclamations or ADV_DEFAULTS.exclamations
	inst.faces = { "(・ω´・)", ";;w;;", "OwO", "UwU", ">w<", "^w^", "ÚwÚ", "^-^", ":3", "x3" }
	inst.exclamations = { "!?", "?!!", "?!?1", "!!11", "?!?!" }
	inst.actions = { "*blushes*", "*whispers to self*", "*sweats*", "*looks at you*", "*huggles tightly*" }
	inst.map = {
		{ "([rl])", "w" }, { "([RL])", "W" },
		{ "n([aeiou])", "ny%1" }, { "N([aeiou])", "Ny%1" }, { "N([AEIOU])", "Ny%1" },
		{ "ove", "uv" }
	}
	return inst
end

function Advanced:_uwuifyWords(text)
	local out = {}
	for w in text:gmatch("%S+") do
		if math.random() <= self._words then
			for _, m in ipairs(self.map) do
				w = w:gsub(m[1], m[2])
			end
		end
		out[#out+1] = w
	end
	return table.concat(out, " ")
end

function Advanced:_uwuifyExclamations(text)
	local out = {}
	for _, w in ipairs(utils.split(text, " ")) do
		if w:find("[%?!]+$") and math.random() <= self._exclamations then
			w = w:gsub("[%?!]+$", "") .. self.exclamations[math.random(#self.exclamations)]
		end
		out[#out+1] = w
	end
	return table.concat(out, " ")
end

function Advanced:_uwuifySpaces(text)
	local words = utils.split(text, " ")
	local fT = self._spaces.faces
	local aT = fT + self._spaces.actions
	local sT = aT + self._spaces.stutters
	for i, w in ipairs(words) do
		local r = math.random()
		if r <= fT and not utils.isUri(w) then
			w = w .. " " .. self.faces[math.random(#self.faces)]
		elseif r <= aT and not utils.isUri(w) then
			w = w .. " " .. self.actions[math.random(#self.actions)]
		elseif r <= sT and not utils.isUri(w) then
			local first = w:sub(1,1)
			local st = math.random(0,2)
			w = (first .. "-"):rep(st) .. w
		end
		words[i] = w
	end
	return table.concat(words, " ")
end

function Advanced:uwuify(sentence)
	if type(sentence) ~= "string" then return sentence end
	local s = sentence
	s = self:_uwuifyWords(s)
	s = self:_uwuifyExclamations(s)
	s = self:_uwuifySpaces(s)
	return s
end

math.randomseed(os.time())

return {
	Simple = Simple,
	Advanced = Advanced
}
