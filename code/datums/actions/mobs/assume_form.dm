/// Allows a mob to assume the form of another item or mob.
/// Warning, this will likely shit the bricks if you add this action to anything more sophisticated than a basic mob- this isn't built for anything carbon-wise.
/datum/action/assume_form
	name = "Assume Form"
	desc = "Choose something that you wish to blend into the environment as."
	button_icon_state = "sniper_zoom"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS

	/// The type of the form we began with. Here as a nice cache so we don't have to keep reading owner.
	var/mob/living/original_type = null
	/// The type of the form we are assuming.
	var/atom/movable/assumed_type = null

/datum/action/assume_form/Grant(mob/grant_to)
	. = ..()
	original_type = grant_to.type // if `original_type` ends up being null after this burn the codebase down

/datum/action/assume_form/Remove(mob/remove_from)
	if(isnull(assumed_type))
		return ..()

	reset_appearances()
	return ..()

/// Assumes the appearance of a desired movable and applies it to our mob. Target is the movable in question.
/datum/action/assume_form/proc/assume_appearances(atom/movable/target)
	assumed_type = target.type

	owner.appearance = target.appearance
	owner.copy_overlays(target)
	owner.alpha = max(alpha, 150) //fucking chameleons
	owner.transform = initial(owner.transform)
	owner.pixel_x = owner.base_pixel_x
	owner.pixel_y = owner.base_pixel_y

/// Resets the appearances of the mob to the default.
/datum/action/cooldown/assume_form/proc/reset_appearances()
	if(isnull(assumed_type))
		owner.balloon_alert("already in normal form!")
		return FALSE

	assumed_type = null

	owner.animate_movement = SLIDE_STEPS
	owner.maptext = null
	owner.alpha = initial(owner.alpha)
	owner.color = initial(owner.color)
	owner.desc = initial(owner.desc)

	owner.name = initial(owner.name)
	owner.icon = initial(owner.icon)
	owner.icon_state = initial(owner.icon_state)
	cut_overlays()
