//Equips umbral tendrils with many uses.
/datum/action/innate/darkspawn/pass
	name = "Pass"
	id = "pass"
	desc = "Twists an active arm into tendrils with many uses."
	button_icon_state = "pass"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	blacklisted = TRUE //baseline

/datum/action/innate/darkspawn/pass/IsAvailable()
	if(!owner.get_empty_held_indexes())
		return
	return ..()

/datum/action/innate/darkspawn/pass/process()
	..()
	active = locate(/obj/item/umbral_tendrils) in owner

/datum/action/innate/darkspawn/pass/Activate()
	owner.visible_message("<span class='warning'>[owner]'s arm contorts into tentacles!</span>", "<span class='velvet bold'>ikna</span><br>\
	<span class='notice'>You transform your arm into umbral tendrils. Examine them to see possible uses.</span>")
	playsound(owner, 'sound/magic/pass_create.ogg', 50, 1)
	var/obj/item/umbral_tendrils/T = new(owner, darkspawn)
	owner.put_in_hands(T)
	return TRUE

/datum/action/innate/darkspawn/pass/Deactivate()
	owner.visible_message("<span class='warning'>[owner]'s tentacles contort into an arm!</span>", "<span class='velvet bold'>haoo</span><br>\
	<span class='notice'>You reform your arm.</span>")
	playsound(owner, 'sound/magic/pass_dispel.ogg', 50, 1)
	for(var/obj/item/umbral_tendrils/T in owner)
		qdel(T)
	return TRUE
