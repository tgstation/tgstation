/datum/species/ethereal
	name = "\improper Ethereal"
	id = SPECIES_ETHEREAL
	meat = /obj/item/food/meat/slab/human/mutant/ethereal
	mutantlungs = /obj/item/organ/internal/lungs/ethereal
	mutantstomach = /obj/item/organ/internal/stomach/ethereal
	mutanteyes = /obj/item/organ/internal/eyes/ethereal
	mutanttongue = /obj/item/organ/internal/tongue/ethereal
	mutantheart = /obj/item/organ/internal/heart/ethereal
	external_organs = list(
		/obj/item/organ/external/ethereal_horns = "None",
		/obj/item/organ/external/tail/ethereal = "None")
	exotic_blood = /datum/reagent/consumable/liquidelectricity //Liquid Electricity. fuck you think of something better gamer
	exotic_bloodtype = "LE"
	siemens_coeff = 0.5 //They thrive on energy
	brutemod = 1.25 //They're weak to punches
	payday_modifier = 1
	inherent_traits = list(
		TRAIT_NOHUNGER,
		TRAIT_NO_BLOODLOSS_DAMAGE, //we handle that species-side.
	)
	species_traits = list(
		DYNCOLORS,
		NO_UNDERWEAR,
		HAIR,
		EYECOLOR,
		FACEHAIR,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_cookie = /obj/item/food/energybar
	species_language_holder = /datum/language_holder/ethereal
	toxic_food = NONE
	// Body temperature for ethereals is much higher then humans as they like hotter environments
	bodytemp_normal = (BODYTEMP_NORMAL + 50)
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // about 150C
	// Cold temperatures hurt faster as it is harder to move with out the heat energy
	bodytemp_cold_damage_limit = (T20C - 10) // about 10c
	hair_color = "fixedmutcolor"
	hair_alpha = 180

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ethereal,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ethereal,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ethereal,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ethereal,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ethereal,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ethereal,
	)

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
	var/default_color

/datum/species/ethereal/Destroy(force)
	QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/on_species_gain(mob/living/carbon/new_ethereal, datum/species/old_species, pref_load)
	. = ..()
	if(!ishuman(new_ethereal))
		return
	var/mob/living/carbon/human/ethereal = new_ethereal
	default_color = ethereal.dna.features["ethcolor"]
	r1 = GETREDPART(default_color)
	g1 = GETGREENPART(default_color)
	b1 = GETBLUEPART(default_color)
	RegisterSignal(ethereal, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag_act))
	RegisterSignal(ethereal, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	RegisterSignal(ethereal, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))
	RegisterSignal(new_ethereal, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(on_after_attackedby))
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
	UnregisterSignal(former_ethereal, COMSIG_ATOM_AFTER_ATTACKEDBY)
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


/datum/species/ethereal/spec_life(mob/living/carbon/human/ethereal, seconds_per_tick, times_fired)
	if(ethereal.stat == DEAD)
		return
	adjust_charge(ethereal, -ETHEREAL_BLOOD_CHARGE_FACTOR * seconds_per_tick, TRUE)
	handle_charge(ethereal, seconds_per_tick, times_fired)

/datum/species/ethereal/proc/adjust_charge(mob/living/carbon/human/ethereal, amount, passive)
	if(passive)
		if(ethereal.blood_volume < ETHEREAL_BLOOD_CHARGE_LOWEST_PASSIVE) //Do not apply the clamp if its below the passive reduction level(no infinite blood sorry)
			return
		if(ethereal.blood_volume + amount < ETHEREAL_BLOOD_CHARGE_LOWEST_PASSIVE+1)
			ethereal.blood_volume = ETHEREAL_BLOOD_CHARGE_LOWEST_PASSIVE+1 //bottom them off here if the end result would be less than the stopping point.
		ethereal.blood_volume = clamp(ethereal.blood_volume + amount, ETHEREAL_BLOOD_CHARGE_LOWEST_PASSIVE+1, ETHEREAL_BLOOD_CHARGE_DANGEROUS)
		return
	ethereal.blood_volume = clamp(ethereal.blood_volume + amount, ETHEREAL_BLOOD_CHARGE_NONE, ETHEREAL_BLOOD_CHARGE_DANGEROUS)

