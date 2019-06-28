local Main = script.Parent.Parent
local Lib = Main.lib
local Src = Main.src
---------------------------------

local json = require(Src.json)

local CookieJar = require(Src.cookies)
local CaseInsensitive = require(Lib.nocasetable)

-- Response Object

local Response = {}
Response.__index = Response
function Response.new(req, resp)
	-- creates response object from original request and roblox http response

	local self = setmetatable({}, Response)

	self.request = req  -- original request object

	-- request meta data
	self.url = req.url
	self.method = req.method

	-- response data
	self.success = resp.Success
	self.code = resp.StatusCode
	self.message = resp.StatusMessage
	self.headers = CaseInsensitive(resp.Headers)
	self.content = resp.Body

	-- additional metadata for quick access
	self.content_type = self.headers["content-type"]
	self.content_length = self.headers["content-length"] or #self.content

	-- cookies
	self.cookies = CookieJar.new()
	self.cookies:set(self.url, self.headers["set-cookie"] or {})

	return self
end

function Response:__tostring()
	return self.content
end

function Response:json()
	-- convert json respose content to table

	local succ, data = pcall(function()
		return json.dec(self.content)
	end)

	if not succ then
		error("[http] Failed to convert response content to JSON:\n", self.content)
	end

	return data
end

---------------

return Response