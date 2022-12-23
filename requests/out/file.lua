-- Compiled with roblox-ts v2.0.4
local TS = require(script.Parent.include.RuntimeLib)
local mimes = TS.import(script, script.Parent, "mimes").default
local startsWith = TS.import(script, script.Parent, "utils").startsWith
local base64 = TS.import(script, script.Parent, "base64")
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
	function File:constructor(arg0, arg1, arg2)
		local _condition = arg1
		if _condition == nil then
			_condition = arg0
		end
		self.content = _condition
		self.name = if arg1 ~= "" and arg1 then arg0 else "file"
		self.contentType = arg2
		local _value = self.contentType
		local _condition_1 = not (_value ~= "" and _value)
		if _condition_1 then
			_condition_1 = { string.find(self.name, ".") }
		end
		if _condition_1 then
			local segments = string.split(self.name, ".")
			local extension = segments[#segments - 1 + 1]
			self.contentType = mimes[extension]
		end
	end
	function File:isText()
		local _condition = self.contentType
		if _condition ~= "" and _condition then
			_condition = startsWith(self.contentType, "text/")
		end
		return not not (_condition ~= "" and _condition)
	end
	function File:encode()
		-- encode to Base64
		return base64.encode(self.content)
	end
end
return {
	File = File,
}
