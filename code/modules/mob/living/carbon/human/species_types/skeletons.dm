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
	)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutanttongue = /obj/item/organ/internal/tongue/bone
	mutantstomach = /obj/item/organ/internal/stomach/bone
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
/datum/species/skeleton/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	if(chem.type == /datum/reagent/toxin/bonehurtingjuice)
		H.adjustStaminaLoss(7.5 * REAGENTS_EFFECT_MULTIPLIER * delta_time, 0)
		H.adjustBruteLoss(0.5 * REAGENTS_EFFECT_MULTIPLIER * delta_time, 0)
		if(DT_PROB(10, delta_time))
			switch(rand(1, 3))
				if(1)
					H.say(pick("oof.", "ouch.", "my bones.", "oof ouch.", "oof ouch my bones."), forced = /datum/reagent/toxin/bonehurtingjuice)
				if(2)
					H.manual_emote(pick("oofs silently.", "looks like [H.p_their()] bones hurt.", "grimaces, as though [H.p_their()] bones hurt."))
				if(3)
					to_chat(H, span_warning("Your bones hurt!"))
		if(chem.overdosed)
			if(DT_PROB(2, delta_time) && iscarbon(H)) //big oof
				var/selected_part = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) //God help you if the same limb gets picked twice quickly.
				var/obj/item/bodypart/bp = H.get_bodypart(selected_part) //We're so sorry skeletons, you're so misunderstood
				if(bp)
					playsound(H, get_sfx(SFX_DESECRATION), 50, TRUE, -1) //You just want to socialize
					H.visible_message(span_warning("[H] rattles loudly and flails around!!"), span_danger("Your bones hurt so much that your missing muscles spasm!!"))
					H.say("OOF!!", forced=/datum/reagent/toxin/bonehurtingjuice)
					bp.receive_damage(200, 0, 0) //But I don't think we should
				else
					to_chat(H, span_warning("Your missing arm aches from wherever you left it."))
					H.emote("sigh")
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * delta_time)
		return TRUE

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
