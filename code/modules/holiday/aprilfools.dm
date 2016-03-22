/*/datum/holiday/april_fools/shouldCelebrate(dd, mm, yy)
	return 1 // Testing testing
*/
/datum/holiday/april_fools/getStationPrefix()
	return pick("Friendship","Magic","My Little","Pony")

/datum/holiday/april_fools/celebrate()
	// Here we go...
	spawn(40)
		// Let the races config load, and then OVERRIDE IT MUHAHAHAHAHA!!!
		roundstart_species["pony"] = /datum/species/pony

/datum/species/pony
	id = "pony"
	name = "Pony"
	roundstart = 1

	sexes = 1
	exotic_blood = /datum/reagent/love

	no_equip = list(slot_shoes, slot_gloves, slot_w_uniform)
	// slots the race can't equip stuff to

	nojumpsuit = 1

	default_features = list("wings" = "None", "alicorn" = "None")
	mutant_bodyparts = list("wings", "alicorn")

	speedmod = -1	// no shoes, but the same speed as humans
	armor = -0.1		// overall defense for the race... or less defense, if it's negative.
	punchdamagelow = 0
	punchdamagehigh = 5
	punchstunthreshold = 5
	// Weaker than humans

	// species flags. these can be found in flags.dm
	specflags = list(MUTCOLORS, HAIR, EYECOLOR)

	attack_verb = "kick"
	ignored_by = list()	// list of mobs that will ignore this species

	var/pony_hair = null
	var/pony_tail = null
	var/alicorn_color = null
	var/list/pony_types = list(
		"rarity", "fleur", "twilight",
		"pinkie", "lyra", "vinyl",
		"whooves", "rainbow", "fluttershy")
	var/recently_updated = 1

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
	if(recently_updated)
		recently_updated = 0
		H.regenerate_icons()
		H.reagents.add_reagent("love", 100)
	return

/datum/species/pony/handle_speech(message, mob/living/carbon/human/H)
	return message

//return a list of spans or an empty list
/datum/species/pony/get_spans()
	return list()


// FRIENDSHIP REAGENT
// Sto- Ported from Goonstation.

/datum/species/pony/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "love")
		return 1

/datum/reagent/love
	name = "pure friendship"
	id = "love"
	description = "What is this emotion you humans call \"love?\" Oh, it's this? This is it? Huh, well okay then, thanks."
	reagent_state = LIQUID
	color = rgb(255, 131, 165)

/datum/reagent/love/reaction_mob(mob/living/M)
	M << "<span class='rose'>You feel loved!</span>"
	..()

/datum/reagent/love/on_mob_life(mob/living/M)
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

	else if (prob(40) && !M.restrained())
		for (var/mob/living/hugTarget in orange(1,M))
			if (hugTarget == M)
				continue
			if (!hugTarget.stat)
				M.visible_message("<span class='rose'>[M] [prob(5) ? "awkwardly side-" : ""]hugs [hugTarget]!</span>")
				break

	if(data >= 60 && prob(33) && ishuman(M))
		M << "<span class='rose'>The wave of friendship overcomes you!</span>"
		M.set_species(/datum/species/pony)
	..(M)
	return