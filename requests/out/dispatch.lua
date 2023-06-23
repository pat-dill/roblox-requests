-- Compiled with roblox-ts v2.1.0
local TS = require(script.Parent.include.RuntimeLib)
local HttpService = game:GetService("HttpService")
local RequestAsync = TS.Promise.promisify(function(options)
	return HttpService:RequestAsync(options)
end)
local function dispatch(request)
	return TS.Promise.new(function(resolve, reject)
		local st = tick()
		RequestAsync({
			Url = request.url,
			Method = string.upper(request.method),
			Body = request.body,
			Headers = request.headers,
		}):andThen(function(rawResponse)
			local secs = tick() - st
			return resolve({ rawResponse, secs })
		end):catch(reject)
	end)
end
return {
	dispatch = dispatch,
}
