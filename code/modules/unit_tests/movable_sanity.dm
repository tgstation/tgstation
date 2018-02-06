//instances most /obj and /mobs to check for runtimes

/datum/unit_test/movable_sanity	
	//list of instantiation arguments keyed by type
	//these extend to child types unless otherwise overwritten
	var/list/arguments = list(

	)

/datum/unit_test/movable_sanity/Run()
	//list of things not to be tested
	//These should not be buggy things but rather things that are dependencies of others
	var/list/blacklist = typecacheof(list(
		/obj/effect/abstract/proximity_checker,
		/obj/effect/hallucination,
		/obj/docking_port,
		/obj/screen,
	)) + list(
		//single entries
		/obj = TRUE,
		/obj/item = TRUE,
		/obj/effect = TRUE,
		/obj/effect/abstract = TRUE,
		/mob = TRUE,
		/mob/living = TRUE,
		/mob/dead = TRUE,
		/mob/living/simple_animal = TRUE,
		/mob/living/carbon = TRUE,
		/mob/living/simple_animal/hostile = TRUE,
		/obj/item/gun/magic/staff = TRUE,
		/obj/item/storage/fancy = TRUE
	)

	for(var/I in typesof(/obj))
		if(blacklist[I])
			continue
		ProcessType(I)
	
	for(var/I in typesof(/mob))
		if(blacklist[I])
			continue
		ProcessType(I)

/datum/unit_test/movable_sanity/proc/ProcessType(target_type)
	var/list/target_arguments
	var/list/_arguments = arguments
	for(var/current_type = target_type; !target_arguments && current_type != /atom/movable; current_type = type2parent(current_type))
		target_arguments = _arguments[current_type]
	
	var/atom/movable/instance
	if(target_arguments)
		instance = new target_type(list(run_loc_bottom_left) + target_arguments)
	else
		instance = new target_type(run_loc_bottom_left)

	qdel(instance)

	CHECK_TICK
