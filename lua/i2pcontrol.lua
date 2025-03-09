--[[
    i2pcontrol.lua
    
    Lua interface for I2P Control API that provides functions to monitor and control an I2P router.
    Includes functionality for:
    - Authentication and API communication
    - Bandwidth monitoring (send/receive rates)
    - Exploratory tunnel statistics
    - Router information queries
    - Network settings management

    Dependencies:
    - json4lua (for JSON-RPC communication)
    - rpc module

    Environment variables:
    - I2P_CONTROL: API endpoint URL (default: http://127.0.0.1:7657/jsonrpc/)
    - I2P_CONTROL_PASSWORD: API authentication password (default: "itoopie")
]]--
package.path = './lua/craigmj/json4lua/json/?.lua;' .. package.path
json = require('json')
require("rpc")

--[[
    findserver: finds the I2P Control API server
    returns: the server URL
    uses the value of the I2P_CONTROL environment variable if set
    otherwise defaults to http://127.0.0.1:7657/jsonrpc/
]]--
function findserver()
    i2pcontrol = os.getenv("I2P_CONTROL")
    if i2pcontrol == nil then
        return "http://127.0.0.1:7657/jsonrpc/"
    end
    print("Using I2P Control API at " .. i2pcontrol)
    return i2pcontrol
end

--[[
    findpassword: finds the I2P Control API password
    returns: the password
    uses the value of the I2P_CONTROL_PASSWORD environment variable if set
    otherwise defaults to "itoopie"
]]--
function findpassword()
    i2pcontrol_password = os.getenv("I2P_CONTROL_PASSWORD")
    if i2pcontrol == nil then
        return "itoopie"
    end
    return i2pcontrol_password
end

--[[
    auth: authenticates with the I2P Control API
    returns: the authentication result
    uses the findserver() and findpassword() functions to get the server and password
]]--
function auth()
    result, error = json.rpc.call(findserver(),'Authenticate', {API = 1, Password = findpassword()})
    if error ~= nil then
        print("auth error")
        return error
    end
    return result
end

--[[
    call: calls a method on the I2P Control API
    method: the method to call
    params: the parameters to pass to the method
    returns: the result of the method call
    uses the auth() function to get the authentication token
    uses the findserver() function to get the server URL
]]--
function call(method, params)
    authResult = auth()
    params.Token = authResult.Token
    if authResult ~= nil then
        return json.rpc.call(findserver(), method, params)
    end
end

--[[
    echo: echoes a message to the I2P Control API
    msg: the message to echo
    returns: the result of the echo
    uses the call() function to call the Echo method
]]--
function echo(msg)
    result, error = call("Echo", {Echo = msg})
    if error ~= nil then
        print("echo error")
        return error
    end
    return result.Result 
end

--[[
    conky_getrate: gets the rate of a statistic from the I2P Control API
    stat: the statistic to get the rate of
    period: the period to get the rate over (default 300000)
    returns: the rate of the statistic
    uses the call() function to call the GetRate method
    if period is not a number, it is converted to a number
    if period is less than 60000, it is set to 60000
    if period is nil, it is set to 300000
    if the result is nil, it returns an error
]]--
function conky_getrate(stat, period)
    if period == nil then
        period = 300000
    end
    if type(period) == "string" then
        period = tonumber(period)
    end
    if period < 60000 then
        period = 60000
    end
    result, error = call("GetRate", {Stat = stat, Period = period})
    if error ~= nil then
        print("getrate error")
        return error
    end
    return result.Result
end

--[[
    getrate: alias for conky_getrate
]]--
function getrate(stat, period)
    return conky_getrate(stat, period)
end

--[[
    conky_getrate_number: gets the rate of a statistic from the I2P Control API
    stat: the statistic to get the rate of
    period: the period to get the rate over (default 300000)
    returns: the rate of the statistic as a number
    if the result is nil, it returns 1
    uses the conky_getrate() function to get the rate
]]--
function conky_getrate_number(stat, period)
    val = conky_getrate(stat, period)
    print(stringifyTable(val))
    num = tonumber(val)
    if num == 0 then
        return 1
    end
    return num
end

--[[
    getrate_number: alias for conky_getrate_number
]]--
function getrate_number(stat, period)
    return conky_getrate_number(stat, period)
end

--[[
    conky_sendBps: gets the send bandwidth in bytes per second
    returns: the send bandwidth in bytes per second
    uses the conky_getrate_number() function to get the rate
]]--
function conky_sendBps()
    return conky_getrate_number("bw.sendBps", 300000)
end

--[[
    sendKbps: alias for conky_sendBps
]]--
function sendKbps()
    return conky_sendBps()
end

--[[
    conky_receiveBps: gets the receive bandwidth in bytes per second
    returns: the receive bandwidth in bytes per second
    uses the conky_getrate_number() function to get the rate
]]--
function conky_receiveBps()
    return conky_getrate_number("bw.receiveBps", 300000)
end

--[[
    receiveKbps: alias for conky_receiveBps
]]--
function receiveKbps()
    return conky_receiveBps()
end

--[[
    conky_sendKbps: gets the send bandwidth in kilobytes per second
    returns: the send bandwidth in kilobytes per second
    uses the conky_getrate_number() function to get the rate
]]--
function conky_exploratoryBuildExpire()
    return conky_getrate_number("tunnel.buildExploratoryExpire", 600000)
end

--[[
    exploratoryBuildExpire: alias for conky_exploratoryBuildExpire
]]--
function exploratoryBuildExpire()
    return conky_exploratoryBuildExpire()
end

--[[
    conky_receiveKbps: gets the receive bandwidth in kilobytes per second
    returns: the receive bandwidth in kilobytes per second
    uses the conky_getrate_number() function to get the rate
]]--
function conky_exploratoryBuildReject()
    return conky_getrate_number("tunnel.buildExploratoryReject", 600000)
end

--[[
    exploratoryBuildReject: alias for conky_exploratoryBuildReject
]]--
function exploratoryBuildReject()
    return conky_exploratoryBuildReject()
end

--[[
    conky_exploratoryBuildSuccess: gets the exploratory build success rate
    returns: the exploratory build success rate
    uses the conky_getrate_number() function to get the rate
]]--
function conky_exploratoryBuildSuccess()
    return conky_getrate_number("tunnel.buildExploratorySuccess", 600000)
end

--[[
    exploratoryBuildSuccess: alias for conky_exploratoryBuildSuccess
]]--
function exploratoryBuildSuccess()
    return conky_exploratoryBuildSuccess()
end

--[[
    conky_exploratoryTotal: gets the total exploratory builds
    returns: the total exploratory builds
    uses the conky_getrate_number() function to get the rate
    if the result is nil, it returns 1
    if the result is not a number, it returns 1
]]--
function exploratoryTotal()
    success = conky_getrate_number("tunnel.buildExploratorySuccess", 600000)
    if type(success) ~= "number" then
        success = 1
    end
    reject = conky_getrate_number("tunnel.buildExploratoryReject", 600000)
    if type(reject) ~= "number" then
        success = 1
    end
    expire = conky_getrate_number("tunnel.buildExploratoryExpire", 600000)
    if type(expire) ~= "number" then
        success = 1
    end
    total = success + reject + expire
    return total
end

--[[
    conky_exploratoryBuildSuccessPercentage: gets the exploratory build success percentage
    returns: the exploratory build success percentage
    uses the conky_getrate_number() function to get the rate
    if the result is nil, it returns 0
    if the result is not a number, it returns 0
]]--
function conky_exploratoryBuildSuccessPercentage()
    success = conky_getrate_number("tunnel.buildExploratorySuccess", 600000)
    total = exploratoryTotal()
    return (success / total) * 100
end

--[[
    conky_exploratoryBuildRejectPercentage: gets the exploratory build reject percentage
    returns: the exploratory build reject percentage
    uses the conky_getrate_number() function to get the rate
    if the result is nil, it returns 0
    if the result is not a number, it returns 0
]]--
function conky_exploratoryBuildRejectPercentage()
    reject = conky_getrate_number("tunnel.buildExploratoryReject", 600000)
    total = exploratoryTotal()
    return (reject / total) * 100
end

--[[
    conky_exploratoryBuildExpirePercentage: gets the exploratory build expire percentage
    returns: the exploratory build expire percentage
    uses the conky_getrate_number() function to get the rate
    if the result is nil, it returns 0
    if the result is not a number, it returns 0
]]--
function conky_exploratoryBuildExpirePercentage()
    expire = conky_getrate_number("tunnel.buildExploratoryExpire", 600000)
    total = exploratoryTotal()
    return (expire / total) * 100
end

--[[
    conky_routerinfo: gets the router information
    info: the information to get
    returns: the router information
    if info is nil, it returns all the information
    if info is not nil, it returns the information
    uses the call() function to call the RouterInfo method
    if the result is nil, it returns an error
]]--
function conky_routerinfo(info)
    params = {}
    if info ~= nil then
        params[info] = ""
    else
        params["i2p.router.status"] = ""
        params["i2p.router.uptime"] = ""
        params["i2p.router.version"] = ""
        params["i2p.router.net.bw.inbound.1s"] = ""
        params["i2p.router.net.bw.inbound.15s"] = ""
        params["i2p.router.net.bw.outbound.1s"] = ""
        params["i2p.router.net.bw.outbound.15s"] = ""
        params["i2p.router.net.status"] = ""
        params["i2p.router.net.tunnels.participating"] = ""
        params["i2p.router.netdb.activepeers"] = ""
        params["i2p.router.netdb.fastpeers"] = ""
        params["i2p.router.netdb.highcapacitypeers"] = ""
        params["i2p.router.netdb.isreseeding"] = ""
        params["i2p.router.netdb.knownpeers"] = ""
    end
    result, error = call("RouterInfo", params)
    if error ~= nil then
        print("routerinfo error")
        return error
    end
    return stringifyTable(result)
end

--[[
    conky_networksettings: gets the network settings
    info: the information to get
    returns: the network settings
    if info is nil, it returns all the information
    if info is not nil, it returns the information
    uses the call() function to call the NetworkSetting method
    if the result is nil, it returns an error
]]--
function conky_networksettings(info)
    params = {}
    if info == nil then
        info = "i2p.router.net.ssu.detectedip"
    end
    if info ~= nil then
        params[info] = ""
    else
        params[info] = ""
    end
    result, error = call("NetworkSetting", params)
    if error ~= nil then
        print("networksettings error")
        return error
    end
    return result[info]
end

function stringifyTable(table)
    result = ""
    if type(table) == "table" then
        for k, v in pairs(table) do
            result = string.format("%s%s = %s\n", result, k, v)
        end
    end
    return result
end
