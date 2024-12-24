/**
 * Station goals
 *
 * Objecives given to the whole station's crew to complete.
 * This gives the crew something to work towards during a round.
 */
/datum/station_goal
	///The name of the objective.
	var/name = "Generic Goal"
	/**
	 * The goal budget says how many objectives they want, and  this takes away from said budget.
	 * we keep taking from the budget until there's no more. As of currently, it's either 1, or infinite for greenshift
	 * meaning this only makes one station objective spawn, or all on a greenshift. Basically this doesn't do much and
	 * you shouldn't really change it.
	 */
	var/report_weight = 1
	///Whether this objective requires to be in a space station, barring it from planetary maps.
	var/requires_space = FALSE
	///Boolean on whether or not the objective has been completed. Most subtypes overwrite this anyways.
	var/completed = FALSE
	///The message that will be sent to the station via station report when the objective is received.
	///This is typically overwritten by subtypes in order to use formatting.
	var/report_message = "Complete this goal."
	///The type of goal this is, used to sort goals by type and to give one station-side and one mining-side.
	var/goal_type = STATION_GOAL

/datum/station_goal/New()
	. = ..()
	SSstation.goals_by_type[goal_type] = src

/datum/station_goal/Destroy(force)
	if(SSstation.goals_by_type[goal_type] == src)
		SSstation.goals_by_type[goal_type] = null
	return ..()

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
