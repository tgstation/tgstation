/// Say something and play a corresponding sound effect
/datum/action/cooldown/bot_announcement
	name = "Make automated announcement"
	desc = "Play a prerecorded message for the benefit of those around you."
	background_icon_state = "bg_tech_blue"
	overlay_icon_state = "bg_tech_blue_border"
	button_icon = 'icons/obj/machines/wallmounts.dmi'
	button_icon_state = "intercom"
	cooldown_time = 5 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_BOT_ANNOUNCMENT
	/// List of strings to sound effects corresponding to automated messages we can play
	var/list/automated_announcements
	/// Maximum amount of buttons this can have
	var/max_buttons = 10
	/// List of buttons that automatically correspond to an announcement and channel
	var/list/buttons = list()

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

/datum/action/cooldown/bot_announcement/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotAnnouncement", "Select announcement")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/action/cooldown/bot_announcement/ui_state(mob/user)
	return GLOB.conscious_state

/datum/action/cooldown/bot_announcement/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(user != owner)
		return UI_CLOSE

/datum/action/cooldown/bot_announcement/ui_data(mob/user)
	var/list/data = list()

	var/mob/living/simple_animal/bot/bot_owner = owner
	if(istype(bot_owner))
		var/list/channels = list()
		for(var/channel in bot_owner.internal_radio.channels)
			channels += channel
		data["channels"] = channels
	else
		data["channels"] = list()
	var/list/lines = list()
	for(var/line in automated_announcements)
		lines += line
	data["lines"] = lines
	var/list/button_data = list()
	for(var/datum/action/cooldown/bot_announcement_shortcut/button as anything in buttons)
		button_data += list(list(
			"name" = button.name,
			"channel" = button.channel
		))
	data["button_data"] = button_data
	data["cooldown_left"] = next_use_time - world.time
	return data

/datum/action/cooldown/bot_announcement/Destroy()
	QDEL_LIST(buttons)
	return ..()

/datum/action/cooldown/bot_announcement/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("announce")
			var/picked = params["picked"]
			var/channel = params["channel"]
			if(!(picked in automated_announcements))
				return
			announce(picked, channel)
			StartCooldown()
			return TRUE
		if("set_button")
			if(length(buttons) >= max_buttons)
				return
			var/picked = params["picked"]
			var/channel = params["channel"]
			if(!(picked in automated_announcements))
				return
			create_shortcut(picked, channel)
			return TRUE
		if("remove_button")
			var/index = text2num(params["index"])
			if(!index)
				return
			if(index < 1 || index > length(buttons))
				return
			var/datum/action/button = buttons[index]
			qdel(button)
			return TRUE

/datum/action/cooldown/bot_announcement/Activate(trigger_flags, atom/target)
	if (length(automated_announcements) > 1)
		ui_interact(owner)
		return
	else if(length(automated_announcements) == 1)
		announce(automated_announcements[1])
	return ..()

/datum/action/cooldown/bot_announcement/proc/create_shortcut(line, channel)
	var/datum/action/cooldown/bot_announcement_shortcut/shortcut = new(src)

	shortcut.prefix = copytext(line, 1, 4)
	var/color = GLOB.radiocolors["[channel]"]
	if(color)
		shortcut.prefix_color = color
	shortcut.name = line
	shortcut.message = line
	shortcut.channel = channel
	shortcut.linked = src
	shortcut.Grant(owner)
	RegisterSignal(shortcut, COMSIG_QDELETING, PROC_REF(on_shortcut_deleted))
	buttons += shortcut

/datum/action/cooldown/bot_announcement/proc/on_shortcut_deleted(datum/shortcut)
	SIGNAL_HANDLER
	buttons -= shortcut

/datum/action/cooldown/bot_announcement/Grant(mob/granted_to)
	. = ..()
	for(var/datum/action/action as anything in buttons)
		action.Grant(granted_to)

/datum/action/cooldown/bot_announcement/Remove(mob/removed_from)
	for(var/datum/action/action as anything in buttons)
		action.Remove(removed_from)
	return ..()

/// Speak the provided line on the provided radio channel
/datum/action/cooldown/bot_announcement/proc/announce(line, channel)
	var/mob/living/simple_animal/bot/bot_owner = owner
	if (!(bot_owner.bot_mode_flags & BOT_MODE_ON))
		return

	bot_owner.say(line)
	if (channel && bot_owner.internal_radio.channels[channel])
		bot_owner.internal_radio.talk_into(bot_owner, message = line, channel = channel)

	if (length(automated_announcements) && !isnull(automated_announcements[line]))
		playsound(bot_owner, automated_announcements[line], vol = 50, vary = FALSE)


/datum/action/cooldown/bot_announcement/medbot

/datum/action/cooldown/bot_announcement/medbot/announce(line, channel)
	var/mob/living/basic/bot/medbot/bot_owner = owner
	if(!(bot_owner.medical_mode_flags & MEDBOT_SPEAK_MODE))
		return
	return ..()

/datum/action/cooldown/bot_announcement_shortcut
	desc = "Play a prerecorded message for the benefit of those around you."
	shared_cooldown = MOB_SHARED_COOLDOWN_BOT_ANNOUNCMENT
	background_icon_state = "bg_tech_blue"
	overlay_icon_state = "bg_tech_blue_border"
	button_icon = 'icons/obj/machines/wallmounts.dmi'
	button_icon_state = "intercom"
	/// The prefix that appears on this button
	var/prefix
	/// The color of the prefix that appears on the button
	var/prefix_color = "#ffffff"
	/// The prefix icon that's rendered on the button
	var/mutable_appearance/prefix_icon
	/// The message to send when this button is clicked
	var/message
	/// The channel to send this to when clicked
	var/channel

	/// The linked bot_announcement ability
	var/datum/action/cooldown/bot_announcement/linked

/datum/action/cooldown/bot_announcement_shortcut/Destroy()
	linked = null
	return ..()

/datum/action/cooldown/bot_announcement_shortcut/apply_button_overlay(atom/movable/screen/movable/action_button/current_button, force)
	. = ..()
	if(prefix_icon)
		current_button.cut_overlay(prefix_icon)
	if(!prefix)
		return
	if(!prefix_icon)
		prefix_icon = mutable_appearance()
	prefix_icon.maptext = MAPTEXT_SPESSFONT("<span style='color: [prefix_color]; text-align: right; '>[prefix]</span>")
	prefix_icon.maptext_x = -4
	prefix_icon.maptext_y = 8
	current_button.add_overlay(prefix_icon)

/datum/action/cooldown/bot_announcement_shortcut/Activate(atom/target)
	if(!message || !linked)
		return
	cooldown_time = linked.cooldown_time
	linked.announce(message, channel)
	return ..()
