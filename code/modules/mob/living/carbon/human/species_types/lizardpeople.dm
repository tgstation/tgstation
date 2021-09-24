/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Lizardperson"
	id = SPECIES_LIZARD
	say_mod = "hisses"
	default_color = COLOR_VIBRANT_LIME
	species_traits = list(MUTCOLORS, EYECOLOR, LIPS, HAS_FLESH, HAS_BONE)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_CAN_USE_FLIGHT_POTION,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	mutant_bodyparts = list("tail_lizard" = "Smooth", "spines" = "None", "body_markings" = "None", "legs" = "Normal Legs")
	external_organs = list(/obj/item/organ/external/horns = "None",
		/obj/item/organ/external/frills = "None",
		/obj/item/organ/external/snout = "Round")
	mutanttongue = /obj/item/organ/tongue/lizard
	mutantstomach = /obj/item/organ/stomach/lizard
	mutantliver = /obj/item/organ/liver/lizard
	mutant_organs = list(/obj/item/organ/tail/lizard, /obj/item/organ/second_heart)
	coldmod = 1.5
	heatmod = 0.67
	toxmod = 1.25
	blood_gain_multiplier = 0.5
	payday_modifier = 0.75
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_effect = ATTACK_EFFECT_CLAW
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/food/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = "L"
	disliked_food = GRAIN | DAIRY | CLOTH
	liked_food = GROSS | MEAT | SEAFOOD
	inert_mutation = FIREBREATH
	deathsound = 'sound/voice/lizard/deathsound.ogg'
	wings_icons = list("Dragon")
	species_language_holder = /datum/language_holder/lizard
	// Lizards are coldblooded and can stand a greater temperature range than humans
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT + 20) // This puts lizards 10 above lavaland max heat for ash lizards.
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 10)

	ass_image = 'icons/ass/asslizard.png'

/// Lizards are cold blooded and do not stabilize body temperature naturally
/datum/species/lizard/body_temperature_core(mob/living/carbon/human/humi, delta_time, times_fired)
	return

/datum/species/lizard/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_lizard_name(gender)

	var/randname = lizard_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

//I wag in death
/datum/species/lizard/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

/datum/species/lizard/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = ..()

/datum/species/lizard/can_wag_tail(mob/living/carbon/human/H)
	return mutant_bodyparts["tail_lizard"] || mutant_bodyparts["waggingtail_lizard"]

/datum/species/lizard/is_wagging_tail(mob/living/carbon/human/H)
	return mutant_bodyparts["waggingtail_lizard"]

/datum/species/lizard/start_wagging_tail(mob/living/carbon/human/H)
	if(mutant_bodyparts["tail_lizard"])
		mutant_bodyparts["waggingtail_lizard"] = mutant_bodyparts["tail_lizard"]
		mutant_bodyparts["waggingspines"] = mutant_bodyparts["spines"]
		mutant_bodyparts -= "tail_lizard"
		mutant_bodyparts -= "spines"
	H.update_body()

/datum/species/lizard/stop_wagging_tail(mob/living/carbon/human/H)
	if(mutant_bodyparts["waggingtail_lizard"])
		mutant_bodyparts["tail_lizard"] = mutant_bodyparts["waggingtail_lizard"]
		mutant_bodyparts["spines"] = mutant_bodyparts["waggingspines"]
		mutant_bodyparts -= "waggingtail_lizard"
		mutant_bodyparts -= "waggingspines"
	H.update_body()

/datum/species/lizard/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	var/real_tail_type = C.dna.features["tail_lizard"]
	var/real_spines = C.dna.features["spines"]

	. = ..()
	C.mob_surgery_speed_mod -= 0.35
	RegisterSignal(C, COMSIG_CARBON_GAIN_ORGAN, .proc/on_gained_organ)
	RegisterSignal(C, COMSIG_CARBON_LOSE_ORGAN, .proc/on_removed_organ)
	// Special handler for loading preferences. If we're doing it from a preference load, we'll want
	// to make sure we give the appropriate lizard tail AFTER we call the parent proc, as the parent
	// proc will overwrite the lizard tail. Species code at its finest.
	if(pref_load)
		C.dna.features["tail_lizard"] = real_tail_type
		C.dna.features["spines"] = real_spines

		var/obj/item/organ/tail/lizard/new_tail = new /obj/item/organ/tail/lizard()

		new_tail.tail_type = C.dna.features["tail_lizard"]
		new_tail.spines = C.dna.features["spines"]

		// organ.Insert will qdel any existing organs in the same slot, so
		// we don't need to manage that.
		new_tail.Insert(C, TRUE, FALSE)

