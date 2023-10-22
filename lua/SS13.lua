local SS13 = {}

__SS13_signal_handlers = __SS13_signal_handlers or {}
__SS13_timeouts = __SS13_timeouts or {}
__SS13_timeouts_id_mapping = __SS13_timeouts_id_mapping or {}

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

function SS13.wait(time)
	local callback = SS13.new("/datum/callback", SS13.SSlua, "queue_resume", SS13.state, __next_yield_index)
	local timedevent = dm.global_proc("_addtimer", callback, time * 10, 8, nil, debug.info(1, "sl"))
	coroutine.yield()
	dm.global_proc("deltimer", timedevent)
	SS13.stop_tracking(callback)
end

function SS13.register_signal(datum, signal, func, make_easy_clear_function)
	if not SS13.istype(datum, "/datum") then
		return
	end
	if not __SS13_signal_handlers[datum] then
		__SS13_signal_handlers[datum] = {}
	end
	if signal == "_cleanup" then
		return
	end
	if not __SS13_signal_handlers[datum][signal] then
		__SS13_signal_handlers[datum][signal] = {}
	end
	local callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first")
	callback:call_proc("RegisterSignal", datum, signal, "Invoke")
	local path = { "__SS13_signal_handlers", dm.global_proc("WEAKREF", datum), signal, dm.global_proc("WEAKREF", callback), "func" }
	callback.vars.arguments = { path }
	if not __SS13_signal_handlers[datum]["_cleanup"] then
		local cleanup_path = { "__SS13_signal_handlers", dm.global_proc("WEAKREF", datum), "_cleanup", "func" }
		local cleanup_callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first", cleanup_path)
		cleanup_callback:call_proc("RegisterSignal", datum, "parent_qdeleting", "Invoke")
		__SS13_signal_handlers[datum]["_cleanup"] = {
			func = function(datum)
				SS13.signal_handler_cleanup(datum)
				SS13.stop_tracking(cleanup_callback)
			end,
			callback = cleanup_callback,
		}
	end
	if signal == "parent_qdeleting" then --We want to make sure that the cleanup function is the very last signal handler called.
		local comp_lookup = datum.vars._listen_lookup
		if comp_lookup then
			local lookup_for_signal = comp_lookup.entries.parent_qdeleting
			if lookup_for_signal and not SS13.istype(lookup_for_signal, "/datum") then
				local cleanup_callback_index =
					dm.global_proc("_list_find", lookup_for_signal, __SS13_signal_handlers[datum]["_cleanup"].callback)
				if cleanup_callback_index ~= 0 and cleanup_callback_index ~= #comp_lookup then
					dm.global_proc("_list_swap", lookup_for_signal, cleanup_callback_index, #lookup_for_signal)
				end
			end
		end
	end
	__SS13_signal_handlers[datum][signal][callback] = { func = func, callback = callback }
	if make_easy_clear_function then
		local clear_function_name = "clear_signal_" .. tostring(datum) .. "_" .. signal .. "_" .. tostring(callback)
		SS13[clear_function_name] = function()
			if callback then
				SS13.unregister_signal(datum, signal, callback)
			end
			SS13[clear_function_name] = nil
		end
	end
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
		handler_callback:call_proc("UnregisterSignal", datum, signal)
		SS13.stop_tracking(handler_callback)
	end

	local function clear_easy_clear_function(callback_to_clear)
		local clear_function_name = "clear_signal_" .. tostring(datum) .. "_" .. signal .. "_" .. tostring(callback_to_clear)
		SS13[clear_function_name] = nil
	end

	if not __SS13_signal_handlers[datum] then
		return
	end
	if signal == "_cleanup" then
		return
	end
	if not __SS13_signal_handlers[datum][signal] then
		return
	end

	if not callback then
		for handler_key, handler_info in __SS13_signal_handlers[datum][signal] do
			clear_easy_clear_function(handler_key)
			clear_handler(handler_info)
		end
		__SS13_signal_handlers[datum][signal] = nil
	else
		if not SS13.istype(callback, "/datum/callback") then
			return
		end
		clear_easy_clear_function(callback)
		clear_handler(__SS13_signal_handlers[datum][signal][callback])
		__SS13_signal_handlers[datum][signal][callback] = nil
	end
end

function SS13.signal_handler_cleanup(datum)
	if not __SS13_signal_handlers[datum] then
		return
	end

	for signal, _ in __SS13_signal_handlers[datum] do
		SS13.unregister_signal(datum, signal)
	end

	__SS13_signal_handlers[datum] = nil
end

function SS13.set_timeout(time, func)
	SS13.start_loop(time, 1, func)
end

function SS13.start_loop(time, amount, func)
	if not amount or amount == 0 then
		return
	end
	local callback = SS13.new("/datum/callback", SS13.state, "call_function")
	local timedevent = dm.global_proc("_addtimer", callback, time * 10, 40, nil, debug.info(1, "sl"))
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
	local path = { "__SS13_timeouts", dm.global_proc("WEAKREF", callback) }
	callback.vars.arguments = { path }
	return timedevent
end

function SS13.end_loop(id)
	local data = __SS13_timeouts_id_mapping[id]
	if data then
		__SS13_timeouts_id_mapping[id] = nil
		__SS13_timeouts[data.callback] = nil
		SS13.stop_tracking(data.callback)
		dm.global_proc("deltimer", id)
	end
end

function SS13.stop_all_loops()
	for id, data in __SS13_timeouts_id_mapping do
		if data.amount ~= 1 then
			SS13.end_loop(id)
		end
	end
end

return SS13
