/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = SPECIES_SKELETON
	sexes = 0
	meat = /obj/item/food/meat/slab/human/mutant/skeleton
	species_traits = list(
		NOTRANSSTING,
		NOEYESPRITES,
		NO_DNA_COPY,
		NO_UNDERWEAR,
	)
	inherent_traits = list(
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_EASYDISMEMBER,
		TRAIT_FAKEDEATH,
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBREATH,
		TRAIT_NOCLONELOSS,
		TRAIT_NOMETABOLISM,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		TRAIT_XENO_IMMUNE,
		TRAIT_NOBLOOD,
		TRAIT_NO_DEBRAIN_OVERLAY,
	)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutanttongue = /obj/item/organ/internal/tongue/bone
	mutantstomach = null
	mutantappendix = null
	mutantheart = null
	mutantliver = null
	mutantlungs = null
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW | GORE
	wing_types = list(/obj/item/organ/external/wings/functional/skeleton)
	//They can technically be in an ERT
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN
	species_cookie = /obj/item/reagent_containers/condiment/milk
	species_language_holder = /datum/language_holder/skeleton

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/skeleton,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/skeleton,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/skeleton,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/skeleton,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/skeleton,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/skeleton,
	)

/datum/species/skeleton/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.set_safe_hunger_level()

/datum/species/skeleton/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

//Can still metabolize milk through meme magic
/datum/species/skeleton/handle_chemical(datum/reagent/chem, mob/living/carbon/human/affected, seconds_per_tick, times_fired)
	. = ..()
	if(. & COMSIG_MOB_STOP_REAGENT_CHECK)
		return
	if(chem.type == /datum/reagent/toxin/bonehurtingjuice)
		affected.adjustStaminaLoss(7.5 * REM * seconds_per_tick, 0)
		affected.adjustBruteLoss(0.5 * REM * seconds_per_tick, 0)
		if(SPT_PROB(10, seconds_per_tick))
			switch(rand(1, 3))
				if(1)
					affected.say(pick("oof.", "ouch.", "my bones.", "oof ouch.", "oof ouch my bones."), forced = chem.type)
				if(2)
					affected.manual_emote(pick("oofs silently.", "looks like [affected.p_their()] bones hurt.", "grimaces, as though [affected.p_their()] bones hurt."))
				if(3)
					to_chat(affected, span_warning("Your bones hurt!"))
		if(chem.overdosed)
			if(SPT_PROB(2, seconds_per_tick)) //big oof
				var/selected_part = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) //God help you if the same limb gets picked twice quickly.
				var/obj/item/bodypart/bodypart = affected.get_bodypart(selected_part) //We're so sorry skeletons, you're so misunderstood
				if(bodypart)
					playsound(affected, get_sfx(SFX_DESECRATION), 50, TRUE, -1) //You just want to socialize
					affected.visible_message(span_warning("[affected] rattles loudly and flails around!!"), span_danger("Your bones hurt so much that your missing muscles spasm!!"))
					affected.say("OOF!!", forced = chem.type)
					bodypart.receive_damage(brute = 200) //But I don't think we should
				else
					to_chat(affected, span_warning("Your missing [parse_zone(selected_part)] aches from wherever you left it."))
					affected.emote("sigh")
		affected.reagents.remove_reagent(chem.type, chem.metabolization_rate * seconds_per_tick)
		return COMSIG_MOB_STOP_REAGENT_CHECK
	if(chem.type == /datum/reagent/consumable/milk)
		if(chem.volume > 50)
			affected.reagents.remove_reagent(chem.type, (50 - chem.volume))
			to_chat(affected, span_warning("The excess milk is dripping off your bones!"))
		affected.heal_bodypart_damage(2.5 * REM * seconds_per_tick, 2.5 * REM * seconds_per_tick)
		for(var/datum/wound/iter_wound as anything in affected.all_wounds)
			iter_wound.on_xadone(1 * REM * seconds_per_tick)
		affected.reagents.remove_reagent(chem.type, chem.metabolization_rate * seconds_per_tick)
		return

/datum/species/skeleton/get_species_description()
	return "A rattling skeleton! They descend upon Space Station 13 \
		Every year to spook the crew! \"I've got a BONE to pick with you!\""

/datum/species/skeleton/get_species_lore()
	return list(
		"Skeletons want to be feared again! Their presence in media has been destroyed, \
		or at least that's what they firmly believe. They're always the first thing fought in an RPG, \
		they're Flanderized into pun rolling JOKES, and it's really starting to get to them. \
		You could say they're deeply RATTLED. Hah."
	)
