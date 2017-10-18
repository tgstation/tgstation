/datum/species/dullahan
	name = "dullahan"
	id = "dullahan"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	mutant_bodyparts = list("tail_human", "ears", "wings")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	use_skintones = 1
	mutant_brain = /obj/item/organ/brain/dullahan
	mutanteyes = /obj/item/organ/eyes/dullahan
	mutanttongue = /obj/item/organ/tongue/dullahan
	mutantears = /obj/item/organ/ears/dullahan
	blacklisted = 1
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human

	var/obj/item/bodypart/head/myhead

/datum/species/dullahan/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	..()
	var/obj/item/bodypart/head/head = H.get_bodypart("head")
	if(head)
		myhead = head
		head.drop_limb()
		myhead.flags_1 = HEAR_1
		var/obj/item/dullahan_relay/DR = new (myhead)
		DR.owner = H
		START_PROCESSING(SSobj, DR)

/datum/species/dullahan/spec_life(mob/living/carbon/human/H)
	if(myhead)
		update_vision_perspective(H)

		if(get_turf(myhead) in view(7, get_turf(H)))
			H.disabilities &= ~DEAF
		else
			H.disabilities |= DEAF
	else
		H.gib()

/datum/species/dullahan/proc/update_vision_perspective(mob/living/carbon/human/H)
	var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		H.update_tint()
		if(eyes.tint)
			H.reset_perspective(H)
		else
			H.reset_perspective(myhead)

/obj/item/organ/brain/dullahan
	decoy_override = TRUE
	vital = FALSE

/obj/item/organ/tongue/dullahan
	zone = "abstract"

/obj/item/organ/tongue/dullahan/TongueSpeech(var/message)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.dna.species.id == "dullahan")
			var/datum/species/dullahan/D = H.dna.species
			D.myhead.say(message)
	message = ""
	return message

/obj/item/organ/ears/dullahan
	zone = "abstract"

/obj/item/organ/eyes/dullahan
	name = "head vision"
	desc = "An abstraction."
	actions_types = list(/datum/action/item_action/organ_action/use)
	zone = "abstract"

/obj/item/organ/eyes/dullahan/ui_action_click()
	if(tint)
		tint = 0
	else
		tint = INFINITY

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.dna.species.id == "dullahan")
			var/datum/species/dullahan/D = H.dna.species
			D.update_vision_perspective(H)

/obj/item/dullahan_relay
	var/mob/living/owner
	flags_1 = HEAR_1

/obj/item/dullahan_relay/process()
	if(!istype(loc, /obj/item/bodypart/head))
		if(owner)
			owner.gib()
		STOP_PROCESSING(SSobj, src)
		qdel(src)

/obj/item/dullahan_relay/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(owner)
		var/turf/T = get_turf(speaker)
		if(T in view(7, get_turf(owner))) //Do not relay things we can already hear
			return
		message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode)
		to_chat(owner,message)