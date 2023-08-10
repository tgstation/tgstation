/// Allows a mob to assume the form of another item or mob.
/// Warning, this will likely shit the bricks if you add this action to anything more sophisticated than a basic mob- this isn't built for anything carbon-wise.
/datum/action/cooldown/mob_cooldown/assume_form
	name = "Assume Form"
	desc = "Choose something that you wish to blend into the environment as. Click on yourself to reset your appearance."
	button_icon_state = "sniper_zoom"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS

	/// The type of the form we began with. Here as a nice cache so we don't have to keep reading owner.
	var/mob/living/original_type = null
	/// The type of the form we are assuming.
	var/atom/movable/assumed_type = null
	/// Stuff that we can not disguise as. Not static so we can modify it on Grant() and avoid extra work in certain checks
	var/list/blacklist_typecache = typecacheof(list(
		/atom/movable/screen,
		/obj/effect,
		/obj/energy_ball,
		/obj/narsie,
		/obj/singularity,
	))

/datum/action/cooldown/mob_cooldown/assume_form/Grant(mob/grant_to)
	. = ..()
	original_type = grant_to.type // if `original_type` ends up being null after this burn the codebase down
	blacklist_typecache += typecacheof(original_type)

/datum/action/cooldown/mob_cooldown/assume_form/Remove(mob/remove_from)
	if(isnull(assumed_type))
		return ..()

	reset_appearances()
	return ..()

/datum/action/cooldown/mob_cooldown/assume_form/Activate(atom/target_atom)
	StartCooldown(360 SECONDS, 360 SECONDS)
	determine_intent(target_atom)
	StartCooldown()
	return TRUE

/// Determines what our user meant by their action. If they clicked on themselves, we reset our appearance. Otherwise, we assume the appearance of the clicked-on item.
/datum/action/cooldown/mob_cooldown/assume_form/proc/determine_intent(atom/target_atom)
	if(is_type_in_typecache(target_atom, blacklist_typecache) || (!isobj(target_atom) && !ismob(target_atom)))
		return

	if(target_atom == owner)
		reset_appearances()
	else
		assume_appearances(target_atom)

/// Assumes the appearance of a desired movable and applies it to our mob. Target is the movable in question.
/datum/action/cooldown/mob_cooldown/assume_form/proc/assume_appearances(atom/movable/target)
	owner.appearance = target.appearance
	owner.copy_overlays(target)
	owner.alpha = max(owner.alpha, 150) //fucking chameleons
	owner.transform = initial(owner.transform)
	owner.pixel_x = owner.base_pixel_x
	owner.pixel_y = owner.base_pixel_y

	assumed_type = target.type
	ADD_TRAIT(owner, TRAIT_DISGUISED, assumed_type) // important: do this at the very end because we might have SIGNAL_ADDTRAIT for this on the mob that's dependent on the above logic

/// Resets the appearances of the mob to the default.
/datum/action/cooldown/mob_cooldown/assume_form/proc/reset_appearances()
	owner.animate_movement = SLIDE_STEPS
	owner.maptext = null
	owner.alpha = initial(owner.alpha)
	owner.color = initial(owner.color)
	owner.desc = initial(owner.desc)

	owner.name = initial(owner.name)
	owner.icon = initial(owner.icon)
	owner.icon_state = initial(owner.icon_state)
	owner.cut_overlays()

	REMOVE_TRAIT(owner, TRAIT_DISGUISED, assumed_type) // important: do this very end because we might have SIGNAL_REMOVETRAIT for this on the mob that's dependent on the above logic
	assumed_type = null