/datum/species/ethereal/proc/handle_charge(mob/living/carbon/human/ethereal, seconds_per_tick, times_fired)
	brutemod = 1.15
	var/word = pick("like you can't breathe","your lungs locking up","extremely lethargic")
	var/blood_volume = ethereal.blood_volume
	if(HAS_TRAIT(ethereal, TRAIT_ETHEREAL_NO_OVERCHARGE))
		blood_volume = min(blood_volume, ETHEREAL_BLOOD_CHARGE_FULL)
	switch(blood_volume)
		if(-INFINITY to ETHEREAL_BLOOD_CHARGE_LOWEST_PASSIVE)
			ethereal.add_mood_event("charge", /datum/mood_event/decharged)
			ethereal.clear_alert("ethereal_overcharge")
			ethereal.throw_alert(ALERT_ETHEREAL_CHARGE, /atom/movable/screen/alert/emptycell/ethereal)
			brutemod = 2
			if(SPT_PROB(7.5, seconds_per_tick))
				to_chat(src, span_warning("You feel [word]."))
			ethereal.adjustOxyLoss(round(0.01 * (ETHEREAL_BLOOD_CHARGE_LOW - ethereal.blood_volume) * seconds_per_tick, 1))
		if(ETHEREAL_BLOOD_CHARGE_LOWEST_PASSIVE to ETHEREAL_BLOOD_CHARGE_LOW)
			ethereal.clear_alert("ethereal_overcharge")
			ethereal.add_mood_event("charge", /datum/mood_event/decharged)
			ethereal.throw_alert(ALERT_ETHEREAL_CHARGE, /atom/movable/screen/alert/lowcell/ethereal, 3)
			brutemod = 1.5
			if(ethereal.health > 10.5)
				ethereal.apply_damage(0.155 * seconds_per_tick, TOX, null, null, ethereal)
		if(ETHEREAL_BLOOD_CHARGE_LOW to ETHEREAL_BLOOD_CHARGE_NORMAL)
			ethereal.clear_alert("ethereal_overcharge")
			ethereal.add_mood_event("charge", /datum/mood_event/lowpower)
			ethereal.throw_alert(ALERT_ETHEREAL_CHARGE, /atom/movable/screen/alert/lowcell/ethereal, 2)
			brutemod = 1.25
		if(ETHEREAL_BLOOD_CHARGE_ALMOSTFULL to ETHEREAL_BLOOD_CHARGE_FULL)
			ethereal.clear_alert("ethereal_overcharge")
			ethereal.clear_alert("ethereal_charge")
			ethereal.add_mood_event("charge", /datum/mood_event/charged)
			brutemod = 1
		if(ETHEREAL_BLOOD_CHARGE_FULL to ETHEREAL_BLOOD_CHARGE_OVERLOAD)
			ethereal.clear_alert("ethereal_charge")
			ethereal.add_mood_event("charge", /datum/mood_event/overcharged)
			ethereal.throw_alert(ALERT_ETHEREAL_OVERCHARGE, /atom/movable/screen/alert/ethereal_overcharge, 1)
			brutemod = 1.25
		if(ETHEREAL_BLOOD_CHARGE_OVERLOAD to ETHEREAL_BLOOD_CHARGE_DANGEROUS)
			ethereal.clear_alert("ethereal_charge")
			ethereal.add_mood_event("charge", /datum/mood_event/supercharged)
			ethereal.throw_alert(ALERT_ETHEREAL_OVERCHARGE, /atom/movable/screen/alert/ethereal_overcharge, 2)
			ethereal.apply_damage(0.2 * seconds_per_tick, TOX, null, null, ethereal)
			brutemod = 1.5
			if(SPT_PROB(5, seconds_per_tick)) // 5% each seacond for ethereals to explosively release excess energy if it reaches dangerous levels
				discharge_process(ethereal)
		else
			ethereal.clear_mood_event("charge")
			ethereal.clear_alert(ALERT_ETHEREAL_CHARGE)
			ethereal.clear_alert(ALERT_ETHEREAL_OVERCHARGE)

