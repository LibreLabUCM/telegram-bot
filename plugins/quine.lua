
local function run(msg, matches)
  if not is_sudo(msg) then
    return "You aren't allowed to send tweets"
  end
  return "Plugin deactivated for obvious reasons -.-"
  --return matches[1]
end

return {
  description = "Simplest plugin ever!",
  usage = "!quine",
  patterns = {
    "^(!quine)$",
    "^(!quine .*)$"
  }, 
  run = run,
  hide = false
}
