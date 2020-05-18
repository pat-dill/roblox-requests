local HttpService = game:GetService("HttpService")

local body = HttpService:JSONEncode({cookies = "milk"})
local r = HttpService:RequestAsync({Url = "https://httpbin.org/put", Method="PUT", Body=body})

if r.Success then
        data = HttpService:JSONDecode(r.Body)
end