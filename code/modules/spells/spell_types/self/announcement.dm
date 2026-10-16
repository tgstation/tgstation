/**
 * Wizard Announcement Spell
 * Allows a wizard to send a customizable announcement to the entire crew. hope this enables some fun gimmicks! or just some funny insults
 */

/datum/action/cooldown/spell/announcement
	name = "Wizard's Proclamation"
	desc = "send a wizardly announcement to the crew"
	button_icon_state = "announcement"
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 80 SECONDS
	invocation_type = INVOCATION_NONE
	var/announcement_text = ""
	var/announcement_sound = 'sound/effects/curse/curse2.ogg'
	button_icon = 'icons/mob/effects/talk.dmi'
	button_icon_state = "lawyer2"

/datum/action/cooldown/spell/announcement/before_cast()
	announcement_text = tgui_input_text(owner, "Insert your message to the stations denizens", "Wizards Proclamation", max_length = MAX_MESSAGE_LEN, multiline = TRUE, encode = FALSE)

	if(isnull(announcement_text) || announcement_text == "")
		owner.balloon_alert(owner, "cancelled announcement")
		return SPELL_CANCEL_CAST

	return ..()

/datum/action/cooldown/spell/announcement/cast()
	priority_announce(
	text = announcement_text,
	title = "Wizards Proclamation",
	sound = announcement_sound,
	has_important_message = TRUE,
	sender_override = "Wizard's Federation",
	color_override = "purple",
	)
	. = ..()
