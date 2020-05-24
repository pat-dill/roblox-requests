local Main = script.Parent.Parent
local Lib = Main.lib
local Src = Main.src
------------------------------------
local Session = require(Src.session)
local scopy = require(Lib.scopy)
------------------------------------

local STATS_SERVER = "http://localhost:3003/api"  -- default stats server
local WINDOW_INTERVAL = 2  -- x second data windows
local POST_INTERVAL = 6  -- post every x seconds

POST_INTERVAL = math.ceil(POST_INTERVAL / WINDOW_INTERVAL)

local Stats = {}

Stats._enabled = false
Stats.session = nil

Stats.data = {}
Stats._lastTS = nil

function Stats:enable(stats_server)
    -- enabled stats platform reporting

    if self._enabled then
        return
    end
    
    self.session = Session.new(stats_server or STATS_SERVER)
    self.session.no_stats = true

    print("[http] Authorizing with Stats Server.")
    local gid = game.GameId
    local pid = game.PlaceId
    local jid = game.JobId

    local params = {
        placeId = pid,
        jobId = jid
    }

    local key = self.session:post(("/auth/%s"):format(gid), { query=params })
    if not key.ok then
        print("[http] FAILED to authorize with Stats Server. Stats will not be reported.")
        print(key.text)
    end

    key = key:json().key

    self.session:set_headers({
        ["X-Authorization"] = key
    })

    print("[http] Testing Auth Key")
    local test = self.session:get(("/auth/%s"):format(gid))
    if not test.ok then
        print("[http] Auth Key failed. Stats will not be reported.")
    end

    print("[http] Authorization Successful! Stats will be reported.")

    self._enabled = true

    self._lastTS = tick()

    coroutine.wrap(function()
        self:_statsPostLoop()
    end)()
end

local function new_window(ts)
    return {
        timestamp = math.floor(ts),
        total = 0,
        codes = {},
        general_codes = {},
        endpoints = {},
        response_times = {}
    }
end

local function load_data(window, req, resp)
    -- if math.floor(req.timestamp) ~= math.floor(self.timestamp) then
    --     return
    -- end

    window.total = window.total + 1

    -- specific status code
    window.codes[tostring(resp.status_code)] = (window.codes[tostring(resp.status_code)] or 0) + 1
    
    -- status code (1xx, 2xx, 3xx, 4xx, 5xx)
    local general_code = tostring(math.floor(resp.status_code/100)*100)
    window.general_codes[general_code] = (window.general_codes[general_code] or 0) + 1

    -- full url without protocol
    local endpoint = req.input_url:split("://")[2]
    window.endpoints[endpoint] = (window.endpoints[endpoint] or 0) + 1
    
    -- response time (ms)
    table.insert(window.response_times, math.ceil(resp.response_time*1000))
end

function Stats:_statsPostLoop()
    -- initial window

    local i = 0
    while true do
        i = i + 1

        if i % POST_INTERVAL == 0 then
            -- reset data table for new requests that may occur while our data is POSTing
            local data_clone = scopy(self.data)
            self.data = {}

            coroutine.wrap(function()
                self.session:post("/report", { data=data_clone, query={gameId=game.GameId} })
            end)()
        end

        table.insert(self.data, new_window(tick()))

        wait(WINDOW_INTERVAL)
    end
end

function Stats:report(req, resp)
    if not self._enabled then
        -- not authorized, don't attempt
        return
    end

    if #self.data == 0 then
        error("no data windows")
    end

    load_data(self.data[#self.data], req, resp)
end

return Stats
