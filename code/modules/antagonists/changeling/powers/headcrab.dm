/datum/action/changeling/headcrab
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, placing us in control of a vessel that can plant our likeness in a new host. Costs 20 chemicals."
	helptext = "We will be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us."
	button_icon_state = "last_resort"
	chemical_cost = 20
	dna_cost = 1
	req_human = TRUE

/datum/action/changeling/headcrab/sting_action(mob/living/user)
	set waitfor = FALSE
	var/confirm = tgui_alert(user, "Are we sure we wish to kill ourself and create a headslug?", "Last Resort", list("Yes", "No"))
	if(confirm != "Yes")
		return

	..()
	var/datum/mind/stored_mind = user.mind
	var/list/organs = user.getorganszone(BODY_ZONE_HEAD, 1)

	explosion(user, light_impact_range = 2, adminlog = TRUE, explosion_cause = src)
	for(var/mob/living/carbon/human/blinded_humans in range(2, user))
		var/obj/item/organ/eyes/eyes = blinded_humans.getorganslot(ORGAN_SLOT_EYES)
		if(!eyes || blinded_humans.is_blind())
			continue
		to_chat(blinded_humans, span_userdanger("You are blinded by a shower of blood!"))
		blinded_humans.Stun(20)
		blinded_humans.blur_eyes(20)
		blinded_humans.adjust_timed_status_effect(3 SECONDS, /datum/status_effect/confusion)

	for(var/mob/living/silicon/blinded_silicons in range(2,user))
		to_chat(blinded_silicons, span_userdanger("Your sensors are disabled by a shower of blood!"))
		blinded_silicons.Paralyze(60)

	var/turf/user_turf = get_turf(user)
	user.transfer_observers_to(user_turf) // user is about to be deleted, store orbiters on the turf
	user.gib()
	. = TRUE
	addtimer(CALLBACK(src, .proc/spawn_headcrab, stored_mind, user_turf, organs), 3 SECONDS)

/datum/action/changeling/headcrab/proc/spawn_headcrab(datum/mind/stored_mind, turf/spawn_location, list/organs)
	var/mob/living/simple_animal/hostile/headcrab/crab = new(spawn_location)
	for(var/obj/item/organ/I in organs)
		I.forceMove(crab)
	crab.origin = stored_mind
	if(!crab.origin)
		return
	crab.origin.active = TRUE
	crab.origin.transfer_to(crab)
	spawn_location.transfer_observers_to(crab)
	to_chat(crab, span_warning("You burst out of the remains of your former body in a shower of gore!"))
