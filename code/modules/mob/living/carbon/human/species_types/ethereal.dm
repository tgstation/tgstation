/datum/species/ethereal
	name = "\improper Ethereal"
	id = SPECIES_ETHEREAL
	meat = /obj/item/food/meat/slab/human/mutant/ethereal
	mutantlungs = /obj/item/organ/lungs/ethereal
	mutantstomach = /obj/item/organ/stomach/ethereal
	mutanttongue = /obj/item/organ/tongue/ethereal
	mutantheart = /obj/item/organ/heart/ethereal
	exotic_blood = /datum/reagent/consumable/liquidelectricity //Liquid Electricity. fuck you think of something better gamer
	exotic_bloodtype = "LE"
	siemens_coeff = 0.5 //They thrive on energy
	payday_modifier = 1.0
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_FIXED_MUTANT_COLORS,
		TRAIT_AGENDER,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_cookie = /obj/item/food/energybar
	species_language_holder = /datum/language_holder/ethereal
	sexes = FALSE //no fetish content allowed
	// Body temperature for ethereals is much higher than humans as they like hotter environments
	bodytemp_normal = (BODYTEMP_NORMAL + 50)
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // about 150C
	// Cold temperatures hurt faster as it is harder to move with out the heat energy
	bodytemp_cold_damage_limit = (T20C - 10) // about 10c
	hair_color_mode = USE_FIXED_MUTANT_COLOR
	hair_alpha = 140
	facial_hair_alpha = 140

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ethereal,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ethereal,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ethereal,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ethereal,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ethereal,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ethereal,
	)

	var/current_color
	var/default_color
	var/EMPeffect = FALSE
	var/emageffect = FALSE
	var/obj/effect/dummy/lighting_obj/ethereal_light

/datum/species/ethereal/Destroy(force)
	QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/on_species_gain(mob/living/carbon/human/new_ethereal, datum/species/old_species, pref_load)
	. = ..()
	if(!ishuman(new_ethereal))
		return
	default_color = new_ethereal.dna.features["ethcolor"]
	RegisterSignal(new_ethereal, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag_act))
	RegisterSignal(new_ethereal, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	RegisterSignal(new_ethereal, COMSIG_ATOM_SABOTEUR_ACT, PROC_REF(hit_by_saboteur))
	RegisterSignal(new_ethereal, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))
	RegisterSignal(new_ethereal, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(refresh_light_color))
	ethereal_light = new_ethereal.mob_light(light_type = /obj/effect/dummy/lighting_obj/moblight/species)
	refresh_light_color(new_ethereal)

	var/obj/item/organ/heart/ethereal/ethereal_heart = new_ethereal.get_organ_slot(ORGAN_SLOT_HEART)
	ethereal_heart.ethereal_color = default_color

	for(var/obj/item/bodypart/limb as anything in new_ethereal.bodyparts)
		if(limb.limb_id == SPECIES_ETHEREAL)
			limb.update_limb(is_creating = TRUE)

/datum/species/ethereal/on_species_loss(mob/living/carbon/human/former_ethereal, datum/species/new_species, pref_load)
	UnregisterSignal(former_ethereal, list(
		COMSIG_ATOM_EMAG_ACT,
		COMSIG_ATOM_EMP_ACT,
		COMSIG_ATOM_SABOTEUR_ACT,
		COMSIG_LIGHT_EATER_ACT,
		COMSIG_LIVING_HEALTH_UPDATE,
	))
	QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/randomize_features()
	var/list/features = ..()
	features["ethcolor"] = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]
	return features

/datum/species/ethereal/proc/refresh_light_color(mob/living/carbon/human/ethereal)
	SIGNAL_HANDLER
	if(isnull(ethereal_light))
		return
	if(ethereal.stat != DEAD && !EMPeffect)
		var/healthpercent = max(ethereal.health, 0) / 100
		if(!emageffect)
			var/static/list/skin_color = rgb2num("#eda495")
			var/list/colors = rgb2num(ethereal.dna.features["ethcolor"])
			var/list/built_color = list()
			for(var/i in 1 to 3)
				built_color += skin_color[i] + ((colors[i] - skin_color[i]) * healthpercent)
			current_color = rgb(built_color[1], built_color[2], built_color[3])

		ethereal_light.set_light_range_power_color(1 + (2 * healthpercent), 1 + (1 * healthpercent), current_color)
		ethereal_light.set_light_on(TRUE)
		fixed_mut_color = current_color
		ethereal.update_body()
		ethereal.set_facial_haircolor(current_color, override = TRUE, update = FALSE)
		ethereal.set_haircolor(current_color, override = TRUE,  update = TRUE)
	else
		ethereal_light.set_light_on(FALSE)
		var/dead_color = rgb(128,128,128)
		fixed_mut_color = dead_color
		ethereal.update_body()
		ethereal.set_facial_haircolor(dead_color, override = TRUE, update = FALSE)
		ethereal.set_haircolor(dead_color, override = TRUE, update = TRUE)

/datum/species/ethereal/proc/on_emp_act(mob/living/carbon/human/source, severity, protection)
	SIGNAL_HANDLER
	if(protection & EMP_PROTECT_SELF)
		return
	EMPeffect = TRUE
	refresh_light_color(source)
	to_chat(source, span_notice("You feel the light of your body leave you."))
	switch(severity)
		if(EMP_LIGHT)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), source), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 10 seconds
		if(EMP_HEAVY)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), source), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 20 seconds

