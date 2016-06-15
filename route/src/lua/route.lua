local cjson = require "cjson"
local http = require "http"
local conf = require "conf"
local ngx = require "ngx"

local ngxlog = ngx.log
local echo = ngx.print

local route_map = conf.route_map

local function send_req(addrs, method, uri, headers, args, body)
    local opt = {
        method = method,
        path = uri,
        args = args,
        body = body,
        headers = headers,
        version = 1
    }

    for _, addr in ipairs(addrs) do
        local req = {
            addr = addr,
            opt = opt
        }
       
        local res, err = http.req(req); 
        if res then
            if res.status ~= 502 and res.status ~= 504 then
                return res;
            else
                ngxlog(ngx.ERR, "[", addr.host, ":", addr.port, uri, "] return 502|504 status code: ", body);
            end
        else
            ngxlog(ngx.ERR, "[", addr.host, ":", addr.port, uri, "] request error: ", err);
        end
    end

    return {headers = {}, status=503};
end

local function get_vm_data(addrs, uri, headers, args)
    local method = ngx.var.request_method;
    local body;
    if method == "POST" then
        body = ngx.req.get_body_data(); 
    end

    local res = send_req(addrs, method, uri, headers, args, body);
    if res.status == 301 or res.status == 302 then
        for k, v in pairs(res.headers or {}) do
            ngx.header[k] = v;
        end
        return ngx.exit(res.status);
    end

    if res.status ~= 200 then
        ngxlog(ngx.ERR, "get vm data fail!!!: ", res.body);
        return ngx.exit(res.status);
    end

    if not res.body then
        ngxlog(ngx.ERR, "get body fail!!!");
        return ngx.exit(ngx.HTTP_INTERNAL_ERROR);
    end

    return res.body;
end

local _M = {}

function _M.route()
    local uri = ngx.var.uri;
    local host = ngx.var.server_name .. ":" .. ngx.var.server_port;
    local server = route_map[host];
    if not server then
        return ngx.exit(ngx.HTTP_NOT_FOUND);
    end

    local need_data = server.page[uri];
    if need_data == nil then
        return ngx.exit(ngx.HTTP_NOT_FOUND);
    end

    if need_data then
        local vm = server.server_prefix .. uri;
        local req_headers = ngx.req.get_headers();
        local args = ngx.req.get_uri_args();

	    local headers = {
            ['Accept-Encoding'] = '',
            ['Cookie'] = req_headers.Cookie,
            ['Host'] = host
        }
        ngx.req.read_body();
        body = get_vm_data(server.server_addrs, vm, headers, args);
        ngx.req.set_method(ngx.HTTP_POST);
        ngx.req.set_header("Content-Type", "application/json;charset=UTF-8");
        ngx.req.set_body_data(body);
    else
        ngx.req.set_method(ngx.HTTP_GET);
    end
end

return _M
