/obj/item/robot_model
	var/icon/cyborg_icon_override
	var/sleeper_overlay
	var/cyborg_pixel_offset
	/// Alternate icon file used for this module's collapsed UI icon
	var/model_select_alternate_icon
	/// Traits unique to this model, i.e. having a unique dead sprite, being wide or being small enough to reject shrinker modules. Leverages defines in code\__DEFINES\~nova_defines\robot_defines.dm
	/// If a sprite overlaps above the standard height, ensure it is not overlapping icons in the selector wheel.
	var/list/model_features = list()

/obj/item/robot_model/proc/update_tallborg()
	var/mob/living/silicon/robot/cyborg = robot || loc
	if (!istype(robot))
		return
	if (model_features && (TRAIT_R_TALL in model_features))
		cyborg.maptext_height = 48 //Runechat blabla
		cyborg.AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE, 2, -6, sound_vary = TRUE)
		add_verb(cyborg, /mob/living/silicon/robot/proc/robot_lay_down)
		switch(cyborg_base_icon)
			if("mekamine")
				cyborg.AddComponent(/datum/component/robot_smoke)
	else
		cyborg.maptext_height = initial(cyborg.maptext_height)
		cyborg.RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE, 2, -6, sound_vary = TRUE)
		remove_verb(cyborg, /mob/living/silicon/robot/proc/robot_lay_down)
		if(cyborg.GetComponent(/datum/component/robot_smoke))
			qdel(cyborg.GetComponent(/datum/component/robot_smoke))
			QDEL_NULL(cyborg.particles)	// Removing left over particles

// STANDARD
/obj/item/robot_model/standard
	name = "Standard"
	borg_skins = list(
		"Default" = list(SKIN_ICON_STATE = "robot", SKIN_FEATURES = list(TRAIT_R_SMALL)),
	)

// SERVICE
/obj/item/robot_model/service
	special_light_key = null
	borg_skins = list(
		/// 32x32 Skins
		"Waitress" = list(SKIN_ICON_STATE = "service_f", SKIN_LIGHT_KEY = "service"),
		"Butler" = list(SKIN_ICON_STATE = "service_m", SKIN_LIGHT_KEY = "service"),
		"Bro" = list(SKIN_ICON_STATE = "brobot", SKIN_LIGHT_KEY = "service"),
		"Tophat" = list(SKIN_ICON_STATE = "tophat", SKIN_HAT_OFFSET = INFINITY),
		"Kent" = list(SKIN_ICON_STATE = "kent", SKIN_LIGHT_KEY = "medical", SKIN_HAT_OFFSET = 3),
		"Can" = list(SKIN_ICON_STATE = "kent", SKIN_LIGHT_KEY = "medical", SKIN_HAT_OFFSET = 3),
		/// 32x64 skins
		"Meka" = list(SKIN_ICON_STATE = "mekaserve", SKIN_ICON = CYBORG_ICON_SERVICE_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"Meka (Alt)" = list(SKIN_ICON_STATE = "mekaserve_alt", SKIN_LIGHT_KEY = "mekaserve", SKIN_ICON = CYBORG_ICON_SERVICE_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKA" = list(SKIN_ICON_STATE = "fmekaserv", SKIN_ICON = CYBORG_ICON_SERVICE_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKO" = list(SKIN_ICON_STATE = "mmekaserv", SKIN_ICON = CYBORG_ICON_SERVICE_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
	)

// MINING
/obj/item/robot_model/miner
	special_light_key = null
	borg_skins = list(
		/// 32x32 Skins
		"Lavaland" = list(SKIN_ICON_STATE = "miner", SKIN_LIGHT_KEY = "miner"),
		"Asteroid" = list(SKIN_ICON_STATE = "minerOLD", SKIN_LIGHT_KEY = "miner"),
		"Spider Miner" = list(SKIN_ICON_STATE = "spidermin", SKIN_LIGHT_KEY = "miner"),
		/// 32x64 skins
		"Meka" = list(SKIN_ICON_STATE = "mekamine", SKIN_ICON = CYBORG_ICON_MINING_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKA" = list(SKIN_ICON_STATE = "fmekamine", SKIN_ICON = CYBORG_ICON_MINING_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKO" = list(SKIN_ICON_STATE = "mmekamine", SKIN_ICON = CYBORG_ICON_MINING_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15)
	)

// CLOWN
/obj/item/robot_model/clown
	borg_skins = list(
		"Default" = list(SKIN_ICON_STATE = "clown"),
	)

// ENGINEERING
/obj/item/robot_model/engineering
	borg_skins = list(
		/// 32x32 Skins
		"Default" = list(SKIN_ICON_STATE = "engineer", SKIN_FEATURES = list(TRAIT_R_SMALL)),
		/// 32x64 Skins
		"Meka" = list(SKIN_ICON_STATE = "mekaengi", SKIN_ICON = CYBORG_ICON_ENG_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKA" = list(SKIN_ICON_STATE = "fmekaeng", SKIN_ICON = CYBORG_ICON_ENG_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKO" = list(SKIN_ICON_STATE = "mmekaeng", SKIN_ICON = CYBORG_ICON_ENG_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15)
	)

// JANITOR
/obj/item/robot_model/janitor
	borg_skins = list(
		/// 32x32 Skins
		"Default" = list(SKIN_ICON_STATE = "janitor"),
		/// 32x64 Skins
		"Meka" = list(SKIN_ICON_STATE = "mekajani", SKIN_ICON = CYBORG_ICON_JANI_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKA" = list(SKIN_ICON_STATE = "fmekajani", SKIN_ICON = CYBORG_ICON_JANI_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKO" = list(SKIN_ICON_STATE = "mmekajani", SKIN_ICON = CYBORG_ICON_JANI_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15)
	)

// MEDICAL
/obj/item/robot_model/medical
	borg_skins = list(
		/// 32x32 Skins
		"Machinified Doctor" = list(SKIN_ICON_STATE = "medical", SKIN_TRAITS = list(TRAIT_R_SMALL)),
		"Qualified Doctor" = list(SKIN_ICON_STATE = "qualified_doctor"),
		/// 32x64 Skins
		"Meka" = list(SKIN_ICON_STATE = "mekamed", SKIN_ICON = CYBORG_ICON_MED_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKA" = list(SKIN_ICON_STATE = "fmekamed", SKIN_ICON = CYBORG_ICON_MED_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKO" = list(SKIN_ICON_STATE = "mmekamed", SKIN_ICON = CYBORG_ICON_MED_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15)
	)

// PEACEKEEPER
/obj/item/robot_model/peacekeeper
	borg_skins = list(
		/// 32x32 Skins
		"Default" = list(SKIN_ICON_STATE = "peace"),
		/// 32x64 Skins
		"Meka" = list(SKIN_ICON_STATE = "mekapeace", SKIN_ICON = CYBORG_ICON_PEACEKEEPER_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKA" = list(SKIN_ICON_STATE = "fmekapeace", SKIN_ICON = CYBORG_ICON_PEACEKEEPER_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15),
		"NiKO" = list(SKIN_ICON_STATE = "mmekapeace", SKIN_ICON = CYBORG_ICON_PEACEKEEPER_TALL, SKIN_FEATURES = list(TRAIT_R_UNIQUEWRECK, TRAIT_R_UNIQUETIP, TRAIT_R_TALL), SKIN_HAT_OFFSET = 15)
	)

// SECURITY
/obj/item/robot_model/security
	borg_skins = list(
		/// 32x32 Skins
		"Default" = list(SKIN_ICON_STATE = "sec"),
	)
