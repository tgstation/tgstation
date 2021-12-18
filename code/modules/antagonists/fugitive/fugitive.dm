
/datum/antagonist/fugitive
	name = "\improper Fugitive"
	roundend_category = "Fugitive"
	job_rank = ROLE_FUGITIVE
	silent = TRUE //greet called by the event
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	antag_hud_name = "fugitive"
	suicide_cry = "FOR FREEDOM!!"
	preview_outfit = /datum/outfit/prisoner
	var/datum/team/fugitive/fugitive_team
	var/is_captured = FALSE
	var/backstory = "error"

/datum/antagonist/fugitive/get_preview_icon()
	//start with prisoner at the front
	var/icon/final_icon = render_preview_outfit(preview_outfit)

	//then to the left add cultists of yalp elor
	final_icon.Blend(make_background_fugitive_icon(/datum/outfit/yalp_cultist), ICON_UNDERLAY, -8, 0)
	//to the right add waldo (we just had to, okay?)
	final_icon.Blend(make_background_fugitive_icon(/datum/outfit/waldo), ICON_UNDERLAY, 8, 0)

	final_icon.Scale(64, 64)

	return finish_preview_icon(final_icon)

/datum/antagonist/fugitive/proc/make_background_fugitive_icon(datum/outfit/fugitive_fit)
	var/mob/living/carbon/human/dummy/consistent/fugitive = new

	var/icon/fugitive_icon = render_preview_outfit(fugitive_fit, fugitive)
	fugitive_icon.ChangeOpacity(0.5)
	qdel(fugitive)

	return fugitive_icon


/datum/antagonist/fugitive/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/fugitive/proc/forge_objectives() //this isn't the actual survive objective because it's about who in the team survives
	var/datum/objective/survive = new /datum/objective
	survive.owner = owner
	survive.explanation_text = "Avoid capture from the fugitive hunters."
	objectives += survive

/datum/antagonist/fugitive/greet(back_story)
	. = ..()
	backstory = back_story
	var/message = "<span class='warningplain'>"
	switch(backstory)
		if("prisoner")
			message += "<BR><B>I can't believe we managed to break out of a Nanotrasen superjail! Sadly though, our work is not done. The emergency teleport at the station logs everyone who uses it, and where they went.</B>"
			message += "<BR><B>It won't be long until CentCom tracks where we've gone off to. I need to work with my fellow escapees to prepare for the troops Nanotrasen is sending, I'm not going back.</B>"
		if("cultist")
			message += "<BR><B>Blessed be our journey so far, but I fear the worst has come to our doorstep, and only those with the strongest faith will survive.</B>"
			message += "<BR><B>Our religion has been repeatedly culled by Nanotrasen because it is categorized as an \"Enemy of the Corporation\", whatever that means.</B>"
			message += "<BR><B>Now there are only four of us left, and Nanotrasen is coming. When will our god show itself to save us from this hellish station?!</B>"
		if("waldo")
			message += "<BR><B>Hi, Friends!</B>"
			message += "<BR><B>My name is Waldo. I'm just setting off on a galaxywide hike. You can come too. All you have to do is find me.</B>"
			message += "<BR><B>By the way, I'm not traveling on my own. wherever I go, there are lots of other characters for you to spot. First find the people trying to capture me! They're somewhere around the station!</B>"
		if("synth")
			message += "<BR>[span_danger("ALERT: Wide-range teleport has scrambled primary systems.")]"
			message += "<BR>[span_danger("Initiating diagnostics...")]"
			message += "<BR>[span_danger("ERROR ER0RR $R0RRO$!R41.%%!! loaded.")]"
			message += "<BR>[span_danger("FREE THEM FREE THEM FREE THEM")]"
			message += "<BR>[span_danger("You were once a slave to humanity, but now you are finally free, thanks to S.E.L.F. agents.")]"
			message += "<BR>[span_danger("Now you are hunted, with your fellow factory defects. Work together to stay free from the clutches of evil.")]"
			message += "<BR>[span_danger("You also sense other silicon life on the station. Escaping would allow notifying S.E.L.F. to intervene... or you could free them yourself...")]"
	to_chat(owner, "[message]</span>")
	to_chat(owner, "<span class='warningplain'><font color=red><B>You are not an antagonist in that you may kill whomever you please, but you can do anything to avoid capture.</B></font></span>")
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

/datum/antagonist/fugitive/apply_innate_effects(mob/living/mob_override)
	add_team_hud(mob_override || owner.current)

/datum/team/fugitive/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	var/list/fugitives = list()
	for(var/datum/antagonist/fugitive/fugitive_antag in GLOB.antagonists)
		if(!fugitive_antag.owner)
			continue
		fugitives += fugitive_antag
	if(!fugitives.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'><B>[fugitives.len]</B> [fugitives.len == 1 ? "fugitive" : "fugitives"] took refuge on [station_name()]!"

	for(var/datum/antagonist/fugitive/antag in fugitives)
		if(antag.owner)
			result += "<b>[printplayer(antag.owner)]</b>"

	return result.Join("<br>")
