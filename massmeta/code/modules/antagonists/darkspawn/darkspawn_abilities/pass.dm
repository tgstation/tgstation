//Equips umbral tendrils with many uses.
/datum/action/innate/darkspawn/pass
	name = "Pass"
	id = "pass"
	desc = "Twists an active arm into tendrils with many important uses. Examine the tendrils to see a list of uses."
	button_icon_state = "pass"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS
	blacklisted = TRUE //baseline

/datum/action/innate/darkspawn/pass/IsAvailable(feedback = FALSE)
	if(istype(owner, /mob/living/simple_animal/hostile/crawling_shadows) || istype(owner, /mob/living/simple_animal/hostile/darkspawn_progenitor) || !owner.get_empty_held_indexes() && !active)
		return
	return ..()

/datum/action/innate/darkspawn/pass/process()
	..()
	active = locate(/obj/item/umbral_tendrils) in owner
	if(darkspawn.upgrades["twin_tendrils"])
		name = "Twinned Pass"
		desc = "Twists one or both of your arms into tendrils with many uses."

/datum/action/innate/darkspawn/pass/Activate()
	var/mob/living/carbon/C = owner
	if(!(C.mobility_flags & MOBILITY_STAND))
		to_chat(owner, span_warning("Stand up first!"))
		return
	var/list/hands_free = owner.get_empty_held_indexes()
	if(!darkspawn.upgrades["twin_tendrils"] || hands_free.len < 2)
		owner.visible_message(span_warning("[owner]'s arm contorts into tentacles!"), "<span class='velvet bold'>ikna</span><br>\
		[span_notice("You transform your arm into umbral tendrils. Examine them to see possible uses.")]")
		playsound(owner, 'massmeta/sounds/magic/pass_create.ogg', 50, 1)
		var/obj/item/umbral_tendrils/T = new(owner, darkspawn)
		owner.put_in_hands(T)
	else
		owner.visible_message(span_warning("[owner]'s arms contort into tentacles!"), "<span class='velvet'><b>ikna ikna</b><br>\
		You transform both arms into umbral tendrils. Examine them to see possible uses.</span>")
		playsound(owner, 'massmeta/sounds/magic/pass_create.ogg', 50, TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, owner, 'massmeta/sounds/magic/pass_create.ogg', 50, TRUE), 1)
		for(var/i in 1 to 2)
			var/obj/item/umbral_tendrils/T = new(owner, darkspawn)
			owner.put_in_hands(T)
	return TRUE

/datum/action/innate/darkspawn/pass/Deactivate()
	owner.visible_message(span_warning("[owner]'s tentacles transform back!"), "<span class='velvet bold'>haoo</span><br>\
	[span_notice("You dispel the tendrils.")]")
	playsound(owner, 'massmeta/sounds/magic/pass_dispel.ogg', 50, 1)
	for(var/obj/item/umbral_tendrils/T in owner)
		qdel(T)
	return TRUE
