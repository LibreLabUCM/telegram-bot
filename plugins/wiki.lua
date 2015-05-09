local wiki_plugin_usage = "!wiki [terms]: Searches wiki and send results"
local _file_wiki = './data/wikiSites.lua'
local _wikiSites = load_from_file(_file_wiki)
local _defaultWikiSite = "wikipedia.org/wiki"

local function save_value(chat, searchSite)
	if _wikiSites[chat] == nil then _wikiSites[chat] = {} end
	_wikiSites[chat] = searchSite
	serialize_to_file(_wikiSites, _file_wiki)
  return "set "..searchSite.." as search site"
end

local function fetch_value(chat)
  _wikiSites = load_from_file(_file_wiki)
  if _wikiSites[chat] == nil then
    save_value(chat, _defaultWikiSite)
    _wikiSites = load_from_file(_file_wiki)
    return _defaultWikiSite
  end
  return _wikiSites[chat]
end



local function wikiSearch(searchTerm, chat)
  local api = "http://"..fetch_value(chat).."/"
  local parameters = (URL.escape(searchTerm) or "")
  local http = require("socket.http")
  local respbody = {} 
  local ltn12 = require "ltn12"
  local body, code, headers, status = http.request{
    url = api..parameters,
    method = "GET",
    --headers = headers,
    --source = ltn12.source.string(reqBody),
    redirect = true,
    sink = ltn12.sink.table(respbody)
  }
  local body = table.concat(respbody)
  if (status == nil) then return "ERROR: status = nil" end
  if code ~=200 then return "ERROR: "..code..". Status: "..status end
  --local wikiContent = string.match(body, "(<div id=\"mw-content-text\"(.*)</p>)")
  local wikiContent = string.match(body, "<p>(.-)</p>")
  if (status == nil) then return "ERROR: wikiContent = nil" end
  wikiContent = string.gsub(wikiContent, "<a.->", "")
  wikiContent = string.gsub(wikiContent, "</a>", "")
  wikiContent = string.gsub(wikiContent, "<p.->", "")
  wikiContent = string.gsub(wikiContent, "</p>", "")
  wikiContent = string.gsub(wikiContent, "<b.->", "")
  wikiContent = string.gsub(wikiContent, "</b>", "")
  wikiContent = string.gsub(wikiContent, "<i.->", "")
  wikiContent = string.gsub(wikiContent, "</i>", "")
  wikiContent = string.gsub(wikiContent, "<sup.->", "")
  wikiContent = string.gsub(wikiContent, "</sup>", "")
  wikiContent = string.gsub(wikiContent, "<span.->", "")
  wikiContent = string.gsub(wikiContent, "</span>", "")
  wikiContent = string.gsub(wikiContent, "[.-]", "")
  return wikiContent
end

local function parseText(chat, text)
  if (text == nil or text == "!wiki" or text == "!wiki get") then
    return fetch_value(chat)
  end
  
  action, value = string.match(text, "!wiki (%a+) (.+)")
  --return text
  if (action == "set") then
    if (value == nil) then
      return wiki_plugin_usage..": nil value"
    end
    return save_value(chat, value)
  end
  
  -- Search here:
  searchTerm = string.match(text, "!wiki (.*)")
	if (searchTerm == nil) then
		return wiki_plugin_usage
	end
  return wikiSearch(searchTerm, chat)
end


local function run(msg, matches)
  local chat_id = tostring(msg.to.id)
	local result = parseText(chat_id, msg.text)
	return result
end

return {
  description = "Searches Wikipedia and send results",
  usage = wiki_plugin_usage,
  patterns = {
    "^!wiki (.*)$",
    "^!wiki$"
  },
  run = run
}