//TODO
// Admin button to override with your own
// Sabotage objective for tators
// Multiple goals with less impact but more department focused

/datum/station_goal
	var/name = "Generic Goal"
	var/weight = 1 //In case of multiple goals later.
	var/required_crew = 10
	var/list/gamemode_blacklist = list()
	var/completed = FALSE
	var/report_message = "Complete this goal."
	var/datum/map_template/goal/template
	var/room_template = /datum/map_template/goal
	var/mappath

/datum/station_goal/proc/send_report()
	priority_announce("Priority Nanotrasen directive received. Project \"[name]\" details inbound.", "Incoming Priority Message", 'sound/ai/commandreport.ogg')
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
		return "<li>[name] :  <span class='greentext'>Completed!</span></li>"
	else
		return "<li>[name] : <span class='redtext'>Failed!</span></li>"

/datum/station_goal/Destroy()
	SSticker.mode.station_goals -= src
	. = ..()

/datum/station_goal/Topic(href, href_list)
	..()

	if(!check_rights(R_ADMIN) || !usr.client.holder.CheckAdminHref(href, href_list))
		return

	if(href_list["announce"])
		on_report()
		send_report()
	else if(href_list["remove"])
		qdel(src)

/datum/map_template/goal
	var/goal_id
	var/descriptiona
	goal_id = "goal_goal"
	mappath = "_maps/templates/goal_engineering.dmm"

/datum/map_template/goal/bsa
	name = "Goal BSA"
	goal_id = "goal_bsa"
	mappath = "_maps/templates/goal_security.dmm"

/datum/map_template/goal/dna_vault
	name = "Goal DNA Vault"
	goal_id = "goal_dna_vault"
	mappath = "_maps/templates/goal_service.dmm"


/datum/map_template/goal/shield
	name = "Goal Shield"
	goal_id = "goal_shield"
	mappath = "_maps/templates/goal_engineering.dmm"

/*
//Crew has to create alien intelligence detector
// Requires a lot of minerals
// Dish requires a lot of power
// Needs five? AI's for decoding purposes
/datum/station_goal/seti
	name = "SETI Project"

//Crew Sweep
//Blood samples and special scans of amount of people on roundstart manifest.
//Should keep sec busy.
//Maybe after completion you'll get some ling detecting gear or some station wide DNA scan ?
*/
