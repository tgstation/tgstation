/**
 * @file hooks.dm
 * Implements hooks, a simple way to run code on pre-defined events.
 */

/** @page hooks Code hooks
 * @section hooks Hooks
 * A hook is defined under /hook in the type tree.
 *
 * To add some code to be called by the hook, define a proc under the type, as so:
 * @code
/hook/foo/proc/bar()
	if(1)
		return 1 //Sucessful
	else
		return 0 //Error, or runtime.
 * @endcode
 * All hooks must return nonzero on success, as runtimes will force return null.
 */

/**
 * Calls a hook, executing every piece of code that's attached to it.
 * @param hook	Identifier of the hook to call.
 * @returns		1 if all hooked code runs successfully, 0 otherwise.
 */
/proc/callHook(hook, list/args=null)
	var/hook_path = text2path("/hook/[hook]")
	if(!hook_path)
		CRASH("Invalid hook '/hook/[hook]' called.")
		return 0

	var/caller = new hook_path
	var/status = 1
	for(var/P in typesof("[hook_path]/proc"))
		if(!call(caller, P)(arglist(args)))
			CRASH("Hook '[P]' failed or runtimed.")
			status = 0

	return status
