
/*
/datum/holiday/april_fools/shouldCelebrate(dd, mm, yy)
	return 1 // Testing testing
*/

/datum/holiday/april_fools/celebrate()
	// Here we go...
	spawn(40)
		// Let the species config load, and then OVERRIDE IT MUHAHAHAHAHA!!!
		if(!config.mutant_races)
			config.mutant_races = TRUE
		roundstart_species["pony"] = /datum/species/pony

/datum/species/pony
	id = "pony"
	name = "Pony"
	roundstart = 1

	sexes = 1
	exotic_blood = /datum/reagent/friendship

	no_equip = list(slot_shoes, slot_gloves, slot_w_uniform)
	// slots the race can't equip stuff to

	nojumpsuit = 1

	default_features = list("wings" = "None", "alicorn" = "None")
	mutant_bodyparts = list("wings", "alicorn")

//	speedmod = -1
	armor = -0.1
	punchdamagelow = 0
	punchdamagehigh = 5
	punchstunthreshold = 5
	// Weaker than humans

	// species flags. these can be found in flags.dm
	specflags = list(MUTCOLORS, HAIR, EYECOLOR, NOBLOOD)

	attack_verb = "kick"
	ignored_by = list()	// list of mobs that will ignore this species

	var/pony_hair = null
	var/pony_tail = null
	var/alicorn_color = null
	var/list/pony_types = list(
		"rarity", "fleur", "twilight",
		"pinkie", "lyra", "vinyl",
		"whooves", "rainbow", "fluttershy")

/datum/species/pony/New()
	if(default_features["alicorn"] == "None" && prob(15))
		default_features["alicorn"] = "alicorn"
	if(default_features["alicorn"] != "None" && !alicorn_color)
		alicorn_color = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
		// Copypasted from colorful reagent
	if(default_features["wings"] == "None" && prob(25))
		default_features["wings"] = "wings"

	if(!pony_hair)
		pony_hair = pick(pony_types)

	if(!pony_tail)
		if(prob(15))
			pony_tail = pony_hair
		else
			pony_tail = pick(pony_types)
	..()


///////////
// PROCS //
///////////

/datum/species/pony/on_species_gain(mob/living/carbon/C)
	C.reagents.add_reagent("friendship", 100)
	for(var/addiction in C.reagents.addiction_list)
		var/datum/reagent/R = addiction
		if(R.id == "friendship")
			C.reagents.addiction_list.Remove(addiction)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.regenerate_icons()
		for(var/obj/item/thing in list(H.shoes, H.gloves, H.w_uniform))
			H.unEquip(thing)


/datum/species/pony/update_base_icon_state(mob/living/carbon/human/H)
	return "[id]_[(H.gender == FEMALE) ? "f" : "m"]" // No husk icon

/datum/species/pony/update_color(mob/living/carbon/human/H, forced_colour)
	H.remove_overlay(SPECIES_LAYER)

	var/image/standing
	var/g = (H.gender == FEMALE) ? "f" : "m"
	var/icon_state_string = "[id]_[g]"

	standing = image("icon" = 'code/modules/holiday/aprilfools.dmi', "icon_state" = icon_state_string, "layer" = -SPECIES_LAYER)
	standing.color = "#[H.dna.features["mcolor"]]"

	H.overlays_standing[SPECIES_LAYER]	+= standing
	H.apply_overlay(SPECIES_LAYER)

/datum/species/pony/handle_hair(mob/living/carbon/human/H, forced_colour)
	H.remove_overlay(HAIR_LAYER)
	if(H.disabilities & HUSK)
		return

	var/list/standing = list()

	if(pony_hair && (HAIR in specflags))
		var/image/img_hair_s = image("icon" = 'code/modules/holiday/aprilfools.dmi', "icon_state" = "[pony_hair]_hair", "layer" = -HAIR_LAYER)
		img_hair_s.color = "#" + H.hair_color
		standing += img_hair_s

	if(pony_tail && (HAIR in specflags))
		var/image/img_hair_s = image("icon" = 'code/modules/holiday/aprilfools.dmi', "icon_state" = "[pony_hair]_tail", "layer" = -HAIR_LAYER)
		img_hair_s.color = "#" + H.hair_color
		standing += img_hair_s

	if(standing.len)
		H.overlays_standing[HAIR_LAYER]	= standing

	H.apply_overlay(HAIR_LAYER)

/datum/species/pony/handle_body(mob/living/carbon/human/H)
	H.remove_overlay(BODY_LAYER)
	var/list/standing	= list()

	handle_mutant_bodyparts(H)
	standing += image("icon" = 'code/modules/holiday/aprilfools.dmi', "icon_state" = "eyes", "layer" = -BODY_LAYER)

	// eyes
	if(EYECOLOR in specflags)
		var/image/img_eyes_s = image("icon" = 'code/modules/holiday/aprilfools.dmi', "icon_state" = "eyes_inner", "layer" = -BODY_LAYER)
		img_eyes_s.color = "#" + H.eye_color
		standing	+= img_eyes_s

	if(standing.len)
		H.overlays_standing[BODY_LAYER] = standing

	H.apply_overlay(BODY_LAYER)
	return

