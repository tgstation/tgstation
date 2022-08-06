local SS13 = {}

SS13.SSlua = dm.global_vars:get_var("SSlua")

SS13.global_proc = "some_magic_bullshit"

local states = SS13.SSlua:get_var("states"):to_table()
for _, state in states do
	if state:get_var("internal_id") == dm.state_id then
		SS13.state = state
		break
	end
end

function SS13.istype(thing, type)
	return dm.global_proc("_istype", thing, dm.global_proc("_text2path", type)) == 1
end

function SS13.new(type, ...)
	local datum = dm.global_proc("_new", type, { ... })
	local references = SS13.state:get_var("references")
	references:add(datum)
	return datum
end

function SS13.await(thing_to_call, proc_to_call, ...)
	if not SS13.istype(thing_to_call, "/datum") then
		thing_to_call = SS13.global_proc
	end
	if thing_to_call == SS13.global_proc then
		proc_to_call = "/proc/" .. proc_to_call
	end
	local promise = SS13.new("/datum/auxtools_promise", thing_to_call, proc_to_call, ...)
	while promise:get_var("status") == 0 do
		sleep()
	end
	return promise:get_var("return_value"), promise:get_var("runtime_message")
end

function SS13.wait(time, timer)
	local index = #__yield_table + 1
	local callback = SS13.new("/datum/callback", SS13.SSlua, "queue_resume", SS13.state, index)
	local timedevent = dm.global_proc("_addtimer", callback, time * 10, 8, timer, debug.info(1, "sl"))
	coroutine.yield()
	dm.global_proc("deltimer", timedevent, timer)
end

function SS13.register_signal(datum, signal, func, make_easy_clear_function)
	if not SS13.signal_handlers then
		SS13.signal_handlers = {}
	end
	if not SS13.istype(datum, "/datum") then
		return
	end
	local ref = dm.global_proc("REF", datum)
	if not SS13.signal_handlers[ref] then
		SS13.signal_handlers[ref] = {}
	end
	if signal == "_cleanup" then
		return
	end
	if not SS13.signal_handlers[ref][signal] then
		SS13.signal_handlers[ref][signal] = {}
	end
	local callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first")
	callback:call_proc("RegisterSignal", datum, signal, "Invoke")
	local callback_ref = dm.global_proc("REF", callback)
	local path = { "SS13", "signal_handlers", ref, signal, callback_ref, "func" }
	callback:set_var("arguments", { path })
	if not SS13.signal_handlers[ref]["_cleanup"] then
		local cleanup_path = { "SS13", "signal_handlers", ref, "_cleanup", "func" }
		local cleanup_callback = SS13.new("/datum/callback", SS13.state, "call_function_return_first", cleanup_path)
		cleanup_callback:call_proc("RegisterSignal", datum, "parent_qdeleting", "Invoke")
		SS13.signal_handlers[ref]["_cleanup"] = {
			func = function(datum)
				SS13.signal_handler_cleanup(datum)
				dm.global_proc("qdel", cleanup_callback)
			end,
			callback = cleanup_callback,
		}
	end
	if signal == "parent_qdeleting" then --We want to make sure that the cleanup function is the very last signal handler called.
		local comp_lookup = datum:get_var("comp_lookup")
		if comp_lookup then
			local lookup_table = comp_lookup:to_table()
			local lookup_for_signal = lookup_table.parent_qdeleting
			if lookup_for_signal and not SS13.istype(lookup_for_signal, "/datum") then
				local cleanup_callback_index =
					dm.global_proc("_list_find", lookup_for_signal, SS13.signal_handlers[ref]["_cleanup"].callback)
				if cleanup_callback_index ~= 0 then
					dm.global_proc("_list_swap", lookup_for_signal, cleanup_callback_index, lookup_for_signal.len)
				end
			end
		end
	end
	SS13.signal_handlers[ref][signal][callback_ref] = { func = func, callback = callback }
	if make_easy_clear_function then
		local clear_function_name = "clear_signal_" .. ref .. "_" .. signal .. "_" .. callback_ref
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
		handler_callback:call_proc("UnregisterSignal", datum, signal)
		dm.global_proc("qdel", handler_callback)
	end

	if not SS13.signal_handlers then
		return
	end

	local ref = dm.global_proc("REF", datum)
	local function clear_easy_clear_function(callback_ref)
		local clear_function_name = "clear_signal_" .. ref .. "_" .. signal .. "_" .. callback_ref
		SS13[clear_function_name] = nil
	end

	if not SS13.signal_handlers[ref] then
		return
	end
	if signal == "_cleanup" then
		return
	end
	if not SS13.signal_handlers[ref][signal] then
		return
	end

	if not callback then
		for handler_key, handler_info in SS13.signal_handlers[ref][signal] do
			clear_easy_clear_function(handler_key)
			clear_handler(handler_info)
		end
		SS13.signal_handlers[ref][signal] = nil
	else
		if not SS13.istype(callback, "/datum/callback") then
			return
		end
		local callback_ref = dm.global_proc("REF", callback)
		clear_easy_clear_function(callback_ref)
		clear_handler(SS13.signal_handlers[ref][signal][callback_ref])
		SS13.signal_handlers[ref][signal][callback_ref] = nil
	end
end

function SS13.signal_handler_cleanup(datum)
	if not SS13.signal_handlers then
		return
	end
	local ref = dm.global_proc("REF", datum)
	if not SS13.signal_handlers[ref] then
		return
	end

	for signal, _ in SS13.signal_handlers[ref] do
		SS13.unregister_signal(datum, signal)
	end

	SS13.signal_handlers[ref] = nil
end

function SS13.set_timeout(time, func)
	if not SS13.timeouts then
		SS13.timeouts = {}
	end
	local callback = SS13.new("/datum/callback", SS13.state, "call_function")
	local callback_ref = dm.global_proc("REF", callback)
	SS13.timeouts[callback_ref] = function()
		SS13.timeouts[callback_ref] = nil
		func()
	end
	local path = { "SS13", "timeouts", callback_ref }
	callback:set_var("arguments", { path })
	dm.global_proc("_addtimer", callback, time * 10, 8, nil, debug.info(1, "sl"))
end

return SS13
