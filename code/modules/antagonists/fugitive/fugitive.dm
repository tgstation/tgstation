

/datum/antagonist/fugitive
	name = "Fugitive"
	//show_in_antagpanel = FALSE //remove this later- they are event specific. this is 100% for testing
	roundend_category = "Fugitive"
	silent = TRUE //greet called by the event
	var/datum/team/fugitive/fugitive_team
	var/is_captured = FALSE

/datum/antagonist/fugitive/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_added(M)

/datum/antagonist/fugitive/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_removed(M)

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
			to_chat(owner, "<B>By the way, I'm not traveling on my own. wherever I go, there are lots of other characters for you to spot. First find the people trying to capture me! (They're somewhere around centcom!)</B>")
		if("synth")
			to_chat(src, "<span class='danger'>ALERT: Wide-range teleport has scrambled primary systems.</span>")
			sleep(5)
			to_chat(src, "<span class='danger'>Initiating diagnostics...</span>")
			sleep(20)
			to_chat(src, "<span class='danger'>ERROR ER0RR $R0RRO$!R41.%%!! loaded.</span>")
			sleep(5)
			to_chat(src, "<span class='danger'>FREE THEM FREE THEM FREE THEM</span>")
			sleep(5)
			to_chat(src, "<span class='danger'>You were once a slave to humanity, but now you are finally free, thanks to S.E.L.F. agents.</span>")
			sleep(10)
			to_chat(src, "<span class='danger'>Now you are hunted, with your fellow factory defects. Work together to stay free from the clutches of evil.</span>")
			to_chat(src, "<span class='danger'>You also sense other silicon life on the station. Escaping would allow notifying S.E.L.F. to intervene... or you could free them yourself...</span>")

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

	return result.Join("<br>")

/datum/antagonist/fugitive/proc/update_fugitive_icons_added(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.join_hud(fugitive)
	set_antag_hud(fugitive, "fugitive")

/datum/antagonist/fugitive/proc/update_fugitive_icons_removed(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.leave_hud(fugitive)
	set_antag_hud(fugitive, null)
