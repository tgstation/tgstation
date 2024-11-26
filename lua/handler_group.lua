local SS13 = require("SS13")
local HandlerGroup = {}
HandlerGroup.__index = HandlerGroup

function HandlerGroup.new()
	return setmetatable({
		registered = {},
	}, HandlerGroup)
end

-- Registers a signal on a datum for this handler group instance.
function HandlerGroup:register_signal(datum, signal, func)
	local registered_successfully = SS13.register_signal(datum, signal, func)
	if not registered_successfully then
		return
	end
	table.insert(self.registered, { datum = datum, signal = signal, func = func })
end

-- Clears all the signals that have been registered on this HandlerGroup
function HandlerGroup:clear()
	for _, data in self.registered do
		if not data.func or not SS13.is_valid(data.datum) then
			continue
		end
		SS13.unregister_signal(data.datum, data.signal, data.func)
	end
	table.clear(self.registered)
end

-- Clears all the signals that have been registered on this HandlerGroup when a specific signal is sent on a datum.
function HandlerGroup:clear_on(datum, signal, func)
	SS13.register_signal(datum, signal, function(...)
		if func then
			func(...)
		end
		self:clear()
	end)
end

-- Registers a signal on a datum and clears it after it is called once.
function HandlerGroup.register_once(datum, signal, func)
	local callback = HandlerGroup.new()
	callback:clear_on(datum, signal, func)
	return callback
end

return HandlerGroup
