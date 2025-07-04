/datum/action/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal cords shift, allowing us to briefly emit a noise that deafens and confuses humans, causing them to lose some control over their movements. Best used to stop prey from escaping. Costs 20 chemicals."
	helptext = "Emits a high-frequency sound that confuses and deafens humans to hamper their movement, blows out nearby lights and overloads cyborg sensors."
	button_icon_state = "resonant_shriek"
	chemical_cost = 20
	dna_cost = 1
	req_human = TRUE
	disabled_by_fire = FALSE

//A flashy ability, good for crowd control and sowing chaos.
/datum/action/changeling/resonant_shriek/sting_action(mob/user)
	..()
	if(user.movement_type & VENTCRAWLING)
		user.balloon_alert(user, "can't shriek in pipes!")
		return FALSE
	for(var/mob/living/M in get_hearers_in_view(4, user))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!IS_CHANGELING(C))
				var/obj/item/organ/ears/ears = C.get_organ_slot(ORGAN_SLOT_EARS)
				if(ears)
					ears.adjustEarDamage(0, 30)
				C.adjust_confusion(25 SECONDS)
				C.set_jitter_if_lower(100 SECONDS)
			else
				SEND_SOUND(C, sound('sound/effects/screech.ogg'))

		if(issilicon(M))
			SEND_SOUND(M, sound('sound/items/weapons/flash.ogg'))
			M.Paralyze(rand(100,200))

	for(var/obj/machinery/light/L in range(4, user))
		L.on = TRUE
		L.break_light_tube()
		stoplag()
	return TRUE

/datum/action/changeling/dissonant_shriek
	name = "Technophagic Shriek"
	desc = "We shift our vocal cords to release a high-frequency sound that overloads nearby electronics. Breaks headsets and cameras, and can sometimes break laser weaponry, doors, and modsuits. Costs 20 chemicals."
	button_icon_state = "dissonant_shriek"
	chemical_cost = 20
	dna_cost = 1
	disabled_by_fire = FALSE

/datum/action/changeling/dissonant_shriek/sting_action(mob/user)
	..()
	if(user.movement_type & VENTCRAWLING)
		user.balloon_alert(user, "can't shriek in pipes!")
		return FALSE
	empulse(get_turf(user), 2, 5, 1)
	for(var/obj/machinery/light/L in range(5, usr))
		L.on = TRUE
		L.break_light_tube()
		stoplag()

	return TRUE
