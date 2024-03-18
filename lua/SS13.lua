local SS13 = {}

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
	if dm.is_valid_ref(datum) and not datum.gc_destroyed then
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
	callback:RegisterSignal(datum, signal, "Invoke")
	local path = {
		"__SS13_signal_handlers",
		dm.global_procs.WEAKREF(datum),
		signal,
		dm.global_procs.WEAKREF(callback),
		"func",
	}
	callback.arguments = { path }
	if not __SS13_signal_handlers[datum]["_cleanup"] then
		local cleanup_path = { "__SS13_signal_handlers", dm.global_procs.WEAKREF(datum), "_cleanup", "func" }
		local cleanup_callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first", cleanup_path)
		cleanup_callback:RegisterSignal(datum, "parent_qdeleting", "Invoke")
		__SS13_signal_handlers[datum]["_cleanup"] = {
			func = SS13.signal_handler_cleanup,
			callback = cleanup_callback,
		}
	end
	if signal == "parent_qdeleting" then --We want to make sure that the cleanup function is the very last signal handler called.
		local comp_lookup = datum._listen_lookup
		if comp_lookup then
			local lookup_for_signal = comp_lookup["parent_qdeleting"]
			if lookup_for_signal and not SS13.istype(lookup_for_signal, "/datum") then
				local cleanup_callback_index =
					list.find(lookup_for_signal, __SS13_signal_handlers[datum]["_cleanup"].callback)
				if cleanup_callback_index ~= 0 and cleanup_callback_index ~= #comp_lookup then
					list.swap(lookup_for_signal, cleanup_callback_index, #lookup_for_signal)
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

function SS13.unregister_signal(datum, signal, callback)
	local function clear_handler(handler_info)
		if not handler_info then
			return
		end
		if not handler_info.callback then
			return
		end
		local handler_callback = handler_info.callback
		handler_callback:UnregisterSignal(datum, signal)
		SS13.stop_tracking(handler_callback)
	end

	local function clear_easy_clear_function(callback_to_clear)
		local clear_function_name = "clear_signal_"
			.. tostring(datum)
			.. "_"
			.. signal
			.. "_"
			.. tostring(callback_to_clear)
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

return SS13
