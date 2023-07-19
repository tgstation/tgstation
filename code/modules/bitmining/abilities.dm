
/datum/avatar_help_text
	/// Text to display in the window
	var/help_text

/datum/avatar_help_text/New(help_text)
	src.help_text = help_text

/datum/avatar_help_text/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AvatarHelp")
		ui.open()

/datum/avatar_help_text/ui_state(mob/user)
	return GLOB.always_state

/datum/avatar_help_text/ui_static_data(mob/user)
	var/list/data = list()

	data["help_text"] = help_text

	return data

/// Displays information about the current virtual domain.
/datum/action/avatar_domain_info
	name = "Open Virtual Domain Information"
	button_icon_state = "round_end"
	show_to_observers = FALSE

/datum/action/avatar_domain_info/New(Target)
	. = ..()
	name = "Open Domain Information"

/datum/action/avatar_domain_info/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	target.ui_interact(owner)

/// Action to give whenever someone steps on a baited tile
/datum/action/avatar_free_sever
	name = "PROXIMITY: Sever Connection"
	show_to_observers = FALSE
	/// Icon displayed on the button
	var/mutable_appearance/intruder_icon

/datum/action/avatar_free_sever/New(Target, appearance)
	. = ..()
	target = Target
	intruder_icon = new(appearance)

	addtimer(CALLBACK(src, PROC_REF(remove_ability)), 5 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/action/avatar_free_sever/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/datum/mind/target_mind = target
	if(!isnull(target_mind))
		target_mind.sever_avatar()

/datum/action/avatar_free_sever/proc/remove_ability()
	qdel(src)
