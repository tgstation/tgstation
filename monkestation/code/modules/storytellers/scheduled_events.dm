///Scheduled event datum for SSgamemode to put events into.
/datum/scheduled_event
	/// What event are scheduling.
	var/datum/round_event_control/event
	/// When do we start our event
	var/start_time = 0
	/// If we were created by a storyteller, here's a cost to refund in case.
	var/cost
	/// Whether we alerted admins about this schedule when it's close to being invoked.
	var/alerted_admins = FALSE
	/// Whether we are faking an occurence or not
	var/fakes_occurence = TRUE
	/// Whether this ignores event can run checks. If bussed by an admin, you want to ignore checks
	var/ignores_checks
	/// Whether the scheduled event will override the announcement change. If null it won't. TRUE = force yes. FALSE = force no.
	var/announce_change

/datum/scheduled_event/New(datum/round_event_control/passed_event, passed_time, passed_cost, passed_ignore, passed_announce)
	. = ..()
	event = passed_event
	start_time = passed_time
	cost = passed_cost
	ignores_checks = passed_ignore
	announce_change = passed_announce
	/// Add a fake occurence to make the weightings/checks properly respect the scheduled event.
	event.add_occurence()
	fakes_occurence = TRUE

/datum/scheduled_event/proc/remove_occurence()
	if(fakes_occurence)
		/// Remove the fake occurence if we still have it
		event.subtract_occurence()
		fakes_occurence = FALSE

/// For admins who want to reschedule the event.
/datum/scheduled_event/proc/reschedule(new_time)
	start_time = new_time
	alerted_admins = FALSE

/datum/scheduled_event/proc/get_href_actions()
	var/round_started = SSticker.HasRoundStarted()
	if(round_started)
		return "<a href='?src=[REF(src)];action=fire'>Fire</a> <a href='?src=[REF(src)];action=reschedule'>Reschedule</a> <a href='?src=[REF(src)];action=cancel'>Cancel</a> <a href='?src=[REF(src)];action=refund'>Refund</a></td>"
	else
		return "<a href='?src=[REF(src)];action=cancel'>Cancel</a>"

/// Try and fire off the scheduled event
/datum/scheduled_event/proc/try_fire()
	/// Remove our fake occurence pre-emptively for the checks.
	remove_occurence()

	///If we can't spawn the scheduled event, refund it.
	if(!ignores_checks && !event.can_spawn_event(FALSE)) //FALSE argument to ignore popchecks, to prevent scheduled events from failing from people dying/cryoing etc.
		message_admins("Scheduled Event: [event] was unable to run and has been refunded.")
		SSgamemode.refund_scheduled_event(src)
		return

	///Trigger the event and remove the scheduled datum
	message_admins("Scheduled Event: [event] successfully triggered.")
	SSgamemode.TriggerEvent(event)
	SSgamemode.remove_scheduled_event(src)

/datum/scheduled_event/Destroy()
	remove_occurence()
	event = null
	return ..()

/datum/scheduled_event/Topic(href, href_list)
	. = ..()
	if(QDELETED(src))
		return
	var/round_started = SSticker.HasRoundStarted()
	switch(href_list["action"])
		if("cancel")
			message_admins("[key_name_admin(usr)] cancelled scheduled event [event.name].")
			log_admin_private("[key_name(usr)] cancelled scheduled event [event.name].")
			SSgamemode.remove_scheduled_event(src)
		if("refund")
			message_admins("[key_name_admin(usr)] refunded scheduled event [event.name].")
			log_admin_private("[key_name(usr)] refunded scheduled event [event.name].")
			SSgamemode.refund_scheduled_event(src)
		if("reschedule")
			var/new_schedule = input(usr, "New schedule time (in seconds):", "Reschedule Event") as num|null
			if(isnull(new_schedule) || QDELETED(src))
				return
			start_time = world.time + new_schedule * 1 SECONDS
			message_admins("[key_name_admin(usr)] rescheduled event [event.name] to [new_schedule] seconds.")
			log_admin_private("[key_name(usr)] rescheduled event [event.name] to [new_schedule] seconds.")
		if("fire")
			if(!round_started)
				return
			message_admins("[key_name_admin(usr)] has fired scheduled event [event.name].")
			log_admin_private("[key_name(usr)] has fired scheduled event [event.name].")
			try_fire()
