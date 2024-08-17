/* This comment bypasses grep checks */ /var/__dreamluau

#define DREAMLUAU (world.system_type == MS_WINDOWS ? "dreamluau.dll" : (__dreamluau || (__dreamluau = __detect_auxtools("dreamluau"))))

#define DREAMLUAU_CALL(func) call_ext(DREAMLUAU, "byond:[#func]")

/**
 * All of the following functions will return a string if the underlying rust code returns an error or a wrapped panic.
 * The return values specified for each function are what they will return if successful.
 */

/**
 * As of 515.1631, byondapi does not provide direct access to `usr`.
 * Use this function to pass `usr` into the dreamluau binary so that luau scripts can retrieve it.
 *
 * @return null on success
 */
#define DREAMLUAU_SET_USR DREAMLUAU_CALL(set_usr)(usr)


/**
 * Sets the execution limit, in milliseconds.
 *
 * @param limit the new execution limit
 *
 * @return null on success
 */
#define DREAMLUAU_SET_EXECUTION_LIMIT_MILLIS(limit) DREAMLUAU_CALL(set_execution_limit_millis)((limit))

/**
 * Sets the execution limit, in seconds.
 *
 * @param limit the new execution limit
 *
 * @return null on success
 */
#define DREAMLUAU_SET_EXECUTION_LIMIT_SECS(limit) DREAMLUAU_CALL(set_execution_limit_secs)((limit))

/**
 * Clears the execution limit, allowing scripts to run as long as they need to.
 *
 * WARNING: This allows infinite loops to block Dream Daemon indefinitely, with no safety checks.
 * Do not use this if you have no reason for scripts to run arbitrarily long.
 *
 * @return null on success
 */
#define DREAMLUAU_CLEAR_EXECUTION_LIMIT DREAMLUAU_CALL(clear_execution_limit)

//Wrapper setters/clearers

/**
 * Set the wrapper for instancing new datums with `dm.new`.
 * Clears it if the argument is null.
 * If unset, the object will be instantiated using the default `new` instruction.
 *
 * The wrapper must be a proc with the signature `(type as path, list/arguments)`.
 *
 * @param wrapper the path to the proc to use as the new wrapper
 *
 * @return null on success
 */
#define DREAMLUAU_SET_NEW_WRAPPER(wrapper) DREAMLUAU_CALL(set_new_wrapper)((wrapper))

/**
 * Set the wrapper for reading the vars of an object.
 * Clears it if the argument is null.
 * If unset, the var will be read directly, without any safety checks.
 *
 * The wrapper must be a proc with the signature `(target, var)`.
 *
 * @param wrapper the path to the proc to use as the new wrapper
 *
 * @return null on success
 */
#define DREAMLUAU_SET_VAR_GET_WRAPPER(wrapper) DREAMLUAU_CALL(set_var_get_wrapper)((wrapper))

/**
 * Set the wrapper for writing the vars of an object.
 * Clears it if the argument is null.
 * If unset, the var will be modified directly, without any safety checks.
 *
 * The wrapper must be a proc with the signature `(target, var, value)`.
 *
 * @param wrapper the path to the proc to use as the new wrapper
 *
 * @return null on success
 */
#define DREAMLUAU_SET_VAR_SET_WRAPPER(wrapper) DREAMLUAU_CALL(set_var_set_wrapper)((wrapper))

/**
 * Set the wrapper for calling a proc on an object.
 * Clears it if the argument is null.
 * If unset, the proc will be called directly, without any safety checks.
 *
 * The wrapper must be a proc with the signature `(target, procname as text, list/arguments)`.
 *
 * @param wrapper the path to the proc to use as the new wrapper
 *
 * @return null on success
 */
#define DREAMLUAU_SET_OBJECT_CALL_WRAPPER(wrapper) DREAMLUAU_CALL(set_object_call_wrapper)((wrapper))

/**
 * Set the wrapper for calling a global proc.
 * Clears it if the argument is null.
 * If unset, the proc will be called directly, without any safety checks.
 *
 * The wrapper must be a proc with the signature `(procname as text, list/arguments)`.
 *
 * @param wrapper the path to the proc to use as the new wrapper
 *
 * @return null on success
 */
#define DREAMLUAU_SET_GLOBAL_CALL_WRAPPER(wrapper) DREAMLUAU_CALL(set_global_call_wrapper)((wrapper))

/**
 * Set the wrapper for printing with the `print` function.
 * Clears it if the argument is null.
 * If unset, `print` will raise an error.
 *
 * The wrapper must be a proc with the signature `(list/arguments)`.
 *
 * @param wrapper the path to the proc to use as the new wrapper
 *
 * @return null on success
 */
#define DREAMLUAU_SET_PRINT_WRAPPER(wrapper) DREAMLUAU_CALL(set_print_wrapper)((wrapper))



/**
 * Create a new luau state.
 *
 * @return a handle to the created state.
 */
#define DREAMLUAU_NEW_STATE DREAMLUAU_CALL(new_state)

/**
 * Some of the following functions return values that cannot be cleanly converted from luau to DM.
 * To account for this, these functions also return a list of variant specifiers, equivalent to
 * an array of objects of the type described beloe:
 * ```
 * type Variants = {
 *     key?: "error"|Array<Variants?>
 *     value?: "error"|Array<Variants?>
 * }
 * ```
 */

