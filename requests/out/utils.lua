-- Compiled with roblox-ts v2.0.4
local startsWith = function(text, val)
	local _text = text
	local _arg1 = #val
	return string.sub(_text, 1, _arg1) == val
end
local endsWith = function(text, val)
	local _text = text
	local _arg0 = -#val
	return string.sub(_text, _arg0, -1) == val
end
return {
	startsWith = startsWith,
	endsWith = endsWith,
}
