local SS13 = {}

SS13.SSlua = dm.global_vars:get_var("SSlua")

SS13.global_proc = "some_magic_bullshit"

local states = SS13.SSlua:get_var("states"):to_table()
for _, state in pairs(states) do
	if state:get_var("internal_id") == dm.state_id then
		SS13.state = state
		break
	end
end

function SS13.new(type, ...)
	local args = table.pack(...)
	args["n"] = nil
	local datum = dm.global_proc("_new", type, args)
	local references = SS13.state:get_var("references")
	references:add(datum)
	return datum
end

function SS13.await(thing_to_call, proc_to_call, ...)
	if thing_to_call == nil then
		thing_to_call = SS13.global_proc
	end
	if thing_to_call == SS13.global_proc then
		proc_to_call = "/proc/" .. proc_to_call
	end
	local args = table.pack(thing_to_call, proc_to_call, ...)
	args["n"] = nil
	local promise = SS13.new("/datum/promise", table.unpack(args))
	while promise:get_var("status") == 0 do
		sleep()
	end
	return promise:get_var("return_value"), promise:get_var("runtime_message")
end

function SS13.wait(time, _timer)
	local index = #__yield_table + 1
	local callback = SS13.new("/datum/callback", SS13.SSlua, "queue_resume", SS13.state, index)
	local timer = dm.global_proc("_addtimer", callback, time*10, 8, _timer, "lua/SS13.lua", 43)
	coroutine.yield()
	dm.global_proc("deltimer", timer, _timer or nil)
end

function SS13.register_signal(datum, signal, func)
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
	local path = {"SS13", "signal_handlers", ref, signal, "func"}
	local callback = SS13.signal_handlers[ref][signal].callback
	if not callback then
		callback = SS13.new("/datum/callback", SS13.state, "call_function", path)
	end
	SS13.signal_handlers[ref][signal].func = func
	callback:call_proc("RegisterSignal", datum, signal, "Invoke")
	return callback
end

function SS13.unregister_signal(datum, callback, signal)
	if not callback then return end
	if not SS13.signal_handlers then return end
	local ref = dm.global_proc("REF", datum)
	if not SS13.signal_handlers[ref] then return end
	SS13.signal_handlers[ref][signal] = nil
	callback:call_proc("UnregisterSignal", datum, signal)
	dm.global_proc("qdel", callback)
end

return SS13
