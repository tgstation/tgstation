/datum/action/cooldown/spell/caretaker
	name = "Caretaker’s Last Refuge"
	desc = "Shifts you into the Caretaker's Refuge, rendering you translucent and intangible. \
		While in the Refuge your movement is unrestricted, but you cannot use your hands or cast any spells. \
		You cannot enter the Refuge while near other sentient beings, \
		and you can be removed from it upon contact with antimagical artifacts."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "caretaker"
	sound = 'sound/effects/curse/curse2.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

/datum/action/cooldown/spell/caretaker/Remove(mob/living/remove_from)
	if(remove_from.has_status_effect(/datum/status_effect/caretaker_refuge))
		remove_from.remove_status_effect(/datum/status_effect/caretaker_refuge)
	return ..()

/datum/action/cooldown/spell/caretaker/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/caretaker/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	for(var/mob/living/alive in orange(5, owner))
		if(alive.stat != DEAD && alive.client)
			owner.balloon_alert(owner, "other minds nearby!")
			return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/caretaker/cast(mob/living/cast_on)
	. = ..()

	var/mob/living/carbon/carbon_user = owner
	if(carbon_user.has_status_effect(/datum/status_effect/caretaker_refuge))
		carbon_user.remove_status_effect(/datum/status_effect/caretaker_refuge)
	else
		carbon_user.apply_status_effect(/datum/status_effect/caretaker_refuge)
	return TRUE
