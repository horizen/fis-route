local cjson = require "cjson"
local util = require "util"
local conf = require "conf"

local function parse(addrs)
    local t = {};
    for _, addr in ipairs(addrs) do
        local ip_port = util.split(addr, ":");
        t[#t + 1] = {host = ip_port[1], port = tonumber(ip_port[2])};
    end
    
    return t;
end

cjson.encode_empty_table_as_object(false);

local prefix = ngx.config.prefix()

for line in io.lines(prefix .. "conf/route/enable") do
    if string.sub(line, 1, 1) ~= "#" then
        local pos = string.find(line, ".", 1, true);
        if not pos then
            pos = string.len(line);
        end
        local file = string.sub(line, 1, pos) .. "conf";
        local fd, err = io.open(prefix .. "conf/" .. file, "r");
        if fd then
            fd:close();

            local fd, err = io.open(prefix .. "conf/route/" .. line);
            if not fd then
                error("open config file error: " .. err);
            end

            local json = fd:read("*a");
            local ok, t = pcall(cjson.decode, json);
            if not ok then
                error("invalid route config[" .. line .. "]: " .. t);
            end

            t.server_addrs = parse(t.server_addrs);
            t.fis_addrs = parse(t.fis_addrs);

            conf.route_map[t.server_name .. ":" .. (t.server_port or 8000)] = t;
            if t.https then
                conf.route_map[t.server_name .. ":" .. (t.https.port or 8443)] = t;
            end
        end
    end
end
