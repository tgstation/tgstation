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

### dm.usr
A weak reference to DM's `usr`. As a rule of thumb, this is a reference to the mob of the client who triggered the chain of procs leading to the execution of lua code. The following is a list of what `usr` is for the most common ways of executing lua code:
- For resumes and awakens, which are generally executed by the MC, `usr` is (most liekly) null.
- `SS13.wait` queues a resume, which gets executed by the MC. Therefore, `usr` is null after `SS13.wait` finishes.
- For chunk loads, `usr` is generally the current mob of the admin that loaded that chunk.
- For function calls done from the lua editor, `usr` is the current mob of the admin calling the function.
- `SS13.register_signal` creates a `/datum/callback` that gets executed by the `SEND_SIGNAL` macro for the corresponding signal. As such, `usr` is the mob that triggered the chain of procs leading to the invocation of `SEND_SIGNAL`.

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

### SS13.global_proc
A wrapper for the magic string used to tell `WrapAdminProcCall` to call a global proc

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
