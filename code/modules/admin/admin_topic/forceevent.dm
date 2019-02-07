/datum/datum_topic/admins_topic/forceevent
	keyword= "forceevent"
	log = FALSE

/datum/datum_topic/admins_topic/forceevent/Run(list/input,var/datum/admins/A)
    if(!check_rights(R_FUN))
        return
    var/datum/round_event_control/E = locate(input["forceevent"]) in SSevents.control
    if(E)
        E.admin_setup(usr)
        var/datum/round_event/event = E.runEvent()
        if(event.announceWhen>0)
            event.processing = FALSE
            var/prompt = alert(usr, "Would you like to alert the crew?", "Alert", "Yes", "No", "Cancel")
            switch(prompt)
                if("Cancel")
                    event.kill()
                    return
                if("No")
                    event.announceWhen = -1
            event.processing = TRUE
        message_admins("[key_name_admin(usr)] has triggered an event. ([E.name])")
        log_admin("[key_name(usr)] has triggered an event. ([E.name])")
    return