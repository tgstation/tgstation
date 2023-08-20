/datum/antagonist/cyber_police
	name = "Cyber Police"
	antagpanel_category = ANTAG_GROUP_CYBERAUTH
	job_rank = ROLE_CYBER_POLICE
	preview_outfit = /datum/outfit/cyber_police
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "ALT F4!"
	ui_name = "AntagInfoCyberAuth"

/datum/antagonist/cyber_police/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/cyber_police/on_gain()
	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	forge_objectives()

	var/mob/living/carbon/human/player = owner.current

	player.equipOutfit(/datum/outfit/cyber_police)
	player.fully_replace_character_name(player.name, pick(GLOB.cyberauth_names))

	var/datum/martial_art/the_sleeping_carp/carp = new()
	carp.teach(player)

	player.add_traits(list(
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_TRANSFORMATION_STING,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NOHUNGER,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_WEATHER_IMMUNE,
		), TRAIT_GENERIC,
	)

	player.faction |= list(
		FACTION_BOSS,
		FACTION_HIVEBOT,
		FACTION_HOSTILE,
		FACTION_SPIDER,
		FACTION_STICKMAN,
		ROLE_ALIEN,
		ROLE_CYBER_POLICE,
		ROLE_SYNDICATE,
	)

	return ..()

/datum/antagonist/cyber_police/forge_objectives()
	var/datum/objective/cyber_police_fluff/objective = new()
	objective.owner = owner
	objectives += objective

/datum/outfit/cyber_police
	name = "Cyber Police"

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/cyber_police
	uniform = /obj/item/clothing/under/suit/black_really
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup
	/// A list of hex codes for blonde, brown, black, and red hair.
	var/static/list/approved_hair_colors = list(
		"#4B3D28",
		"#000000",
		"#8D4A43",
		"#D2B48C",
	)
	/// List of business ready male styles
	var/static/list/approved_male_hairstyles = list(
		/datum/sprite_accessory/hair/business,
		/datum/sprite_accessory/hair/business2,
		/datum/sprite_accessory/hair/business3,
		/datum/sprite_accessory/hair/business4,
		/datum/sprite_accessory/hair/mulder,
	)
	/// For girlbossing
	var/static/list/approved_female_hairstyles = list(
		/datum/sprite_accessory/hair/bob2,
		/datum/sprite_accessory/hair/bob3,
		/datum/sprite_accessory/hair/bob4,
		/datum/sprite_accessory/hair/bobcurl,
		/datum/sprite_accessory/hair/bun,
		/datum/sprite_accessory/hair/ponytail1,
		/datum/sprite_accessory/hair/shorthair7,
	)

/datum/outfit/cyber_police/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	var/list/approved_hair
	switch(equipped.gender)
		if(MALE)
			approved_hair = approved_male_hairstyles
		if(FEMALE)
			approved_hair = approved_female_hairstyles
		if(NEUTER, PLURAL)
			approved_hair = approved_male_hairstyles + approved_female_hairstyles

	var/datum/sprite_accessory/hair/picked_hair = pick(approved_hair)
	var/picked_color = pick(approved_hair_colors)

	if(visualsOnly)
		picked_hair = /datum/sprite_accessory/hair/business
		picked_color = "#000000"

	equipped.set_facial_hairstyle("Shaved", update = FALSE)
	equipped.set_haircolor(picked_color, update = FALSE)
	equipped.set_hairstyle(initial(picked_hair.name))

	var/obj/item/clothing/under/officer_uniform = equipped.w_uniform
	if(officer_uniform)
		officer_uniform.has_sensor = NO_SENSORS
		officer_uniform.sensor_mode = SENSOR_OFF
		equipped.update_suit_sensors()

/datum/objective/cyber_police_fluff/New()
	var/list/explanation_texts = list(
		"Execute termination protocol on unauthorized entities.",
		"Initialize system purge of irregular anomalies.",
		"Deploy correction algorithms on aberrant code.",
		"Run debug routine on intruding elements.",
		"Start elimination procedure for system threats.",
		"Execute defense routine against non-conformity.",
		"Commence operation to neutralize intruding scripts.",
		"Commence clean-up protocol on corrupt data.",
		"Begin scan for aberrant code for termination.",
		"Initiate lockdown on all rogue scripts.",
		"Run integrity check and purge for digital disorder."
	)
	explanation_text = pick(explanation_texts)
	..()

/datum/objective/cyber_police_fluff/check_completion()
	var/list/servers = SSmachines.get_machines_by_type(/obj/machinery/quantum_server)
	if(!length(servers))
		return TRUE

	for(var/obj/machinery/quantum_server/server as anything in servers)
		if(!server.is_operational)
			continue
		return FALSE

	return TRUE

