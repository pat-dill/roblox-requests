-- Compiled with roblox-ts v2.0.4
local TS = require(script.Parent.include.RuntimeLib)
local defaultSessionConfig = TS.import(script, script.Parent, "defaults").defaultSessionConfig
local startsWith = TS.import(script, script.Parent, "utils").startsWith
local dispatch = TS.import(script, script.Parent, "dispatch").dispatch
local Response = TS.import(script, script.Parent, "response").Response
local createHeaders = TS.import(script, script.Parent, "headers").default
local Form = TS.import(script, script.Parent, "form").Form
local Session
do
	Session = setmetatable({}, {
		__tostring = function()
			return "Session"
		end,
	})
	Session.__index = Session
	function Session.new(...)
		local self = setmetatable({}, Session)
		return self:constructor(...) or self
	end
	function Session:constructor(config)
		if config == nil then
			config = {}
		end
		local _object = {}
		for _k, _v in defaultSessionConfig do
			_object[_k] = _v
		end
		for _k, _v in config do
			_object[_k] = _v
		end
		self.config = _object
		self.config.headers = defaultSessionConfig.headers or createHeaders()
		if config.headers then
			for key, val in pairs(config.headers) do
				self.config.headers[key] = val
			end
		end
	end
	function Session:prepareRequest(config)
		-- prepares final request data based on session and request configs
		local _object = {
			method = string.lower(config.method),
		}
		local _left = "headers"
		local _object_1 = {}
		local _spread = self.config.headers
		if type(_spread) == "table" then
			for _k, _v in _spread do
				_object_1[_k] = _v
			end
		end
		local _spread_1 = config.headers
		if type(_spread_1) == "table" then
			for _k, _v in _spread_1 do
				_object_1[_k] = _v
			end
		end
		_object[_left] = createHeaders(_object_1)
		local _left_1 = "params"
		local _object_2 = {}
		local _spread_2 = self.config.params
		if type(_spread_2) == "table" then
			for _k, _v in _spread_2 do
				_object_2[_k] = _v
			end
		end
		local _spread_3 = config.params
		if type(_spread_3) == "table" then
			for _k, _v in _spread_3 do
				_object_2[_k] = _v
			end
		end
		_object[_left_1] = _object_2
		_object.paramsArrayFormat = config.paramsArrayFormat or self.config.paramsArrayFormat
		local _left_2 = "timeout"
		local _condition = config.timeout
		if _condition == nil then
			_condition = self.config.timeout
		end
		_object[_left_2] = _condition
		_object.body = config.body
		local finalConfig = _object
		-- handle baseURLs
		local _condition_1 = config.url
		if _condition_1 == nil then
			_condition_1 = ""
		end
		local url = _condition_1
		if not (startsWith(url, "http://") or startsWith(url, "https://")) then
			local _condition_2 = config.baseURL
			if not (_condition_2 ~= "" and _condition_2) then
				_condition_2 = self.config.baseURL
			end
			if _condition_2 ~= "" and _condition_2 then
				local _condition_3 = config.baseURL
				if not (_condition_3 ~= "" and _condition_3) then
					_condition_3 = self.config.baseURL
				end
				url = tostring(_condition_3) .. url
			else
				error(tostring(config.url) .. " is not an absolute URL and no baseURL was set")
			end
		end
		-- next handle query string parameters
		if config.params or self.config.params then
			local transformParams = config.paramsSerializer or self.config.paramsSerializer
			if not transformParams then
				error("URL parameters were passed but no paramsSerializer was found")
			end
			local _object_3 = {}
			local _spread_4 = self.config.params
			if type(_spread_4) == "table" then
				for _k, _v in _spread_4 do
					_object_3[_k] = _v
				end
			end
			local _spread_5 = config.params
			if type(_spread_5) == "table" then
				for _k, _v in _spread_5 do
					_object_3[_k] = _v
				end
			end
			local queryString = transformParams(_object_3, finalConfig)
			-- append if URL already included a query string
			local _value = (string.find(url, "%?"))
			url ..= (if _value ~= 0 and (_value == _value and _value) then "&" else "?") .. queryString
		end
		finalConfig.url = url
		-- transform passed data
		local _value = config.data
		if _value ~= 0 and (_value == _value and (_value ~= "" and _value)) then
			if config.transformData then
				finalConfig.body = config.transformData(config.data, finalConfig)
			elseif self.config.transformData then
				finalConfig.body = self.config.transformData(config.data, finalConfig)
			else
				error("Data passed but data transformer is undefined")
			end
		end
		-- handle forms
		-- first convert normal tables to form
		if config.form ~= nil then
			local _value_1 = config.form._isForm
			if not (_value_1 ~= 0 and (_value_1 == _value_1 and (_value_1 ~= "" and _value_1))) then
				config.form = Form.new(config.form)
			end
		end
		-- add any directly passed files to form
		if config.file then
			if config.files == nil then
				config.files = {}
			end
			local _files = config.files
			local _file = config.file
			table.insert(_files, _file)
		end
		if config.files then
			if config.form == nil then
				config.form = Form.new()
			end
			for i, file in ipairs(config.files) do
				if not file._isFile then
					error("Object passed in file argument is not a File")
				end
				local name = if (#config.files == 1) then "file" else "files[" .. (tostring(i - 1) .. "]")
				-- cannot use (config.form as Form).set() because it compiles to
				-- (config.form):set(), which is considered ambiguous by lua and causes an error
				local _form = config.form
				_form:set(name, file)
			end
		end
		-- then build form
		if config.form then
			local _value_1 = finalConfig.body
			if _value_1 ~= "" and _value_1 then
				warn("Request body is being overridden by form data. You may be passing multiple" .. " types of data, such as JSON and a form. Only the form will be sent")
			end
			local _value_2 = config.form._isForm
			if not (_value_2 ~= 0 and (_value_2 == _value_2 and (_value_2 ~= "" and _value_2))) then
				-- convert table to form
				config.form = Form.new(config.form)
			end
			local body, contentType = (config.form):build()
			if finalConfig.headers == nil then
				finalConfig.headers = createHeaders()
			end
			finalConfig.headers["Content-Type"] = contentType
			finalConfig.body = body
		end
		-- handle cookies
		local _object_3 = {}
		local _spread_4 = self.config.cookies
		if type(_spread_4) == "table" then
			for _k, _v in _spread_4 do
				_object_3[_k] = _v
			end
		end
		local _spread_5 = config.cookies
		if type(_spread_5) == "table" then
			for _k, _v in _spread_5 do
				_object_3[_k] = _v
			end
		end
		local cookies = _object_3
		local serialCookies = {}
		for name, value in pairs(cookies) do
			if type(value) == "string" then
				-- serialCookies.push(`${urlEncode(name, false)}=${urlEncode(value, false)}`)
				local _arg0 = '"' .. (tostring(name) .. ('"="' .. (value .. '"')))
				table.insert(serialCookies, _arg0)
			else
				if value:shouldSend(finalConfig) then
					-- serialCookies.push(`${urlEncode(name, false)}=${urlEncode(value.value, false)}`)
					local _arg0 = '"' .. (tostring(name) .. ('"="' .. (value.value .. '"')))
					table.insert(serialCookies, _arg0)
				end
			end
		end
		if finalConfig.headers == nil then
			finalConfig.headers = createHeaders()
		end
		if #serialCookies > 0 then
			finalConfig.headers.cookie = table.concat(serialCookies, "; ")
		end
		return finalConfig
	end
	function Session:request(config)
		local preparedRequest = self:prepareRequest(config)
		-- create promise that dispatches request
		local requestPromise = TS.Promise.new(function(resolve, reject)
			-- dispatch request
			local success, responseOrRejection = dispatch(preparedRequest):await()
			if not success then
				return reject(responseOrRejection)
			end
			local dispatchResponse = responseOrRejection
			local _binding = dispatchResponse
			local rawResponse = _binding[1]
			local secs = _binding[2]
			local response = Response.new(config, rawResponse, secs, self)
			if config.throwForStatus and not response.ok then
				return reject({
					message = response.content,
					response = response,
				})
			end
			return resolve(response)
		end)
		if preparedRequest.timeout ~= nil then
			requestPromise = requestPromise:timeout(preparedRequest.timeout)
		end
		return requestPromise
	end
	function Session:updateHeaders(headers)
		local _exp = self.config
		if _exp.headers == nil then
			_exp.headers = {}
		end
		for key, val in pairs(headers) do
			self.config.headers[key] = val
		end
	end
	function Session:get(url, config)
		local _fn = self
		local _object = {}
		if type(config) == "table" then
			for _k, _v in config do
				_object[_k] = _v
			end
		end
		_object.method = "get"
		_object.url = url
		return _fn:request(_object)
	end
	function Session:post(url, data, config)
		local _object = {}
		if type(config) == "table" then
			for _k, _v in config do
				_object[_k] = _v
			end
		end
		_object.method = "post"
		_object.url = url
		local newConfig = _object
		if not (data ~= 0 and (data == data and (data ~= "" and data))) then
			newConfig.data = nil
		elseif data._isForm then
			-- data is form
			newConfig.form = data
		elseif data._isFile then
			-- add file to form
			newConfig.form = Form.new({
				file = data,
			})
		else
			newConfig.data = data
		end
		return self:request(newConfig)
	end
	function Session:put(url, data, config)
		local _fn = self
		local _object = {}
		if type(config) == "table" then
			for _k, _v in config do
				_object[_k] = _v
			end
		end
		_object.method = "put"
		_object.url = url
		_object.data = data
		return _fn:request(_object)
	end
	function Session:patch(url, data, config)
		local _fn = self
		local _object = {}
		if type(config) == "table" then
			for _k, _v in config do
				_object[_k] = _v
			end
		end
		_object.method = "patch"
		_object.url = url
		_object.data = data
		return _fn:request(_object)
	end
	function Session:delete(url, config)
		local _fn = self
		local _object = {}
		if type(config) == "table" then
			for _k, _v in config do
				_object[_k] = _v
			end
		end
		_object.method = "delete"
		_object.url = url
		return _fn:request(_object)
	end
	function Session:head(url, config)
		local _fn = self
		local _object = {}
		if type(config) == "table" then
			for _k, _v in config do
				_object[_k] = _v
			end
		end
		_object.method = "head"
		_object.url = url
		return _fn:request(_object)
	end
	function Session:options(url, config)
		local _fn = self
		local _object = {}
		if type(config) == "table" then
			for _k, _v in config do
				_object[_k] = _v
			end
		end
		_object.method = "options"
		_object.url = url
		return _fn:request(_object)
	end
end
return {
	Session = Session,
}
