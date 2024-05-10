local graph = require("graph")

local plot = graph.plot()

local inp, hours, active = ... -- in and presently absorbed in milligrams
active = active or 0

active_graph,inactive_graph = graph.path(0,0), graph.path(0,0)

local dt, hlin, hlout = 0.1, 0.75, 3 -- time step, half life in and half life out
for t=0,hours,dt do
  active = active + inp * (dt / hlin)
  inp = inp - inp * (dt / hlin)
  active = active - active * (dt / hlout)
  --print(string.format("Time %.0f minutes. Inactive %.1fmg, active %.1fmg, total %.1fmg",t*60, inp, active, inp + active))
  active_graph:line_to(t, active)
  inactive_graph:line_to(t, inp)
  plot:addline(active_graph,"red")
  plot:addline(inactive_graph,"blue")
end

plot:show()
local _=io.read()
