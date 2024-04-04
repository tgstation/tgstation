local SS13 = {}

__SS13_signal_handlers = __SS13_signal_handlers or {}

SS13.SSlua = dm.global_vars.vars.SSlua

SS13.global_proc = "some_magic_bullshit"

for _, state in SS13.SSlua.vars.states do
	if state.vars.internal_id == dm.state_id then
		SS13.state = state
		break
	end
end

function SS13.get_runner_ckey()
	return SS13.state:get_var("ckey_last_runner")
end

function SS13.get_runner_client()
	return dm.global_vars:get_var("GLOB"):get_var("directory"):get(SS13.get_runner_ckey())
end

function SS13.istype(thing, type)
	return dm.global_proc("_istype", thing, dm.global_proc("_text2path", type)) == 1
end

function SS13.new(type, ...)
	local datum = SS13.new_untracked(type, table.unpack({...}))
	if datum then
		local references = SS13.state.vars.references
		references:add(datum)
		SS13.state:call_proc("clear_on_delete", datum)
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
	if not __SS13_signal_handlers[datum] then
		__SS13_signal_handlers[datum] = {}
	end
	if signal == "parent_qdeleting_post_signal" then
		return
	end
	if not __SS13_signal_handlers[datum][signal] then
		__SS13_signal_handlers[datum][signal] = {}
	end
	local callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first")
	callback:call_proc("RegisterSignal", datum, signal, "Invoke")
	local path = { "__SS13_signal_handlers", dm.global_proc("WEAKREF", datum), signal, dm.global_proc("WEAKREF", callback), "func" }
	callback.vars.arguments = { path }
	if not __SS13_signal_handlers[datum]["parent_qdeleting_post_signal"] then
		__SS13_signal_handlers[datum]["parent_qdeleting_post_signal"] = {}
		local cleanup_callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first")
		local cleanup_path = { "__SS13_signal_handlers", dm.global_proc("WEAKREF", datum), "parent_qdeleting_post_signal", dm.global_proc("WEAKREF", cleanup_callback), "func" }
		cleanup_callback.vars.arguments = { cleanup_path }
		cleanup_callback:call_proc("RegisterSignal", datum, "parent_qdeleting_post_signal", "Invoke")
		__SS13_signal_handlers[datum]["parent_qdeleting_post_signal"][cleanup_callback] = {
			func = function(datum)
				SS13.signal_handler_cleanup(datum)
				SS13.stop_tracking(cleanup_callback)
			end,
			callback = cleanup_callback,
		}
	end
	__SS13_signal_handlers[datum][signal][callback] = { func = func, callback = callback }
	return callback
end

function SS13.stop_tracking(datum)
	SS13.state:call_proc("let_soft_delete", datum)
end

local signalBypass = false
function SS13.unregister_signal(datum, signal, callback)
	local function clear_handler(handler_info)
		if not handler_info then
			return
		end
		if not handler_info.callback then
			return
		end
		local handler_callback = handler_info.callback
		handler_callback:call_proc("UnregisterSignal", datum, signal)
		SS13.stop_tracking(handler_callback)
	end

	if not __SS13_signal_handlers[datum] then
		return
	end

	if not signalBypass and signal == "parent_qdeleting_post_signal" then
		return
	end

	if not __SS13_signal_handlers[datum][signal] then
		return
	end

	if not callback then
		for handler_key, handler_info in __SS13_signal_handlers[datum][signal] do
			clear_handler(handler_info)
		end
		__SS13_signal_handlers[datum][signal] = nil
	else
		if not SS13.istype(callback, "/datum/callback") then
			return
		end
		clear_handler(__SS13_signal_handlers[datum][signal][callback])
		__SS13_signal_handlers[datum][signal][callback] = nil
	end
end

function SS13.signal_handler_cleanup(datum)
	if not __SS13_signal_handlers[datum] then
		return
	end

	signalBypass = true
	for signal, _ in __SS13_signal_handlers[datum] do
		SS13.unregister_signal(datum, signal)
	end
	signalBypass = false

	__SS13_signal_handlers[datum] = nil
end

return SS13
