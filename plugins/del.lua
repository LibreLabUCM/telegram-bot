local function get_variables_hash(msg)
  if msg.to.type == 'chat' then
    return 'chat:'..msg.to.id..':variables'
  end
  if msg.to.type == 'user' then
    return 'user:'..msg.from.id..':variables'
  end
end 

local function del_value(msg, var_name)
  local hash = get_variables_hash(msg)
  if hash then
    local value = redis:hget(hash, var_name)
    if not value then
      return var_name .. ' not found, use "!get" to list variables'
    else
      if redis:hdel(hash, var_name) then
        return var_name .. ' removed!'
      else
        return 'There was an error trying to delete '..var_name
      end
    end
  end
end

local function run(msg, matches)
  local text = del_value(msg, matches[1])
  return text
end

return {
  description = "Delete variables saved with !set", 
  usage = "!del (value_name): Delete value_name entry.",
  patterns = {
    "^!del (.+)$"
  },
  run = run
}
