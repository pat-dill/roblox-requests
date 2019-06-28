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
with the request before it is sent. The following allows you to:

```lua
local request = http.Request("POST", "https://httpbin.org/post", { data=data })

request:set_data("use this body instead")

local response = request:send()
```

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