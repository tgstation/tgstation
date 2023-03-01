/// Datum that holds a proc for additional options when running an event.
/// Prototypes are declared here, non-prototypes on the event files.
/datum/event_admin_setup
	/// event control that owns this.
	var/datum/round_event_control/event_control

/datum/event_admin_setup/New(event_control)
	src.event_control = event_control

/datum/event_admin_setup/proc/prompt_admins()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented prompt_admins() on [event_control]'s admin setup.")

/datum/event_admin_setup/proc/apply_to_event(datum/round_event/event)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented apply_to_event() on [event_control]'s admin setup.")

/// A very common pattern is picking from a tgui list input, so this does that.
/// Supply a list in `get_list` and prompt admins will have the admin pick from it or cancel.
/datum/event_admin_setup/listed_options
	/// Text to ask the user, for example "What deal would you like to offer the crew?"
	var/input_text = "Unset Text"
	/// If set, picking this will be the same as running the event without admin setup.
	var/normal_run_option
	/// if you want a special button, this will add it. Remember to actually handle that case for chosen in `apply_to_event`
	/// Example is in scrubber_overflow.dm
	var/special_run_option
	/// Picked list option to be applied.
	var/chosen

/datum/event_admin_setup/listed_options/proc/get_list()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented get_list() on [event_control]'s admin setup.")

/datum/event_admin_setup/listed_options/prompt_admins()
	var/list/options = get_list()
	if(special_run_option)
		options.Insert(1, special_run_option)
	if(normal_run_option)
		options.Insert(1, normal_run_option)
	chosen = tgui_input_list(usr, input_text, event_control.name, options)
	if(!chosen)
		return ADMIN_CANCEL_EVENT
	if(normal_run_option && chosen == normal_run_option)
		chosen = null //no admin pick = runs as normal

/// For admin setups that want a custom string. Suggests what the event would have picked normally.
/datum/event_admin_setup/text_input
	/// Text to ask the user, for example "What horrifying truth will you reveal?"
	var/input_text = "Unset Text"
	/// Picked string to be applied.
	var/chosen

/// Returns a string to suggest to the admin, which would be what the event would have chosen.
/// No suggestion if an empty string, which is default behavior.
/datum/event_admin_setup/text_input/proc/get_text_suggestion()
	return ""

/datum/event_admin_setup/text_input/prompt_admins()
	var/suggestion = get_text_suggestion()
	chosen = tgui_input_text(usr, input_text, event_control.name, suggestion)
	if(!chosen)
		return ADMIN_CANCEL_EVENT

/// Some events are not always a good idea when a game state is in a certain situation.
/// This runs a check and warns the admin.
/datum/event_admin_setup/warn_admin
	/// Warning text shown to admin on the alert.
	var/warning_text = "Unset warning text"
	/// Message sent to other admins. Example: "has forced a shuttle catastrophe while a shuttle was already docked."
	var/snitch_text = "Unset snitching text (be mad at coders AND the admin responsible)"

/datum/event_admin_setup/warn_admin/prompt_admins()
	if(!should_warn())
		return
	var/mob/admin = usr
	if(tgui_alert(usr, "WARNING: [warning_text]", event_control.name, list("Yes", "No")) == "Yes")
		message_admins("[admin.ckey] [snitch_text]")
	else
		return ADMIN_CANCEL_EVENT

/// Returns whether the admin should get an alert.
/datum/event_admin_setup/warn_admin/proc/should_warn()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented should_warn() on [event_control]'s admin setup.")

/datum/event_admin_setup/warn_admin/apply_to_event(datum/round_event/event)
	return
