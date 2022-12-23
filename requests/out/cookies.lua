-- Compiled with roblox-ts v2.0.4
local TS = require(script.Parent.include.RuntimeLib)
local _utils = TS.import(script, script.Parent, "utils")
local endsWith = _utils.endsWith
local startsWith = _utils.startsWith
local urlEncode = TS.import(script, script.Parent, "urlencode").urlEncode
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
		local urlSplit = string.split(config.url, "://")
		local segments = string.split(urlSplit[#urlSplit - 1 + 1], "/")
		local host = segments[1]
		table.remove(segments, 1)
		local path = "/" .. table.concat(segments, "/")
		path = string.split(string.split(path, "?")[1], "#")[1]
		local _value = self.domain
		if _value ~= "" and _value then
			local matchDomain = self.domain
			if string.sub(matchDomain, 1, 1) == "." then
				matchDomain = string.sub(matchDomain, 2)
			end
			if not endsWith(host, matchDomain) then
				return false
			end
		end
		local _value_1 = self.path
		if _value_1 ~= "" and _value_1 then
			if not startsWith(path, self.path) then
				return false
			end
		end
		return true
	end
	function Cookie:toString()
		return urlEncode(self.name) .. ("=" .. urlEncode(self.value))
	end
	function Cookie:__tostring()
		return self:toString()
	end
end
return {
	Cookie = Cookie,
}
