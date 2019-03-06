local ipfsAddProxy = "/ipfsaddproxy/add"
local ipfsCatProxy = "/ipfscatproxy/cat"
local ipfsPinAddProxy = "/ipfscatproxy/pin/add"
local ipfsPinRmProxy = "/ipfscatproxy/pin/rm"
local paymentProxy = "/paymentProxy/hash/add"
local proxyUrl = "/parityproxy"
local cjson = require "cjson"

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function checkAndExtractAuthHeaders(authHeader)
    local neededAuthValues = 3
    local checkedAuthValues = 0
    local checkAuthValues = {'EvanAuth', 'EvanMessage', 'EvanSignedMessage'}
    for i, authValue in ipairs(authHeader) do
        authValue = trim(authValue)
        local divider = authValue:find(' ')
        if has_value(checkAuthValues, authValue:sub(0, divider-1)) then
           checkedAuthValues = checkedAuthValues + 1
           checkAuthValues[authValue:sub(0, divider-1)] = authValue:sub(divider+1)
        end
    end
    return checkAuthValues
end

function addFileMetaIpfsFile(hash, accountId, check)
    local RANDOM_BOUNDARY = string.sub(tostring({}), 10)
    ngx.req.set_header("Content-Type", "multipart/form-data; boundary=--------------------------" .. RANDOM_BOUNDARY)
    local postData = '----------------------------' .. RANDOM_BOUNDARY .. '\nContent-Disposition: file; filename="ipfsMetaFile"\nContent-Type: application/json\n\n{"hash":"' .. hash .. '", "accountId":"' .. accountId .. '"}\n----------------------------' .. RANDOM_BOUNDARY .. '--'
    local ipfsMeta = nil
    if check then
        ipfsMeta = ngx.location.capture( ipfsAddProxy .. '?only-hash=true&pin=false',  { method = ngx.HTTP_POST, body = postData})
    else
        ipfsMeta = ngx.location.capture( ipfsAddProxy .. '?pin=false',  { method = ngx.HTTP_POST, body = postData})
    end
    local parsedBody = cjson.decode(ipfsMeta.body)
    return parsedBody

end

function getIpfsFile(hash)
    ipfsMeta = ngx.location.capture( ipfsCatProxy .. '?arg=' .. hash .. '&length=0')
    if ipfsMeta.status == 200 then
        return true
    else
        return false
    end
end

function addOrRemovePin(hash, type)
    local response = nil

    paymentResponse = ngx.location.capture( paymentProxy .. '?hash=' .. hash .. '&type=' .. type)
    local parsedPaymentResponse = cjson.decode(paymentResponse.body)
    if parsedPaymentResponse.status == "error" then
        ngx.status = ngx.HTTP_NOT_ALLOWED
        ngx.say(parsedPaymentResponse.error)
        -- to cause quit the whole request rather than the current phase handler
        ngx.exit(ngx.HTTP_NOT_ALLOWED)
    end
    if type == "add" then
        response = ngx.location.capture( ipfsPinAddProxy .. '?arg=' .. hash)
    elseif type == "rm" then
        response = ngx.location.capture( ipfsPinRmProxy .. '?arg=' .. hash)
    end
    return response
end


function recoverMessage(values)
    local postBody = "{\"method\":\"personal_ecRecover\",\"params\":[\"" .. values["EvanMessage"] .. "\",\"" .. values["EvanSignedMessage"] .."\"],\"id\":1,\"jsonrpc\":\"2.0\"}"
    local res = ngx.location.capture( proxyUrl,  { method = ngx.HTTP_POST, body = postBody })
    local parsedBody = cjson.decode(res.body)
    return parsedBody
end

-- read the body initally
ngx.req.read_body()

local authHeader = ngx.req.get_headers()["Authorization"]
-- check 3 authHeaders
if authHeader then
    authHeader = split(authHeader, ",")
    local authValues = checkAndExtractAuthHeaders(authHeader)
    local recoveredAddress = recoverMessage(authValues)
    if recoveredAddress.result then
        if ngx.var.request_type == "pin" then
            local args = ngx.req.get_uri_args()
            local fileHash = addFileMetaIpfsFile(args.arg, recoveredAddress.result, true)
            local fileAvailable = getIpfsFile(fileHash.Hash)
            if fileAvailable then
                local pinResponse = addOrRemovePin(args.arg, ngx.var.pin_type)
                for k,v in pairs(pinResponse.header) do
                    ngx.header[k] = v
                end
                ngx.header["Access-Control-Allow-Origin"] = "*"
                ngx.say(pinResponse.body)
            else
                ngx.status = ngx.HTTP_NOT_ALLOWED
            end
        elseif ngx.var.request_type == "add" then
            local ipfsRes = ngx.location.capture( ipfsAddProxy,  { method = ngx.HTTP_POST, body = ngx.req.get_body_data() })
            for line in ipfsRes.body:gmatch("[^\r\n]+") do
                local parsedIpfsRes = cjson.decode(line)
                addFileMetaIpfsFile(parsedIpfsRes.Hash, recoveredAddress.result, false)
            end
            for k,v in pairs(ipfsRes.header) do
                ngx.header[k] = v
            end
            ngx.say(ipfsRes.body)
        else
        end
    else
        ngx.status = ngx.HTTP_NOT_ALLOWED
    end
else
    ngx.status = ngx.HTTP_NOT_ALLOWED
end