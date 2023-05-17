/// Makes sure turf icons actually exist. :)
/datum/unit_test/turf_icons

/datum/unit_test/turf_icons/Run()
	for(var/turf/turf_path as anything in subtypesof(/turf))

		var/icon_state = initial(turf_path.icon_state)
		var/icon_file = initial(turf_path.icon)
		if(isnull(icon_state) || isnull(icon_file))
			continue
		if(!(icon_state in icon_states(icon_file)))
			TEST_FAIL("[turf_path] using invalid icon_state - \"[icon_state]\" in icon file, '[icon_file]")

	for(var/turf/turf_path as anything in (subtypesof(/turf/open) - typesof(/turf/open/floor/glass)))
		var/turf/open/instanced_turf = turf_path
		var/damaged_dmi = initial(instanced_turf.damaged_dmi)
		if(isnull(damaged_dmi))
			continue
		instanced_turf = allocate(turf_path)

		var/list/burnt_states = instanced_turf.burnt_states()
		for(var/state in burnt_states)
			if(!(state in icon_states(damaged_dmi)))
				TEST_FAIL("[turf_path] has an invalid icon in burnt_states - \"[state]\", in '[damaged_dmi]'")


		var/list/broken_states = instanced_turf.broken_states()
		for(var/state in broken_states)
			if(!(state in icon_states(damaged_dmi)))
				TEST_FAIL("[turf_path] has an invalid icon in broken_states - \"[state]\", in '[damaged_dmi]'")

