# Quickstart

This page gives an introduction into how to use Roblox Requests.
From this point forward, we will assume that Requests is installed in `ReplicatedStorage`.

## Make a request

Making a request is simple. We'll begin by obtaining the module:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local http = require(ReplicatedStorage.http)
```

Now, we'll make a GET request.

```lua
local r = http.get("https://api.github.com/events")  -- GitHub's public timeline
```

This gives us a `Response` object containing the information we need.

What about the other HTTP methods?

```lua
local r = http.post("https://httpbin.org/post", { data={key="value"} })

local r = http.put("https://httpbin.org/put", { data={key="value"} })
local r = http.patch("https://httpbin.org/patch", { data={key="value"} })
local r = http.delete("https://httpbin.org/delete")
local r = http.head("https://httpbin.org/head")
local r = http.options("https://httpbin.org/options")
```

All methods accept an options dictionary for any additional information.


## Passing Parameters in URLs

It's common to send data in a URL's query string. With HttpService, constructing key/value pairs in URLs gets very tedious.
Requests allows you to provide these arguments as a dictionary using the `query` option. For example:

```lua
local payload = {key1 = "value1", key2 = "value2"}
local r = http.get("https://httpbin.org/get", { query=payload })
```

You can see the encoded URL by printing it:

```lua
print(r.url)
-- https://httpbin.org/get?key1=value1&key2=value2
```

## Response Content

Requests makes it easy to read different kinds of response content.

```lua
local r = http.get("https://api.github.com/orgs/Roblox/repos")
print(r.content)
-- [{"id":10803524,"node_id":"MDEwOlJlcG9zaXRvcnkxMD...
```

The `content` attribute provides the plaintext response body, regardless of the given content-type.
If you'd like to decode JSON data, you can use the `:json()` method:

```lua
local r = http.get("https://api.github.com/orgs/Roblox/repos")
local repos = r:json()
print(#repos)
-- 30
```

In the case that JSON decoding fails, an exception will be raised. It should be noted, however, that a successful `:json()` call
does **not** indicate the success of the response. Some servers may return a JSON object in a failed response, such as error details.

To check that a response is successful, use `r.success` or `r.code`.

## Custom Headers

If you'd like to add HTTP headers, just pass a dictionary to the `headers` option.

For example, API keys are often specified in the headers of a request:

```lua
local url = "https://api.github.com/some/endpoint"
local custom_headers = {Authorization = "api-key-here"}

local r = http.get(url, { headers=custom_headers })
```

Note: The `User-Agent` and `Roblox-Id` headers cannot be overridden.

## POST JSON Payloads

It's common to send JSON data via HTTP. To do this, just pass a table to the `data` argument. It will be detected as JSON and automatically
encoded when the request is made:

```lua
local payload = {key1 = "value1", list={"a", "b", "c"}}

local r = http.post("https://httpbin.org/post", { data=payload })
print(r.content)
-- {
-- 	...
-- 	"json": {
-- 		"key1": "value1", 
-- 		"list": [
-- 			"a", 
-- 			"b", 
--			"c"
--		]
--  }, 
--  ...
-- }
```

## POST Form Data

Requests supports URL encoded and multipart encoded forms through the `FormData` class. Creating forms is simple:

```lua
local form = http.FormData({"key", "value"}, {"key2", "value2"}, ...)
```

Fields can also be added after the form is created:

```lua
local form = http.FormData()

form:AddField("size", "large")
form:AddField("toppings", {"cheese", "pepperoni"})
```

To use a form in a POST request, just set it as the `data` option:

```lua
local form = http.FormData({"key", "value"}, {"key2", "value2"})
local r = http.post("https://httpbin.org/post", { data=form })

print(r.content)
--	{
--    ...
--	  "form": {
--	    "key": "value", 
--	    "key2": "value2"
--	  }, 
--	  ...
--	}
```

### File Uploads

Requests makes it easy to upload files:

```lua
local file_name = "example.txt"
local file_content = "Lorem ipsum"

local form = http.FormData()
form:AddFile("file", file_content, file_name)

local r = http.post("https://api.anonymousfiles.io/", { data=form })
print(r:json().url)
-- https://anonymousfiles.io/et78xhGK/
```

Binary files can also be uploaded. This example downloads an image then uploads it to another site:

```lua
local image_url = "https://upload.wikimedia.org/wikipedia/en/a/a9/Example.jpg"
local image = http.get(image_url)

local form = http.FormData()
form:AddFile("file", image.content, "image.jpg", "image/jpeg")  -- content type must be specified for non-text files

local r = http.post("https://api.anonymousfiles.io/", { data=form })
print(r:json().url)
-- https://anonymousfiles.io/zwtSGyvZ/
```

Any non-text files will be encoded using Base64 before upload.

!!! warning
	Roblox doesn't support file uploads larger than 100 MB.

## Response Status Codes

We can check the response status code and message:

```lua
local r = http.get("https://httpbin.org/get")
print(r.code, r.message)
-- 200 OK
print(r.success)
-- true
```

All is well.