local cjson = require "cjson"


local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

cjson.encode_empty_table_as_object(false);

local confs = new_tab(5, 0);
local upstream = new_tab(25, 0);

local prefix = arg[1];
for i = 2, #arg do
    local line = arg[i]
    local fd, err = io.open(prefix .. "/conf/route/" .. line, "r");
    if not fd then
        error("open config file error: " .. err);
    end

    local json = fd:read("*a");
    fd:close();
    local ok, t = pcall(cjson.decode, json);
    if not ok then
        error("invalid route config[" .. line .. "]: " .. t);
    end

    if not t.server_name then
        error("no server name config");
    end

    if not t.server_port then
	    t.server_port = 8000;
    end

    if not t.server_prefix then
        error("no server prefix config");
    end

    if not t.server_addrs then
        error("no server addrs config");
    end

    if not t.fis_addrs then
        error("no fis addrs config");
    end

    if not t.index_page then
        t.index_page = "/page/index";
    end

    if not t.error_page then
        t.error_page = "/static/error.html";
    end

    local fis_upstream_addr = "fis." .. t.server_name .. "_" .. t.server_port;
    upstream[#upstream + 1] = "upstream " .. fis_upstream_addr .. " {";
    for _, addr in ipairs(t.fis_addrs) do
        upstream[#upstream + 1] = "    server " .. addr .. ";";
    end
    upstream[#upstream + 1] = "    keepalive " .. #t.fis_addrs * 10 .. ";";
    upstream[#upstream + 1] = "}\n";

    local upstream_addr = "backend." .. t.server_name .. "_" .. t.server_port;
    upstream[#upstream + 1] = "upstream " .. upstream_addr .. " {";
    upstream[#upstream + 1] = "    ip_hash;";
    for _, addr in ipairs(t.server_addrs) do
        upstream[#upstream + 1] = "    server " .. addr .. ";";
    end
    upstream[#upstream + 1] = "    keepalive " .. #t.server_addrs * 10 .. ";";
    upstream[#upstream + 1] = "}\n";

    local conf = new_tab(48, 0);
    conf[#conf + 1] = "location ^~ /page/ {";
    conf[#conf + 1] = "        access_by_lua \'";
    conf[#conf + 1] = "            local route = require \"route\"";
    conf[#conf + 1] = "            route.route()";
    conf[#conf + 1] = "        \';\n";
    conf[#conf + 1] = "        add_header \"Cache-Control\" \"no-cache, no-store, must-revalidate\";";
    conf[#conf + 1] = "        proxy_pass http://%s%s/page/;"; 
    conf[#conf + 1] = "        error_page 400 403 404 500 502 503 504 %s;";
    conf[#conf + 1] = "    }\n";
    conf[#conf + 1] = "    location %s/intra/ {";
    for _, ip in ipairs(t.intra_allow_ips or {}) do
        conf[#conf + 1] = "        allow " .. ip .. ";";
    end
    conf[#conf + 1] = "        deny all;";
    conf[#conf + 1] = "        proxy_pass http://%s%s/intra/;";
    conf[#conf + 1] = "    }\n";
    conf[#conf + 1] = "    location %s/ {";
    conf[#conf + 1] = "        proxy_pass http://%s%s/;";
    conf[#conf + 1] = "    }\n";
    conf[#conf + 1] = "    location ~* \\.(css|html|js|xml|htm|jpg|gif|jpeg|png|mp3|mp4|svg|ttf|woff|eot|woff2) {";
    conf[#conf + 1] = "        access_log off;";
    conf[#conf + 1] = "        root %s;";
    conf[#conf + 1] = "        charset utf-8;";
    conf[#conf + 1] = "    }\n";
    conf[#conf + 1] = "    location =/ {";
    conf[#conf + 1] = "        access_log off;";
    conf[#conf + 1] = "        rewrite ^(.*)$ %s last;";
    conf[#conf + 1] = "    }\n";
    conf[#conf + 1] = "    location / {";
    conf[#conf + 1] = "        access_log off;";
    conf[#conf + 1] = "        return 403;";
    conf[#conf + 1] = "        error_page 403 %s;";
    conf[#conf + 1] = "    }";

    local conf_str = table.concat(conf, "\n");
    conf_str = string.format(conf_str, fis_upstream_addr, t.server_prefix, t.error_page, t.server_prefix, upstream_addr, t.server_prefix, t.server_prefix, upstream_addr, t.server_prefix, t.resource_path, t.index_page, t.error_page);

    local str = "";
    if not t.https_only then
        local http_conf = new_tab(8, 0);
        http_conf[#http_conf + 1] = "server {";
        http_conf[#http_conf + 1] = "    listen %s;";
        http_conf[#http_conf + 1] = "    server_name %s;\n";
        http_conf[#http_conf + 1] = "    " .. (t.conf_predefine or "");
        http_conf[#http_conf + 1] = "    " .. conf_str;
        http_conf[#http_conf + 1] = "}";
        local http_conf_str = table.concat(http_conf, "\n");
        str = str .. string.format(http_conf_str, t.server_port, t.server_name);
    else
        local http_conf = new_tab(15, 0);
        http_conf[#http_conf + 1] = "server {";
        http_conf[#http_conf + 1] = "    listen %s;";
        http_conf[#http_conf + 1] = "    server_name %s;\n";
        http_conf[#http_conf + 1] = "    " .. (t.conf_predefine or "");
        http_conf[#http_conf + 1] = "    location =/ {";
    	http_conf[#http_conf + 1] = "        access_log off;";
        http_conf[#http_conf + 1] = "        return 301 https://%s;";
        http_conf[#http_conf + 1] = "    }\n";
        http_conf[#http_conf + 1] = "    location / {";
    	http_conf[#http_conf + 1] = "        access_log off;";
        http_conf[#http_conf + 1] = "        return 403;";
        http_conf[#http_conf + 1] = "        error_page 403 %s;";
        http_conf[#http_conf + 1] = "    }";
        http_conf[#http_conf + 1] = "}";
        local http_conf_str = table.concat(http_conf, "\n");
        str = str .. string.format(http_conf_str, t.server_port, t.server_name, t.server_name, t.error_page);
    end

    --https interface
    if t.https then
        t.https.port = t.https.port or 8443;
        if not t.https.certificate or not t.https.certificate_key then
            error("no https certificate config");
        end

        local https_conf = new_tab(10, 0);
        https_conf[#https_conf + 1] = "server {";
        https_conf[#https_conf + 1] = "    listen %s ssl;";
        https_conf[#https_conf + 1] = "    server_name %s;\n";
        https_conf[#https_conf + 1] = "    " .. (t.conf_predefine or "");
        https_conf[#https_conf + 1] = "    ssl_certificate %s;\n";
        https_conf[#https_conf + 1] = "    ssl_certificate_key %s;\n";
        https_conf[#https_conf + 1] = "    ssl_session_timeout 1200m;\n";
        https_conf[#https_conf + 1] = "    ssl_protocols SSLv2 SSLv3 TLSv1;\n";
        https_conf[#https_conf + 1] = "    ssl_prefer_server_ciphers on;\n";
        https_conf[#https_conf + 1] = "    " .. conf_str;
        https_conf[#https_conf + 1] = "}";

        local https_conf_str = table.concat(https_conf, "\n");
        https_conf_str = string.format(https_conf_str, t.https.port, t.server_name, t.https.certificate, t.https.certificate_key);

        str = str .. "\n\n" .. https_conf_str;
    end

    local pos = string.find(line, ".", 1, true);
    if not pos then
        pos = string.len(line);
    end

    local file = string.sub(line, 1, pos) .. "conf";
    local fd, err = io.open("conf/" .. file, "w");
    if not fd then
        error("can not open file: " .. err);
    end

    fd:write(str);
    fd:close();
    
    confs[#confs + 1] = "\n    include " .. file .. ";";
end

local cfd, err = io.open("conf/nginx.conf.default", "r+");
if not cfd then
    error("can not open file: ", err);
end
local str = cfd:read("*a");
cfd:close();

local cfd, err = io.open("conf/nginx.conf", "w");
if not cfd then
    error("can not open file: ", err);
end

cfd:write(str .. table.concat(confs, "\n") .. "\n}");
cfd:close();

local ufd, err = io.open("conf/upstream.conf", "w");
if not ufd then
    error("can not open file: ", err);
end

ufd:write(table.concat(upstream, "\n"));
ufd:close();
