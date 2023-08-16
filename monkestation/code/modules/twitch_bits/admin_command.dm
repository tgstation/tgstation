/client/proc/summon_twitch_event()
	set category = "Admin.Fun"
	set name = "Summon Twitch Event"
	set desc = "Starts a twitch event with the given ID."

	var/datum/twitch_event/choice = tgui_input_list(usr, "Choose an event", "Event Selection", subtypesof(/datum/twitch_event))
	if(!choice)
		return
	SStwitch.add_to_queue(initial(choice.id_tag))

	log_admin("[key_name(usr)] added [choice] to the Twitch Event Queue.")
