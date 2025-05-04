local archie_http = nil
local response = gg.makeRequest("https://raw.githubusercontent.com/SurusD/ArchieHTTP/refs/heads/master/archie_http.lua")
if type(response) == "table" and response.code == 200 then
    archie_http = load(response.content, "lib", "t")
end
if archie_http == nil then
    return error("failed to load archie http")
end

function get(url, headers) -- headers can be nil
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

function post(url, headers, data) -- headers can be nil but data not its required
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
