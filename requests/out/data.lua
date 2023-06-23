-- Compiled with roblox-ts v2.1.0
local HttpService = game:GetService("HttpService")
local function transformData(data, config)
	local _data = data
	if type(_data) == "string" then
		return data
	else
		local _data_1 = data
		if type(_data_1) == "table" then
			if config.headers == nil then
				config.headers = {}
			end
			local _exp = config.headers
			if _exp["Content-Type"] == nil then
				_exp["Content-Type"] = "application/json"
			end
		end
		return HttpService:JSONEncode(data)
	end
end
return {
	default = transformData,
}
