local archie_http = nil
local bootstrap = gg.makeRequest("https://raw.githubusercontent.com/SurusD/ArchieHTTP/refs/heads/master/archie_http.lua")
if type(bootstrap) == "table" and bootstrap.code == 200 then
    archie_http = load(bootstrap.content, "lib", "t")()
end
if archie_http == nil then
    return error("failed to load archie http")
end

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
-- for post request you need to change GET to POST and add :withData(data: string)
