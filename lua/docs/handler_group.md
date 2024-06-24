# Handler Group

This module is for registering signals on a datum or several datums and being able to clear them all at once without having to unregister them manually. This is particularly useful if you register signals on a datum and need to clear them later without accidentally unregistering unrelated signals

## Functions

### HandlerGroup.new()
Creates a new handler group instance

### HandlerGroup:register_signal(datum, signal, func)
Registers a signal on a datum, exactly the same as `SS13.register_signal`

### HandlerGroup:clear()
Clears all registered signals that have been registered by this handler group.

### HandlerGroup:clear_on(datum, signal, func)
Clears all registered signals that have been registered by this handler group when a signal is called on the specified datum. Additionally, a function can be ran before it is cleared

### HandlerGroup.register_once(datum, signal func)
Identical to just creating a new HandlerGroup instance and calling `clear_on(datum, signal, func)`.

The idea is to register a signal and clear it after it has been called once.

## Examples

The following examples showcase why using handler groups can make life easier in specific situations.

### Explode when mob enters location
This function creates a 1 tile-wide explosion at the specified location if a specific mob walks over it. The explosion won't happen if the mob dies. This function should be callable on the same mob for different locations. The function should be self-contained, it should not affect other registered signals that the mob may have registered.

#### Without Handler Groups
```lua
local function explodeAtLocation(mobVar, position)
	local deathCallback
	local moveCallback
	local function unlinkFromMob()
		SS13.unregister_signal(mobVar, "living_death", deathCallback)
		SS13.unregister_signal(mobVar, "movable_moved", moveCallback)
	end
	deathCallback = SS13.register_signal(mobVar, "living_death", function(_, gibbed)
		unlinkFromMob()
	end)
	moveCallback = SS13.register_signal(mobVar, "movable_moved", function(_, oldLoc)
		if mobVar:get_var("loc") == position then
			-- Creates a 1 tile-wide explosion at the specified position
			dm.global_proc("explosion", position, 1, 0, 0)
			unlinkFromMob()
		end
	end)
end
```

#### With Handler Groups
```lua
local function explodeAtLocation(mobVar, position)
	local handler = handler_group.new()
	handler:clear_on(mobVar, "living_death")
	handler:register_signal(mobVar, "movable_moved", function(_, oldLoc)
		if mobVar:get_var("loc") == position then
			-- Creates a 1 tile-wide explosion at the specified position
			dm.global_proc("explosion", position, 1, 0, 0)
			handler:clear()
		end
	end)
end
```
