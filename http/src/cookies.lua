-- cookie jar class --
----------------------

local Main = script.Parent.Parent
local Lib = Main.lib
local Src = Main.src
---------------------------------

local json = require(Src.json)
local Url = require(Lib.url)

local function get_domain(url)
	local host = Url.parse(url).host

	return host or url
end

local function maybe_number(str)
	-- convert value to number if possible

	local num = tonumber(str)

	return num or str
end

local function trim(s)
	while s:sub(1, 1) == " " do
		s = s:sub(2)
	end

	while s:sub(-1, -1) == " " do
		s = s:sub(1, -2)
	end

	return s
end

local function parse(cookie_string, sep)
	-- parse cookie string and return table

	sep = sep or ","

	local ck = {}

	-- ignore expiration data, etc
	cookie_string = cookie_string:split(";")[1]

	for _, s in ipairs(cookie_string:split(sep)) do
		local nv = s:split("=")
		if #nv < 2 then
			error("[http] Error parsing cookies: " .. s)
		end

		local name = trim(nv[1])

		-- concat rest of cookie (may have extra equal signs that get split)
		table.remove(nv, 1)
		local value = trim(table.concat(nv, "="))

		ck[name] = maybe_number(value)
	end

	return ck
end

-- CookieJar object

local CookieJar = {}
CookieJar.__index = CookieJar
function CookieJar.new()
	local self = setmetatable({}, CookieJar)

	self.__cookiejar = true  -- used to differentiate from dictionaries

	self.domains = {}

	return self
end

function CookieJar:set(url, c_or_n, v)
	-- set new cookies in cookie jar

	local domain = get_domain(url)

	if not self.domains[domain] then
		self.domains[domain] = {}
	end

	if v then 
		-- single cookie passed
		self.domains[domain][c_or_n] = v

	else 
		-- table passed
		local cookies = c_or_n

		if cookies.__cookiejar then
			-- if cookiejar passed, only get relevant cookies
			cookies = cookies.domains[domain]
		end

		if type(cookies) == "string" then
			cookies = parse(cookies)
		end

		for k, v in pairs(cookies) do
			self.domains[domain][k] = v
		end
	end

	return self
end

function CookieJar:delete(domain, name)
	self.cookies[domain][name] = nil
end

function CookieJar:string(url)
	-- convert to header string
	local domain = get_domain(url)

	if not self.domains[domain] then  -- no cookies for this domain
		return ""
	end

	local str = ""

	for k, v in pairs(self.domains[domain]) do
		if v ~= nil then
			str = str .. k .. "=" .. v .. ";"
		end
	end

	return str:sub(1, -2)
end

function CookieJar:__tostring()
	return json.enc(self.domains)
end


return CookieJar
