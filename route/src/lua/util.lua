local strfind = string.find
local strgmatch = string.gmatch
local strsub = string.sub
local strgsub = string.gsub
local strlen = string.len
local strbyte = string.byte
local floor = math.floor

local _M = {}

--[[ NOTE: where delim can not be one of these characters(^$()%.[]*+-?) ]]
function _M.split(str, delim, maxNb)   
    if delim == nil then delim = "," end

    if strfind(str, delim) == nil then  
        return { str };
    end

    if maxNb == nil or maxNb < 1 then  
        maxNb = 0;    -- No limit   
    end

    -- let last field happy
    local str = str .. delim;

    local result = {};
    local pat = "(.-)" .. delim;   
    local nb = 0;
    local lastPos;   
    for part in strgmatch(str, pat) do  
        nb = nb + 1;
        result[nb] = part;
        if nb == maxNb then break end  
    end  

    return result;   
end

_M.debug = false;

return _M;
