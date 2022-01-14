/datum/species/ethereal
	name = "Ethereal"
	id = SPECIES_ETHEREAL
	attack_verb = "burn"
	attack_sound = 'sound/weapons/etherealhit.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	meat = /obj/item/food/meat/slab/human/mutant/ethereal
	mutantlungs = /obj/item/organ/lungs/ethereal
	mutantstomach = /obj/item/organ/stomach/ethereal
	mutanttongue = /obj/item/organ/tongue/ethereal
	mutantheart = /obj/item/organ/heart/ethereal
	exotic_blood = /datum/reagent/consumable/liquidelectricity //Liquid Electricity. fuck you think of something better gamer
	siemens_coeff = 0.5 //They thrive on energy
	brutemod = 1.25 //They're weak to punches
	payday_modifier = 0.75
	attack_type = BURN //burn bish
	damage_overlay_type = "" //We are too cool for regular damage overlays
	species_traits = list(DYNCOLORS, AGENDER, HAIR, FACEHAIR, HAS_FLESH, HAS_BONE) // i mean i guess they have blood so they can have wounds too
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/ethereal
	sexes = FALSE //no fetish content allowed
	toxic_food = NONE
	// Body temperature for ethereals is much higher then humans as they like hotter environments
	bodytemp_normal = (BODYTEMP_NORMAL + 50)
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // about 150C
	// Cold temperatures hurt faster as it is harder to move with out the heat energy
	bodytemp_cold_damage_limit = (T20C - 10) // about 10c
	hair_color = "fixedmutcolor"
	hair_alpha = 140
	var/current_color
	var/EMPeffect = FALSE
	var/emageffect = FALSE
	var/r1
	var/g1
	var/b1
	var/static/r2 = 237
	var/static/g2 = 164
	var/static/b2 = 149
	var/obj/effect/dummy/lighting_obj/ethereal_light

/datum/species/ethereal/Destroy(force)
	if(ethereal_light)
		QDEL_NULL(ethereal_light)
	return ..()


/datum/species/ethereal/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/ethereal = C
	default_color = ethereal.dna.features["ethcolor"]
	r1 = GETREDPART(default_color)
	g1 = GETGREENPART(default_color)
	b1 = GETBLUEPART(default_color)
	RegisterSignal(ethereal, COMSIG_ATOM_EMAG_ACT, .proc/on_emag_act)
	RegisterSignal(ethereal, COMSIG_ATOM_EMP_ACT, .proc/on_emp_act)
	RegisterSignal(ethereal, COMSIG_LIGHT_EATER_ACT, .proc/on_light_eater)
	ethereal_light = ethereal.mob_light()
	spec_updatehealth(ethereal)
	C.set_safe_hunger_level()

	var/obj/item/organ/heart/ethereal/ethereal_heart = C.getorganslot(ORGAN_SLOT_HEART)
	ethereal_heart.ethereal_color = default_color

/datum/species/ethereal/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	UnregisterSignal(C, COMSIG_ATOM_EMAG_ACT)
	UnregisterSignal(C, COMSIG_ATOM_EMP_ACT)
	UnregisterSignal(C, COMSIG_LIGHT_EATER_ACT)
	QDEL_NULL(ethereal_light)
	return ..()


/datum/species/ethereal/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_ethereal_name()

	var/randname = ethereal_name()

	return randname


/datum/species/ethereal/spec_updatehealth(mob/living/carbon/human/H)
	. = ..()
	if(H.stat != DEAD && !EMPeffect)
		var/healthpercent = max(H.health, 0) / 100
		if(!emageffect)
			current_color = rgb(r2 + ((r1-r2)*healthpercent), g2 + ((g1-g2)*healthpercent), b2 + ((b1-b2)*healthpercent))
		ethereal_light.set_light_range_power_color(1 + (2 * healthpercent), 1 + (1 * healthpercent), current_color)
		ethereal_light.set_light_on(TRUE)
		fixed_mut_color = current_color
	else
		ethereal_light.set_light_on(FALSE)
		fixed_mut_color = rgb(128,128,128)
	H.update_body()
	H.update_hair() // This should fix the ethereal hair not changing with body, no clue as to why hair is not in update_body but okay

/datum/species/ethereal/proc/on_emp_act(mob/living/carbon/human/H, severity)
	SIGNAL_HANDLER
	EMPeffect = TRUE
	spec_updatehealth(H)
	to_chat(H, span_notice("You feel the light of your body leave you."))
	switch(severity)
		if(EMP_LIGHT)
			addtimer(CALLBACK(src, .proc/stop_emp, H), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 10 seconds
		if(EMP_HEAVY)
			addtimer(CALLBACK(src, .proc/stop_emp, H), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 20 seconds

/datum/species/ethereal/proc/on_emag_act(mob/living/carbon/human/H, mob/user)
	SIGNAL_HANDLER
	if(emageffect)
		return
	emageffect = TRUE
	if(user)
		to_chat(user, span_notice("You tap [H] on the back with your card."))
	H.visible_message(span_danger("[H] starts flickering in an array of colors!"))
	handle_emag(H)
	addtimer(CALLBACK(src, .proc/stop_emag, H), 2 MINUTES) //Disco mode for 2 minutes! This doesn't affect the ethereal at all besides either annoying some players, or making someone look badass.

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
	addtimer(CALLBACK(src, .proc/handle_emag, H), 5) //Call ourselves every 0.5 seconds to change color

/datum/species/ethereal/proc/stop_emag(mob/living/carbon/human/H)
	emageffect = FALSE
	spec_updatehealth(H)
	H.visible_message(span_danger("[H] stops flickering and goes back to their normal state!"))

/datum/species/ethereal/get_features()
	var/list/features = ..()

	features += "feature_ethcolor"

	return features

/datum/species/ethereal/get_scream_sound(mob/living/carbon/human/ethereal)
	return pick('sound/voice/ethereal/ethereal_scream_1.ogg',
				'sound/voice/ethereal/ethereal_scream_2.ogg',
				'sound/voice/ethereal/ethereal_scream_3.ogg')
