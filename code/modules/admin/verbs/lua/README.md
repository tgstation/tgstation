# Objects

Datums, lists, typepaths, static appearances, and some other objects are represented in Luau as userdata. Certain operations can be performed on these types of objects.

## Common metamethods

The following metamethods are defined for all objects.

### \_\_tostring(): string

Returns the string representation of the object. This uses BYOND's internal string conversion function.

### \_\_eq(other: any): boolean

Compare the equality of two objects. While passing the same object into luau twice will return two references to the same userdata, some DM projects may override the equality operator using an `__operator==` proc definition.

## Datum-like Objects

Datum-like objects include datums themselves, clients (if they have not been redefined to be children of `/datum`), static appearances, and the world.

### \_\_index(index: string): any

Access the member specified by `index`.

If `index` is a valid var for the object, the index operation will return that var's value.
If the var getting wrapper proc is set, the operation will instead call that proc with the arguments `(object, index)`.

For objects other than static appearances, if `index` is a valid proc for the object, the operation will return a wrapper for that proc that can be invoked using call syntax (e.g. `object:proc(...arguments)`). If the object proc calling wrapper is set, calling the returned function will instead call the wrapper proc with the arguments `(object, proc, {...arguments})`. Note that vars will be shadowed by procs with the same name. To work around this, use the `dm.get_var` function.

### \_\_newindex(index: string, value: any): ()

Set the var specified by `index` to `value`, if that var exists on the object.

If the var setting wrapper proc is set, the operation will instead call that proc with the arguments `(object, index, value)`.

## Lists

Lists are syntactically similar to tables, with one crucial difference.
Unlike tables, numeric indices must be non-zero integers within the bounds of the list.

### \_\_index(index: any): any

Read the list at `index`. This works both for numeric indices and assoc keys.
Vars lists cannot be directly read this way if the var getting wrapper proc is set.

### \_\_newindex(index: any, value: any): any

Write `value` to the list at `index`. This works both for writing numeric indices and assoc keys.
Vars lists cannot be directly written this way if the var setting wrapper proc is set.

### \_\_len(): integer

Returns the length of the list, similarly to the `length` builtin in DM.

### Iteration

Lists support Luau's generalized iteration. Iteration this way returns pairs of numeric indices and list values.
For example, the statement `for _, v in L do` is logically equivalent to the DM statement `for(var/v in L)`.

# Global Fields and Modules

In addition to the full extent of Luau's standard library modules, some extra functions and modules have been added.

## Global-Level Fields

### sleep(): ()

Yields the active thread, without worrying about passing data into or out of the state.

Threads yielded this way are placed at the end of a queue. Call the `awaken` hook function from DM to execute the thread at the front of the queue.

### loadstring(code: string): function

Luau does not inherently include the `loadstring` function common to a number of other versions of lua. This is an effective reimplementation of `loadstring`.

### print(...any): ()

Calls the print wrapper with the passed in arguments.
Raises an error if no print wrapper is set, as that means there is nothing to print with.

### \_state_id: integer

The handle to the underlying luau state in the dreamluau binary.

## \_exec

The `_exec` module includes volatile fields related to the current execution context.

### \_next_yield_index: integer

When yielding a thread with `coroutine.yield`, it will be inserted into an internal table at the first open integer index.
This field corresponds to that first open integer index.

### \_limit: integer?

If set, the execution limit, rounded to the nearest millisecond.

### \_time: integer

The length of successive time luau code has been executed, including recursive calls to DM and back into luau, rounded to the nearest millisecond.

## dm

The `dm` module includes fields and functions for basic interaction with DM.

### world: userdata

A static reference to the DM `world`.

### global_vars: userdata

A static reference that functions like the DM keyword `global`. This can be indexed to read/write global vars.

### global_procs: table

A table that can be indexed by string for functions that wrap global procs.

Due to BYOND limitations, attempting to index an invalid proc returns a function logically equivalent to a no-op.

### get_var(object: userdata, var: string): function

Reads the var `var` on `object`. This function can be used to get vars that are shadowed by procs declared with the same name.

### new(path: string, ...any): userdata

