local archie_http = nil
local bootstrap = gg.makeRequest("https://raw.githubusercontent.com/SurusD/ArchieHTTP/refs/heads/master/archie_http.lua")
if type(bootstrap) == "table" and bootstrap.code == 200 then
    archie_http = load(bootstrap.content, "lib", "t")()
end
if archie_http == nil then
    return error("failed to load archie http")
end

local function get(url, headers) -- headers can be nil
    local response = nil
    archie_http.make():
        withURL(url):
        withMethod("GET"):
        withHeaders(headers):
        onSuccess(function(resp)
            response = resp
        end):request()
    return response
end

local function post(url, headers, data) -- headers can be nil but data not its required
    local success = false
    archie_http.make():
        withData(data):
        withURL(url):
        withHeaders(headers):
        withMethod("POST"):
        onSuccess(function(_)
            success = true
        end):request()
    return success
end
local google = get("https://google.com", nil)
if google ~= nil then
    print(google.code, " ", google.content)
else
    print("failed")
end
-- or you can do
archie_http.make():
    withMethod("GET"):
    withURL("https://google.com"):
    onFail(function()
        print("failed")
    end):
    onSuccess(function(response)
        print(response.code, " ", response.content)
    end):
    request()
