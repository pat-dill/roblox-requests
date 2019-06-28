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

### http.get(url, options), post, head, put, delete, patch, options

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
- url (string) - URL that generated this response
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
