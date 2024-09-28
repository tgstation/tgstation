/datum/action/changeling/headcrab
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, placing us in control of a vessel that can plant our likeness in a new host. Costs 20 chemicals."
	helptext = "We will be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us."
	button_icon_state = "last_resort"
	chemical_cost = 20
	dna_cost = CHANGELING_POWER_INNATE
	req_human = TRUE
	req_stat = DEAD
	ignores_fakedeath = TRUE
	disabled_by_fire = FALSE

/datum/action/changeling/headcrab/sting_action(mob/living/user)
	set waitfor = FALSE
	var/confirm = tgui_alert(user, "Are we sure we wish to destroy our body and create a headslug?", "Last Resort", list("Yes", "No"))
	if(confirm != "Yes")
		return

	..()
	var/datum/mind/stored_mind = user.mind
	var/list/organs = user.get_organs_for_zone(BODY_ZONE_HEAD, TRUE)

	explosion(user, light_impact_range = 2, adminlog = TRUE, explosion_cause = src)
	for(var/mob/living/carbon/human/blinded_human in range(2, user))
		var/obj/item/organ/internal/eyes/eyes = blinded_human.get_organ_slot(ORGAN_SLOT_EYES)
		if(!eyes || blinded_human.is_blind())
			continue
		to_chat(blinded_human, span_userdanger("You are blinded by a shower of blood!"))
		blinded_human.Stun(4 SECONDS)
		blinded_human.set_eye_blur_if_lower(40 SECONDS)
		blinded_human.adjust_confusion(12 SECONDS)

	for(var/mob/living/silicon/blinded_silicon in range(2,user))
		to_chat(blinded_silicon, span_userdanger("Your sensors are disabled by a shower of blood!"))
		blinded_silicon.Paralyze(6 SECONDS)

	var/turf/user_turf = get_turf(user)
	user.transfer_observers_to(user_turf) // user is about to be deleted, store orbiters on the turf
	if(user.stat != DEAD)
		user.investigate_log("has been gibbed by headslug burst.", INVESTIGATE_DEATHS)
	user.gib(DROP_ALL_REMAINS)
	. = TRUE
	addtimer(CALLBACK(src, PROC_REF(spawn_headcrab), stored_mind, user_turf, organs), 1 SECONDS)

/// Creates the headrab to occupy
/datum/action/changeling/headcrab/proc/spawn_headcrab(datum/mind/stored_mind, turf/spawn_location, list/organs)
	var/mob/living/basic/headslug/crab = new(spawn_location)
	for(var/obj/item/organ/I in organs)
		I.forceMove(crab)

	stored_mind.transfer_to(crab, force_key_move = TRUE)
	spawn_location.transfer_observers_to(crab)
	to_chat(crab, span_warning("You burst out of the remains of your former body in a shower of gore!"))
