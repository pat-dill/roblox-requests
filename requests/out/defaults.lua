-- Compiled with roblox-ts v2.0.4
local TS = require(script.Parent.include.RuntimeLib)
local createHeaders = TS.import(script, script.Parent, "headers").default
local serializeParams = TS.import(script, script.Parent, "params").default
local transformData = TS.import(script, script.Parent, "data").default
local HttpService = game:GetService("HttpService")
local defaultSessionConfig = {
	headers = createHeaders({}),
	paramsArrayFormat = "repeat",
	paramsSerializer = serializeParams,
	transformData = transformData,
	cookies = {},
	throwForStatus = true,
	contentTypeWarning = true,
}
return {
	defaultSessionConfig = defaultSessionConfig,
}
