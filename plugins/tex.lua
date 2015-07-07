do

local function run(msg, matches)
  local eq = URL.escape(matches[1])

  local url = "http://latex.codecogs.com/png.download?"
  				.."\\dpi{300}%20\\large%20"..eq

  local receiver = get_receiver(msg)
  send_photo_from_url(receiver, url)
end

return {
  description = "Convert LaTeX equation to image",
  usage = {
    "!tex [equation]: Convert LaTeX equation to image"
  },
  patterns = {
    "^!tex (.+)$"
  },
  run = run
}

end

