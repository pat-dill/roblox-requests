local Main = script.Parent.Parent
local Lib = Main.lib
local Src = Main.src
---------------------------------------------------

local httpservice = game:GetService("HttpService")

local Url = require(Lib.url)
local Promise = require(Lib.promise)

local json = require(Src.json)
local Response = require(Src.response)
local CookieJar = require(Src.cookies)
local RateLimiter = require(Src.ratelimit)

---------------------------------------------------


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
		-- ignore_ratelimit: (bool) If true, rate limiting is ignored. Not recommended unless you are rate limiting yourself.

	local self = setmetatable({}, Request)

	opts = opts or {}

	local u = Url.parse(url)
	local headers = opts.headers or {}

	self.method = method
	self.url = u
	self.input_url = url
	self.headers = headers
	self.query = {}
	self.data = nil

	self.no_stats = opts.no_stats or false

	self._ratelimits = {RateLimiter.get("http", 250, 30)}

	self.ignore_ratelimit = opts.ignore_ratelimit or false

	if opts.data then
		self:set_data(opts.data)
	end

	self:update_query(opts.query or {})

	-- handle cookies

	local cj = opts.cookies or {}
	if not cj.__cookiejar then  -- check if CookieJar was passed. if not, convert to CookieJar
		local jar = CookieJar.new()

		if cj then
			for k, v in pairs(cj) do
				jar:insert(k, v)
			end
		end

		cj = jar
	end

	self.cookies = cj
	self.headers["Cookie"] = cj:string(url)

	self._callback = nil


	self._log = (opts.log == nil and true) or opts.log

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

function Request:_ratelimit()
	-- checks all ratelimiters assigned to request

	for _, rl in ipairs(self._ratelimits) do
		if not rl:request() then
			return false
		end
	end

	return true
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

	local attempts = 0
	local succ, resp = false, nil

	while attempts < 5 do
		-- check if request will exceed rate limit
		if self.ignore_ratelimit or self:_ratelimit() then
			local st = tick()
			resp = Response.new(self, httpservice:RequestAsync(options), tick()-st)
			self.timestamp = st
			succ = true
			break
		end

		warn("[http] Rate limit exceeded. Retrying in 5 seconds")

		attempts = attempts + 1
		wait(5)
	end

	if not succ then
		error("[http] Rate limit still exceeded after 5 attempts")
	end

	if self._log then
		local rl = tostring(math.floor(self._ratelimits[#self._ratelimits]:consumption()*1000)*0.1) .. "%"

		print("[http]", resp.code, resp.message, "|", resp.method, resp.url, "(", rl, "ratelimit )")
	end

	if self._callback then
		self._callback(resp)
	end

	-- don't block to report stats
	if not self.no_stats then
		coroutine.wrap(function()
			local Stats = require(Src.stats)
			Stats:report(self, resp)
		end)()
	end

	return resp
end


function Request:send(promise)
	-- send request via HTTPService and return Response object

	-- if promise is true, returns promise

	if promise then
		return Promise.new(function(resolve, reject)
			local ok, result = pcall(self._send, self)

			local succ = ok and result.ok
	
			if succ then
				resolve(result)
			else
				if ok then
					reject({request_sent=true, response=result})
				else
					reject({request_sent=false, error=result})
				end
			end
		end)
	else
		return self:_send()
	end
end

function Request:promise()
	return self:send(true)
end

return Request