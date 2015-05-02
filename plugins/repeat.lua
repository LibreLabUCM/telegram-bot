
local function run(msg, matches)
  return matches[1]
end

return {
  description = "Simplest plugin ever!",
  usage = "!repeat [whatever]: repeats the msg",
  patterns = {
    "^(!repeat (.*))$"
  }, 
  run = run,
  hide = false
}
