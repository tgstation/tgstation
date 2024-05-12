local SS13 = require("SS13_base")
local timer = require("timer")

__SS13_signal_handlers = __SS13_signal_handlers or {}
__SS13_timeouts = __SS13_timeouts or {}
__SS13_timeouts_id_mapping = __SS13_timeouts_id_mapping or {}

SS13.SSlua = dm.global_vars.SSlua

SS13.global_proc = "some_magic_bullshit"

for _, state in SS13.SSlua.states do
	if state.internal_id == _state_id then
		SS13.state = state
		break
	end
end

function SS13.get_runner_ckey()
	return SS13.state.ckey_last_runner
end

function SS13.get_runner_client()
	return dm.global_vars.GLOB.directory[SS13.get_runner_ckey()]
end

SS13.type = dm.global_procs._text2path

function SS13.istype(thing, type)
	return dm.global_procs._istype(thing, SS13.type(type)) == 1
end

SS13.new = dm.new

function SS13.qdel(datum)
	if SS13.is_valid(datum) then
		dm.global_proc("qdel", datum)
		return true
	end
	return false
end

function SS13.is_valid(datum)
	return dm.is_valid_ref(datum) and not datum.gc_destroyed
end

function SS13.await(thing_to_call, proc_to_call, ...)
	if not SS13.istype(thing_to_call, "/datum") then
		thing_to_call = SS13.global_proc
	end
	if thing_to_call == SS13.global_proc then
		proc_to_call = "/proc/" .. proc_to_call
	end
	local promise = SS13.new("/datum/promise", thing_to_call, proc_to_call, ...)
	while promise.status == 0 do
		sleep()
	end
	return promise.return_value, promise.runtime_message
end

function SS13.wait(time)
	local callback = SS13.new("/datum/callback", SS13.SSlua, "queue_resume", SS13.state, __next_yield_index)
	local timedevent = dm.global_procs._addtimer(callback, time * 10, 8, nil, debug.info(1, "sl"))
	coroutine.yield(timedevent)
	dm.global_procs.deltimer(timedevent)
end

local function signal_handler(data, ...)
	local output = 0
	for _, func in data.functions do
		output = bit32.bor(output, func(...))
	end
	return output
end

local function create_qdeleting_callback(datum)
	local callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first")
	callback:RegisterSignal(datum, parent_qdeleting, "Invoke")
	local path = {
		"__SS13_signal_handlers",
		dm.global_procs.WEAKREF(datum),
		"parent_qdeleting",
		"handler",
	}
	callback.arguments = { path }
	__SS13_signal_handlers[datum]["parent_qdeleting"] = {
		callback = callback,
		functions = {},
		handler = function(source, ...)
			local result = signal_handler(handler_data, source, ...)
			for signal, signal_data in __SS13_signal_handlers[source] do
				signal_data.callback:UnregisterSignal(source, signal)
			end
			__SS13_signal_handlers[source] = nil
			return result
		end,
	}
end

function SS13.register_signal(datum, signal, func)
	if not SS13.istype(datum, "/datum") then
		return
	end
	if not SS13.is_valid(datum) then
		error("Tried to register a signal on a deleted datum", 2)
	end
	if not __SS13_signal_handlers[datum] then
		__SS13_signal_handlers[datum] = {}
		create_qdeleting_callback(datum)
	end
	local handler_data = __SS13_signal_handlers[datum][signal]
	if not handler_data then
		handler_data = { callback = nil, functions = {} }
		local callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first")
		callback:RegisterSignal(datum, signal, "Invoke")
		local path = {
			"__SS13_signal_handlers",
			dm.global_procs.WEAKREF(datum),
			signal,
			"handler",
		}
		callback.arguments = { path }
		handler_data.callback = callback
		handler_data.handler = function(...)
			return signal_handler(handler_data, ...)
		end
		__SS13_signal_handlers[datum][signal] = handler_data
	end
	handler_data.functions[func] = true
end

function SS13.unregister_signal(datum, signal, func)
	if not __SS13_signal_handlers[datum] then
		return
	end
	local handler_data = __SS13_signal_handlers[datum][signal]
	if not handler_data then
		return
	end
	handler_data.functions[func] = nil
	if not (#handler_data.functions or (signal == "parent_qdeleting")) then
		handler_data.callback:UnregisterSignal(datum, signal)
		__SS13_signal_handlers[datum][signal] = nil
	end
end

function SS13.set_timeout(time, func)
	SS13.start_loop(time, 1, func)
end

function SS13.start_loop(time, amount, func)
	if not amount or amount == 0 then
		return
	end
	local callback = SS13.new("/datum/callback", SS13.state, "call_function")
	local timedevent = dm.global_procs._addtimer(callback, time * 10, 40, nil, debug.info(1, "sl"))
	local doneAmount = 0
	__SS13_timeouts[callback] = function()
		doneAmount += 1
		if amount ~= -1 and doneAmount >= amount then
			SS13.end_loop(timedevent)
		end
		func()
	end
	local loop_data = {
		callback = callback,
		loop_amount = amount,
	}
	__SS13_timeouts_id_mapping[timedevent] = loop_data
	local path = { "__SS13_timeouts", dm.global_procs.WEAKREF(callback) }
	callback.arguments = { path }
	return timedevent
end

function SS13.end_loop(id)
	local data = __SS13_timeouts_id_mapping[id]
	if data then
		__SS13_timeouts_id_mapping[id] = nil
		__SS13_timeouts[data.callback] = nil
		dm.global_procs.deltimer(id)
	end
end

function SS13.stop_all_loops()
	for id, data in __SS13_timeouts_id_mapping do
		if data.amount ~= 1 then
			SS13.end_loop(id)
		end
	end
end

SS13.wait = timer.wait
SS13.set_timeout = timer.set_timeout
SS13.start_loop = timer.start_loop
SS13.end_loop = timer.end_loop
SS13.stop_all_loops = timer.stop_all_loops

return SS13
