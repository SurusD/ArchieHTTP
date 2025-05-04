local http = require "archie_http"

function get(url, headers) -- headers can be nil
    local response = nil
    http.make():
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
    http.make():
        withData(data):
        withURL(url):
        withHeaders(headers):
        withMethod("POST"):
        onSuccess(function(_)
            success = true
        end):request()
    return success
end
