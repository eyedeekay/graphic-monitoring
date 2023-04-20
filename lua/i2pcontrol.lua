package.path = './lua/craigmj/json4lua/json/?.lua;' .. package.path
json = require('json')
require("rpc")
function findserver()
    i2pcontrol = os.getenv("I2P_CONTROL")
    if i2pcontrol == nil then
        return "http://127.0.0.1:7657/jsonrpc/"
    end
    return i2pcontrol
end
function auth()
    result, error = json.rpc.call(findserver(),'Authenticate', {API = 1, Password = 'itoopie'})
    if error ~= nil then
        print("auth error")
        return error
    end
    return result
end

function call(method, params)
    authResult = auth()
    params.Token = authResult.Token
    if authResult ~= nil then
        return json.rpc.call(findserver(), method, params)
    end
end

function echo(msg)
    result, error = call("Echo", {Echo = msg})
    if error ~= nil then
        print("echo error")
        return error
    end
    return result.Result 
end

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

function conky_getrate_number(stat, period)
    val = conky_getrate(stat, period)
    print(stringifyTable(val))
    num = tonumber(val)
    if num == 0 then
        return 1
    end
    return num
end

function conky_sendBps()
    return conky_getrate_number("bw.sendBps", 300000)
end

function conky_receiveBps()
    return conky_getrate_number("bw.receiveBps", 300000)
end

function conky_exploratoryBuildExpire()
    return conky_getrate_number("tunnel.buildExploratoryExpire", 600000)
end

function conky_exploratoryBuildReject()
    return conky_getrate_number("tunnel.buildExploratoryReject", 600000)
end

function conky_exploratoryBuildSuccess()
    return conky_getrate_number("tunnel.buildExploratorySuccess", 600000)
end

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

function conky_exploratoryBuildSuccessPercentage()
    success = conky_getrate_number("tunnel.buildExploratorySuccess", 600000)
    total = exploratoryTotal()
    return (success / total) * 100
end

function conky_exploratoryBuildRejectPercentage()
    reject = conky_getrate_number("tunnel.buildExploratoryReject", 600000)
    total = exploratoryTotal()
    return (reject / total) * 100
end

function conky_exploratoryBuildExpirePercentage()
    expire = conky_getrate_number("tunnel.buildExploratoryExpire", 600000)
    total = exploratoryTotal()
    return (expire / total) * 100
end

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
