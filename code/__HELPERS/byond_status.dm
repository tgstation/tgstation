/// Returns the debug status, including sleeping procs.
/// If this blame is older than a month, please revert the PR that added it.
/proc/byond_status()
	if (world.system_type == UNIX)
		return LIBCALL("libbyond_sleeping_procs.so", "get_status")()
	else
		return "byond_status is not supported on [world.system_type]"
