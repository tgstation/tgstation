/// Allows us to move through glass but not electrified glass. Can also do a little slowdown before passing through
/datum/status_effect/glass_passer
	id = "glass_passer"
	duration = INFINITE
	alert_type = null
	/// How long does it take us to move into glass?
	var/pass_time = 0 SECONDS

/datum/status_effect/glass_passer/on_apply()
	if(!pass_time)
		passwindow_on(owner, type)
	else
		RegisterSignal(owner, COMSIG_MOVABLE_BUMP, PROC_REF(bumped))
	owner.generic_canpass = FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_CAN_PASS_THROUGH, PROC_REF(can_pass_through))
	return TRUE

/datum/status_effect/glass_passer/on_remove()
	passwindow_off(owner, type)

/datum/status_effect/glass_passer/proc/can_pass_through(mob/living/carbon/human/human, atom/blocker, direction)
	SIGNAL_HANDLER

	if(istype(blocker, /obj/structure/grille))
		var/obj/structure/grille/grille = blocker
		if(grille.shock(human, 100))
			return COMSIG_COMPONENT_REFUSE_PASSAGE

	return null

/datum/status_effect/glass_passer/proc/bumped(mob/living/owner, atom/bumpee)
	SIGNAL_HANDLER

	if(!istype(bumpee, /obj/structure/window))
		return FALSE

	INVOKE_ASYNC(src, PROC_REF(phase_through_glass), owner, bumpee)

/datum/status_effect/glass_passer/proc/phase_through_glass(mob/living/owner, atom/bumpee)
	if(!do_after(owner, pass_time, bumpee))
		return
	passwindow_on(owner, type)
	try_move_adjacent(owner, get_dir(owner, bumpee))
	passwindow_off(owner, type)

/// Move through glass but a bit slower
/datum/status_effect/glass_passer/delayed
	pass_time = 2 SECONDS

/// THE GRAVITY!!! IT WEIGHS!!!
/datum/movespeed_modifier/grounded_voidwalker
	multiplicative_slowdown = 1.3

/// Regenerate in space
/datum/status_effect/space_regeneration
	id = "space_regeneration"
	duration = INFINITE
	alert_type = null

/datum/status_effect/space_regeneration/on_apply()
	heal_owner()
	return TRUE

/datum/status_effect/space_regeneration/tick(effect)
	heal_owner()

/// Regenerate health whenever this status effect is applied or reapplied
/datum/status_effect/space_regeneration/proc/heal_owner()
	owner.heal_overall_damage(brute = 1, burn = 1, required_bodytype = BODYTYPE_ORGANIC)

/datum/status_effect/planet_allergy
	id = "planet_allergy"
	duration = INFINITE
	alert_type = /atom/movable/screen/alert/veryhighgravity

/datum/status_effect/planet_allergy/tick()
	owner.adjustBruteLoss(1)
