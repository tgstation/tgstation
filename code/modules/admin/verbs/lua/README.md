# Auxlua

---

## Datums
DM datums are treated as Lua userdata, and can be stored in fields. Regular datums are referenced weakly, so if a datum has been deleted, the corresponding userdata will evaluate to `nil` when used in comparisons or functions.

Keep in mind that BYOND can't see that a datum is referenced in a Lua field, and will garbage collect it if it is not referenced anywhere in DM.

### datum:get_var(var)
Equivalent to DM's `datum.var`

### datum:set_var(var, value)
Equivalent to DM's `datum.var = value`

### datum:call_proc(procName, ...)
Equivalent to DM's `datum.procName(...)`

---

## Lists
In order to allow lists to be modified in-place across the DM-to-Lua language barrier, lists are treated as userdata. Whenever running code that expects a DM value, auxlua will attempt to convert tables into lists.

List references are subject to the same limitations as datum userdata, but you are less likely to encounter these limitations.

### list.len
Equivalent to DM's `list.len`

### list:get(index)
Equivalent to DM's `list[index]`

### list:set(index, value)
Equivalent to DM's `list[index] = value`

### list:add(value)
Equivalent to DM's `list.Add(value)`

### list:to_table()
Converts a DM list into a lua table.

### list:of_type(type_path)
Will extract only values of type `type_path`.

---

## The dm table
The `dm` table consists of the basic hooks into the DM language.

### dm.state_id
The address of the Lua state in memory. This is a copy of the internal value used by auxlua to locate the Lua state in a global hash map.

### dm.global_proc(proc, ...)
Calls the global proc `/proc/[proc]` with `...` as its arguments.

### dm.world
A reference to DM's `world`, in the form of datum userdata. This reference will never evaluate to `nil`, since `world` always exists.

Due to limitations inherent in the wrapper functions used on tgstation, `world:set_var` and `world:call_proc` will raise an error.

### dm.global_vars
A reference to DM's `global`, in the form of datum userdata. Subject to the same limitations as `dm.world`

### dm.usr
A weak reference to DM's `usr`. As a rule of thumb, this is a reference to the mob of the client who triggered the chain of procs leading to the execution of Lua code. The following is a list of what `usr` is for the most common ways of executing Lua code:
- For resumes and awakens, which are generally executed by the MC, `usr` is (most likely) null.
- `SS13.wait` queues a resume, which gets executed by the MC. Therefore, `usr` is null after `SS13.wait` finishes.
- For chunk loads, `usr` is generally the current mob of the admin that loaded that chunk.
- For function calls done from the Lua editor, `usr` is the current mob of the admin calling the function.
- `SS13.register_signal` creates a `/datum/callback` that gets executed by the `SEND_SIGNAL` macro for the corresponding signal. As such, `usr` is the mob that triggered the chain of procs leading to the invocation of `SEND_SIGNAL`.

---

## Task management
The Lua Scripting subsystem manages the execution of tasks for each Lua state. A single fire of the subsystem behaves as follows:
- All tasks that slept since the last fire are resumed in the order they slept.
- For each queued resume, the corresponding task is resumed.

### sleep()
Yields the current thread, scheduling it to be resumed during the next fire of SSlua. Use this function to prevent your Lua code from exceeding its allowed execution duration. Under the hood, `sleep` performs the following:

- Sets the global flag `__sleep_flag`
- Calls `coroutine.yield()`
- Clears the sleep flag when determining whether the task slept or yielded
- Ignores the return values of `coroutine.yield()` once resumed

---

## The SS13 package
The `SS13` package contains various helper functions that use code specific to tgstation.

### SS13.state
A reference to the state datum (`/datum/lua_state`) handling this Lua state.

### SS13.global_proc
A wrapper for the magic string used to tell `WrapAdminProcCall` to call a global proc.
For instance, `/datum/callback` must be instantiated with `SS13.global_proc` as its first argument to specify that it will be invoking a global proc.
The following example declares a callback which will execute the global proc `to_chat`:
```lua
local callback = SS13.new("/datum/callback", SS13.global_proc, "to_chat", dm.world, "Hello World")
```

