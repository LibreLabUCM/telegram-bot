-- -- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- -- licensed under the terms of the LGPL2
 
-- -- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
 
-- -- encoding
-- local function enc(data)
    -- return ((data:gsub('.', function(x) 
        -- local r,b='',x:byte()
        -- for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        -- return r;
    -- end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        -- if (#x < 6) then return '' end
        -- local c=0
        -- for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        -- return b:sub(c+1,c+1)
    -- end)..({ '', '==', '=' })[#data%3+1])
-- end
 
-- decoding
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end
----------------------------------------------



local ltn12 = require "ltn12"
local mime = require "mime"

local function mineSearch(ip, port, receiver) --25565
  local responseText = ""
  local api = "https://api.syfaro.net/server/status"
  local parameters = "?ip="..(URL.escape(ip) or "").."&port="..(URL.escape(port) or "").."&players=true&favicon=true"
  local http = require("socket.http")
  local respbody = {} 
  local body, code, headers, status = http.request{
    url = api..parameters,
    method = "GET",
    redirect = true,
    sink = ltn12.sink.table(respbody)
  }
  local body = table.concat(respbody)
  if (status == nil) then return "ERROR: status = nil" end
  if code ~=200 then return "ERROR: "..code..". Status: "..status end
  local jsonData = json:decode(body)
  responseText = responseText..ip..":"..port.." ->\n"
  if (jsonData.motd ~= nil) then
    local tempMotd = ""
    tempMotd = jsonData.motd:gsub('%§.', '')
    if (jsonData.motd ~= nil) then responseText = responseText.." Motd: "..tempMotd.."\n" end
  end
  if (jsonData.online ~= nil) then
    responseText = responseText.." Online: "..tostring(jsonData.online).."\n"
  end
  if (jsonData.players ~= nil) then
    if (jsonData.players.max ~= nil) then
      responseText = responseText.."  Max Players: "..jsonData.players.max.."\n"
    end
    if (jsonData.players.now ~= nil) then
      responseText = responseText.."  Players online: "..jsonData.players.now.."\n"
    end
    if (jsonData.players.sample ~= nil and jsonData.players.sample ~= false) then
      responseText = responseText.."  Players: "..table.concat(jsonData.players.sample, ", ").."\n"
    end
  end
  if (jsonData.favicon ~= nil and false) then
    file = io.open("/tmp/telegrambot-mineIcon.png","w")
      file:write(dec(jsonData.favicon))
    io.close(file)
    send_photo(receiver, "/tmp/telegrambot-mineIcon.png")
  end
  return responseText
end

local function parseText(chat, text)
  if (text == nil or text == "!mine") then
    return "USAGE"
  end
  ip, port = string.match(text, "^!mine (.-) (.*)$")
  if (ip ~= nil and port ~= nil) then
    return mineSearch(ip, port, chat)
  end
  local ip = string.match(text, "^!mine (.*)$")
  if (ip ~= nil) then
    return mineSearch(ip, "25565", chat)
  end
  return "ERROR: no input ip?"
end


local function run(msg, matches)
  local chat_id = tostring(msg.to.id)
	local result = parseText(chat_id, msg.text)
	return result
end

return {
  description = "Searches Minecraft server and send info",
  usage = "!mine <ip> [port]",
  patterns = {
    "^!mine (.*)$"
  },
  run = run
}