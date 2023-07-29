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

/datum/action/cooldown/bot_announcement/Activate(trigger_flags, atom/target)
	var/picked
	if (length(automated_announcements) > 1)
		picked = tgui_input_list(owner, message = "Choose announcement to make.", title = "Select announcement", items = automated_announcements)
	else
		picked = pick(automated_announcements)
	if (isnull(picked))
		return
	announce(picked)
	return ..()

/// Speak the provided line on the provided radio channel
/datum/action/cooldown/bot_announcement/proc/announce(line, channel)
	var/mob/living/simple_animal/bot/bot_owner = owner
	if (!(bot_owner.bot_mode_flags & BOT_MODE_ON))
		return

	if (channel && bot_owner.internal_radio.channels[channel])
		bot_owner.internal_radio.talk_into(bot_owner, message = line, channel = channel)
	else
		bot_owner.say(line)

	if (length(automated_announcements) && !isnull(automated_announcements[line]))
		playsound(bot_owner, automated_announcements[line], vol = 50, vary = FALSE)
