/// Allows a mob to assume the form of another item or mob.
/// Warning, this will likely shit the bricks if you add this action to anything more sophisticated than a basic mob- this isn't built for anything carbon-wise.
/datum/action/cooldown/mob_cooldown/assume_form
	name = "Assume Form"
	desc = "Choose something that you wish to blend into the environment as. Click on yourself to reset your appearance."
	button_icon_state = "sniper_zoom"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 1.5 SECONDS

	/// Stuff that we can not disguise as.
	var/static/list/blacklist_typecache = typecacheof(list(
		/atom/movable/screen,
		/obj/effect,
		/obj/energy_ball,
		/obj/narsie,
		/obj/singularity,
	))

/datum/action/cooldown/mob_cooldown/assume_form/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(reset_appearances))

/datum/action/cooldown/mob_cooldown/assume_form/Remove(mob/remove_from)
	reset_appearances()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	return ..()

/datum/action/cooldown/mob_cooldown/assume_form/Activate(atom/target_atom)
	StartCooldown(360 SECONDS, 360 SECONDS)
	determine_intent(target_atom)
	StartCooldown()
	return TRUE

/// Rapid proc to test if we can assume the form of a given atom. Returns TRUE if we can, FALSE if we can't. Done like this so we can be nice and explicit.
/datum/action/cooldown/mob_cooldown/assume_form/proc/can_assume_form(atom/target_atom)
	if(is_type_in_typecache(target_atom, blacklist_typecache) || (!isobj(target_atom) && !ismob(target_atom)))
		return FALSE

	return TRUE

/// Determines what our user meant by their action. If they clicked on themselves, we reset our appearance. Otherwise, we assume the appearance of the clicked-on item.
/datum/action/cooldown/mob_cooldown/assume_form/proc/determine_intent(atom/target_atom)
	if(!can_assume_form(target_atom))
		return

	if(target_atom == owner)
		reset_appearances()
		return

	assume_appearances(target_atom)

/// Assumes the appearance of a desired movable and applies it to our mob. Target is the movable in question.
/datum/action/cooldown/mob_cooldown/assume_form/proc/assume_appearances(atom/movable/target_atom)
	owner.appearance = target_atom.appearance
	owner.copy_overlays(target_atom)
	owner.alpha = max(target_atom.alpha, 150) //fucking chameleons
	owner.transform = initial(target_atom.transform)
	owner.pixel_x = target_atom.base_pixel_x
	owner.pixel_y = target_atom.base_pixel_y

	// important: do this at the very end because we might have SIGNAL_ADDTRAIT for this on the mob that's dependent on the above logic
	SEND_SIGNAL(owner, COMSIG_ACTION_DISGUISED_APPEARANCE, target_atom)
	ADD_TRAIT(owner, TRAIT_DISGUISED, REF(src))

/// Resets the appearances of the mob to the default.
/datum/action/cooldown/mob_cooldown/assume_form/proc/reset_appearances()
	SIGNAL_HANDLER

	if(!HAS_TRAIT(owner, TRAIT_DISGUISED))
		return // in case we're being invoked on death and we aren't disguised (or we just click on ourselves randomly), no need to do this additional work.

	owner.animate_movement = SLIDE_STEPS
	owner.maptext = null
	owner.alpha = initial(owner.alpha)
	owner.color = initial(owner.color)
	owner.desc = initial(owner.desc)

	owner.name = initial(owner.name)
	owner.icon = initial(owner.icon)
	owner.icon_state = initial(owner.icon_state)
	owner.cut_overlays()

	// important: do this very end because we might have SIGNAL_REMOVETRAIT for this on the mob that's dependent on the above logic
	REMOVE_TRAIT(owner, TRAIT_DISGUISED, REF(src))
