/datum/antagonist/melting
	name = "Melting Abnormality"
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE

/datum/antagonist/melting/greet()
	to_chat(owner.current, "<span class='notice'>You are the [owner.special_role]!</span>")
	to_chat(owner.current, "<span class='notice'>Infect members of the crew to gain adaptation points, and spread your infection further.</span>")
	owner.announce_objectives()

/datum/antagonist/melting/proc/forge_objectives(var/datum/mind/obsessionmind)

/datum/antagonist/melting/roundend_report_header()
	return 	"<span class='header'>There was a melting abnormality!</span><br>"

/datum/antagonist/melting/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += "<b>[printplayer(owner)]</b>"

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	report += "<span class='neutraltext'>[name] had converted [GLOB.meltedmobs.len] into slime creatures!</span>"

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

//objectives//



//It does nothing! (Besides tracking)

/datum/antagonist/melted
	name = "Melted"
