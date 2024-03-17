/datum/station_goal
	var/name = "Generic Goal"
	var/weight = 1 //In case of multiple goals later.
	var/required_crew = 10
	var/requires_space = FALSE
	var/completed = FALSE
	var/report_message = "Complete this goal."

/datum/station_goal/proc/send_report()
	priority_announce("Priority Nanotrasen directive received. Project \"[name]\" details inbound.", "Incoming Priority Message", SSstation.announcer.get_rand_report_sound())
	print_command_report(get_report(),"Nanotrasen Directive [pick(GLOB.phonetic_alphabet)] \Roman[rand(1,50)]", announce=FALSE)
	on_report()

/datum/station_goal/proc/on_report()
	//Additional unlocks/changes go here
	return

/datum/station_goal/proc/get_report()
	return report_message

/datum/station_goal/proc/check_completion()
	return completed

/datum/station_goal/proc/get_result()
	if(check_completion())
		return "<li>[name] : [span_greentext("Completed!")]</li>"
	else
		return "<li>[name] : [span_redtext("Failed!")]</li>"

/datum/station_goal/Topic(href, href_list)
	..()
	if(!check_rights(R_ADMIN) || !usr.client.holder.CheckAdminHref(href, href_list))
		return

	if(href_list["announce"])
		on_report()
		send_report()
	else if(href_list["remove"])
		qdel(src)

/datum/station_goal/New()
	if(type in SSstation.goals_by_type)
		stack_trace("Creating a new station_goal of type [type] when one already exists in SSstation.goals_by_type this is not supported anywhere. I trust you tho")
	else
		SSstation.goals_by_type[type] = src
	return ..()

/datum/station_goal/Destroy(force)
	if(SSstation.goals_by_type[type] == src)
		SSstation.goals_by_type -= type
	return ..()
