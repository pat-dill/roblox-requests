-- HTTP Module by Patrick Dill
-- based on Python Requests (python-requests.org)

-- API --

local Lib = script.lib
local Src = script.src

local Request = require(Src.request)
local Session = require(Src.session)
local Forms = require(Src.form)

local RateLimiter = require(Src.ratelimit)

local http = {}

http.VERSION = "0.2.1"

http.Request = Request.new
http.Session = Session.new

http.FormData = Forms.FormData.new
http.File = Forms.File.new

function http.send(method, url, opts)
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

	local req = Request.new(method, url, opts)
	return req:send()
end

-- create quick functions for each http method
for _, method in pairs({"GET", "POST", "HEAD", "OPTIONS", "PUT", "DELETE", "PATCH"}) do
	http[method:lower()] = function(url, opts)
		return http.send(method, url, opts)
	end
end

function http.set_ratelimit(requests, period)
	-- sets rate limit settings
	local rl = RateLimiter.get("http", requests, period)

	print("[http] RateLimiter settings changed: ", rl.rate, "reqs /", rl.window_size, "secs")
end

http.stats = require(Src.stats)

return http
