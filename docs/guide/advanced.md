# Advanced Usage

This page covers some more advanced features of Roblox Requests.

## Session Objects

The Session object allows you to persist certain data across requests.
It also persists cookies across all requests made from the Session instance.

A Session object has all the same methods of the main Requests API.

Persisting cookies across requests:
```lua
local session = http.Session()

session:get("https://httpbin.org/cookies/set/sessioncookie/123456789")
local r = session:get("https://httpbin.org/cookies")

print(r.content)
-- {"cookies": {"sessioncookie": "123456789"}}
```

Sessions can also be used to provide default data to requests. This is done
with some helper functions:

```lua
local session = http.Session()
session:set_headers{["X-Test"] = "true"}

-- both "x-test" and "x-test2" are sent
session:get("https://httpbin.org/headers", { headers={["X-Test2"] = "true"} })
```

Any options that you pass to a request method will be merged with the session-level values.
Method-level parameters override session parameters.

However, method-level parameters aren't persisted across requests, even if
using a session. This example will only send cookies with the first request:

```lua
local session = http.Session()

local r = session:get("https://httpbin.org/cookies", { cookies={["temp"] = "value"} })
print(r.content)
-- {"cookies": {"temp": "value"}}

local r2 = session:get("https://httpbin.org/cookies")
print(r2.content)
-- {"cookies": {}}
```

## Request Objects

When you send a request with the `http.get()` method, a `Request` object is actually created and
prepared with any data you passed. In some cases, you may wish to do something extra
with the request before it is sent. This is possible by creating the Request directly:

```lua
local request = http.Request("POST", "https://httpbin.org/post", { data=data })

request:set_data("use this body instead")

local response = request:send()
```

The same is possible from a session by using `Session:Request()`.

### Asynchronous Requests

When handling `Request` objects directly, you can send them in a separate thread by specifying a callback:

```lua
function cb(response)
	print(response.content)
	-- do stuff
end

local request = http.Request("POST", "https://httpbin.org/post")
request:send(cb)

-- continue executing without waiting for response
```

## Rate-limiting

Roblox Requests ratelimits all HTTP requests sent through the module. If a request would tip the ratelimit past 500
requests/minute, Requests will issue a warning and retry in 5 seconds.

By default, the rate-limiter allows 250 requests every 30 seconds, smoothing bursts over a 1 minute period.
You can change these settings with `http.set_ratelimit`:

```lua
local http = require(ReplicatedStorage.http)

http.set_ratelimit(10, 60)  -- allow 10 requests every 60 seconds
```

In order for these changes to apply, `set_ratelimit` **must** be called before any HTTP requests are sent.

If you'd like a request to ignore the rate-limit, just set the `ignore_ratelimit` option to `true`:

```lua

if custom_ratelimit_function() then
	http.get("https://httpbin.org", { ignore_ratelimit=true })
end
```

You can also disable a session's rate-limits by setting the `ignore_ratelimit` property:

```lua
local session = http.Session()

session.ignore_ratelimit = true

-- let's break roblox!
while wait() do
	session:get("https://httpbin.org/get")
end
```

It's recommended that you only do this if you're applying some other limiting function.

### Session rate-limits

If you want to make a specific session follow a different rate-limit, you can set one:

```lua
local session = http.Session()

session:set_ratelimit(10, 60)  -- 10 requests/minute

local i = 0
while wait(1) do
	i = i + 1

	http.get("https://httpbin.org/get")  -- module level requests still follow normal rate-limit

	if i%6 == 0 then  -- only send every 6 seconds (10/min)
		session:get("https://httpbin.org/get")
	end
end
```

Unlike the global rate-limiter, this one can be changed any time you like by calling `set_ratelimit`.
It can also be removed by calling `disable_ratelimit`.

