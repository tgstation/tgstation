/// Verifies that all glands for an egg are valid
/datum/unit_test/mob_spawn

/datum/unit_test/mob_spawn/Run()

	//these are not expected to be filled out as they are base prototypes
	var/list/prototypes = list(
		/obj/effect/mob_spawn,
		/obj/effect/mob_spawn/corpse,
		/obj/effect/mob_spawn/corpse/human,
		/obj/effect/mob_spawn/ghost_role,
		/obj/effect/mob_spawn/ghost_role/human,
	)

	//ghost role checks
	for(var/role_spawn_path in subtypesof(/obj/effect/mob_spawn/ghost_role) - prototypes)
		var/obj/effect/mob_spawn/ghost_role/ghost_role = allocate(role_spawn_path)

		if(ghost_role.outfit_override)
			TEST_FAIL("[ghost_role.type] has a defined \"outfit_override\" list, which is only for mapping. Do not set this!")

		if(ghost_role.mob_type != /mob/living/carbon/human)
			//vars that must not be set if the mob type isn't human
			var/list/human_only_vars = list(
				"mob_species",
				"outfit",
				"hairstyle",
				"facial_hairstyle",
				"haircolor",
				"facial_haircolor",
				"skin_tone",
			)
			for(var/human_only_var in human_only_vars)
				if(ghost_role.vars[human_only_var])
					TEST_FAIL("[ghost_role.type] has a defined \"[human_only_var]\" HUMAN ONLY var, but this type doesn't spawn humans.")

		//vars that must be set on
		var/list/required_vars = list(
			//mob_type is not included because the errors on it are loud and some types choose their mob_type on selection
			"prompt_name" = "Your ghost role has broken tgui without it.",
			//these must be set even if show_flavor is false because the spawn menu still uses them and in 2021 we simply must have higher quality roles
			"you_are_text" = "Spawners menu uses it.",
			"flavour_text" = "Spawners menu uses it.",
		)
		for(var/required_var in required_vars)
			if(required_var == "prompt_name" && !ghost_role.prompt_ghost)
				continue //only case it makes sense why you shouldn't have a prompt_name
			if(!ghost_role.vars[required_var])
				TEST_FAIL("[ghost_role.type] must have \"[required_var]\" defined. Reason: [required_vars[required_var]]")

		qdel(ghost_role)
