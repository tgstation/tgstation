//Hey! This file also contains the antagonist datum for the hunters!


/datum/antagonist/fugitive
	name = "Fugitive"
	//show_in_antagpanel = FALSE //remove this later- they are event specific. this is 100% for testing
	roundend_category = "Fugitive"
	silent = TRUE //greet called by the event
	var/datum/team/fugitive/fugitive_team

/datum/antagonist/fugitive/greet(backstory)
	to_chat(owner, "<span class='boldannounce'>You are the Fugitive!</span>")
	switch(backstory)
		if("prisoner")
			to_chat(owner, "<B>I can't believe we managed to break out of a Nanotrasen superjail! Sadly though, our work is not done. The emergency teleport at the station logs everyone who uses it, and where they went.</B>")
			to_chat(owner, "<B>It won't be long until Centcom tracks where we've gone off to. I need to work with my fellow escapees to prepare for the troops Nanotrasen is sending, I'm not going back.</B>")
		if("cultist")
			to_chat(owner, "<B>Blessed be our journey so far, but I fear the worst has come to our doorstep, and only those with the strongest faith will survive.</B>")
			to_chat(owner, "<B>Our religion has been repeatedly culled by Nanotrasen because it is categorized as an \"Enemy of the Corporation\", whatever that means.</B>")
			to_chat(owner, "<B>Now there are only three of us left, and Nanotrasen is coming. But we have a secret weapon: Our weakened god, Yalp Elor, will help us survive.</B>")
		if("waldo")
			to_chat(owner, "<B>Hi, Friends!</B>")
			to_chat(owner, "<B>My name is Waldo. I'm just setting off on a galaxywide hike. You can come too. All you have to do is find me.</B>")
			to_chat(owner, "<B>By the way, I'm not traveling on my own. wherever I go, there are lots of other characters for you to spot. First find the people hunting me (They're somewhere around centcom).</B>")
	to_chat(owner, "<span class='boldannounce'>You are not an antagonist in that you may kill whomever you please, but you can do anything to avoid capture.</span>")
	owner.announce_objectives()

/datum/antagonist/fugitive/create_team(datum/team/fugitive/new_team)
	if(!new_team)
		for(var/datum/antagonist/fugitive/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.fugitive_team)
				fugitive_team = H.fugitive_team
				return
		fugitive_team = new /datum/team/fugitive
		fugitive_team.update_objectives()
		fugitive_team.update_heads()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	fugitive_team = new_team

/datum/antagonist/fugitive/get_team()
	return fugitive_team

/datum/team/fugitive/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	if(!members.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'><B>[members.len]</B> fugitives took refuge on [station_name()]!"
	
	for(var/datum/mind/M in members)
		result += "<b>[printplayer(M)]</b>"

	return report.Join("<br>")

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
		hunter_team.update_heads()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	hunter_team = new_team

/datum/antagonist/fugitive_hunter/get_team()
	return hunter_team

/datum/team/fugitive_hunters/get_result()
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
			report += "<span class='greentext big'>Badass Hunter Victory!</span>"
			report += "<span class='redtext big'>Major Fugitive Defeat!</span>"
			report += "<span class='redtext big'>Minor Fugitive Defeat</span>"
			report += "<span class='neutraltext big'>Bloody Stalemate</span>"
			report += "<span class='greentext big'>Minor Fugitive Victory</span>"
			report += "<span class='greentext big'>Major Fugitive Victory</span>"
		
	return report.Join("<br>")
