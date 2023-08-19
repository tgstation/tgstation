/datum/species/ethereal
	name = "\improper Ethereal"
	id = SPECIES_ETHEREAL
	meat = /obj/item/food/meat/slab/human/mutant/ethereal
	mutantlungs = /obj/item/organ/internal/lungs/ethereal
	mutantstomach = /obj/item/organ/internal/stomach/ethereal
	mutanttongue = /obj/item/organ/internal/tongue/ethereal
	mutantheart = /obj/item/organ/internal/heart/ethereal
	exotic_blood = /datum/reagent/consumable/liquidelectricity //Liquid Electricity. fuck you think of something better gamer
	exotic_bloodtype = "LE"
	siemens_coeff = 0.5 //They thrive on energy
	payday_modifier = 1.0
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_MUTANT_COLORS,
		TRAIT_FIXED_MUTANT_COLORS,
		TRAIT_FIXED_HAIRCOLOR,
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
	hair_color = "fixedmutcolor"
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
	var/r1
	var/g1
	var/b1
	var/static/r2 = 237
	var/static/g2 = 164
	var/static/b2 = 149
	var/EMPeffect = FALSE
	var/emageffect = FALSE
	var/obj/effect/dummy/lighting_obj/ethereal_light

/datum/species/ethereal/Destroy(force)
	QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/on_species_gain(mob/living/carbon/new_ethereal, datum/species/old_species, pref_load)
	. = ..()
	if(!ishuman(new_ethereal))
		return
	var/mob/living/carbon/human/ethereal = new_ethereal
	default_color = ethereal.dna.features["ethcolor"]
	fixed_hair_color = default_color
	r1 = GETREDPART(default_color)
	g1 = GETGREENPART(default_color)
	b1 = GETBLUEPART(default_color)
	RegisterSignal(ethereal, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag_act))
	RegisterSignal(ethereal, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	RegisterSignal(ethereal, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))
	ethereal_light = ethereal.mob_light(light_type = /obj/effect/dummy/lighting_obj/moblight/species)
	spec_updatehealth(ethereal)
	new_ethereal.set_safe_hunger_level()
	update_mail_goodies(ethereal)

	var/obj/item/organ/internal/heart/ethereal/ethereal_heart = new_ethereal.get_organ_slot(ORGAN_SLOT_HEART)
	ethereal_heart.ethereal_color = default_color

	for(var/obj/item/bodypart/limb as anything in new_ethereal.bodyparts)
		if(limb.limb_id == SPECIES_ETHEREAL)
			limb.update_limb(is_creating = TRUE)

/datum/species/ethereal/on_species_loss(mob/living/carbon/human/former_ethereal, datum/species/new_species, pref_load)
	UnregisterSignal(former_ethereal, COMSIG_ATOM_EMAG_ACT)
	UnregisterSignal(former_ethereal, COMSIG_ATOM_EMP_ACT)
	UnregisterSignal(former_ethereal, COMSIG_LIGHT_EATER_ACT)
	QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/update_quirk_mail_goodies(mob/living/carbon/human/recipient, datum/quirk/quirk, list/mail_goodies = list())
	if(istype(quirk, /datum/quirk/blooddeficiency))
		mail_goodies += list(
			/obj/item/reagent_containers/blood/ethereal
		)
	return ..()

/datum/species/ethereal/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_ethereal_name()

	var/randname = ethereal_name()

	return randname

/datum/species/ethereal/randomize_features(mob/living/carbon/human/human_mob)
	human_mob.dna.features["ethcolor"] = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]

/datum/species/ethereal/spec_updatehealth(mob/living/carbon/human/ethereal)
	. = ..()
	if(!ethereal_light)
		return
	if(default_color != ethereal.dna.features["ethcolor"])
		var/new_color = ethereal.dna.features["ethcolor"]
		r1 = GETREDPART(new_color)
		g1 = GETGREENPART(new_color)
		b1 = GETBLUEPART(new_color)
	if(ethereal.stat != DEAD && !EMPeffect)
		var/healthpercent = max(ethereal.health, 0) / 100
		if(!emageffect)
			current_color = rgb(r2 + ((r1-r2)*healthpercent), g2 + ((g1-g2)*healthpercent), b2 + ((b1-b2)*healthpercent))
		ethereal_light.set_light_range_power_color(1 + (2 * healthpercent), 1 + (1 * healthpercent), current_color)
		ethereal_light.set_light_on(TRUE)
		fixed_mut_color = current_color
		fixed_hair_color = current_color
		ethereal.update_body()
		ethereal.set_facial_haircolor(current_color, override = TRUE, update = FALSE)
		ethereal.set_haircolor(current_color, override = TRUE,  update = TRUE)
	else
		ethereal_light.set_light_on(FALSE)
		var/dead_color = rgb(128,128,128)
		fixed_mut_color = dead_color
		fixed_hair_color = dead_color
		ethereal.update_body()
		ethereal.set_facial_haircolor(dead_color, override = TRUE, update = FALSE)
		ethereal.set_haircolor(dead_color, override = TRUE, update = TRUE)

