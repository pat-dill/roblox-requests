-- Compiled with roblox-ts v2.0.4
local TS = require(script.Parent.include.RuntimeLib)
local defaultSessionConfig = TS.import(script, script.Parent, "defaults").defaultSessionConfig
local startsWith = TS.import(script, script.Parent, "utils").startsWith
local dispatch = TS.import(script, script.Parent, "dispatch").dispatch
local createHeaders = TS.import(script, script.Parent, "headers").default
local urlEncode = TS.import(script, script.Parent, "urlencode").urlEncode
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
	function Session:request(config)
		local _object = {
			method = string.lower(config.method),
		}
		local _left = "headers"
		local _object_1 = {
			["content-type"] = "text/plain",
		}
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
		local _left_3 = "ratelimit"
		local _condition_1 = config.ratelimit
		if _condition_1 == nil then
			_condition_1 = self.config.ratelimit
		end
		_object[_left_3] = _condition_1
		_object.body = config.body
		local finalConfig = _object
		-- processing
		local _condition_2 = config.url
		if _condition_2 == nil then
			_condition_2 = ""
		end
		local url = _condition_2
		-- first handle baseURLs
		if not (startsWith(url, "http://") or startsWith(url, "https://")) then
			local _condition_3 = self.config.baseURL
			if not (_condition_3 ~= "" and _condition_3) then
				_condition_3 = config.baseURL
			end
			if _condition_3 ~= "" and _condition_3 then
				local _condition_4 = self.config.baseURL
				if not (_condition_4 ~= "" and _condition_4) then
					_condition_4 = config.baseURL
				end
				url = tostring(_condition_4) .. url
			else
				error(tostring(config.url) .. " is not an absolute URL and no baseURL was specified")
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
			local _value_1 = value
			if type(_value_1) == "string" then
				local _serialCookies = serialCookies
				local _arg0 = urlEncode(name) .. ("=" .. urlEncode(value))
				table.insert(_serialCookies, _arg0)
			else
				local _serialCookies = serialCookies
				local _arg0 = urlEncode(name) .. ("=" .. urlEncode(value.value))
				table.insert(_serialCookies, _arg0)
			end
		end
		if finalConfig.headers == nil then
			finalConfig.headers = createHeaders()
		end
		if #serialCookies > 0 then
			finalConfig.headers.cookie = table.concat(serialCookies, "; ")
		end
		-- create promise that dispatches request
		local requestPromise = TS.Promise.new(function(resolve, reject)
			-- dispatch request
			local success, responseOrRejection = dispatch(finalConfig):await()
			if not success then
				return reject(responseOrRejection)
			end
			local response = responseOrRejection
			if config.throwForStatus and not response.ok then
				return reject({
					message = response.body,
					response = response,
				})
			end
			return resolve(response)
		end)
		local _value_1 = finalConfig.timeout
		if _value_1 ~= 0 and (_value_1 == _value_1 and _value_1) then
			requestPromise = requestPromise:timeout(finalConfig.timeout)
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
		local _fn = self
		local _object = {}
		if type(config) == "table" then
			for _k, _v in config do
				_object[_k] = _v
			end
		end
		_object.method = "post"
		_object.url = url
		_object.data = data
		return _fn:request(_object)
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
