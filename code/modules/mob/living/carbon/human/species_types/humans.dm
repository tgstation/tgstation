/datum/species/human
	name = "Human"
	id = "human"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,HAS_FLESH,HAS_BONE)
	default_features = list("mcolor" = "FFF", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW
	liked_food = JUNKFOOD | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	payday_modifier = 1

	var/groin_pain_timer

	var/groin_pain_threshold = 20
	var/groin_pain_nads_modifier = 2

/datum/species/human/qualifies_for_rank(rank, list/features)
	return TRUE	//Pure humans are always allowed in all roles.

/datum/species/human/handle_groin_damage(mob/living/carbon/human/H, damage_amount, sharpness)
	if(damage_amount >= 10)
		H.emote("wince")

	if (sharpness != SHARP_NONE)
		return

	var/pain_threshold = groin_pain_threshold
	if (H.gender == MALE)
		pain_threshold -= groin_pain_nads_modifier

	if (groin_pain_timer || damage_amount < pain_threshold)
		return

	to_chat(H, "<span class='boldwarning'>That's <i>REALLY</i> going to hurt in a few seconds!<span>")
	groin_pain_timer = addtimer(CALLBACK(src, .proc/groin_pain, H), 8 SECONDS)

/datum/species/human/proc/groin_pain(mob/living/carbon/human/H)
	groin_pain_timer = null
	H.emote("groan")
	H.adjustStaminaLoss(120)
	H.visible_message("<span class='notice'>[H] grabs [H.p_their()] groin!</span>", "<span class='warning'>You grab your groin in pain!</span>")

#ifdef TESTING
/datum/species/human/proc/print_potential_groin_pain_sources()
	to_chat(usr, "Items ending with '!' are male only")
	for(var/path in subtypesof(/obj/item))
		var/obj/item/template = path
		var/sharpness = initial(template.sharpness)
		if(sharpness != SHARP_NONE)
			continue
		var/force = initial(template.force)
		if(force >= groin_pain_threshold - groin_pain_nads_modifier)
			to_chat(usr, "[path][(force >= groin_pain_threshold ? "" : " !")]")
#endif