### SS13.istype(thing, type)
Equivalent to the DM statement `istype(thing, text2path(type))`.

### SS13.new(type, ...)
Instantiates a datum of type `type` with `...` as the arguments passed to `/proc/_new`
The following example spawns a singularity at the caller's current turf:
```lua
SS13.new("/obj/singularity", dm.global_proc("_get_step", dm.usr, 0))
```

### SS13.await(thing_to_call, proc_to_call, ...)
Calls `proc_to_call` on `thing_to_call`, with `...` as its arguments, and sleeps until that proc returns.
Returns two return values - the first is the return value of the proc, and the second is the message of any runtime exception thrown by the called proc.
The following example calls and awaits the return of `poll_ghost_candidates`:
```lua
local ghosts, runtime = SS13.await(SS13.global_proc, "poll_ghost_candidates", "Would you like to be considered for something?")
```

### SS13.wait(time, timer)
Waits for a number of **seconds** specified with the `time` argument. You can optionally specify a timer subsystem using the `timer` argument.

Internally, this function creates a timer that will resume the current task after `time` seconds, then yields the current task by calling `coroutine.yield` with no arguments and ignores the return values. If the task is prematurely resumed, the timer will be safely deleted.

### SS13.register_signal(datum, signal, func, make_easy_clear_function)
Registers the Lua function `func` as a handler for `signal` on `datum`.

Like with signal handlers written in DM, Lua signal handlers should not sleep (either by calling `sleep` or `coroutine.yield`).

If `make_easy_clear_function` is truthy, a member function taking no arguments will be created in the `SS13` table to easily unregister the signal handler.

This function returns the `/datum/callback` created to call `func` from DM.

The following example defines a function which will register a signal that makes `target` make a honking sound any time it moves:
```lua
function honk(target)
	SS13.register_signal(target, "movable_moved", function(source)
		dm.global_proc("playsound", target, "sound/items/bikehorn.ogg", 100, true)
	end)
end
```

### SS13.unregister_signal(datum, signal, callback)
Unregister a signal previously registered using `SS13.register_signal`. `callback` should be a `datum/callback` previously returned by `SS13.register_signal`. If `callback` is not specified, **ALL** signal handlers registered on `datum` for `signal` will be unregistered.

### SS13.set_timeout(time, func)
Creates a timer which will execute `func` after `time` **seconds**. `func` should not expect to be passed any arguments, as it will not be passed any. Unlike `SS13.wait`, `SS13.set_timeout` does not yield or sleep the current task, making it suitable for use in signal handlers for `SS13.register_signal`

The following example will output a message to chat after 5 seconds:
```lua
SS13.set_timeout(5, function()
	dm.global_proc("to_chat", dm.world, "Hello World!")
end)
```

---

## Internal globals
Auxlua defines several globals for internal use. These are read-only.

### __sleep_flag
This flag is used to designate that a yielding task should be put in the sleep queue instead of the yield table. Once auxlua determines that a task should sleep, `__sleep_flag` is cleared.

### __set_sleep_flag(value)

A function that sets `__sleep_flag` to `value`. Calling this directly is not recommended, as doing so muddies the distinction between sleeps and yields.

### __sleep_queue

A sequence of threads, each corresponding to a task that has slept. When calling `/proc/__lua_awaken`, auxlua will dequeue the first thread from the sequence and resume it. Threads in this queue can be resumed from Lua code, but doing so is heavily advised against.

### __yield_table

A table of threads, each corresponding to a coroutine that has yielded. When calling `/proc/__lua_resume`, auxlua will look for a thread at the index specified in the `index` argument, and resume it with the arguments specified in the `arguments` argument. Threads in this table can be resumed from Lua code, but doing so is heavily advised against.

### __task_info

A table of key-value-pairs, where the keys are threads, and the values are tables consisting of the following fields:

- name: A string containing the name of the task
- status: A string, either "sleep" or "yield"
- index: The task's index in `__sleep_queue` or `__yield_table`

The threads constituting this table's keys can be resumed from Lua code, but doing so is heavily advised against.