/**
 * The following 4 functions execute luau code and return
 * an associative list containing information about the result.
 * This list has the following params.
 *
 * - "status": either "finished", "sleep", "yield", or "error"
 * - "return_values": if "status" is "finished" or "yield", contains a list of the return values
 * - "variants": a list of variant specifiers for the "return_values" param
 * - "message": if "status" is "error", contains the error message
 * - "name": the name of the executed code, according to the `what` field of `debug.getinfo`
 */

/**
 * Load and execute a luau script.
 *
 * @param state the handle to the state
 * @param code the source code of the script to run
 * @param name an optional name to give to the script, for debugging purposes
 *
 * @return an associative list containing result information as specified above
 */
#define DREAMLUAU_LOAD DREAMLUAU_CALL(load)

/**
 * Awaken the thread at the front of the specified state's sleeping thread queue.
 *
 * @param state the handle to the state
 *
 * @return an associative list containing result information as specified above
 */
#define DREAMLUAU_AWAKEN(state) DREAMLUAU_CALL(awaken)((state))

/**
 * Resume one of the state's yielded threads.
 *
 * @param state the handle to the state
 * @param index the index of the thread in the state's yielded threads list
 * @param ...arguments arguments that will be returned by the `coroutine.yield` that yielded the thread
 *
 * @return an associative list containing result information as specified above
 */
#define DREAMLUAU_RESUME DREAMLUAU_CALL(resume)

/**
 * Call a function accessible from the global table.
 *
 * @param state the handle to the state
 * @param function a list of nested indices from the global table to the specified function
 * @param ...arguments arguments to pass to the function
 *
 * @return an associative list containing result information as specified above
 */
#define DREAMLUAU_CALL_FUNCTION DREAMLUAU_CALL(call_function)

// State information collection functions

/**
 * Obtain a copy of the state's global table, converted to DM.
 *
 * @param state the handle to the state
 *
 * @return an associative list with the follwing entries:
 * - "values": The actual values of the global table
 * - "variants": Variant specifiers for "values"
 */
#define DREAMLUAU_GET_GLOBALS(state) DREAMLUAU_CALL(get_globals)((state))

/**
 * List the names of all sleeping or yielded threads for the state.
 *
 * @param state the handle to the state
 *
 * @return an associative list with the following entries:
 *  - "sleeps": A list of sleeping threads
 *  - "yields": A list of yielded threads
 */
#define DREAMLUAU_LIST_THREADS(state) DREAMLUAU_CALL(list_threads)((state))

// Cleanup functions

/**
 * Run garbage collection on the state.
 *
 * This may be necessary to prevent hanging references, as some
 * hard references may persist in unreachable luau objects that
 * would be collected after a garbage collection cycle or two.
 *
 * @param state the handle to the state
 *
 * @return null on success
 */
#define DREAMLUAU_COLLECT_GARBAGE(state) DREAMLUAU_CALL(collect_garbage)((state))

/**
 * Remove a sleeping thread from the sleep queue, without executing it.
 *
 * @param state the handle to the state
 * @param thread the index in the sleep queue to the target thread
 *
 * @return null on success
 */
#define DREAMLUAU_KILL_SLEEPING_THREAD(state, thread) DREAMLUAU_CALL(kill_sleeping_thread)((state), (thread))

/**
 * Remove a yielded thread from the yield table, without executing it.
 *
 * @param state the handle to the state
 * @param thread the index in the yield table to the target thread
 *
 * @return null on success
 */
#define DREAMLUAU_KILL_YIELDED_THREAD(state, thread) DREAMLUAU_CALL(kill_yielded_thread)((state), (thread))

/**
 * Delete a state. The state's handle will be freed for any new states created afterwards.
 *
 * @param state the handle to the state
 *
 * @return null on success
 */
#define DREAMLUAU_KILL_STATE(state) DREAMLUAU_CALL(kill_state)((state))

/**
 * Retrieve lua traceback info, containing every lua stack frame between the lua entrypoint and the re-entry to dm code.
 *
 * @param level the level of lua execution to get the traceback for,
 * with 1 being the lua code that executed the dm code that called this function,
 * 2 being the lua code that executed the dm code that executed the lua code
 * that executed the dm code that called this function, etc.
 *
 * @return the callstack of the specified lua level if valid, null if invalid
 */
#define DREAMLUAU_GET_TRACEBACK(index) DREAMLUAU_CALL(get_traceback)((index))

/**
 * Luau userdata corresponding to a ref-counted DM type counts as a hard reference for BYOND's garbage collector.
 * If you need to delete a DM object, and you cannot be certain that there are no references to it in any luau state,
 * call this function before deleting that object to disassociate it from any userdata in any luau state.
 *
 * Hard deleting an object without clearing userdata corresponding to it leaves the userdata to become associated with
 * the next DM object to receive the old object's reference ID, which may be undesirable behavior.
 *
 * @param object the object to disassociate from userdata.
 *
 * @return null on success
 */
#define DREAMLUAU_CLEAR_REF_USERDATA(object) DREAMLUAU_CALL(clear_ref_userdata)((object))

