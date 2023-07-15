/// Say something and play a corresponding sound effect
/datum/action/cooldown/bot_announcement
	name = "Make automated announcement"
	desc = "Play a prerecorded message for the benefit of those around you."
	background_icon_state = "bg_tech_blue"
	overlay_icon_state = "bg_tech_blue_border"
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "intercom"
	cooldown_time = 10 SECONDS
	melee_cooldown_time = 0 SECONDS
	/// List of strings to sound effects corresponding to automated messages we can play
	var/list/automated_announcements

/datum/action/cooldown/bot_announcement/New(Target, original, list/automated_announcements)
	src.automated_announcements = automated_announcements
	return ..()

/datum/action/cooldown/bot_announcement/IsAvailable(feedback)
	. = ..()
	if (!.)
		return
	if (!isbot(owner))
		if (feedback)
			owner.balloon_alert(owner, "no announcement system!")
		return FALSE
	if (!length(automated_announcements))
		if (feedback)
			owner.balloon_alert(owner, "no valid announcements!")
		return FALSE
	return TRUE

/datum/action/cooldown/bot_announcement/Trigger(trigger_flags, atom/target)
	var/picked
	if (length(automated_announcements) > 1)
		picked = tgui_input_list(owner, message = "Choose announcement to make.", title = "Select announcement", items = automated_announcements)
	else
		picked = pick(automated_announcements)
	if (isnull(picked))
		return
	var/mob/living/simple_animal/bot/bot_owner = owner
	bot_owner.speak(picked)
	if (!isnull(automated_announcements[picked]))
		playsound(bot_owner, automated_announcements[picked], vol = 50, vary = FALSE)
	return ..()
