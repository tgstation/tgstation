/**
 * This datum defines an action that can be used by any mob/living to instantly admin heal themselves.
 * By default it has a 30 second cooldown.
 */
/datum/action/cooldown/arena_aheal
	name = "Fully Heal Self"
	icon_icon = 'modular_event/event_aheal/icons/button.dmi'
	button_icon_state = "arena_heal"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/arena_aheal/UpdateButtonIcon(status_only, force)
	button_icon_state = IsAvailable() ? initial(button_icon_state) : "arena_heal_used"
	return ..()

/datum/action/cooldown/arena_aheal/Trigger()
	var/mob/living/user = usr
	var/area/user_area = get_area(user)
	var/static/arena_areas = typecacheof(/area/tdome/arena)
	if(is_type_in_typecache(user_area.type, arena_areas))
		to_chat(user, span_boldwarning("You cannot use this ability inside [user_area]!"))
		return FALSE

	. = ..()
	if(!.)
		return FALSE

	// custom lightning bolt for sound
	var/turf/lightning_source = get_step(get_step(user, NORTH), NORTH)
	lightning_source.Beam(user, icon_state="lightning[rand(1,12)]", time = 5)
	playsound(get_turf(user), 'sound/magic/charge.ogg', 50, TRUE)
	if(ishuman(user))
		var/mob/living/carbon/human/human_target = user
		human_target.electrocution_animation(LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH)
	user.revive(TRUE, TRUE)
	StartCooldown()