Creates an instance of the object specified by `path`, with `...` as its arguments.
If the "new" wrapper is set, that proc will be called instead, with the arguments `(path, {...})`.

### is_valid_ref(ref: any): boolean

Returns true if the value passed in corresponds to a valid reference-counted DM object.

### usr: userdata?

Corresponds to the DM var `usr`.

## list

The `list` module contains wrappers for the builtin list procs, along with several other utility functions for working with lists.

### add(list: userdata, ...any): ()

Logically equivalent to the DM statement `list.Add(...)`.

### copy(list: userdata, start?: integer, end?: integer): userdata

Logically equivalent to the DM statement `list.Copy(start, end)`.

### cut(list: userdata, start?: integer, end?: integer): userdata

Logically equivalent to the DM statement `list.Cut(start, end)`.

### find(list: userdata, item: any, start?: integer, end?: integer): integer

Logically equivalent to the DM statement `list.Find(item, start, end)`.

### insert(list: userdata, index: integer, ...any): integer

Logically equivalent to the DM statement `list.Insert(item, ...)`.

### join(list: userdata, glue: string, start?: integer, end?: integer): string

Logically equivalent to the statement `list.Join(glue, start, end)`.

### remove(list: userdata, ...any): integer

Logically equivalent to the DM statement `list.Remove(...)`.

### remove_all(list: userdata, ...any): integer

Logically equivalent to the DM statement `list.RemoveAll(...)`.

### splice(list: userdata, start?: integer, end?: integer, ...any): ()

Logically equivalent to the DM statement `list.Splice(start, end, ...)`.

### swap(list: userdata, index_1: integer, index_2: integer): ()

Logically equivalent to the DM statement `list.Swap(index_1, index_2)`.

### to_table(list: userdata, deep?: boolean): table

Creates a table that is a copy of `list`. If `deep` is true, `to_table` will be called on any lists inside that list.

### from_table(table: table): userdata

Creates a list that is a copy of `table`. This is not strictly necessary, as tables are automatically converted to lists when passed back into DM, using the same internal logic as `from_table`.

### filter(list: userdata, path: string): userdata

Returns a copy of `list`, containing only elements that are objects descended from `path`.

## pointer

The `pointer` module contains utility functions for interacting with pointers.
Keep in mind that passing DM pointers into luau and manipulating them in this way can bypass wrapper procs.

### read(pointer: userdata): any

Gets the underlying data the pointer references.

### write(pointer: userdata, value: any): ()

Writes `value` to the underlying data the pointer references.

### unwrap(possible_pointer: any): any

If `possible_pointer` is a pointer, reads it. Otherwise, it is returned as-is.

# The SS13 package

The `SS13` package contains various helper functions that use code specific to tgstation.

## SS13.state

A reference to the state datum (`/datum/lua_state`) handling this Lua state.

## SS13.get_runner_ckey()

The ckey of the user who ran the lua script in the current context. Can be unreliable if accessed after sleeping.

## SS13.get_runner_client()

Returns the client of the user who ran the lua script in the current context. Can be unreliable if accessed after sleeping.

## SS13.global_proc

A wrapper for the magic string used to tell `WrapAdminProcCall` to call a global proc.
For instance, `/datum/callback` must be instantiated with `SS13.global_proc` as its first argument to specify that it will be invoking a global proc.
The following example declares a callback which will execute the global proc `to_chat`:

```lua
local callback = SS13.new("/datum/callback", SS13.global_proc, "to_chat", dm.world, "Hello World")
```

## SS13.istype(thing, type)

Equivalent to the DM statement `istype(thing, text2path(type))`.

## SS13.new(type, ...)

An alias for `dm.new`

## SS13.is_valid(datum)

Can be used to determine if the datum passed is not nil, not undefined and not qdel'd all in one. A helper function that allows you to check the validity from only one function.
Example usage:

```lua
local datum = SS13.new("/datum")
dm.global_procs.qdel(datum)
print(SS13.is_valid(datum)) -- false

local null = nil
print(SS13.is_valid(null)) -- false

local datum = SS13.new("/datum")
print(SS13.is_valid(datum)) -- true
```

## SS13.type(string)

Converts a string into a typepath. Equivalent to doing `dm.global_proc("_text2path", "/path/to/type")`

