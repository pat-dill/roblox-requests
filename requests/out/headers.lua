-- case-insensitive headers table
-- e.g.: headers["content-type"] == headers["Content-Type"]

local function convertKey(key)
	key, _ = key:gsub("(%w+)", function (match)
		return string.sub(match, 1, 1):upper() .. string.sub(match, 2):lower()
	end)

	return key
end

return {
    default = function (t)
        local nt = setmetatable({}, {
            __index = function(self, idx)
                if type(idx) ~= "string" then
                    return error("Headers only accept string keys")
                end

                return rawget(self, convertKey(idx))
            end,
            __newindex = function(self, idx, val)
                if type(idx) ~= "string" then
                    return error("Headers only accept string keys")
                end

                rawset(self, convertKey(idx), tostring(val))
            end
        })

        -- use custom newindex func to write all values to new table
        for k, v in pairs(t) do
            nt[k] = v
        end

        return nt
    end
}