local Main = script.Parent.Parent
local Lib = Main.lib
local Src = Main.src
------------------------------------
local Session = require(Src.session)
local scopy = require(Lib.scopy)
------------------------------------

local STATS_SERVER = "http://localhost:3003/api"  -- default stats server
local WINDOW_INTERVAL = 1  -- x second data windows
local POST_INTERVAL = 4  -- post every x seconds

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

function Stats:_statsPostLoop()
    -- initial window
    table.insert(self.data, {})

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

        table.insert(self.data, {})

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

    local req_data = {
        timestamp = math.floor(req.timestamp),
        response_time = resp.response_time,
        upload = math.ceil(#(req.data or "")/102.4)/10,
        download = math.ceil((resp.content_length)/102.4)/10,
        content_type = resp.content_type,
        encoding = resp.encoding or "utf-8",
        url = req.input_url,
        code = resp.status_code,
        method = req.method:lower(),
    }
    

    table.insert(self.data[#self.data], req_data)
end


return Stats
