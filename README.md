# Roblox Requests

```lua
local http = require(path.to.requests)

http.get("https://httpbin.org/get")
	:andThen(function (resp)
		print(resp:json())
	end)
```