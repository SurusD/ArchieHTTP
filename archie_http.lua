local function invalidArgument(forfun, expected, got)
    return string.format("Archie: invalid argument for function %s, %s expected but got %s", forfun, expected, got)
end

local function builder()
    return {
        withMethod = function(self, method)
            if type(method) ~= "string" then
                return error(invalidArgument("withMethod(self, method: string)", "string", type(method)))
            end
            local method_lower = string.lower(method)
            if method_lower == "get" then
                self._method = false
            elseif method_lower == "post" then
                self._method = true
            else
                return error(string.format(
                    "Archie: invalid argument for function withMethod(self, method: string), only GET and POST requests are supported, not '%s'",
                    method))
            end
            return self
        end,

        withURL = function(self, url)
            if type(url) ~= "string" then
                return error(invalidArgument("withURL(self, url: string)", "string", type(url)))
            end
            self._url = url
            return self
        end,

        withHeaders = function(self, headers)
            if type(headers) ~= "table" and headers ~= nil then
                return error(invalidArgument("withHeaders(self, headers: table | nil)", "table | nil", type(headers)))
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
            self._onFail = self._onFail and function(response)
                self._onFail(response)
                callback(response)
            end or callback
            return self
        end,

        onSuccess = function(self, callback)
            if type(callback) ~= "function" then
                return error(invalidArgument("onSuccess(self, callback: function)", "function", type(callback)))
            end
            self._onSuccess = self._onSuccess and function(response)
                self._onSuccess(response)
                callback(response)
            end or callback
            return self
        end,

        autoload = function(self, withName)
            self:onSuccess(function(response)
                local loadedContent = load(response.content)()
                if withName then
                    _G[tostring(withName)] = loadedContent
                end
            end)
            return self
        end,

        request = function(self)
            if not self._url then return error("Archie: request to what? Please provide URL using withURL(url: string)") end
            local url = self._url
            local method = self._method
            local data = self._data
            local headers = self._headers

            if method then
                if data == nil then return error("Archie: can't request POST method without providing data") end
                local response = gg.makeRequest(url, headers, tostring(data))
                if type(response) == "table" and response.code == 200 then
                    self._onSuccess(response)
                else
                    self._onFail(response)
                end
            else
                local response = gg.makeRequest(url, headers)
                if type(response) == "table" and response.code == 200 then
                    self._onSuccess(response)
                else
                    self._onFail(response)
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
