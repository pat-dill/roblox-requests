# Roblox Requests

**Roblox Requests** brings user-friendly HTTP to Roblox with no need for the manual labor of HttpService.

---

With Requests you can send robust, human-readable HTTP requests without ever having to deal with the underlying HttpService.
No more manual query strings or encoding POST data.

The Power of Roblox Requests:

```lua
local r = http.get("https://api.github.com/orgs/Roblox/repos")

print(r.status_code, r.message)
-- 200 OK

repos = r:json()
print(#repos)
-- 30

print(r.content_type)
-- application/json
print(r.encoding)
-- utf-8
print(r.headers["x-ratelimit-remaining"])
-- 59
```

Roblox Requests will bring simple support for all internet resources to your game.

## Roblox Requests Features

- Sessions with Cookie Persistence
- Default Headers, URL prefixes
- Automatic Query Strings
- JSON Body Encoding, JSON Response Decoding
- Elegant Key/Value Cookies
  - Domain/Path filters
- Multipart File Encoding and Upload
- Global/Per-Session Ratelimiting


[In this documentation](https://jpatrickdill.github.io/roblox-requests/guide/installation/) you'll find step-by-step instructions to get the most out of Roblox Requests.
