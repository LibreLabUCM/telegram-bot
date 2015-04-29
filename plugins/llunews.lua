do

local function get_news_llu()
  local web = "http://librelabucm.github.io/data/llunews.txt"
  local b, c, h = http.request(web)
  return b
end


local function run(msg, matches)
  return get_news_llu()
end

return {
  description = "LLU news!",
  usage = "!llunews",
  patterns = {
    "^!llunews$"
  },
  run = run
}

end
