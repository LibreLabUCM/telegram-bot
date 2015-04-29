local function run(msg, matches)
  return "fdi*"
end

return {
  description = "fda -> fdi",
  usage = "Prints fdi* when someone writes fda.",
  patterns = {
    "(.*)fda(.*)"
  },
  run = run
}