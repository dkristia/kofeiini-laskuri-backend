#!/usr/bin/luvit

local http = require("http")
local url = require("url")
local json = require("json")

local function getCaffeine(obj) -- returns human readable advice as a string
  local inp, hours = obj.amount, obj.time or 10
  local reached = false
  local active = obj.previous and tonumber(obj.previous) or 0
  local plot = {}
  local dt, hlin, hlout = 0.1, 0.75, 3
  for t = 0, hours, dt do
    active = active + inp * (dt / hlin)
    inp = inp - inp * (dt / hlin)
    active = active - active * (dt / hlout)
    table.insert(plot, {active=active, time=t})
  end
  return json.encode(plot)   -- string.format("%.0fmg active at %.0f minutes", active, hours*60)
end

http.createServer(function(req, res)
  local obj = url.parse(req.url, true).query
  local ok, out = pcall(getCaffeine, obj)
  if ok then
    res:finish(out)
    return
  else
    print("Error:", out)
  end
  res.statusCode = 400
  res:finish("Bad Request")
end):listen(1886)
