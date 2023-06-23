-- Compiled with roblox-ts v2.1.0
local charToHex = function(c)
	return string.format("%%%02X", (string.byte(c)))
end
local hexToChar = function(hex)
	return string.char(tonumber(hex, 16))
end
local urlEncode = function(rawUrl, plus)
	if plus == nil then
		plus = false
	end
	local url = tostring(rawUrl)
	local _url = url
	local _arg0 = if plus then "([^%w ])" else "([^%w])"
	url = (string.gsub(_url, _arg0, charToHex))
	url = (string.gsub(url, " ", "+"))
	return url
end
local urlEncodeMapSafe = function(rawUrl)
	local plus = true
	local url = tostring(rawUrl)
	local _url = url
	local _arg0 = if plus then "([^%w ])" else "([^%w])"
	url = (string.gsub(_url, _arg0, charToHex))
	url = (string.gsub(url, " ", "+"))
	return url
end
local urlDecode = function(encodedUrl)
	local url = (string.gsub(encodedUrl, "%%(%x%x)", hexToChar))
	return (string.gsub(url, "+", " "))
end
return {
	urlEncode = urlEncode,
	urlEncodeMapSafe = urlEncodeMapSafe,
	urlDecode = urlDecode,
}
