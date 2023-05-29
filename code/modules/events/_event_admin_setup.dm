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
		if(snitch_text)
			message_admins("[admin.ckey] [snitch_text]")
	else
		return ADMIN_CANCEL_EVENT

/// Returns whether the admin should get an alert.
/datum/event_admin_setup/warn_admin/proc/should_warn()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented should_warn() on [event_control]'s admin setup.")

/datum/event_admin_setup/warn_admin/apply_to_event(datum/round_event/event)
	return

/datum/event_admin_setup/set_location
	///Text shown when admins are queried about setting the target location.
	var/input_text = "Aimed at the turf we're on?"
	///Turf that will be passed onto the event.
	var/atom/chosen_turf

/datum/event_admin_setup/set_location/prompt_admins()
	var/set_location = tgui_alert(usr, input_text, event_control.name, list("Yes", "No", "Cancel"))
	switch(set_location)
		if("Yes")
			chosen_turf = get_turf(usr)
		if("No")
			chosen_turf = null
		else
			return ADMIN_CANCEL_EVENT

/datum/event_admin_setup/input_number
	///Text shown when admins are queried about what number to set.
	var/input_text = "Unset text"
	///The value the number will be set to by default
	var/default_value
	///The highest value setable by the admin.
	var/max_value = 10000
	///The lowest value setable by the admin
	var/min_value = 0
	///Value selected by the admin
	var/chosen_value

/datum/event_admin_setup/input_number/prompt_admins()
	chosen_value = tgui_input_number(usr, input_text, event_control.name, default_value, max_value, min_value)
	if(isnull(chosen_value))
		return ADMIN_CANCEL_EVENT

///For events that mandate a set number of candidates to function
/datum/event_admin_setup/minimum_candidate_requirement
	///Text shown when there are not enough candidates
	var/output_text = "There are no candidates eligible to..."
	///Minimum number of candidates for the event to function
	var/min_candidates = 1

/datum/event_admin_setup/minimum_candidate_requirement/prompt_admins()
	var/candidate_count = count_candidates()
	if(candidate_count < min_candidates)
		tgui_alert(usr, output_text, "Error")
		return ADMIN_CANCEL_EVENT
	tgui_alert(usr, "[candidate_count] candidates found!", event_control.name)

/// Checks for candidates. Should return the total number of candidates
/datum/event_admin_setup/minimum_candidate_requirement/proc/count_candidates()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented count_candidates() on [event_control]'s admin setup.")

/datum/event_admin_setup/minimum_candidate_requirement/apply_to_event(datum/round_event/event)
	return

///For events that require a true/false question
/datum/event_admin_setup/question
	///Question shown to the admin.
	var/input_text = "Are you sure you would like to do this?"
	///Value passed to the event.
	var/chosen

/datum/event_admin_setup/question/prompt_admins()
	var/response = tgui_alert(usr, input_text , event_control.name , list("Yes", "No", "Cancel"))
	switch(response)
		if("Yes")
			chosen = TRUE
		if("No")
			chosen = FALSE
		else
			return ADMIN_CANCEL_EVENT

/datum/event_admin_setup/multiple_choice
	///Text shown to the admin when queried about which options they want to pick.
	var/input_text = "Unset Text"
	///The minimum number of choices an admin must make for this event.
	var/min_choices = 1
	///The maximum number of choices that the admin can make for this event.
	var/max_choices = 50
	///List of choices returned by this setup to the event.
	var/list/choices = list()

/datum/event_admin_setup/multiple_choice/proc/get_options()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented get_options() on [event_control]'s admin setup.")

/datum/event_admin_setup/multiple_choice/prompt_admins()
	var/list/options = get_options()
	choices = tgui_input_checkboxes(usr, input_text, event_control.name, options, min_choices, max_choices)
	if(isnull(choices))
		return ADMIN_CANCEL_EVENT
