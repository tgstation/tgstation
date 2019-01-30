//The hunters!!
/datum/antagonist/fugitive_hunter
	name = "Fugitive Hunter"
	//show_in_antagpanel = FALSE //remove this later- they are event specific. this is 100% for testing
	roundend_category = "Fugitive"
	silent = TRUE //greet called by the event as well
	var/datum/team/fugitive_hunters/hunter_team

/datum/antagonist/fugitive_hunter/greet(backstory)
	switch(backstory)
		if("police")
			to_chat(owner, "<span class='boldannounce'>Justice has arrived. I am a member of the Spacepol!</span>")
			to_chat(owner, "<B>The criminals should be on the station, we have special huds to recognize them (they will most likely recognize us as well, mind you).</B>")
			to_chat(owner, "<B>As we have lost pretty much all power over these damned lawless megacorporations, it's a mystery if their security will cooperate with us.</B>")
	to_chat(owner, "<span class='boldannounce'>You are not an antagonist in that you may kill whomever you please, but you can do anything to ensure the capture of the fugitives, even if that means going through the station.</span>")
	owner.announce_objectives()

/datum/antagonist/fugitive_hunter/create_team(datum/team/fugitive_hunters/new_team)
	if(!new_team)
		for(var/datum/antagonist/fugitive_hunter/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.hunter_team)
				hunter_team = H.hunter_team
				return
		hunter_team = new /datum/team/fugitive_hunters
		hunter_team.update_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	hunter_team = new_team

/datum/antagonist/fugitive_hunter/get_team()
	return hunter_team

/datum/team/fugitive_hunters/proc/update_objectives(initial = FALSE)
	objectives = list()
	var/datum/objective/O = new()
	O.team = src
	objectives += O

/datum/team/fugitive_hunters/proc/get_result()
	return 1

/datum/team/fugitive_hunters/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	if(!members.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'>...And <B>[members.len]</B> hunters tried to hunt them down!"

	for(var/datum/mind/M in members)
		result += "<b>[printplayer(M)]</b>"

	switch(get_result())
		if(1)//use defines
			result += "<span class='greentext big'>Badass Hunter Victory!</span>"
			result += "<span class='redtext big'>Major Fugitive Defeat!</span>"
			result += "<span class='redtext big'>Minor Fugitive Defeat</span>"
			result += "<span class='neutraltext big'>Bloody Stalemate</span>"
			result += "<span class='greentext big'>Minor Fugitive Victory</span>"
			result += "<span class='greentext big'>Major Fugitive Victory</span>"

	return result.Join("<br>")
