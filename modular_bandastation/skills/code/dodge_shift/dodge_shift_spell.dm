/datum/action/cooldown/spell/dodge_mode
	name = "Dodge Mode"
	desc = "Toggles dodge mode."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "blink"
	cooldown_time = 3 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
	/// Whether dodge mode is active
	var/dodge_active = FALSE
	var/datum/element/dodge_shift/shift_type = /datum/element/dodge_shift/ultimate

/datum/action/cooldown/spell/dodge_mode/cast(mob/living/cast_on)
	. = ..()

	if(dodge_active)
		cast_on.RemoveElement(shift_type)
		dodge_active = FALSE
		name = "Dodge Mode"
		desc = "Enable dodge mode."
		to_chat(cast_on, span_warning("Dodge mode disabled."))
		cast_on.balloon_alert(cast_on, "dodge mode disabled")
	else
		cast_on.AddElement(shift_type)
		dodge_active = TRUE
		name = "Dodge Mode (Active)"
		desc = "Disable dodge mode."
		to_chat(cast_on, span_notice("Dodge mode enabled!"))
		cast_on.balloon_alert(cast_on, "dodge mode enabled")

	build_all_button_icons()

/datum/action/cooldown/spell/dodge_mode/Remove(mob/living/remove_from)
	. = ..()
	if(dodge_active && !QDELETED(remove_from))
		remove_from.RemoveElement(shift_type)
		dodge_active = FALSE
