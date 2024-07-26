local SS13 = require('SS13')
local HandlerGroup = {}
HandlerGroup.__index = HandlerGroup

function HandlerGroup.new()
	return setmetatable({
		registered = {}
	}, HandlerGroup)
end

-- Registers a signal on a datum for this handler group instance.
function HandlerGroup:register_signal(datum, signal, func)
	local callback = SS13.register_signal(datum, signal, func)
	if not callback then
		return
	end
	table.insert(self.registered, { datum = dm.global_proc("WEAKREF", datum), signal = signal, callback = callback  })
end

-- Clears all the signals that have been registered on this HandlerGroup
function HandlerGroup:clear()
	for _, data in self.registered do
		if not data.callback or not data.datum then
			continue
		end
		SS13.unregister_signal(data.datum, data.signal, data.callback)
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
