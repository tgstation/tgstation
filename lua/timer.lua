local SS13 = require("SS13")
local Timer = {}

__Timer_timers = __Timer_timers or {}

function __add_internal_timer(func, time, loop)
	timer = {
		time = time,
		loop = loop,
		executeTime = time + dm.world:get_var("time")
	}
	__Timer_timers[func] = timer
	return func
end

function __stop_internal_timer(func)
	__Timer_timers[func] = nil
end

SS13.state:set_var("timer_enabled", 1)
__SS13_timer_process = function(seconds_per_tick)
	local time = dm.world:get_var("time")
	for func, timeData in __Timer_timers do
		if over_exec_usage(0.7) then
			sleep()
		end
		if time >= timeData.executeTime then
			func()
			if timeData.loop then
				timeData.executeTime = time + timeData.time
			else
				__Timers_timers[func] = nil
			end
		end
	end
end

function Timer.wait(time)
	local next_yield_index = __next_yield_index
	__add_internal_timer(function()
		dm.global_vars:get_var("SSlua"):call_proc("queue_resume", SS13.state, next_yield_index)
	end, time, false)
	coroutine.yield()
end

function Timer.set_timeout(time, func)
	Timer.start_loop(time, 1, func)
end

function Timer.start_loop(time, amount, func)
	if not amount or amount == 0 then
		return
	end
	if amount == -1 then
		return __add_internal_timer(func, amount, true)
	end
	if amount == 1 then
		return __add_internal_timer(func, amount, false)
	end
	local callback = SS13.new("/datum/callback", SS13.state, "call_function")
	local timedevent = dm.global_proc("_addtimer", callback, time * 10, 40, nil, debug.info(1, "sl"))
	local doneAmount = 0
	local newFunc = function()
		func()
		doneAmount += 1
		if doneAmount >= amount then
			Timer.end_loop(timedevent)
		end
	end
	__add_internal_timer(newFunc, time, true)
	return newFunc
end

function Timer.end_loop(id)
	__stop_internal_timer(id)
end

function Timer.stop_all_loops()
	for id, data in __Timer_timers do
		if data.loop then
			Timer.end_loop(id)
		end
	end
end

return Timer
