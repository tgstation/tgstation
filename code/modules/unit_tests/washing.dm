/datum/unit_test/washing
	/// Stuff we want to test that isn't cleanables, just to make sure they are getting cleaned when they should
	var/list/cleanable_bonus_list = list(
		/obj/effect/rune,
		/obj/item/clothing/gloves/color/black,
		/mob/living/carbon/human/dummy/consistent,
	)

	/// Tracks if we caught the clean signal, to know we washed successfully
	VAR_PRIVATE/clean_sig_caught = 0

/datum/unit_test/washing/Run()
	for(var/i in subtypesof(/obj/effect/decal/cleanable) + cleanable_bonus_list)
		var/atom/movable/to_clean = allocate(i)
		var/mopable = HAS_TRAIT(to_clean, TRAIT_MOPABLE)

		clean_sig_caught = 0
		RegisterSignal(to_clean, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_caught))
		run_loc_floor_bottom_left.wash(CLEAN_ALL)
		// mopables are cleaned when their turf is cleaned
		if(mopable)
			if(clean_sig_caught == 0)
				TEST_FAIL("[i] was not cleaned when its turf was cleaned (cleaning only mopables)!")
			if(clean_sig_caught > 1)
				TEST_FAIL("[i] was cleaned more than once when its turf was cleaned (cleaning only mopables)!")
		// non-mopables require the all_contents = TRUE flag to be cleaned
		else
			if(clean_sig_caught != 0)
				TEST_FAIL("[i] was cleaned when its turf was cleaned (cleaning only mopables)!")
			run_loc_floor_bottom_left.wash(CLEAN_ALL, TRUE)
			if(clean_sig_caught == 0)
				TEST_FAIL("[i] was not cleaned when its turf was cleaned (cleaning all contents)!")
			if(clean_sig_caught > 1)
				TEST_FAIL("[i] was cleaned more than once when its turf was cleaned (cleaning all contents)!")

		if(!QDELETED(to_clean))
			if(istype(to_clean, /obj/effect/decal/cleanable))
				TEST_FAIL("[i] was not deleted when its turf was cleaned!")
			qdel(to_clean)

/datum/unit_test/washing/proc/clean_caught(...)
	SIGNAL_HANDLER

	clean_sig_caught += 1
	return COMPONENT_CLEANED
