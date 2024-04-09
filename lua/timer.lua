local state = require("state")

local Timer = {}

local SSlua = dm.global_vars:get_var("SSlua")
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
	if timer then
		if not timer.executing then
			__Timer_timers[func] = nil
			__Timer_callbacks[func] = nil
		else
			timer.terminate = true
		end
	end
end

__Timer_timer_processing = __Timer_timer_processing or false
state.state:set_var("timer_enabled", 1)
__Timer_timer_process = function(seconds_per_tick)
	if __Timer_timer_processing then
		return 0
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
			state.state:get_var("functions_to_execute"):add(func)
			timeData.executing = true
		end
	end
	__Timer_timer_processing = false
	return 1
end

function Timer.wait(time)
	local next_yield_index = __next_yield_index
	__add_internal_timer(function()
		SSlua:call_proc("queue_resume", state.state, next_yield_index)
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
	-- Lua counts from 1 so let's keep consistent with that
	local doneAmount = 1
	local funcId
	local newFunc = function()
		func(doneAmount)
		doneAmount += 1
		if doneAmount > amount then
			Timer.end_loop(funcId)
		end
	end
	funcId = __add_internal_timer(newFunc, time * 10, true)
	return funcId
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
