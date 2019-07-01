# {{ version }} Release Notes

Here you'll find a list of changes in this release, along with a list of what's to come.

## Additions

### Global Rate-Limiting

Requests are rate-limited using a sliding window.
Default setting is 250 requests / 30 seconds, but can be changed via `http.set_ratelimit`.
Individual session rate-limits can also be with `Session:set_ratelimit`.

## Changes

- Reworked FormData class
    - Fields are now passed in a dictionary
    - `:AddField()` method used for both text and file fields
    - New `http.File` class for files

## To Do

- Rework CookieJars

!!! warning
    Backwards-compatibility is NOT guaranteed before version 1.0.