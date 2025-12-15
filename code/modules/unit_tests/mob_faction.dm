/// Checks if any mob's faction var initial value is not a list, which is not supported by the current code
/datum/unit_test/mob_faction

/datum/unit_test/mob_faction/Run()
	/// Right now taken from create_and_destroy
	var/list/ignored = list(
		/mob/living/carbon,
		/mob/dview,
		/mob/oranges_ear
	)
	ignored += typesof(/mob/eye/imaginary_friend)
	ignored += typesof(/mob/living/silicon/robot/model)
	ignored += typesof(/mob/eye/camera/remote/base_construction)
	ignored += typesof(/mob/eye/camera/remote/shuttle_docker)
	for (var/mob_type in typesof(/mob) - ignored)
		var/mob/mob_instance = allocate(mob_type)
		var/list/mob_faction = mob_instance.get_faction()
		if(isnull(mob_faction))
			continue
		else if (!islist(mob_faction))
			TEST_FAIL("[mob_type] faction variable is not a list or null! Only lazy lists are supported currently (currently set to [mob_faction]).")
		else if (!LAZYLEN(mob_faction))
			TEST_FAIL("[mob_type] faction variable is an empty list! Set to null instead, faction lists are lazy.")
		qdel(mob_instance)
