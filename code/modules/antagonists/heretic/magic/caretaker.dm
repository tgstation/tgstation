/datum/action/cooldown/spell/caretaker
	name = "Caretaker’s Last Refuge"
	desc = "Makes you transparent and not dense.  Cannot be used near living sentient beings. \
		While in refuge, you cannot use your hands or spells, and you are immune to slowdown. \
		You are also invincible, but pretty much cannot hurt anyone. Cancelled by being hit with an antimagic item."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"
	sound = 'sound/effects/curse2.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	
	var/list/caretaking_traits = list(TRAIT_HANDS_BLOCKED, TRAIT_IGNORESLOWDOWN)
	var/caretaking = FALSE

/datum/action/cooldown/spell/caretaker/Remove(mob/living/remove_from)
	if(caretaking)
		stop_caretaking()
	return ..()

/datum/action/cooldown/spell/caretaker/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/caretaker/cast(atom/cast_on)
	. = ..()
	for(var/mob/living/alive in orange(5, owner))
		if(alive.stat != DEAD && alive.client)
			owner.balloon_alert(owner, "there are heathens!")
			return FALSE

	if(caretaking)
		stop_caretaking()
	else
		start_caretaking()
	return TRUE

/datum/action/cooldown/spell/caretaker/proc/start_caretaking()
	var/mob/living/carbon/carbon_user = owner
	carbon_user.apply_status_effect(/datum/status_effect/caretaker_refuge)
	caretaking = TRUE

/datum/action/cooldown/spell/caretaker/proc/stop_caretaking()
	var/mob/living/carbon/carbon_user = owner
	carbon_user.remove_status_effect(/datum/status_effect/caretaker_refuge)
	caretaking = FALSE
