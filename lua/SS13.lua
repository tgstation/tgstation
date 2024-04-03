local SS13 = require("SS13_base")
local timer = require("timer")

SS13.wait = timer.wait
SS13.set_timeout = timer.set_timeout
SS13.start_loop = timer.start_loop
SS13.end_loop = timer.end_loop
SS13.stop_all_loops = timer.stop_all_loops

return SS13
