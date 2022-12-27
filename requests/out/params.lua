-- Compiled with roblox-ts v2.0.4
local TS = require(script.Parent.include.RuntimeLib)
local _urlencode = TS.import(script, script.Parent, "urlencode")
local urlEncode = _urlencode.urlEncode
local urlEncodeMapSafe = _urlencode.urlEncodeMapSafe
local function serializeParams(params, config)
	local serials = {}
	for key, val in pairs(params) do
		local _val = val
		local _condition = type(_val) == "string"
		if not _condition then
			local _val_1 = val
			_condition = type(_val_1) == "number"
		end
		if _condition then
			val = urlEncode(val)
			local _serials = serials
			local _arg0 = key .. ("=" .. val)
			table.insert(_serials, _arg0)
		else
			local _result = config
			if _result ~= nil then
				_result = _result.paramsArrayFormat
			end
			repeat
				local _fallthrough = false
				if _result == "comma" then
					-- ▼ ReadonlyArray.map ▼
					local _newValue = table.create(#val)
					for _k, _v in val do
						_newValue[_k] = urlEncodeMapSafe(_v, _k - 1, val)
					end
					-- ▲ ReadonlyArray.map ▲
					local combined = table.concat(_newValue, ",")
					local _serials = serials
					local _arg0 = key .. ("=" .. combined)
					table.insert(_serials, _arg0)
					break
				end
				if _result == "repeat" then
				end
				for _, subval in ipairs(val) do
					subval = urlEncode(subval)
					local _serials = serials
					local _arg0 = key .. ("=" .. subval)
					table.insert(_serials, _arg0)
				end
				break
			until true
		end
	end
	return table.concat(serials, "&")
end
return {
	default = serializeParams,
}
