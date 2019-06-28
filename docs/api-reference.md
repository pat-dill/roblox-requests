# API Reference

## Module Level

### http.send

`http.send(method, url, [options]) -> Response`

Creates and sends an HTTP request with the given method, URL, and options.

Accepted options:

| Name    | Type                        | Description                                                                            |
|---------|-----------------------------|----------------------------------------------------------------------------------------|
| headers | dictionary                  | Headers to be used with the Request.                                                   |
| query   | dictionary                  | Query string parameters to add to the URL.                                             |
| data    | string OR table OR FormData | Data to send in the body of the request. Tables will automatically be encoded as JSON. |
| cookies | dictionary OR CookieJar     | Cookies to send with request.                                                          |

### http.get, post, head, put, delete, patch, options

`http.get(url, [options]) -> Response`

Shortcut methods for `http.send`.

## http.Request

`http.Request(method, url, [options]) -> Request`

Creates and prepares a Request object.

### Attributes

Note: These attributes are all read-only. Use the provided methods instead of setting them directly.

- **method** (string) - HTTP verb used for request
- **url** (string) - URL request is sent to
- **headers** (dictionary) - Headers used for this request
- **query** (dictionary) - Parameters to add to URL
- **data** (string) - Raw data sent with request

### Request:update_headers

`Request:update_headers(headers)`

Updates request headers based on a dictionary of new headers.

### Request:update_query

`Request:update_query(params)`

Updates URL query string based on a dictionary of parameters.

### Request:set_data

`Request:set_data(data)`

Sets new data for request. The data can be a string, table (JSON), or FormData.

### Request:send

`Request:send() -> Response`

Sends the request and returns a `Response` object.

`Request:send(cb)`

Sends request and passes the response to a callback function. This
will not block the current thread.

## Response

### Attributes

- request (Request) - Request that generated this response
- url (string) - Requests' URL
- method (string) - Request's HTTP method
- success (bool) - `true` if response was successful
- code (number) - Status code of reponse
- message (string) - Status message of response
- headers (dictionary) - Headers sent in response
- content (string) - Response body
- cookies (CookieJar) - **New** cookies sent in this response

### Response:json

`Response:json() -> Variant`

Converts JSON response to a Lua object.

## http.Session

`http.Session([base_url]) -> Session`

Creates a session with an optional base URL.

All main module methods also apply to sessions.

### Attributes

- headers (dictionary) - Default headers used with each request
- cookies (CookieJar) - Current session cookies. Updates automatically from Set-Cookie header
- base_url (string) - Base URL to prefix each request with. If a request UTL contains the HTTP protocol ("http(s)://"), this will be ignored

### Session:set_headers

`Session:set_headers(new_headers)`

Updates headers dictionary with values of new_headers.

### Session:send

`Session:send(method, url, [opts]) -> Response`

Creates and sends a request prepared with session defaults.
Options specified here will override the session values.

### Session:get, post, head, put, delete, patch, options

`Session:get(url, [opts]) -> Response`

Shortcut methods for `Session:send`

### Session:Request

`Session:Request(method, url, [opts]) -> Request`

Creates a Request prepared with session defaults.
Options specified here will override the session values.

## http.FormData

`http.FormData([{fieldName, fieldValue}, [...]]) -> FormData`

Creates form data based on given fields. Field names cannot contain '=' or '&' characters.

### FormData:AddField

`FormData:AddField(name, value)`

Adds field with given name and value.

### FormData:AddFile

`FormData:AddFile(fieldName, fileContent, [fileName, [contentType]])`

Adds a file to the form with optional file name and content type.
Content type must be specified if not `text/plain`.

Any non-text files will be encoded using Base64.

## http.CookieJar

`http.CookieJar() -> CookieJar`

Creates a CookieJar object.

When cookies are added for a URL, its hostname is taken and used as the domain for that cookie
(this is being reworked in the future).

### Attributes

- domains (dictionary) - Table containing cookies for each domain

### CookieJar:set

`CookieJar:set(url, name, value)`

Creates a new cookie under the specified URL

`CookieJar:set(url, cookie_table)`

Adds multiple cookies to the specified URL.
Table should be in the format `{name="value"}`.

### CookieJar:delete

`CookieJar:delete(url, name)`

Deletes a cookie from the specified domain.
