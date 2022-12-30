-- Compiled with roblox-ts v2.0.4
local TS = require(script.Parent.include.RuntimeLib)
local mimes = TS.import(script, script.Parent, "mimes").default
local base64 = TS.import(script, script.Parent, "base64")
local serializeParams = TS.import(script, script.Parent, "params").default
local startsWith = TS.import(script, script.Parent, "utils").startsWith
-- function randomString(l)
-- local s = ""
-- 
-- for _=1, l do
-- s = s .. string.char(math.random(97, 122))
-- end
-- 
-- return s
-- end
local randomString = function(length)
	local s = ""
	do
		local i = 1
		local _shouldIncrement = false
		while true do
			if _shouldIncrement then
				i += 1
			else
				_shouldIncrement = true
			end
			if not (i <= length) then
				break
			end
			s ..= string.char(math.random(97, 122))
		end
	end
	return s
end
local File
do
	File = setmetatable({}, {
		__tostring = function()
			return "File"
		end,
	})
	File.__index = File
	function File.new(...)
		local self = setmetatable({}, File)
		return self:constructor(...) or self
	end
	function File:constructor(nameOrContent, content, contentType)
		self._isFile = true
		self.name = nil
		if content ~= nil then
			self.name = nameOrContent
			self.content = content
		else
			local _condition = nameOrContent
			if not (_condition ~= "" and _condition) then
				_condition = ""
			end
			self.content = _condition
		end
		-- if no contentType specified, try to guess from file extension
		if contentType ~= nil then
			local _condition = contentType
			if not (_condition ~= "" and _condition) then
				_condition = "text/plain"
			end
			self.contentType = _condition
		else
			local _result = self.name
			if _result ~= nil then
				_result = (string.find(_result, "%."))
			end
			if _result ~= 0 and (_result == _result and _result) then
				local segments = string.split(self.name, ".")
				local extension = segments[#segments - 1 + 1]
				local _condition = mimes[extension]
				if not (_condition ~= "" and _condition) then
					_condition = "text/plain"
				end
				self.contentType = _condition
			else
				self.contentType = "text/plain"
			end
		end
	end
	function File:encode()
		return base64.encode(self.content)
	end
end
local Form
do
	Form = setmetatable({}, {
		__tostring = function()
			return "Form"
		end,
	})
	Form.__index = Form
	function Form.new(...)
		local self = setmetatable({}, Form)
		return self:constructor(...) or self
	end
	function Form:constructor(fields)
		self._isForm = true
		self.fields = fields or {}
	end
	function Form:set(fieldsOrName, value)
		if value ~= 0 and (value == value and (value ~= "" and value)) then
			local _fieldsOrName = fieldsOrName
			if not (type(_fieldsOrName) == "string") then
				error("Field name must be string")
			end
			self.fields[fieldsOrName] = value
		else
			local _fieldsOrName = fieldsOrName
			if not (type(_fieldsOrName) == "table") then
				error("Invalid arguments. Fields must be in a table")
			end
			for k, v in pairs(fieldsOrName) do
				self.fields[k] = v
			end
		end
	end
	function Form:hasFile()
		for k, v in pairs(self.fields) do
			if type(v) == "table" and v._isFile then
				return true
			end
		end
		return false
	end
	function Form:buildURL()
		if self:hasFile() then
			error("URL encoded forms cannot have files")
		end
		return serializeParams(self.fields), "application/x-www-form-urlencoded"
	end
	function Form:buildMultipart()
		local boundary = "--FormBoundary-" .. randomString(28)
		local body = ""
		for k, v in pairs(self.fields) do
			body ..= "--" .. (boundary .. ('\r\nContent-Disposition: form-data; name="' .. (tostring(k) .. '"')))
			local _v = v
			local _condition = type(_v) == "table"
			if _condition then
				_condition = v._isFile
			end
			if _condition then
				-- value is file
				v = v
				local _condition_1 = v.name
				if not (_condition_1 ~= "" and _condition_1) then
					_condition_1 = k
				end
				body ..= '; filename="' .. (tostring(_condition_1) .. '"')
				body ..= "\r\nContent-Type: " .. v.contentType
				-- get raw content
				-- encode non-text files
				if startsWith(v.contentType, "text/") then
					v = v.content
				else
					v = v:encode()
					body ..= "\r\nContent-Transfer-Encoding: base64"
				end
			end
			body ..= "\r\n\r\n" .. (tostring(v) .. "\r\n")
		end
		body ..= "--" .. boundary
		return body, 'multipart/form-data; boundary="' .. (boundary .. '"')
	end
	function Form:build(contentType)
		if contentType == nil then
			contentType = if self:hasFile() then "multipart" else "url"
		end
		if contentType == "url" then
			return self:buildURL()
		else
			return self:buildMultipart()
		end
	end
end
return {
	File = File,
	Form = Form,
}
