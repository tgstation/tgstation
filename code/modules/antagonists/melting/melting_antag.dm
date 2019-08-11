/datum/antagonist/melting
	name = "Melting Abnormality"
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE

/datum/antagonist/melting/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/slimealert.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, "<span class='notice'>You are the [owner.special_role]!</span>")
	to_chat(owner.current, "<span class='notice'>Use your mark ability while close to brainwash a champion! He will safely spread your disease generating you an army.</span>")
	to_chat(owner.current, "<span class='notice'>If you're in trouble, use your slime toss to infect a victim and deal massive damage. Sadly, it's on a very high cooldown so be wise when you use it.</span>")
	to_chat(owner.current, "<span class='notice'>If you die, your infection will be globally cured and your slime minions will no longer be able to infect victims with the infection.</span>")
	owner.announce_objectives()

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

//and for the melted antag...
//It does nothing! (Besides tracking)

/datum/antagonist/melted
	name = "Melted"
