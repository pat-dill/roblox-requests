-- form data module --
----------------------

local Main = script.Parent.Parent
local Lib = Main.lib
local Src = Main.src
---------------------------------

local httpservice = game:GetService("HttpService")

local b64 = require(Lib.b64)

--

local function randomString(l)
	local s = ""

	for i=1, l do
		s = s .. string.char(math.random(97, 122))
	end

	return s
end


-- FormData object

local FormData = {}
FormData.__index = FormData
function FormData.new(...)
	local self = setmetatable({}, FormData)
	self.__FormData = true

	local args = {...}

	self.boundary = "--FormBoundary-" .. randomString(28)

	self.fields = {}

	self.content_type = "application/x-www-form-urlencoded"

	for _, v in ipairs(args) do
		-- if 2 values: (name, value)
		-- if 3 values: (name, filename, value)

		if #v == 2 then
			self:AddField(v[1], v[2])
		else
			self:AddFile(v[1], v[3], v[2])
		end
	end


	return self
end

function FormData:AddField(name, value)
	table.insert(self.fields, {
		Name = name,
		Value = value,
		File = false
	})
end

function FormData:AddFile(name, value, filename, filetype)
	table.insert(self.fields, {
		Name = name,
		Value = value,
		FileName = filename or "unknown",
		ContentType = filetype or "text/plain",
		File = true
	})

	self.content_type = 'multipart/form-data; boundary="' .. self.boundary .. '"'
end

function FormData:build()
	-- return request payload data for these form values
	
	local content = ""

	if self.content_type == "application/x-www-form-urlencoded" then
		for _, field in ipairs(self.fields) do
			if field.File then
				error("[http] URL encoded forms cannot contain any files")
			end

			if field.Name:find("=") or field.Name:find("&") then
				error("[http] Form field names must not contain '=' or '&'")
			end

			-- handle lists
			if type(field.Value) == "table" then
				for _, val in ipairs(field.Value) do
					if #content > 0 then
						content = content .. "&"
					end

					content = content .. field.Name .. "=" .. httpservice:UrlEncode(val)
				end
			else
				if #content > 0 then
					content = content .. "&"
				end

				content = content .. field.Name .. "=" .. httpservice:UrlEncode(field.Value)
			end
		end
	else
		for _, field in pairs(self.fields) do
			content = content .. "--"..self.boundary.."\r\n"

			content = content .. ('Content-Disposition: form-data; name="%s"'):format(field.Name)
			if field.FileName then
				content = content .. ('; filename="%s"'):format(field.FileName)
				content = content .. "\r\nContent-Type: " .. field.ContentType
			end

			if field.ContentType:sub(1, 4) ~= "text" then
				field.Value = b64.encode(field.Value)
				content = content .. "\r\nContent-Transfer-Encoding: base64"
			end

			content = content .. "\r\n\r\n\r\n" .. field.Value .. "\r\n"
		end
		content = content .. "--"..self.boundary.."--"
	end

	return content
end

---------------
return FormData