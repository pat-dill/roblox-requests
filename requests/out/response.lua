-- Compiled with roblox-ts v2.0.4
local TS = require(script.Parent.include.RuntimeLib)
local endsWith = TS.import(script, script.Parent, "utils").endsWith
local createHeaders = TS.import(script, script.Parent, "headers").default
local parseSetCookie = TS.import(script, script.Parent, "cookies").parseSetCookie
local HttpService = game:GetService("HttpService")
local Response
do
	Response = setmetatable({}, {
		__tostring = function()
			return "Response"
		end,
	})
	Response.__index = Response
	function Response.new(...)
		local self = setmetatable({}, Response)
		return self:constructor(...) or self
	end
	function Response:constructor(request, rawResponse, time, session)
		self.isResponse = true
		self._session = session
		self.request = request
		self.url = request.url
		self.method = request.method
		self.code = rawResponse.StatusCode
		self.message = rawResponse.StatusMessage
		self.ok = self.code >= 200 and self.code < 300
		self.time = time
		self.headers = createHeaders(rawResponse.Headers)
		local _condition = self.headers["content-type"]
		if _condition == nil then
			_condition = ""
		end
		self.contentType = _condition
		self.content = rawResponse.Body
		local _value = self.headers["set-cookie"]
		if _value ~= "" and _value then
			self.cookies = parseSetCookie(self.headers["set-cookie"])
		else
			self.cookies = {}
		end
		local _exp = self._session.config
		if _exp.cookies == nil then
			_exp.cookies = {}
		end
		for name, cookie in pairs(self.cookies) do
			self._session.config.cookies[name] = cookie
		end
	end
	function Response:json(ignoreWarning)
		if ignoreWarning == nil then
			ignoreWarning = not (self.request.contentTypeWarning)
		end
		if not ignoreWarning and not endsWith(self.contentType, "/json") then
			warn("You are calling json() on a response whose content type doesn't specify JSON." .. " You can disable this warning by setting http.config.contentTypeWarning = false")
		end
		return HttpService:JSONDecode(self.content)
	end
end
return {
	Response = Response,
}
