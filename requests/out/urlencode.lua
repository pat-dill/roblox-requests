-- Compiled with roblox-ts v2.0.4
local charToHex = function(c)
	return string.format("%%%02X", (string.byte(c)))
end
local hexToChar = function(hex)
	return string.char(tonumber(hex, 16))
end
local urlEncode = function(rawUrl)
	local url = tostring(rawUrl)
	url = (string.gsub(url, "([^%w ])", charToHex))
	url = (string.gsub(url, " ", "+"))
	return url
end
local urlDecode = function(encodedUrl)
	local url = (string.gsub(encodedUrl, "%%(%x%x)", hexToChar))
	return (string.gsub(url, "+", " "))
end
return {
	urlEncode = urlEncode,
	urlDecode = urlDecode,
}