/datum/species/lizard/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.mob_surgery_speed_mod += 0.35
	UnregisterSignal(C, COMSIG_CARBON_GAIN_ORGAN)
	UnregisterSignal(C, COMSIG_CARBON_LOSE_ORGAN)
	C.remove_client_colour(/datum/client_colour/monochrome/lizard)
	return ..()

/datum/species/lizard/randomize_main_appearance_element(mob/living/carbon/human/human_mob)
	var/tail = pick(GLOB.tails_list_lizard)
	human_mob.dna.features["tail_lizard"] = tail
	mutant_bodyparts["tail_lizard"] = tail
	human_mob.update_body()

/datum/species/lizard/on_tail_lost(mob/living/carbon/human/tail_owner, obj/item/organ/tail/lost_tail, on_species_init)
	. = ..()
	if(!.)
		return
	if(lost_tail.type in mutant_organs)
		RegisterSignal(tail_owner, COMSIG_MOVABLE_MOVED, .proc/on_move)

/datum/species/lizard/on_tail_regain(mob/living/carbon/human/tail_owner, obj/item/organ/tail/found_tail, on_species_init)
	. = ..()
	if(!.)
		return
	if(found_tail.type in mutant_organs)
		UnregisterSignal(tail_owner, COMSIG_MOVABLE_MOVED)

/datum/species/lizard/clear_tail_moodlets(mob/living/carbon/human/former_tail_owner)
	. = ..()
	UnregisterSignal(former_tail_owner, COMSIG_MOVABLE_MOVED)

/datum/species/lizard/proc/on_gained_organ(mob/living/receiver, obj/item/organ/tongue/organ)
	SIGNAL_HANDLER

	if(!istype(organ) || organ.taste_sensitivity > LIZARD_TASTE_SENSITIVITY)
		return
	receiver.remove_client_colour(/datum/client_colour/monochrome/lizard)

/datum/species/lizard/proc/on_removed_organ(mob/living/unceiver, obj/item/organ/tongue/organ)
	SIGNAL_HANDLER

	if(!istype(organ) || organ.taste_sensitivity > LIZARD_TASTE_SENSITIVITY)
		return
	unceiver.add_client_colour(/datum/client_colour/monochrome/lizard)

/datum/species/lizard/proc/on_move(mob/living/mover, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if(!movement_dir || !prob(1))
		return
	mover.Knockdown(1 SECONDS)
	to_chat(mover, span_warning("You trip from your imbalance!"))

/*
Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = SPECIES_LIZARD_ASH
	limbs_id = "lizard"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,DIGITIGRADE,HAS_FLESH,HAS_BONE)
	mutantlungs = /obj/item/organ/lungs/ashwalker
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_CHUNKYFINGERS,
		TRAIT_VIRUSIMMUNE,
	)
	species_language_holder = /datum/language_holder/lizard/ash

/*
Lizard subspecies: SILVER SCALED
*/
/datum/species/lizard/silverscale
	name = "Silver Scale"
	id = SPECIES_LIZARD_SILVER
	limbs_id = "lizard"
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_HOLY,
		TRAIT_NOBREATH,
		TRAIT_VIRUSIMMUNE,
		TRAIT_WINE_TASTER,
	)
	species_language_holder = /datum/language_holder/lizard/silver
	mutanttongue = /obj/item/organ/tongue/lizard/silver
	armor = 10 //very light silvery scales soften blows
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	///stored mutcolor for when we turn back off of a silverscale.
	var/old_mutcolor
	///stored eye color for when we turn back off of a silverscale.
	var/old_eyecolor

/datum/species/lizard/silverscale/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	var/mob/living/carbon/human/new_silverscale = C
	old_mutcolor = C.dna.features["mcolor"]
	old_eyecolor = new_silverscale.eye_color
	new_silverscale.dna.features["mcolor"] = "eeeeee"
	new_silverscale.eye_color = "0000a0"
	..()
	new_silverscale.add_filter("silver_glint", 2, list("type" = "outline", "color" = "#ffffff63", "size" = 2))

/datum/species/lizard/silverscale/on_species_loss(mob/living/carbon/C)
	var/mob/living/carbon/human/was_silverscale = C
	was_silverscale.dna.features["mcolor"] = old_mutcolor
	was_silverscale.eye_color = old_eyecolor

	was_silverscale.remove_filter("silver_glint")
	..()
