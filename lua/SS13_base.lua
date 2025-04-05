local timer = require("timer")
local state = require("state")

local SS13 = {}

__SS13_signal_handlers = __SS13_signal_handlers or {}

SS13.SSlua = dm.global_vars.SSlua

SS13.global_proc = "some_magic_bullshit"

SS13.state = state.state

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
		dm.global_procs.qdel(datum)
		return true
	end
	return false
end

function SS13.is_valid(datum)
	return dm.is_valid_ref(datum) and not datum.gc_destroyed
end

function SS13.check_tick(high_priority)
	local tick_limit = if high_priority then 95 else dm.global_vars.Master.current_ticklimit
	if dm.world.tick_usage > tick_limit then
		sleep()
	end
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

local function signal_handler(data, ...)
	local output = 0
	for func, _ in data.functions do
		local result = func(...)
		if type(result) == "number" then
			output = bit32.bor(output, math.floor(result))
		end
	end
	return output
end

local function create_qdeleting_callback(datum)
	local callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first")
	callback:RegisterSignal(datum, "parent_qdeleting", "Invoke")
	local path = {
		"__SS13_signal_handlers",
		dm.global_procs.WEAKREF(datum),
		"parent_qdeleting",
		"handler",
	}
	callback.arguments = { path }
	local handler_data = { callback = callback, functions = {} }
	handler_data.handler = function(source, ...)
		local result = signal_handler(handler_data, source, ...)
		for signal, signal_data in __SS13_signal_handlers[source] do
			signal_data.callback:UnregisterSignal(source, signal)
		end
		__SS13_signal_handlers[source] = nil
		return result
	end
	__SS13_signal_handlers[datum]["parent_qdeleting"] = handler_data
end

function SS13.register_signal(datum, signal, func)
	if not type(func) == "function" then
		return
	end
	if not SS13.istype(datum, "/datum") then
		return
	end
	if not SS13.is_valid(datum) then
		error("Tried to register a signal on a deleted datum", 2)
	end
	if not __SS13_signal_handlers[datum] then
		__SS13_signal_handlers[datum] = {}
		-- Turfs don't remove their signals on deletion.
		if not SS13.istype(datum, "/turf") then
			create_qdeleting_callback(datum)
		end
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
	return true
end

function SS13.unregister_signal(datum, signal, func)
	if not (func == nil or type(func) == "function") then
		return
	end
	if not __SS13_signal_handlers[datum] then
		return
	end
	local handler_data = __SS13_signal_handlers[datum][signal]
	if not handler_data then
		return
	end
	if func == nil then
		if signal == "parent_qdeleting" then
			handler_data.functions = {}
		else
			handler_data.callback:UnregisterSignal(datum, signal)
			__SS13_signal_handlers[datum][signal] = nil
		end
	else
		handler_data.functions[func] = nil
		if not (#handler_data.functions or (signal == "parent_qdeleting")) then
			handler_data.callback:UnregisterSignal(datum, signal)
			__SS13_signal_handlers[datum][signal] = nil
		end
	end
end

return SS13
