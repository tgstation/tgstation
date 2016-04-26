/************
 * D2K5-STYLE HOOKS
 *
 * BLATANTLY STOLEN FROM D2K5 AND MODIFIED
 *
 * SOMEHOW SUCKS LESS THAN BAY'S HOOKS
 ************

 The major change is to standardize them a bit
 by changing the event prefix to On instead of Hook.

 Oh and it's documented and cleaned up. - N3X
 */

/hook
	var/name = "DefaultHookName"
	var/list/handlers = list()

	proc/Called(var/list/args) // When the hook is called
		return 0

	proc/Setup() // Called when the setup things is ran for the hook, objs contain all objects with that is hooking

/hook_handler
	// Your hook handler should do this:
	// proc/OnThingHappened(var/list/args)
	// 	return handled // boolean

var/global/list/hooks = list()

/proc/SetupHooks()
	for (var/hook_path in typesof(/hook))
		var/hook/hook = new hook_path
		hooks[hook.name] = hook
		//world.log << "Found hook: " + hook.name
	for (var/hook_path in typesof(/hook_handler))
		var/hook_handler/hook_handler = new hook_path
		for (var/name in hooks)
			if (hascall(hook_handler, "On" + name))
				var/hook/hook = hooks[name]
				hook.handlers += hook_handler
				//world.log << "Found hook handler for: " + name
	for (var/hook/hook in hooks)
		hook.Setup()

/proc/CallHook(var/name as text, var/list/args)
	var/hook/hook = hooks[name]
	if (!hook)
		//world.log << "WARNING: Hook with name " + name + " does not exist"
		return
	if (hook.Called(args))
		return
	for (var/hook_handler/hook_handler in hook.handlers)
		call(hook_handler, "On" + hook.name)(args)