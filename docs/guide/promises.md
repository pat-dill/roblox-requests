# Promises

Roblox Requests supports [Roblox Lua Promises](https://eryn.io/roblox-lua-promise/) for response handling. This section
shows how to use all yielding functions in this library as Promises.

## Making a Request

In the quickstart, we learned how to send a basic request:

```lua
local response = http.get("https://api.github.com/orgs/Roblox/repos")  -- GitHub's public timeline
```

Let's try sending this using a Promise. All module-level functions are implemented as promises:

- http.send -> http.promise_send
- http.get -> http.promise_get
- http.post -> http.promise_post
- etc.

We'll use `http.promise_get` to get the reponse as a Promise and print the result.

```lua
http.promise_get("https://api.github.com/orgs/Roblox/repos")
    :andThen(function(response)
        print(response.text)
    end)

    -- [{"id":10803524,"node_id":"MDEwOlJlcG9zaXRvcnkxMD...
```

## Handling Errors

Using Promises with Roblox Requests allows you to more easily handle failed requests.
When a request fails, the Promise is rejected with a table:

| Name             | Type                        | Description                                                                            |
|------------------|-----------------------------|----------------------------------------------------------------------------------------|
| request_sent     | bool                        | Whether the request was sent successfully.                                             |
| response         | bool                        | The response object. This value is only present if `request_sent` is `true`.           |
| error            | string                      | The error thrown during preparation of the request if `request_sent` is `false`.       |

If the request was sent and returned a non-2xx status code, `request_sent` will be `true` and `response` will hold the Response object.
If the request threw an error during preparation, `request_sent` will be `false` and `error` will show the error thrown.

Here's an example that handles HTTP errors:

```lua
http.promise_get("https://api.github.com/orgs/this_org_does_not_exist/repos")
    :andThen(function(response)
        print(response.text)
    end)
    :catch(function(err)
        if err.request_sent then
            print("HTTP Error:", err.response.status_code, err.response.message)
        else
            print(err.error)
        end
    end)

    -- HTTP Error: 404 Not Found
```

## Sessions

The same module-level promise functions are provided for sessions:

```lua

    local session = http.Session("https://httpbin.org")

    session:promise_get("/get")
        :andThen(function(response)
            print(response.text)
        end)
        :catch(function(err)
            if err.request_sent then
                print("HTTP Error:", err.response.status_code, err.response.message)
            else
                print(err.error)
            end
        end)

    -- {
    --     "args": {}, 
    --     "url": "http://httpbin.org/get",
    --     ...

```

## Prepared Requests

Directly created Request objects can be sent as Promises, too. Calling `:promise()` on a Request
will return a Promise object.

```lua
    local request = http.Request("POST", "https://httpbin.org/post")

    request:set_data("request body")

    local response = request:promise()
        :andThen(function(response)
            print(response.text)
        end)
        :catch(function(err)
            if err.request_sent then
                print("HTTP Error:", err.response.status_code, err.response.message)
            else
                print(err.error)
            end
        end)
```


