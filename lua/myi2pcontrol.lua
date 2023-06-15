package.path = './lua/craigmj/json4lua/json/?.lua;' .. package.path
json = require('json')
require("rpc")
function findserver()
    i2pcontrol = os.getenv("I2P_CONTROL")
    if i2pcontrol == nil then
--        print("*** Local JsonRPC")
        return "http://127.0.0.1:7657/jsonrpc/"
    end
--    print("** Using I2P Control API at " .. i2pcontrol)
    return i2pcontrol
end

function findpassword()
    i2pcontrol_password = os.getenv("I2P_CONTROL_PASSWORD")
    if i2pcontrol_password == nil then
        i2pcontrol_password = "itoopie"
    end
    return i2pcontrol_password
end

function auth()
    result, error = json.rpc.call(findserver(),'Authenticate', {API = 1, Password = findpassword()})
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
        print("***getrate error ", stat, period)
        return error
    end
    return result.Result
end

function conky_getrate_number(stat, period)
    val = conky_getrate(stat, period)
    print(stringifyTable(val))
    num = tonumber(val)
    print("getrate " .. stat .. ":" ..  num)
    if type(num) ~= "number" then
        num = 0
    end
    return num
end

function conky_sendBps()
--    return conky_getrate_number("bw.sendBps", 300000)
    return conky_getrate_number("bw.sendRate", 300000)
end

function conky_receiveBps()
--    return conky_getrate_number("bw.receiveBPS", 300000)
    return conky_getrate_number("bw.recvRate", 300000)
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


function conky_clientBuildExpire()
    return conky_getrate_number("tunnel.buildClientExpire", 600000)
end   

function conky_clientBuildReject()
    return conky_getrate_number("tunnel.buildClientReject", 600000)
end   

function conky_clientBuildSuccess()
    return conky_getrate_number("tunnel.buildClientSuccess", 600000)
end


function exploratoryTotal()
    success = conky_getrate_number("tunnel.buildExploratorySuccess", 600000)
    reject = conky_getrate_number("tunnel.buildExploratoryReject", 600000)
    expire = conky_getrate_number("tunnel.buildExploratoryExpire", 600000)
    return success + reject + expire
end

function clientTotal() 
    csuccess = conky_getrate_number("tunnel.buildClientSuccess", 600000)
    creject = conky_getrate_number("tunnel.buildClientReject", 600000)          
    cexpire = conky_getrate_number("tunnel.buildClientExpire", 600000)
    return csuccess + creject + cexpire
end

function conky_exploratoryBuildSuccessPercentage()
    success = conky_getrate_number("tunnel.buildExploratorySuccess", 600000)
    total = exploratoryTotal()
    percent = 0
    if total ~= 0 then
        percent = ( success / total ) * 100
    end
    return percent
end

function conky_clientBuildSuccessPercentage()
    csuccess = conky_getrate_number("tunnel.buildClientSuccess", 600000) 
    total = clientTotal()
    percent = 0
    if total ~= 0 then
        percent = (csuccess / total) * 100
    end
    return percent
end

function conky_ComboBuildSuccessPercentage()
    -- *** Test if router version string contains "+"
    if conky_isplus() == true then 
        percent = conky_getrate_number("tunnel.tunnelBuildSuccessAvg", 600000)
--        print("I2P+ detected")
    else
        success = conky_getrate_number("tunnel.buildExploratorySuccess", 600000)
        csuccess = conky_getrate_number("tunnel.buildClientSuccess", 600000)
        total = exploratoryTotal() + clientTotal()
        percent = 0
        if total ~= 0 then
            if type(total) == "number" then
                percent = ( ( success + csuccess ) / total ) * 100
            end
        end
    end
    return percent
end
    
function conky_exploratoryBuildRejectPercentage()
    reject = conky_getrate_number("tunnel.buildExploratoryReject", 600000)
    total = exploratoryTotal()
    percent = 0
    if total ~= 0 then
        percent = reject / total * 100
    end
    return percent
