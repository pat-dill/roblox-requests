-- Sliding Window rate limit algorithm

-- Hybrid approach between fixed window and sliding log algorithm
-- Track a counter for each fixed window of time (typically 60 seconds)
-- When processing request, use weighted sum of previous and current window as ratelimit counter
-- If current window is 25% through, weigh previous window by 75% and use sum as counter

-- Relatively small # of data points per rate limit


local RateLimiter = {}
RateLimiter.__index = RateLimiter

local function log(s)
    -- log(s)
end

function RateLimiter.get(id, rate, window_size)
    local self = setmetatable({}, RateLimiter)

    if not _G.ratelimit then
        _G.ratelimit = {}
    end

    -- create window table for this id
    if not _G.ratelimit[id] then
        _G.ratelimit[id] = {}

        _G.ratelimit[id].windows = {}
        _G.ratelimit[id].window_size = window_size
        _G.ratelimit[id].rate = rate
    end

    self.id = id
    self.window_size = _G.ratelimit[id].window_size
    self.rate = _G.ratelimit[id].rate

    log("[ratelimit] Created RateLimiter with id", self.id)

    return self    
end

function RateLimiter:window()
    return math.floor(tick() / self.window_size)
end

function RateLimiter:progress()
    -- returns progress through current window

    return (tick() % self.window_size) / self.window_size
end

function RateLimiter:increment()
    -- increment current window and return value

    local w = self:window()

    log("[ratelimit] Incrementing window", w)


    if not _G.ratelimit[self.id].windows[w] then
        _G.ratelimit[self.id].windows[w] = 0
    end

    _G.ratelimit[self.id].windows[w] = _G.ratelimit[self.id].windows[w] + 1

    return _G.ratelimit[self.id].windows[w]
end

function RateLimiter:weighted(i)
    -- return weighted counter value with optional increment

    i = i or 0

    local p = self:progress()
    local w = self:window()

    local current = (_G.ratelimit[self.id].windows[w] or 0) + i
    local prev = _G.ratelimit[self.id].windows[w-1] or 0

    return current*p + prev*(1-p)
end

function RateLimiter:request()
    -- checks if request will fall within ratelimit
    -- returns true if allowed, false if denied

    if self:weighted(1) > self.rate then
        return false
    else
        self:increment()
        return true
    end
end

------------------
return RateLimiter