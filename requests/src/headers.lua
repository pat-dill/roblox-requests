-- case-insensitive headers table
-- e.g.: headers["content-type"] == headers["Content-Type"]

return {
    default = function (t)
        local nt = setmetatable({}, {
            __index = function(self, idx)
                if type(idx) ~= "string" then
                    return error("Headers only accept string keys")
                end

                return rawget(self, idx:lower())
            end,
            __newindex = function(self, idx, val)
                if type(idx) ~= "string" then
                    return error("Headers only accept string keys")
                end

                rawset(self, idx:lower(), tostring(val))
            end
        })

        -- use custom newindex func to write all values to new table
        for k, v in pairs(t) do
            nt[k] = v
        end

        return nt
    end
}