/datum/species/ethereal/proc/discharge_process(mob/living/carbon/human/ethereal)
	to_chat(ethereal, span_warning("You begin to lose control over your charge!"))
	ethereal.visible_message(span_danger("[ethereal] begins to spark violently!"))

	var/static/mutable_appearance/overcharge //shameless copycode from lightning spell
	overcharge = overcharge || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	ethereal.add_overlay(overcharge)

	if(do_after(ethereal, 5 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED)))
		ethereal.flash_lighting_fx(5, 7, ethereal.dna.species.fixed_mut_color ? ethereal.dna.species.fixed_mut_color : ethereal.dna.features["mcolor"])

		playsound(ethereal, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
		ethereal.cut_overlay(overcharge)
		tesla_zap(ethereal, 2, ethereal.blood_volume*9, ZAP_OBJ_DAMAGE | ZAP_GENERATES_POWER | ZAP_ALLOW_DUPLICATES)
		adjust_charge(ethereal, ETHEREAL_BLOOD_CHARGE_FULL - ethereal.blood_volume)
		ethereal.visible_message(span_danger("[ethereal] violently discharges energy!"), span_warning("You violently discharge energy!"))

		ethereal.Paralyze(100)

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
		ethereal_light.set_light_range_power_color(1 + (2 * healthpercent), 1 + round(0.5 * healthpercent), current_color)
		ethereal_light.set_light_on(TRUE)
		fixed_mut_color = current_color
	else
		ethereal_light.set_light_on(FALSE)
		current_color = rgb(230, 230, 230)
		fixed_mut_color = current_color
	ethereal.hair_color = current_color
	ethereal.facial_hair_color = current_color
	if(ethereal.organs_slot["horns"])
		var/obj/item/organ/external/horms = ethereal.organs_slot["horns"]
		horms.bodypart_overlay.draw_color = current_color
	if(ethereal.organs_slot["tail"])
		var/obj/item/organ/external/tail = ethereal.organs_slot["tail"]
		tail.bodypart_overlay.draw_color = current_color
	ethereal.update_body()

/datum/species/ethereal/proc/on_emp_act(mob/living/carbon/human/H, severity)
	SIGNAL_HANDLER
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

/datum/species/ethereal/proc/on_after_attackedby(mob/living/lightbulb, obj/item/item, mob/living/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	var/obj/item/clothing/mask/cigarette/cig = item
	if(!proximity_flag || !istype(cig) || !istype(user) || cig.lit)
		return
	cig.light()
	user.visible_message(span_notice("[user] quickly strikes [item] across [lightbulb]'s skin, [lightbulb.p_their()] warmth lighting it!"))
	return COMPONENT_NO_AFTERATTACK

/datum/species/ethereal/get_scream_sound(mob/living/carbon/human/ethereal)
	return pick(
		'sound/voice/ethereal/ethereal_scream_1.ogg',
		'sound/voice/ethereal/ethereal_scream_2.ogg',
		'sound/voice/ethereal/ethereal_scream_3.ogg',
	)

/datum/species/ethereal/get_laugh_sound(mob/living/carbon/human/ethereal)
	return 'monkestation/sound/voice/laugh/ethereal/ethereal_laugh_1.ogg'

/datum/species/ethereal/get_species_description()
	return "Coming from the planet of Sprout, the theocratic ethereals are \
		separated socially by caste, and espouse a dogma of aiding the weak and \
		downtrodden."

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
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shield-halved",
			SPECIES_PERK_NAME = "Power(Only) Armor",
			SPECIES_PERK_DESC = "You take increased brute damage the less power you have.	",
		),
	)

	return to_add
