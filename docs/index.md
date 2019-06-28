# Roblox Requests

**Roblox Requests** brings user-friendly HTTP to Roblox with no need for the manual labor of HttpService.

---

An example of what you can do with Requests:

```lua
local http = require(game.ReplicatedStorage.http)

local r = http.post("https://httpbin.org/post", { query = {arg="value"},
	                                              data = {this="json"}  })

print(r.content_type,
	  r:json().url)

-- output:
-- application/json
-- https://httpbin.org/post?arg=value
```

See [similar code with HttpService.](https://gist.github.com/jpatrickdill/8fe2a82c47c1bdf679eb1a1c5f07d7a0)

Requests' powerful API allows you to send HTTP/1.1 requests without the need of manual labor. You'll never
have to add query strings to URLs or encode your POST data again.

### Roblox Requests Features

- Sessions with cookie persistance, base URLs/headers/query
- Automatic query string building
- Automatic JSON body encoding
- Elegant response structure with builtin JSON decoding
- Domain based Key/Value cookies
- Multipart form building including file encoding and upload

Roblox Requests was inspired by the well known [Python Requests](https://2.python-requests.org/en/master/) library.
Feel free to contribute new features on the library's [GitHub](https://github.com/jpatrickdill/roblox-requests).

In this documentation you'll find step-by-step instructions to get the most out of Roblox Requests.
