SS13 = {}

local function get_subsystem_and_context()
	local SSlua = dm.global_vars:get_var("SSlua")
	local contexts = SSlua:get_var("contexts"):to_table()
	for _, context in pairs(contexts) do
		if context:get_var("internal_id") == dm.context_id then
			return SSlua, context
		end
	end
end

local SSlua, context = get_subsystem_and_context()
SS13.SSlua = SSlua
SS13.context = context

SS13.new = function(type, args)
	local datum = dm.global_proc("_new", type, args)
	local references = SS13.context:get_var("references")
	references:add(datum)
	return datum
end

SS13.await = function(args)
	local promise = SS13.new("/datum/promise", args)
	while promise:get_var("status") == 0 do
		dm.sleep()
	end
	return promise:get_var("return_value"), promise:get_var("runtime_message")
end

SS13.wait = function(time, _timer)
	local index = #__yield_table
	local callback = SS13.new("/datum/callback", {SS13.SSlua, "queue_resume", SS13.context, index})
	local timer = dm.global_proc("_addtimer", callback, time*10, 8, _timer, "lua/SS13.lua", 35)
	coroutine.yield()
	dm.global_proc("deltimer", timer, _timer or nil)
end

SS13.register_signal = function(datum, signal, func, override)
	if not SS13.signal_handlers then
		SS13.signal_handlers = {}
	end
	local ref = dm.global_proc("REF", datum)
	if not SS13.signal_handlers[ref] then
		SS13.signal_handlers[ref] = {}
	end
	if not SS13.signal_handlers[ref][signal] then
		SS13.signal_handlers[ref][signal] = {}
	end
	local path = {"_G", "SS13", "signal_handlers", ref, signal, "func"}
	local callback = SS13.signal_handlers[ref][signal].callback
	if not callback then
		callback = SS13.new("/datum/callback", {SS13.context, "call_function", path})
	end
	if SS13.signal_handlers[ref][signal].func and not override then
		warn(signal .. " overridden. Use override = true to suppress this warning.") --TODO - actually make a warning handler for auxlua
	end
	SS13.signal_handlers[ref][signal].func = func
	callback:call_proc("RegisterSignal", datum, signal, "Invoke")
	return callback
end

SS13.unregister_signal = function(datum, callback, signal)
	if not callback then return end
	if not SS13.signal_handlers then return end
	local ref = dm.global_proc("REF", datum)
	if not SS13.signal_handlers[ref] then return end
	SS13.signal_handlers[ref][signal] = nil
	callback:call_proc("UnregisterSignal", datum, signal)
	dm.global_proc("qdel", callback)
end

return SS13
