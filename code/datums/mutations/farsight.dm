/datum/mutation/farsight
	name = "Farsight"
	desc = "The subject's eyes are able to see further than normal."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MINOR
	text_gain_indication = span_notice("You feel your eyes tingle.")
	text_lose_indication = span_notice("Your eyes feel normal.")
	difficulty = 16
	power_coeff = 1
	power_path = /datum/action/cooldown/spell/farsight

/datum/mutation/farsight/setup()
	. = ..()
	var/datum/action/cooldown/spell/farsight/to_modify = .
	if(istype(to_modify))
		to_modify.set_sight_range(initial(to_modify.sight_range) * (GET_MUTATION_POWER(src) == 1 ? 1 : 3))

/datum/action/cooldown/spell/farsight
	name = "Farsight"
	desc = "You can see further than normal."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 8 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = NONE

	/// How much to expand the view size by
	var/sight_range = 1
	/// If we are currently active
	VAR_PRIVATE/active = FALSE

/datum/action/cooldown/spell/farsight/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, sight_range))
		set_sight_range(sight_range)

/datum/action/cooldown/spell/farsight/proc/set_sight_range(new_value)
	if(sight_range == new_value)
		return
	sight_range = new_value
	if(active)
		owner?.client?.view_size.setTo(sight_range)

/datum/action/cooldown/spell/farsight/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = cast_on
	if(active)
		caster.client?.view_size.resetToDefault()
		active = FALSE
		cooldown_time *= 2
	else
		caster.client?.view_size.setTo(sight_range)
		active = TRUE
		cooldown_time *= 0.5
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/cooldown/spell/farsight/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return active

/datum/action/cooldown/spell/farsight/Remove(mob/living/remove_from)
	. = ..()
	if(active)
		remove_from.client?.view_size.resetToDefault()
		active = FALSE
		cooldown_time *= 2
