#!/usr/bin/luvit

local http = require("http")
local url = require("url")

local function multiples(t,suffix,prefix,min)
  t,suffix,prefix=math.floor(t),suffix or "", prefix or ""
  if t<(min or 0) then return "" end
  if t==0 then return "" end
  if t==1 then return prefix.."1 "..suffix end
  return string.format("%s%i %ss",prefix,t,suffix)
end

local function getCaffeine(obj) -- returns human readable advice as a string
  local inp,hours = obj.amount, obj.time or 10
  local reached = false
  local active = obj.previous and tonumber(obj.previous) or 0
  if obj.previous and obj.threshold and active<tonumber(obj.threshold) then
    return "It's time for coffee!"
  end
  local dt, hlin, hlout = 0.1, 0.75, 3
  for t=0,hours,dt do
    active = active + inp * (dt / hlin)
    inp = inp - inp * (dt / hlin)
    active = active - active * (dt / hlout)
    if reached and not obj.time and obj.threshold and active<tonumber(obj.threshold) then
      return string.format("Next coffee break in%s%s.",multiples(t,"hour"," ",1),multiples(t%1*60,"minute",t>1 and " and " or " "))
    elseif not obj.time and obj.threshold and active>tonumber(obj.threshold) then
      reached = true
    end
  end
  return "You don't need a coffee break."  --string.format("%.0fmg active at %.0f minutes", active, hours*60)
end

http.createServer(function(req, res)
  local obj = url.parse(req.url,true).query
  local ok, out = pcall(getCaffeine,obj)
  if ok then
    res:finish(out)
    return
  else
    print("Error:", out)
  end
  res.statusCode = 400
  res:finish("Bad Request")
end):listen(8080)
