local Main = script.Parent.Parent
local Lib = Main.lib
local Src = Main.src
------------------------------------
local Session = require(Src.session)
------------------------------------

local STATS_SERVER = "http://localhost:3003/api"

local Stats = {}

Stats._enabled = false
Stats.session = nil

function Stats:enable()
    -- enabled stats platform reporting

    if self._enabled then
        return
    end
    
    self.session = Session.new(STATS_SERVER)
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

    print("[http] Retrieved Auth Key")
    print("[http] Testing Auth Key")
    local test = self.session:get(("/auth/%s"):format(gid))
    if not test.ok then
        print("[http] Auth Key failed. Stats will not be reported.")
    end

    print("[http] Authorization Successful! Stats will be reported.")

    self._enabled = true
end