end

function conky_exploratoryBuildExpirePercentage()
    expire = conky_getrate_number("tunnel.buildExploratoryExpire", 600000)
    total = exploratoryTotal()
    percent = 0
    if total ~= 0 then
        percent = expire / total * 100
    end
    return percent
end


function conky_routerinfo(info)
    params = {}
    if info ~= nil then
        params[info] = ""
    else
        params["i2p.router.status"] = ""
--        params["i2p.router.uptime"] = ""
--        params["i2p.router.version"] = ""
--        params["i2p.router.net.bw.inbound.1s"] = ""
--        params["i2p.router.net.bw.inbound.15s"] = ""
--        params["i2p.router.net.bw.outbound.1s"] = ""
--        params["i2p.router.net.bw.outbound.15s"] = ""
--        params["i2p.router.net.status"] = ""
        params["i2p.router.net.tunnels.participating"] = ""
        params["i2p.router.netdb.activepeers"] = ""
--        params["i2p.router.netdb.fastpeers"] = ""
--        params["i2p.router.netdb.highcapacitypeers"] = ""
--        params["i2p.router.netdb.isreseeding"] = ""
        params["i2p.router.netdb.knownpeers"] = ""
--no        params["i2p.router.net.bw.in"] = ""
--no        params["i2p.router.net.bw.out"] = ""
--no        params["i2p.router.integratedPeers"] = ""
    end
    result, error = call("RouterInfo", params)
    if error ~= nil then
        print("routerinfo error")
        return error
    end
    return stringifyTable(result)
end

function conky_isplus()
    vers = conky_routerinfo("i2p.router.version")
    plus = (string.match(vers, "+") == "+")
--    print(plus)
--    print(vers)
    return plus
end

function conky_networksettings(info)
    params = {}
    if info == nil then
        info = "i2p.router.net.ssu.detectedip"
--no        info = "i2p.router.net.bw.in"
    end
--    if info ~= nil then
        params[info] = ""
--    else
--        params[info] = ""
--    end
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

function conky_EBSP()
    num = conky_exploratoryBuildSuccessPercentage()
    result = math.floor(num)
    return result
end  

function conky_ClientBSP()
    num = conky_clientBuildSuccessPercentage()
    result = math.floor(num)
    return result
end

function conky_rxkb()
    num = conky_receiveBps()
    if type(num) ~= "number" then
        num = 0
    end
--    result = math.floor(num / 8 )
    result = conky_bytesToSize(num ) .. "/s"
    return result
end

function conky_txkb()
    num = conky_sendBps()
    if type(num) ~= "number" then
        num = 0
    end
--    result = math.floor(num / 8 )
    result = conky_bytesToSize(num ) .. "/s"
    
    return result
end

function conky_ComboBSP()
    num = conky_ComboBuildSuccessPercentage()
    if type(num) ~= "number" then
        num = 0
     end
     result = math.floor(num)
     return result
 end

--function conky_bwin()
--    inbw = conky_networksettings("i2p.router.net.bw.in")
--    print(inbw)
--    return inbw
--end

function conky_bytesToSize(bytes)
  kilobyte = 1024;
  megabyte = kilobyte * 1024;
  gigabyte = megabyte * 1024;
  terabyte = gigabyte * 1024;

  if((bytes >= 0) and (bytes < kilobyte)) then
    return bytes .. " bytes";
  elseif((bytes >= kilobyte) and (bytes < megabyte)) then
    return math.floor(bytes / kilobyte) .. ' KB';
  elseif((bytes >= megabyte) and (bytes < gigabyte)) then
    return math.floor(bytes / megabyte) .. ' MB';
  elseif((bytes >= gigabyte) and (bytes < terabyte)) then
    return math.floor(bytes / gigabyte) .. ' GB';
  elseif(bytes >= terabyte) then
    return math.floor(bytes / terabyte) .. ' TB';
  else
    return bytes .. ' bytes';
  end
end