## SS13.qdel(datum)

Deletes a datum. You shouldn't try to reference it after calling this function. Equivalent to doing `dm.global_proc("qdel", datum)`

## SS13.await(thing_to_call, proc_to_call, ...)

Calls `proc_to_call` on `thing_to_call`, with `...` as its arguments, and sleeps until that proc returns.
Returns two return values - the first is the return value of the proc, and the second is the message of any runtime exception thrown by the called proc.
The following example calls and awaits the return of `poll_ghost_candidates`:

```lua
local ghosts, runtime = SS13.await(SS13.global_proc, "poll_ghost_candidates", "Would you like to be considered for something?")
```

## SS13.wait(time, timer)

Waits for a number of **seconds** specified with the `time` argument. You can optionally specify a timer subsystem using the `timer` argument.

Internally, this function creates a timer that will resume the current task after `time` seconds, then yields the current task by calling `coroutine.yield` with no arguments and ignores the return values. If the task is prematurely resumed, the timer will be safely deleted.

## SS13.register_signal(datum, signal, func)

Registers the Lua function `func` as a handler for `signal` on `datum`.

Like with signal handlers written in DM, Lua signal handlers should not sleep (either by calling `sleep` or `coroutine.yield`).

This function returns whether the signal registration was successful.

The following example defines a function which will register a signal that makes `target` make a honking sound any time it moves:

```lua
function honk(target)
	SS13.register_signal(target, "movable_moved", function(source)
		dm.global_procs.playsound(target, "sound/items/bikehorn.ogg", 100, true)
	end)
end
```

NOTE: if `func` is an anonymous function declared inside the call to `SS13.register_signal`, it cannot be referenced in order to unregister that signal with `SS13.unregister_signal`

## SS13.unregister_signal(datum, signal, func)

Unregister a signal previously registered using `SS13.register_signal`. `func` must be a function for which a handler for the specified signal has already been registered. If `func` is `nil`, all handlers for that signal will be unregistered.

## SS13.set_timeout(time, func)

Creates a timer which will execute `func` after `time` **seconds**. `func` should not expect to be passed any arguments, as it will not be passed any. Unlike `SS13.wait`, `SS13.set_timeout` does not yield or sleep the current task, making it suitable for use in signal handlers for `SS13.register_signal`

The following example will output a message to chat after 5 seconds:

```lua
SS13.set_timeout(5, function()
	dm.global_procs.to_chat(dm.world, "Hello World!")
end)
```

## SS13.start_loop(time, amount, func)

Creates a timer which will execute `func` after `time` **seconds**. `func` should not expect to be passed any arguments, as it will not be passed any. Works exactly the same as `SS13.set_timeout` except it will loop the timer `amount` times. If `amount` is set to -1, it will loop indefinitely. Returns a number value, which represents the timer's id. Can be stopped with `SS13.end_loop`
Returns a number, the timer id, which is needed to stop indefinite timers.
The following example will output a message to chat every 5 seconds, repeating 10 times:

```lua
SS13.start_loop(5, 10, function()
	dm.global_procs.to_chat(dm.world, "Hello World!")
end)
```

The following example will output a message to chat every 5 seconds, until `SS13.end_loop(timerid)` is called:

```lua
local timerid = SS13.start_loop(5, -1, function()
	dm.global_proc.to_chat(dm.world, "Hello World!")
end)
```

## SS13.end_loop(id)

Prematurely ends a loop that hasn't ended yet, created with `SS13.start_loop`. Silently fails if there is no started loop with the specified id.
The following example will output a message to chat every 5 seconds and delete it after it has repeated 20 times:

```lua
local repeated_amount = 0
-- timerid won't be in the looping function's scope if declared before the function is declared.
local timerid
timerid = SS13.start_loop(5, -1, function()
	dm.global_procs.to_chat(dm.world, "Hello World!")
	repeated_amount += 1
	if repeated_amount >= 20 then
		SS13.end_loop(timerid)
	end
end)
```

## SS13.stop_all_loops()

Stops all current running loops that haven't ended yet.
Useful in case you accidentally left a indefinite loop running without storing the id anywhere.