/datum/species/pony/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing	= list()

	H.remove_overlay(BODY_BEHIND_LAYER)
	H.remove_overlay(BODY_ADJ_LAYER)
	H.remove_overlay(BODY_FRONT_LAYER)

	if(!mutant_bodyparts)
		return

	if(!bodyparts_to_add)
		return

	var/image/I

	for(var/layer in relevent_layers)
		for(var/bodypart in bodyparts_to_add)
			var/icon_string = H.dna.features[bodypart]
			if(!icon_string)
				icon_string = default_features[bodypart]

			if(!icon_string || icon_string == "None")
				continue

			I = image("icon" = 'code/modules/holiday/aprilfools.dmi', "icon_state" = icon_string, "layer" =- layer)

			if(!(H.disabilities & HUSK))
				switch(bodypart)
					if("wings")
						I.color = "#[H.dna.features["mcolor"]]"
					if("hair", "tail")
						I.color = "#[H.hair_color]"
					if("alicorn")
						if(alicorn_color)
							I.color = alicorn_color
			standing += I

		H.overlays_standing[layer] = standing.Copy()
		standing = list()

	H.apply_overlay(BODY_BEHIND_LAYER)
	H.apply_overlay(BODY_ADJ_LAYER)
	H.apply_overlay(BODY_FRONT_LAYER)

/datum/species/pony/spec_life(mob/living/carbon/human/H)
	if(H.reagents.get_reagent_amount("friendship") < 100)
		H.reagents.add_reagent("friendship", 2)
	return

/datum/species/pony/handle_speech(message, mob/living/carbon/human/H)
	return message

//return a list of spans or an empty list
/datum/species/pony/get_spans()
	return list()


// FRIENDSHIP REAGENT
// Sto- Ported from Goonstation.

/datum/species/pony/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "friendship")
		return 1

/datum/reagent/friendship
	name = "pure friendship"
	id = "friendship"
	description = "Friendship, in liquid form. Yes, the concept of friendship. As a liquid. This makes sense in the future."
	//description = "What is this emotion you humans call \"love?\" Oh, it's this? This is it? Huh, well okay then, thanks."
	reagent_state = LIQUID
	color = rgb(255, 131, 165)
	addiction_threshold = 9

/datum/reagent/friendship/reaction_mob(mob/living/M)
	M << "<span class='rose'>You feel loved!</span>"
	..()

/datum/reagent/friendship/on_mob_life(mob/living/M)
	// Better than omnizine, but at what cost...
	M.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustStaminaLoss(-1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.AdjustStunned(-1, 0)

	if (M.a_intent != "help")
		M.a_intent_change("help")

	if (prob(8))
		var/msg = ""
		switch (rand(1, 5))
			if (1)
				msg = "appreciated"
			if (2)
				msg = "loved"
			if (3)
				msg = "pretty good"
			if (4)
				msg = "really nice"
			if (5)
				msg = "pretty happy with yourself, even though things haven't always gone as well as they could"

		M << "<span class='rose'>You feel [msg].</span>"

	else if (prob(50) && !M.restrained() && !M.stat)
		for (var/mob/living/hugTarget in orange(1,M))
			if (hugTarget == M)
				continue
			if (!hugTarget.stat)
				M.visible_message("<span class='rose'>[M] [prob(5) ? "awkwardly side-" : ""]hugs [hugTarget]!</span>")
				break

	if(current_cycle >= 50 && prob(33) && ishuman(M))
		M << "<span class='userdanger rose'>The friendship overcomes you!</span>"
		M.set_species(/datum/species/pony)
	..(M)
	return

/datum/reagent/friendship/addiction_act_stage1(mob/living/M)
	if(prob(30))
		M << "<span class='notice'>You feel like some <span class='rose'>friendship</span> right about now.</span>"
	return

/datum/reagent/friendship/addiction_act_stage2(mob/living/M)
	if(prob(30))
		M << "<span class='notice'>You feel like you need <span class='rose'>friendship</span>. You just can't get enough.</span>"
	return

/datum/reagent/friendship/addiction_act_stage3(mob/living/M)
	if(prob(30))
		M << "<span class='danger'>You have an intense craving for <span class='rose'>friendship</span>.</span>"

	M.adjustOxyLoss(2*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER, 0)
	if(prob(25))
		M << "<span class='danger'>The lack of <span class='rose'>friendship</span> is stunning!</span>"
		M.Weaken(8)
		M.Stun(8)
	return

/datum/reagent/friendship/addiction_act_stage4(mob/living/M)
	if(prob(20))
		addiction_act_stage3(M)
	else if(prob(40))
		M << "<span class='boldannounce'>You're not feeling good at all! You really need some <span class='rose'>friendship</span>.</span>"

	M.adjustOxyLoss(3*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustToxLoss(2*REAGENTS_EFFECT_MULTIPLIER, 0)

	if(prob(25))
		M << "<span class='danger'>The lack of <span class='rose'>friendship</span> is driving you mad!</span>"
		M.hallucination += 80
	return