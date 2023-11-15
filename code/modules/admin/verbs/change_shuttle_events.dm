///Manipulate the events that are gonna run/are running on the escape shuttle
/datum/admins/proc/change_shuttle_events()
	set category = "Admin.Events"
	set name = "Change Shuttle Events"
	set desc = "Allows you to change the events on a shuttle."

	if (!istype(src, /datum/admins))
		src = usr.client.holder
	if (!istype(src, /datum/admins))
		to_chat(usr, "Error: you are not an admin!", confidential = TRUE)
		return

	//At least for now, just letting admins modify the emergency shuttle is fine
	var/obj/docking_port/mobile/port = SSshuttle.emergency

	if(!port)
		to_chat(usr, span_admin("Uh oh, couldn't find the escape shuttle!"))

	var/list/options = list("Clear"="Clear")

	//Grab the active events so we know which ones we can Add or Remove
	var/list/active = list()
	for(var/datum/shuttle_event/event in port.event_list)
		active[event.type] = event

	for(var/datum/shuttle_event/event as anything in subtypesof(/datum/shuttle_event))
		options[((event in active) ? "(Remove)" : "(Add)") + initial(event.name)] = event

	//Throw up an ugly menu with the shuttle events and the options to add or remove them, or clear them all
	var/result = input(usr, "Choose an event to add/remove", "Shuttle Events") as null|anything in sort_list(options)

	if(result == "Clear")
		port.event_list.Cut()
		message_admins("[key_name_admin(usr)] has cleared the shuttle events on: [port]")
	else if(options[result])
		var/typepath = options[result]
		if(typepath in active)
			port.event_list.Remove(active[options[result]])
			message_admins("[key_name_admin(usr)] has removed '[active[result]]' from [port].")
		else
			port.event_list.Add(new typepath (port))
			message_admins("[key_name_admin(usr)] has added '[typepath]' to [port].")
