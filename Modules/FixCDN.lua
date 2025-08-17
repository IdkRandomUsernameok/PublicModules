local HttpService = game:GetService("HttpService")

local function isExpired(exParam)
	local success, result = pcall(function()
		local exTime = tonumber(exParam, 16)
		return exTime and (exTime * 1000) <= tick() * 1000
	end)
	return not success or not result
end

local function shouldFix(url, responseBody, statusCode)
	if statusCode == 404 then
		return true
	end

	if typeof(responseBody) == "string" then
		if responseBody:match("^%s*This content is no longer available%.%s*$") then
			return true
		end
	end

	return false
end

local function fixcdn(originalUrl)
	local parsedUrl
	pcall(function()
		parsedUrl = HttpService:UrlEncode(originalUrl)
	end)

	local exParam = originalUrl:match("[&?]ex=([^&]+)")
	if exParam and isExpired(exParam) then
		return "https://fixcdn.hyonsu.com" .. originalUrl:match("^https?://[^/]+(.*)$")
	end

	local success, response = pcall(function()
		return game:HttpGet(originalUrl)
	end)

	local statusCode = 200
	if not success or response == nil then
		statusCode = 404
	end

	if shouldFix(originalUrl, response, statusCode) then
		return "https://fixcdn.hyonsu.com" .. originalUrl:match("^https?://[^/]+(.*)$")
	end

	return originalUrl
end

return fixcdn
