/datum/brain_trauma/special/unstable_insanity
	name = "Deranged"
	desc = "Patient's mind has collapsed, and they are now experiencing severe hallucinations."
	scan_desc = "deranged delusions"
	gain_text = "<span class='warning'>There's a buzzing in your head, and you feel watched...</span>"
	lose_text = "<span class='notice'>Your mind finally feels calm again.</span>"
	can_gain = TRUE
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE
	var/list/eyeballs = list()

/datum/brain_trauma/special/unstable_insanity/on_life()
	for(var/obj/effect/temp_visual/watching_eyeball/current_eyes in eyeballs)
		current_eyes.update_looks()

	if(prob(1))
		switch(rand(1,3))
			if(1)//eyeballs on the walls
				var/list/valid_walls_to_eyeballs = list()
				for(var/turf/closed/T in range(7, owner))
					valid_walls_to_eyeballs += T
				if(valid_walls_to_eyeballs.len)
					var/obj/effect/temp_visual/watching_eyeball/new_eye = new(pick(valid_walls_to_eyeballs), owner)
					eyeballs += new_eye
	//		if(2)//random chatter from objects
				//
	//		if(3)//vibrant colors!!


/*
/datum/brain_trauma/special/unstable_insanity/on_hear(message, speaker, message_language, raw_message, radio_freq)
	if(!owner.can_hear()) //if hearing what they say from objects is in your mind, the objects can't be heard either.
		return message
	var/list/
	for(var/
	message = reg.Replace(message, "<span class='phobia'>$1</span>")
	break
*/

/obj/effect/temp_visual/watching_eyeball
	icon_state = null
	duration = 3 MINUTES
	var/datum/brain_trauma/special/unstable_insanity/trauma

/obj/effect/temp_visual/watching_eyeball/Initialize(mapload, mob/living/carbon/seer)
	. = ..()
	for(var/datum/brain_trauma/special/unstable_insanity/B in seer.get_traumas())
		trauma = B
		break
	var/image/I = image(icon = 'icons/effects/effects.dmi', icon_state = "eyeball_[rand(1,3)]", layer = ABOVE_MOB_LAYER, loc = src)
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/onePerson, "eyeball", I, seer)

/obj/effect/temp_visual/watching_eyeball/proc/update_looks(mob/watched)
	dir = get_dir(src, watched)

/obj/effect/temp_visual/watching_eyeball/Destroy()
	if(trauma)
		trauma.eyeballs.Remove(src)
	..()
