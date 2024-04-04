local SS13 = require('SS13')
local HandlerGroup = {}

HandlerGroup.metatable = {}
HandlerGroup.metatable.__index = HandlerGroup.metatable

function HandlerGroup.new()
	local newGroup = {
		registered = {}
	}
	setmetatable(newGroup, HandlerGroup.metatable)
	return newGroup
end

function HandlerGroup.metatable:register_signal(datum, signal, func)
	local callback = SS13.register_signal(datum, signal, func)
	if not callback then
		return
	end
	table.insert(self.registered, { datum = datum, signal = signal, callback = callback  })
end

function HandlerGroup.metatable:clear()
	for _, data in self.registered do
		if not data.callback or not data.datum then
			continue
		end
		SS13.unregister_signal(data.datum, data.signal, data.callback)
	end
end

function HandlerGroup.metatable:clear_on(datum, signal, func)
	SS13.register_signal(datum, signal, function(...)
		if func then
			func(table.unpack({...}))
		end
		self:clear()
	end)
end

function HandlerGroup.register_once(datum, signal, func)
	local callback = HandlerGroup.new()
	callback:clear_on(datum, signal, func)
	return callback
end


return HandlerGroup
