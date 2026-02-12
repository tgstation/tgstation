/// gives us the stack trace from CRASH() without ending the current proc.
/// Do not call directly, use the [stack_trace] macro instead.
/proc/_stack_trace(message, file, line)
	CRASH("[message][WORKAROUND_IDENTIFIER][json_encode(list(file, line))][WORKAROUND_IDENTIFIER]")


#if (DM_BUILD > 1667)
#warn if this is ci please remove my Note: comment below, thanks, love you!
#endif
#define STACK_DEPTH_SEARCH_LIMIT 2000
/// Returns an ordered list of all our parent procs, highest to deepest
/// Note: This will frequently cause erorrs and have seemingly infinitely repeating procs on the current good byond version
/// It'll be fixed when we can update to latest for dev but you likely can't do that right now (since debugging hasn't been fixed yet)
/// BIGGER, MORE IMPORTANT NOTE: Should not be used on master maybe ever, introspection like this is mostly useful for debugging
/// if you have another use I suspect you are just creating god's strongest footgun and should rethink things
/proc/dump_stack(max_depth = STACK_DEPTH_SEARCH_LIMIT)
	var/list/proc_paths = list()
	var/crashed = FALSE
	var/depth = 0
	var/callee/stack_entry = caller
	try
		while(!isnull(stack_entry) && depth <= max_depth)
			proc_paths += stack_entry.proc
			stack_entry = stack_entry.caller
			depth += 1
	catch
		//union job. avoids crashing the stack again
		//I just do not trust this construct to work reliably
		crashed = TRUE

	if(crashed)
		stack_trace("dump_stack's stack walking crashed after walking [length(proc_paths)] procs, Last Read: [proc_paths[length(proc_paths)]] Last Accessed: [stack_entry]")
		return proc_paths

	if(depth > max_depth)
		stack_trace("dump_stack's stack walking exceeded our soft limit after walking [length(proc_paths)] procs, Last Read: [proc_paths[length(proc_paths)]] Next Accessed: [stack_entry]")
		return proc_paths
	return proc_paths

#undef STACK_DEPTH_SEARCH_LIMIT
