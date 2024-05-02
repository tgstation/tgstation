local timer = require("timer")
local state = require("state")

local SS13 = {}

__SS13_signal_handlers = __SS13_signal_handlers or {}

SS13.SSlua = dm.global_vars.vars.SSlua

SS13.global_proc = "some_magic_bullshit"

SS13.state = state.state

function SS13.get_runner_ckey()
	return SS13.state:get_var("ckey_last_runner")
end

function SS13.get_runner_client()
	return dm.global_vars:get_var("GLOB"):get_var("directory"):get(SS13.get_runner_ckey())
end

function SS13.istype(thing, type)
	return dm.global_proc("_istype", thing, dm.global_proc("_text2path", type)) == 1
end

function SS13.start_tracking(datum)
	local references = SS13.state.vars.references
	references:add(datum)
	SS13.state:call_proc("clear_on_delete", datum)
end

function SS13.new(type, ...)
	local datum = SS13.new_untracked(type, ...)
	if datum then
		SS13.start_tracking(datum)
		return datum
	end
end

function SS13.type(string_type)
	return dm.global_proc("_text2path", string_type)
end

function SS13.qdel(datum)
	if SS13.is_valid(datum) then
		dm.global_proc("qdel", datum)
		return true
	end
	return false
end

function SS13.new_untracked(type, ...)
	return dm.global_proc("_new", type, { ... })
end

function SS13.is_valid(datum)
	if datum and not datum:is_null() and not datum:get_var("gc_destroyed") then
		return true
	end
	return false
end

function SS13.await(thing_to_call, proc_to_call, ...)
	if not SS13.istype(thing_to_call, "/datum") then
		thing_to_call = SS13.global_proc
	end
	if thing_to_call == SS13.global_proc then
		proc_to_call = "/proc/" .. proc_to_call
	end
	local promise = SS13.new("/datum/auxtools_promise", thing_to_call, proc_to_call, ...)
	local promise_vars = promise.vars
	while promise_vars.status == 0 do
		sleep()
	end
	local return_value, runtime_message = promise_vars.return_value, promise_vars.runtime_message
	SS13.stop_tracking(promise)
	return return_value, runtime_message
end

function SS13.register_signal(datum, signal, func)
	if not SS13.istype(datum, "/datum") then
		return
	end
	if not SS13.is_valid(datum) then
		error("Tried to register a signal on a deleted datum!", 2)
		return
	end
	local datumWeakRef = dm.global_proc("WEAKREF", datum)
	if not __SS13_signal_handlers[datumWeakRef] then
		__SS13_signal_handlers[datumWeakRef] = {}
	end
	if signal == "_cleanup" then
		return
	end
	if not __SS13_signal_handlers[datumWeakRef][signal] then
		__SS13_signal_handlers[datumWeakRef][signal] = {}
	end
	local callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first")
	local callbackWeakRef = dm.global_proc("WEAKREF", callback)
	callback:call_proc("RegisterSignal", datum, signal, "Invoke")
	local path = { "__SS13_signal_handlers", datumWeakRef, signal, callbackWeakRef, "func" }
	callback.vars.arguments = { path }
	-- Turfs don't remove their signals on deletion.
	if not __SS13_signal_handlers[datumWeakRef]._cleanup and not SS13.istype(datum, "/turf") then
		local cleanupCallback = SS13.new("/datum/callback", SS13.state, "call_function_return_first")
		local cleanupPath = { "__SS13_signal_handlers", datumWeakRef, "_cleanup"}
		cleanupCallback.vars.arguments = { cleanupPath }
		cleanupCallback:call_proc("RegisterSignal", datum, "parent_qdeleting", "Invoke")
		__SS13_signal_handlers[datumWeakRef]._cleanup = function(datum)
			SS13.start_tracking(datumWeakRef)
			timer.set_timeout(0, function()
				SS13.signal_handler_cleanup(datumWeakRef)
				SS13.stop_tracking(cleanupCallback)
				SS13.stop_tracking(datumWeakRef)
			end)
		end
	end
	__SS13_signal_handlers[datumWeakRef][signal][callbackWeakRef] = { func = func, callback = callback }
	return callback
end

function SS13.stop_tracking(datum)
	SS13.state:call_proc("let_soft_delete", datum)
end

function SS13.unregister_signal(datum, signal, callback)
	local function clear_handler(handler_info)
		if not handler_info then
			return
		end
		if not handler_info.callback then
			return
		end
		local handler_callback = handler_info.callback
		local callbackWeakRef = dm.global_proc("WEAKREF", handler_callback)
		if not SS13.istype(datum, "/datum/weakref") then
			handler_callback:call_proc("UnregisterSignal", datum, signal)
		else
			local actualDatum = datum:call_proc("hard_resolve")
			if SS13.is_valid(actualDatum) then
				handler_callback:call_proc("UnregisterSignal", actualDatum, signal)
			end
		end
		SS13.stop_tracking(handler_callback)
	end

	local datumWeakRef = datum
	if not SS13.istype(datum, "/datum/weakref") then
		datumWeakRef = dm.global_proc("WEAKREF", datum)
	end
	if not __SS13_signal_handlers[datumWeakRef] then
		return
	end

	if signal == "_cleanup" then
		return
	end

	if not __SS13_signal_handlers[datumWeakRef][signal] then
		return
	end

	if not callback then
		for handler_key, handler_info in __SS13_signal_handlers[datumWeakRef][signal] do
			clear_handler(handler_info)
		end
		__SS13_signal_handlers[datumWeakRef][signal] = nil
	else
		if not SS13.istype(callback, "/datum/callback") then
			return
		end
		local callbackWeakRef = dm.global_proc("WEAKREF", callback)
		clear_handler(__SS13_signal_handlers[datumWeakRef][signal][callbackWeakRef])
		__SS13_signal_handlers[datumWeakRef][signal][callbackWeakRef] = nil
	end
end

function SS13.signal_handler_cleanup(datumWeakRef)
	if not __SS13_signal_handlers[datumWeakRef] then
		return
	end

	for signal, _ in __SS13_signal_handlers[datumWeakRef] do
		SS13.unregister_signal(datumWeakRef, signal)
	end
	__SS13_signal_handlers[datumWeakRef] = nil
end

return SS13
