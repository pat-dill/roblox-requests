# {{ version }} Release Notes

Here you'll find a list of changes in this release, along with a list of what's to come.

## Additions

### Rate-limit Functionality

Requests are globally rate limited using the Sliding Window algorithm.
Default setting is 250 requests / 30 seconds, but can be changed via `http.set_ratelimit`.

## Changes

- Added `http.File`
- Changed FormData functionality

## To Do

- Add session level rate-limit config
- Rework CookieJars

!!! warning
    Backwards-compatibility is NOT guaranteed before the 1.0 release.