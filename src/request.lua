local Main = script.Parent.Parent
local Lib = Main.lib
local Src = Main.src
---------------------------------

local httpservice = game:GetService("HttpService")
local Url = require(Lib.url)

local json = require(Src.json)

local Response = require(Src.response)
local CookieJar = require(Src.cookies)

-- Request object

local Request = {}
Request.__index = Request
function Request.new(method, url, opts)
	-- quick method to send http requests
	--  method: (str) HTTP Method
	--     url: (str) Fully qualified URL
	-- options (dictionary):
		-- headers: (dictionary) Headers to send with request
		--   query: (dictionary) Query string parameters
		--    data: (str OR dictionary) Data to send in POST or PATCH request
		--     log: (bool) Whether to log the request
		-- cookies: (CookieJar OR dict) Cookies to use in request

	local self = setmetatable({}, Request)

	local u = Url.parse(url)
	local headers = opts.headers or {}

	self.method = method
	self.url = u
	self.headers = headers
	self.query = {}
	self.data = nil

	if opts.data then
		self:set_data(opts.data)
	end

	self:update_query(opts.query or {})

	-- handle cookies

	local cj = opts.cookies or {}
	if not cj.__cookiejar then  -- check if CookieJar was passed. if not, convert to CookieJar
		local jar = CookieJar.new()

		if cj then
			jar:set(self.url, cj)
		end

		cj = jar
	end

	self.cookies = cj
	self.headers["Cookie"] = cj:string(url)

	self._callback = nil


	self._log = opts.log or true

	return self
end


function Request:update_headers(headers)
	-- headers: (dictionary) additional headers to set

	for k, v in pairs(headers) do
		self.headers[k] = v
	end

	return self
end


function Request:update_query(params)
	-- params: (dictionary) additional query string parameters to set

	for k, v in pairs(params) do
		self.query[k] = v
	end

	self.url:setQuery(self.query)  -- update url

	return self
end


function Request:set_data(data)
	-- sets request data (string or table)

	if type(data) == "table" then
		if data.__FormData then
			self.headers["Content-Type"] = data.content_type
			data = data:build()
		else
			data = json.enc(data)
			self.headers["Content-Type"] = "application/json"
		end
	end

	self.data = data
end


function Request:_send()
	-- prepare request options
	local options = {
		["Url"] = self.url:build(),
		Method = self.method,
		Headers = self.headers
	}

	if self.data ~= nil then
		options.Body = self.data
	end

	local resp = httpservice:RequestAsync(options)
	resp = Response.new(self, resp)

	if self._log then
		print("[http]", resp.code, resp.message, "|", resp.method, resp.url)
	end

	if self._callback then
		self._callback(resp)
	end

	return resp
end


function Request:send(cb)
	-- send request via HTTPService and return Response object

	-- if a callback function is specified, the request will be executed asynchronously and
	-- pass the return value to the callback. Otherwise, it is run blocking

	if cb then
		-- run in new coroutine
		coroutine.wrap(function()
			cb(self:_send())
		end)()
	else
		return self:_send()
	end
end

return Request