/datum/species/ethereal/proc/hit_by_saboteur(mob/living/carbon/human/source, disrupt_duration)
	EMPeffect = TRUE
	refresh_light_color(source)
	to_chat(source, span_warning("Something inside of you crackles in a bad way."))
	source.take_bodypart_damage(burn = 3, wound_bonus = CANT_WOUND)
	addtimer(CALLBACK(src, PROC_REF(stop_emp), source), disrupt_duration, TIMER_UNIQUE|TIMER_OVERRIDE)
	return TRUE

/datum/species/ethereal/proc/on_emag_act(mob/living/carbon/human/source, mob/user)
	SIGNAL_HANDLER
	if(emageffect)
		return FALSE
	emageffect = TRUE
	if(user)
		to_chat(user, span_notice("You tap [source] on the back with your card."))
	source.visible_message(span_danger("[source] starts flickering in an array of colors!"))
	handle_emag(source)
	addtimer(CALLBACK(src, PROC_REF(stop_emag), source), 2 MINUTES) //Disco mode for 2 minutes! This doesn't affect the ethereal at all besides either annoying some players, or making someone look badass.
	return TRUE

/// Special handling for getting hit with a light eater
/datum/species/ethereal/proc/on_light_eater(mob/living/carbon/human/source, datum/light_eater)
	SIGNAL_HANDLER
	source.emp_act(EMP_LIGHT)
	return COMPONENT_BLOCK_LIGHT_EATER

/datum/species/ethereal/proc/stop_emp(mob/living/carbon/human/ethereal)
	EMPeffect = FALSE
	refresh_light_color(ethereal)
	to_chat(ethereal, span_notice("You feel more energized as your shine comes back."))

/datum/species/ethereal/proc/handle_emag(mob/living/carbon/human/ethereal)
	if(!emageffect)
		return
	current_color = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]
	refresh_light_color(ethereal)
	addtimer(CALLBACK(src, PROC_REF(handle_emag), ethereal), 0.5 SECONDS)

/datum/species/ethereal/proc/stop_emag(mob/living/carbon/human/ethereal)
	emageffect = FALSE
	refresh_light_color(ethereal)
	ethereal.visible_message(span_danger("[ethereal] stops flickering and goes back to their normal state!"))

/datum/species/ethereal/get_features()
	var/list/features = ..()

	features += "feature_ethcolor"

	return features

/datum/species/ethereal/get_scream_sound(mob/living/carbon/human/ethereal)
	return pick(
		'sound/mobs/humanoids/ethereal/ethereal_scream_1.ogg',
		'sound/mobs/humanoids/ethereal/ethereal_scream_2.ogg',
		'sound/mobs/humanoids/ethereal/ethereal_scream_3.ogg',
	)

/datum/species/ethereal/get_physical_attributes()
	return "Ethereals process electricity as their power supply, not food, and are somewhat resistant to it.\
		They do so via their crystal core, their equivalent of a human heart, which will also encase them in a reviving crystal if they die.\
		However, their skin is very thin and easy to pierce with brute weaponry."

/datum/species/ethereal/get_species_description()
	return "Coming from the planet of Sprout, the theocratic ethereals are \
		separated socially by caste, and espouse a dogma of aiding the weak and \
		downtrodden."

/datum/species/ethereal/get_species_lore()
	return list(
		"Ethereals are a species native to the planet Sprout. \
		When they were originally discovered, they were at a medieval level of technological progression, \
		but due to their natural acclimation with electricity, they felt easy among the large Nanotrasen installations.",
	)

/datum/species/ethereal/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shockingly Tasty",
			SPECIES_PERK_DESC = "Ethereals can feed on electricity from APCs, and do not otherwise need to eat.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Disco Ball",
			SPECIES_PERK_DESC = "Ethereals passively generate their own light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "gem",
			SPECIES_PERK_NAME = "Crystal Core",
			SPECIES_PERK_DESC = "The Ethereal's heart will encase them in crystal should they die, returning them to life after a time - \
				at the cost of a permanent brain trauma.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Elemental Attacker",
			SPECIES_PERK_DESC = "Ethereals deal burn damage with their punches instead of brute.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Starving Artist",
			SPECIES_PERK_DESC = "Ethereals take toxin damage while starving.",
		),
	)

	return to_add

/datum/species/ethereal/lustrous //Ethereal pirates with an inherent bluespace prophet trauma.
	name = "Lustrous"
	id = SPECIES_ETHEREAL_LUSTROUS
	examine_limb_id = SPECIES_ETHEREAL
	mutantbrain = /obj/item/organ/brain/lustrous
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_FIXED_MUTANT_COLORS,
		TRAIT_AGENDER,
		TRAIT_NOBREATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_VIRUSIMMUNE,
	)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ethereal/lustrous,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ethereal,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ethereal,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ethereal,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ethereal,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ethereal,
	)

/datum/species/ethereal/lustrous/get_physical_attributes()
	return "Lustrous are what remains of an Ethereal after freebasing esoteric drugs. \
		They are pressure immune, virus immune, can see bluespace tears in reality, and have a really weird scream. They remain vulnerable to physical damage."

/datum/species/ethereal/lustrous/get_scream_sound(mob/living/carbon/human/ethereal)
	return pick(
		'sound/mobs/humanoids/ethereal/lustrous_scream_1.ogg',
		'sound/mobs/humanoids/ethereal/lustrous_scream_2.ogg',
		'sound/mobs/humanoids/ethereal/lustrous_scream_3.ogg',
	)

/datum/species/ethereal/lustrous/on_species_gain(mob/living/carbon/new_lustrous, datum/species/old_species, pref_load)
	..()
	default_color = new_lustrous.dna.features["ethcolor"]
	new_lustrous.dna.features["ethcolor"] = GLOB.color_list_lustrous[pick(GLOB.color_list_lustrous)] //Picks one of 5 lustrous-specific colors.