/datum/species/ethereal/proc/on_emp_act(mob/living/carbon/human/H, severity, protection)
	SIGNAL_HANDLER
	if(protection & EMP_PROTECT_SELF)
		return
	EMPeffect = TRUE
	spec_updatehealth(H)
	to_chat(H, span_notice("You feel the light of your body leave you."))
	switch(severity)
		if(EMP_LIGHT)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), H), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 10 seconds
		if(EMP_HEAVY)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), H), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 20 seconds

/datum/species/ethereal/proc/on_emag_act(mob/living/carbon/human/H, mob/user)
	SIGNAL_HANDLER
	if(emageffect)
		return FALSE
	emageffect = TRUE
	if(user)
		to_chat(user, span_notice("You tap [H] on the back with your card."))
	H.visible_message(span_danger("[H] starts flickering in an array of colors!"))
	handle_emag(H)
	addtimer(CALLBACK(src, PROC_REF(stop_emag), H), 2 MINUTES) //Disco mode for 2 minutes! This doesn't affect the ethereal at all besides either annoying some players, or making someone look badass.
	return TRUE

/// Special handling for getting hit with a light eater
/datum/species/ethereal/proc/on_light_eater(mob/living/carbon/human/source, datum/light_eater)
	SIGNAL_HANDLER
	source.emp_act(EMP_LIGHT)
	return COMPONENT_BLOCK_LIGHT_EATER

/datum/species/ethereal/proc/stop_emp(mob/living/carbon/human/H)
	EMPeffect = FALSE
	spec_updatehealth(H)
	to_chat(H, span_notice("You feel more energized as your shine comes back."))


/datum/species/ethereal/proc/handle_emag(mob/living/carbon/human/H)
	if(!emageffect)
		return
	current_color = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]
	spec_updatehealth(H)
	addtimer(CALLBACK(src, PROC_REF(handle_emag), H), 5) //Call ourselves every 0.5 seconds to change color

/datum/species/ethereal/proc/stop_emag(mob/living/carbon/human/H)
	emageffect = FALSE
	spec_updatehealth(H)
	H.visible_message(span_danger("[H] stops flickering and goes back to their normal state!"))

/datum/species/ethereal/get_features()
	var/list/features = ..()

	features += "feature_ethcolor"

	return features

/datum/species/ethereal/get_scream_sound(mob/living/carbon/human/ethereal)
	return pick(
		'sound/voice/ethereal/ethereal_scream_1.ogg',
		'sound/voice/ethereal/ethereal_scream_2.ogg',
		'sound/voice/ethereal/ethereal_scream_3.ogg',
	)

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
	mutantbrain = /obj/item/organ/internal/brain/lustrous
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_MUTANT_COLORS,
		TRAIT_FIXED_MUTANT_COLORS,
		TRAIT_FIXED_HAIRCOLOR,
		TRAIT_AGENDER,
		TRAIT_TENACIOUS,
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

/datum/species/ethereal/lustrous/get_scream_sound(mob/living/carbon/human/ethereal)
	return pick(
		'sound/voice/ethereal/lustrous_scream_1.ogg',
		'sound/voice/ethereal/lustrous_scream_2.ogg',
		'sound/voice/ethereal/lustrous_scream_3.ogg',
	)

/datum/species/ethereal/lustrous/on_species_gain(mob/living/carbon/new_lustrous, datum/species/old_species, pref_load)
	..()
	default_color = new_lustrous.dna.features["ethcolor"]
	new_lustrous.dna.features["ethcolor"] = GLOB.color_list_lustrous[pick(GLOB.color_list_lustrous)] //Picks one of 5 lustrous-specific colors.
