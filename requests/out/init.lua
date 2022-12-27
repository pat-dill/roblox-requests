-- Compiled with roblox-ts v2.0.4
local TS = require(script.include.RuntimeLib)
local Session = TS.import(script, script, "session").Session
local _form = TS.import(script, script, "form")
local File = _form.File
local Form = _form.Form
local defaultSession = Session.new()
local config = defaultSession.config
local file = function(nameOrContent, content, contentType)
	return File.new(nameOrContent, content, contentType)
end
local form = function(fields)
	return Form.new(fields)
end
local request = function(config)
	return defaultSession:request(config)
end
local get = function(url, config)
	return defaultSession:get(url, config)
end
local delete_ = function(url, config)
	return defaultSession:delete(url, config)
end
local head = function(url, config)
	return defaultSession:head(url, config)
end
local options = function(url, config)
	return defaultSession:options(url, config)
end
local post = function(url, data, config)
	return defaultSession:post(url, data, config)
end
local put = function(url, data, config)
	return defaultSession:put(url, data, config)
end
local patch = function(url, data, config)
	return defaultSession:patch(url, data, config)
end
return {
	config = config,
	file = file,
	form = form,
	request = request,
	get = get,
	delete_ = delete_,
	head = head,
	options = options,
	post = post,
	put = put,
	patch = patch,
}
