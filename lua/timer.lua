local SS13 = require("SS13_base")
local Timer = {}

__Timer_timers = __Timer_timers or {}
__Timer_callbacks = __Timer_callbacks or {}

function __add_internal_timer(func, time, loop)
	local timer = {
		loop = loop,
		executeTime = time + dm.world:get_var("time")
	}
	__Timer_callbacks[tostring(func)] = function()
		timer.executing = false
		if loop and timer.terminate ~= true then
			timer.executeTime = dm.world:get_var("time") + time
		else
			__stop_internal_timer(tostring(func))
		end
		func()
	end
	__Timer_timers[tostring(func)] = timer
	return tostring(func)
end

function __stop_internal_timer(func)
	local timer = __Timer_timers[func]
	if timer and not timer.executing then
		__Timer_timers[func] = nil
		__Timer_callbacks[func] = nil
	else
		timer.terminate = true
	end
end

__Timer_timer_processing = __Timer_timer_processing or false
SS13.state:set_var("timer_enabled", 1)
__Timer_timer_process = function(seconds_per_tick)
	if __Timer_timer_processing then
		return
	end
	__Timer_timer_processing = true
	local time = dm.world:get_var("time")
	for func, timeData in __Timer_timers do
		if timeData.executing == true then
			continue
		end
		if over_exec_usage(0.85) then
			sleep()
		end
		if time >= timeData.executeTime then
			SS13.state:get_var("functions_to_execute"):add(func)
			timeData.executing = true
		end
	end
	__Timer_timer_processing = false
end

function Timer.wait(time)
	local next_yield_index = __next_yield_index
	__add_internal_timer(function()
		SS13.SSlua:call_proc("queue_resume", SS13.state, next_yield_index)
	end, time * 10, false)
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
		return __add_internal_timer(func, time * 10, true)
	end
	if amount == 1 then
		return __add_internal_timer(func, time * 10, false)
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
	__add_internal_timer(newFunc, time * 10, true)
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
