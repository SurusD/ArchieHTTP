local function invalidArgument(forfun, expected, got)
    return string.format("Archie: invalid argument for function %s, %s expected but got %s", forfun, expected, got)
end

local function builder()
    return {
        withMethod = function(self, method)
            if type(method) ~= "string" then
                return error(invalidArgument("withMethod(self, method: string)", "string", type(method)))
            end
            if string.lower(method) == "get" then
                self._method = false
                return self
            elseif string.lower(method) == "post" then
                self._method = true
                return self
            else
                return error(string.format(
                    "Archie: invalid argmuent for function withMethod(self, method: string), GameGuardian only supports GET and POST requests not '%s'",
                    method))
            end
        end,
        withURL = function(self, url)
            if type(url) ~= "string" then
                return error(invalidArgument("withURL(self, url: string", "string", type(url)))
            end
            self._url = url
            return self
        end,
        withHeaders = function(self, headers)
            if type(headers) ~= "table" or type(headers) ~= "nil" then
                return error(invalidArgument("withHeaders(self, headers: table | nil)", "table",
                    type(headers)))
            end
            self._headers = headers
            return self
        end,
        withData = function(self, data)
            self._data = data
            return self
        end,
        onFail = function(self, callback)
            if type(callback) ~= "function" then
                return error(invalidArgument("onFail(self, callback: function)", "function", type(callback)))
            end
            self._onFail = callback
            return self
        end,
        onSuccess = function(self, callback)
            if type(callback) ~= "function" then
                return error(invalidArgument("onSuccess(self, callback: function)", "function", type(callback)))
            end
            if self._onSuccess then
                local originalListener = self._onSuccess
                self._onSuccess = function(response)
                    originalListener(response)
                    callback(response)
                end
            else
                self._onSuccess = callback
            end
            return self
        end,
        autoload = function(self, withName)
            self:onSuccess(function(response)
                if withName then
                    _G[tostring(withName)] = load(response.content)()
                else
                    load(response.content)()
                end
            end)
            return self
        end,
        request = function(self)
            if not self._url then return error("Archie: request to what? Please provide URl: :withURL(url: string)") end
            local url = self._url
            local method = self._method or false
            if method then
                if self._data == nil then return error("Archie: cant request post method without providing data") end
                local data = tostring(self._data)
                local headers = self._headers
                local response = gg.makeRequest(url, headers, data)
                if type(response) == "table" and response.code == 200 then
                    self._onSuccess(response)
                else
                    self._onFail()
                end
            else
                local headers = self._headers
                local response = gg.makeRequest(url, headers)
                if type(response) == "table" and response.code == 200 then
                    if self._onSuccess then
                        self._onSuccess(response)
                    end
                else
                    if self._onFail then
                        self._onFail()
                    end
                end
            end
        end

    }
end
local lib = {
    make = function()
        return builder()
    end,
}
return setmetatable(lib, {
    __index = lib,
    __newindex = function(self, _, _)
        error(tostring(self) .. " is not mutable")
    end
})
