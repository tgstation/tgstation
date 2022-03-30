# Auxlua

---

## Datums
DM datums are treated as lua userdata, and can be stored in fields. Regular datums are referenced weakly, so if a datum has been deleted, the corresponding userdata will evaluate to `nil` when used in comparisons or functions.

Keep in mind that BYOND can't see that a datum is referenced in a lua field, and will garbage collect it if it is not referenced anywhere in DM.

### datum:get_var(var)
Equivalent to DM's `datum.var`

### datum:set_var(var, value)
Equivalent to DM's `datum.var = value`

### datum:call_proc(proc, ...)
Equivalent to DM's `datum.proc(...)`

---

## Lists
In order to allow lists to be modified in-place across the DM-to-lua language barrier, lists are treated as userdata. Whenever running code that expects a DM value, auxlua will attempt to convert tables into lists.

List references are subject to the same limitations as datum userdata, but you are less likely to encounter these limitations.

### list.len
Equivalent to DM's `list.len`

### list:get(index)
Equivalent to DM's `list[index]`

### list:set(index, value)
Equivalent to DM's `list[index] = value`

### list:to_table()
Converts a DM list into a lua table.

---

## The dm table
The `dm` table consists of the basic hooks into the DM language.

### dm.state_id
The address of the lua state in memory. This is a copy of the internal value used by auxlua to locate the lua state in a global hash map.

### dm.global_proc(proc, ...)
Calls the global proc `/proc/[proc]` with `...` as its arguments.

### dm.world
A reference to DM's `world`, in the form of datum userdata. This reference will never evaluate to `nil`, since `world` always exists.

Due to limitations inherent in the wrapper functions used on tgstation, `world:set_var` and `world:call_proc` will raise an error.

### dm.global_vars
A reference to DM's `global`, in the form of datum userdata. Subject to the same limitations as `dm.world`

---

## Task management
The Lua Scripting subsystem manages the execution of tasks for each lua state. A single fire of the subsystem behaves as follows:
- All tasks that slept since the last fire are resumed in the order they slept.
- For each queued resume, the corresponding task is resumed.

### sleep()
Yields the current thread, scheduling it to be resumed during the next fire of SSlua. Use this function to prevent your lua code from exceeding its allowed execution duration.

Under the hood, this function sets the internal global flag `__sleep_flag`, calls `coroutine.yield` with no arguments, ignores its return values, then clears `__sleep_flag`.

---

## The SS13 package
The `SS13` package contains various helper functions that use code specific to tgstation.

### SS13.state
A reference to the state datum handling this lua state.

### SS13.new(type, ...)
Instantiates a datum of type `type` with `...` as the arguments passed to `/proc/_new`

### SS13.await(thing_to_call, proc_to_call, ...)
Calls `proc_to_call` on `thing_to_call`, with `...` as its arguments, and sleeps until that proc returns.

### SS13.wait(time, _timer)
Waits for a number of seconds specified with the `time` argument. You can optionally specify a timer subsystem using the `_timer` argument.

Internally, this function creates a timer that will resume the current task after `time` seconds, then yields the current task by calling `coroutine.yield` with no arguments and ignores the return values. If the task is prematurely resumed, the timer will be safely deleted.

### SS13.register_signal(datum, signal, func)
Registers the lua function `func` as a handler for the specified signal on a specified datum. Only one handler can be specified for a given datum and signal per lua state. Calling this function again with the same datum and signal will override the signal handler.

Like with signal handlers written in DM, lua signal handlers should not sleep.

### SS13.unregister_signal(datum, signal)
Unregister a signal previously registered using `SS13.register_signal`.

---

## Internal globals
Auxlua defines several globals for internal use. These are read-only.

### __sleep_flag
This flag is used to designate that a yielding task should be put in the sleep queue instead of the yield table.

### __sleep_queue
A sequence of threads, each corresponding to a task that has slept. When calling `__lua_awaken` from DM, auxlua will dequeue the first thread from the sequence and resume it. Threads in this queue can be resumed from lua code, but doing so is heavily advised against.

### __yield_table
A table of threads, each corresponding to a coroutine that has yielded. When calling `__lua_resume` from DM, auxlua will look for a thread at the index specified in the `index` argument, and resume it with the arguments specified in the `arguments` argument. Threads in this table can be resumed from lua code, but doing so is heavily advised against.

### __task_info
A table of key-value-pairs, where the keys are threads, and the values are tables consisting of the following fields:
- name: A string containing the name of the task
- status: A string, either "sleep" or "yield"
- index: The task's index in `__sleep_queue` or `__yield_table`
The threads constituting this table's keys can be resumed from lua code, but doing so is heavily advised against.

### env
Auxlua uses this table as the initial environment for every task executed. This table uses the global environment as its `__index` metamethod, allowing you to access (but not modify) global fields as if you were in the global environment.
