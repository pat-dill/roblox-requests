local Cache = {}
-- Cache.__index = Cache

Cache.settings = {}
Cache.max_size = math.huge

Cache.data = {}
Cache.exists_in_cloud = {}


--

local function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+i] = t2[i]
    end
    return t1
end

--

-- Cache.update_settings({"paric.xyz", "*.paric.xyz"})

function Cache.update_settings(urls, settings)
    urls = type(urls) == "table" and urls or {urls}

    local _concat = {}
    local i = 0
    while i < #urls do
        i += 1

        local url = urls[i]

        if url:sub(1, 7) == "http://" then
            urls[i] = url:sub(8)
            url = urls[i]
        elseif url:sub(1, 8) == "https://" then
            urls[i] = url:sub(9)
            url = urls[i]
        end

        if url:sub(1, 2) == "*." then
            table.insert(urls, url:sub(3))
        end

        if not url:find("/") then
            table.insert(urls, url .. "/")
            table.insert(urls, url .. "/*")
        end
    end

    for _, url in ipairs(urls) do
        Cache.settings[url] = settings
    end
end

function Cache.cache_locally(urls)
    Cache.update_settings(urls, {cache_globally=false})
end

function Cache.cache_globally(urls)
    Cache.update_settings(urls, {cache_globally=true})
end

-- "paric.xyz/" would cache http://paric.xyz/ only
-- "paric.xyz/*" would cache all subdirectories
-- "*.paric.xyz" would cache all subdomains INCLUDING paric.xyz

function Cache.should_cache(url)
    for key, _ in pairs(Cache.settings) do
        local pattern = ".*://" .. key:gsub("%*", ".*")

        if url:match(pattern) then
            return key
        end
    end

    return false
end

function Cache.is_cached(url, req_id)
    -- check local server cache first

    local setting_key = Cache.should_cache(url)
    local settings = Cache.settings[setting_key]

    if not setting_key then
        return false
    end

    if Cache.data[req_id] ~= nil then
        if settings.expires then
            if tick() - Cache.data[req_id].timestamp > settings.expires then
                return false
            end
        end

        return true
    end

    if Cache.settings[setting_key].cache_globally then
        if Cache.exists_in_cloud[req_id] then
            return true
        else
            return false
        end
    else
        return false
    end
end

function Cache.get_cached(url, req_id)
    local setting_key = Cache.should_cache(url)

    local server_cached = Cache.data[req_id]
    if server_cached then
        return server_cached, "local"
    end
end

function Cache.update_cache(url, req_id, data)
    print(("[http] %s added to cache"):format(url))
    
    data.timestamp = tick()

    Cache.data[req_id] = data

    local setting_key = Cache.should_cache(url)

    -- cloud cache
    if Cache.settings[setting_key].cache_globally then
        -- back it up!!
        return
    end
end




return Cache
