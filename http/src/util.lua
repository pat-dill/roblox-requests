local _U = {}

-- deprecated decorator
function _U.deprecate(method, version)
    return function(...)
        if version then
            warn(("[http] Method deprecated in version %s. See documentation at http://requests.paric.xyz/"):format(version))
        else
            warn("[http] Method deprecated. See documentation at http://requests.paric.xyz/")
        end

        return method(...)
    end
end

return _U