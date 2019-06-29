-- Sessions

local Main = script.Parent.Parent
local Lib = Main.lib
local Src = Main.src
---------------------------------

local Request = require(Src.request)
local CookieJar = require(Src.cookies)

-- Session class
local Session = {}
Session.__index = Session
function Session.new(base_url)
	-- Creates new Session object

	local self = setmetatable({}, Session)

	self.headers = {}
	self.cookies = CookieJar.new()

	self.base_url = base_url or ""

	self.ignore_ratelimit = false

	self.before_request = nil
	self.after_request = nil

	self.log = true

	-----------
	return self
end

function Session:set_headers(headers)
	-- headers: (dictionary) additional headers to set

	for k, v in pairs(headers) do
		self.headers[k] = v
	end

	return self
end

function Session:Request(method, url, opts)
	-- prepares request based on Session's default values, such as headers
	-- session defaults will NOT overwrite values set per-request

	opts = opts or {}

	-- add prefix if not absolute url
	if not (url:sub(1, 7) == "http://" or url:sub(1, 8) == "https://") then
		url = self.base_url .. url
	end

	-- prepare request based on session defaults
	local request = Request.new(method, url, {
		headers = self.headers,
		query = opts.query,
		data = opts.data,
		log = self.log or opts.log,
		cookies = opts.cookies or self.cookies,
		ignore_ratelimit = opts.ignore_ratelimit or self.ignore_ratelimit
	})

	request:update_headers(opts.headers or {})

	request._callback = function(resp)
		self.cookies:set(url, resp.cookies)
	end

	return request
end

function Session:send(method, url, opts)
	-- quick method to send http requests
	--  method: (str) HTTP Method
	--     url: (str) Fully qualified URL
	-- options (dictionary):
		-- headers: (dictionary) Headers to send with request
		--   query: (dictionary) Query string parameters
		--    data: (str OR dictionary) Data to send in POST or PATCH request
		--     log: (bool) Whether to log the request
		-- cookies: (CookieJar OR dict) Cookies to use in request

	opts = opts or {}

	local req = self:Request(method, url, opts)
	return req:send()
end

-- create quick functions for each http method
for _, method in pairs({"GET", "POST", "HEAD", "OPTIONS", "PUT", "DELETE", "PATCH"}) do
	Session[method:lower()] = function(self, url, opts)
		return self:send(method, url, opts)
	end
end

--------------
return Session