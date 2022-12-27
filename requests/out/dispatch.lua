-- Compiled with roblox-ts v2.0.4
local TS = require(script.Parent.include.RuntimeLib)
local Response = TS.import(script, script.Parent, "response").Response
local HttpService = game:GetService("HttpService")
local RequestAsync = TS.Promise.promisify(function(options)
	return HttpService:RequestAsync(options)
end)
local function dispatch(request, session)
	return TS.Promise.new(function(resolve, reject)
		local st = tick()
		RequestAsync({
			Url = request.url,
			Method = string.upper(request.method),
			Body = request.body,
			Headers = request.headers,
		}):andThen(function(rawResponse)
			local secs = tick() - st
			return resolve(Response.new(request, rawResponse, secs, session))
		end):catch(reject)
	end)
end
return {
	dispatch = dispatch,
}
