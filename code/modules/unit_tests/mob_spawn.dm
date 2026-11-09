/// Verifies that all glands for an egg are valid
/datum/unit_test/mob_spawn

/datum/unit_test/mob_spawn/Run()
	// The ghost role that we're going to iterate over. defined all the way up here for easy/cleaner static analysis
	var/obj/effect/mob_spawn/ghost_role/ghost_role

	//these are not expected to be filled out as they are base prototypes
	var/list/prototypes = list(
		/obj/effect/mob_spawn,
		/obj/effect/mob_spawn/corpse,
		/obj/effect/mob_spawn/corpse/human,
		/obj/effect/mob_spawn/ghost_role,
		/obj/effect/mob_spawn/ghost_role/human,
	)

	//vars that must not be set if the mob type isn't human
	var/list/human_only_vars = list(
		NAMEOF(ghost_role, facial_haircolor),
		NAMEOF(ghost_role, facial_hairstyle),
		NAMEOF(ghost_role, haircolor),
		NAMEOF(ghost_role, hairstyle),
		NAMEOF(ghost_role, mob_species),
		NAMEOF(ghost_role, outfit),
		NAMEOF(ghost_role, skin_tone),
	)

	//vars that must be set on all ghost roles.
	var/list/required_vars = list(
		//mob_type is not included because the errors on it are loud and some types choose their mob_type on selection
		NAMEOF(ghost_role, prompt_name) = "Your ghost role has broken tgui without it.",
		//these must be set even if show_flavor is false because the spawn menu still uses them and we simply must have higher quality roles
		NAMEOF(ghost_role, flavour_text) = "Spawners menu uses it.",
		NAMEOF(ghost_role, you_are_text) = "Spawners menu uses it.",
	)

	//ghost role checks - where the actual work is done
	for(var/role_spawn_path in subtypesof(/obj/effect/mob_spawn/ghost_role) - prototypes)
		ghost_role = allocate(role_spawn_path)

		if(ghost_role.outfit_override)
			TEST_FAIL("[ghost_role.type] has a defined \"outfit_override\" list, which is only for mapping. Do not set this!")

		var/human_type = /mob/living/carbon/human // this exists to prevent being caught by checks
		if(ghost_role.mob_type != human_type)
			for(var/human_only_var in human_only_vars)
				if(ghost_role.vars[human_only_var])
					TEST_FAIL("[ghost_role.type] has a defined \"[human_only_var]\" HUMAN ONLY var, but this type doesn't spawn humans.")

		for(var/required_var in required_vars)
			if(required_var == NAMEOF(ghost_role, prompt_name) && !ghost_role.prompt_ghost)
				continue //only case it makes sense why you shouldn't have a prompt_name
			if(!ghost_role.vars[required_var])
				TEST_FAIL("[ghost_role.type] must have \"[required_var]\" defined. Reason: [required_vars[required_var]]")

		qdel(ghost_role)
