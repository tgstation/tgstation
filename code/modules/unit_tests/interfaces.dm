/**
 * Checks whether everything that declares that it uses a particular interface actually does so properly.
 */
/datum/unit_test/Run()
	var/list/cached_implementations = SSinterfaces.aggregate_implementations() // So we aren't looping over entire typecaches. If these pass the subtypes should too.
	for(var/interface_type in cached_implementations)
		var/datum/interface/interface = new interface_type
		for(var/typepath in cached_implementations[interface_type])
			var/datum/to_check = new typepath()

			var/list/missing_vars = list()
			var/list/missing_procs = list()
			for(var/varname in interface.vars)
				if(varname == INTERFACE_PROC_CACHE_NAME_STRING)
					continue
				if(!varname in to_check.vars)
					missing_vars += varname

			for(var/procname in interface.INTERFACE_PROC_CACHE_NAME)
				if(!hascall(to_check, procname))
					missing_procs += procname

			qdel(to_check)
			TEST_ASSERT(!missing_vars.len && !missing_procs.len, "[typepath] fails to properly implement [interface_type].[missing_vars.len ? " It is missing vars [missing_vars.Join(", ")]." : null][missing_procs.len ? " It is missing procs [missing_procs.Join(", ")]." : null]")
