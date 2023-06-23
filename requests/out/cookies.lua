-- Compiled with roblox-ts v2.1.0
local TS = require(script.Parent.include.RuntimeLib)
local _utils = TS.import(script, script.Parent, "utils")
local endsWith = _utils.endsWith
local startsWith = _utils.startsWith
local _urlencode = TS.import(script, script.Parent, "urlencode")
local urlDecode = _urlencode.urlDecode
local urlEncode = _urlencode.urlEncode
local Cookie
do
	Cookie = setmetatable({}, {
		__tostring = function()
			return "Cookie"
		end,
	})
	Cookie.__index = Cookie
	function Cookie.new(...)
		local self = setmetatable({}, Cookie)
		return self:constructor(...) or self
	end
	function Cookie:constructor(name, value, domain, path)
		self.name = name
		self.value = value
		self.domain = domain
	end
	function Cookie:shouldSend(config)
		local _condition = self.domain
		if not (_condition ~= "" and _condition) then
			_condition = self.path
		end
		if not (_condition ~= "" and _condition) then
			return true
		end
		local _value = config.url
		if not (_value ~= "" and _value) then
			return false
		end
		local urlSplit = string.split(config.url, "://")
		local segments = string.split(urlSplit[#urlSplit - 1 + 1], "/")
		local host = segments[1]
		table.remove(segments, 1)
		local path = "/" .. table.concat(segments, "/")
		path = string.split(string.split(path, "?")[1], "#")[1]
		local _value_1 = self.domain
		if _value_1 ~= "" and _value_1 then
			local matchDomain = self.domain
			if string.sub(matchDomain, 1, 1) == "." then
				matchDomain = string.sub(matchDomain, 2)
			end
			if not endsWith(host, matchDomain) then
				return false
			end
		end
		local _value_2 = self.path
		if _value_2 ~= "" and _value_2 then
			if not startsWith(path, self.path) then
				return false
			end
		end
		return true
	end
	function Cookie:toString()
		return urlEncode(self.value, false)
	end
	function Cookie:parse(setCookie)
		local attrs = string.split(setCookie, "; ")
		local cookieName = string.split(attrs[1], "=")[1]
		if startsWith(cookieName, '"') then
			-- noinspection TypeScriptValidateJSTypes
			local _cookieName = cookieName
			local _arg1 = #cookieName - 1
			cookieName = string.sub(_cookieName, 2, _arg1)
		end
		cookieName = urlDecode(cookieName)
		local cookieVal = string.split(attrs[1], "=")[2]
		if startsWith(cookieVal, '"') then
			-- noinspection TypeScriptValidateJSTypes
			local _cookieVal = cookieVal
			local _arg1 = #cookieVal - 1
			cookieVal = string.sub(_cookieVal, 2, _arg1)
		end
		cookieVal = urlDecode(cookieVal)
		local cookie = Cookie.new(cookieName, cookieVal)
		table.remove(attrs, 1)
		return cookie
	end
	function Cookie:__tostring()
		return self:toString()
	end
end
local parseSetCookie = function(setCookie)
	local _setCookie = setCookie
	if type(_setCookie) == "string" then
		local cookie = Cookie:parse(setCookie)
		return {
			[cookie.name] = cookie,
		}
	else
		local cookies = {}
		for _, cookieStr in ipairs(setCookie) do
			local cookie = Cookie:parse(cookieStr)
			cookies[cookie.name] = cookie
		end
		return cookies
	end
end
return {
	Cookie = Cookie,
	parseSetCookie = parseSetCookie,
}
