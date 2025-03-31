//The hunters!!
/datum/antagonist/fugitive_hunter
	name = "Fugitive Hunter"
	roundend_category = "Fugitive"
	silent = TRUE //greet called by the spawn
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_HUNTERS
	prevent_roundtype_conversion = FALSE
	antag_hud_name = "fugitive_hunter"
	suicide_cry = "FOR GLORY!!"
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/fugitive_hunters/hunter_team
	var/backstory = "error"

/datum/antagonist/fugitive_hunter/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/fugitive_hunter/forge_objectives() //this isn't an actual objective because it's about round end rosters
	var/datum/objective/capture = new /datum/objective
	capture.owner = owner
	capture.explanation_text = "Capture the fugitives in the station and put them into the bluespace capture machine on your ship."
	objectives += capture

/datum/antagonist/fugitive_hunter/greet()
	switch(backstory)
		if(HUNTER_PACK_COPS)
			to_chat(owner, span_bolddanger("Justice has arrived. I am a member of the Spacepol!"))
			to_chat(owner, "<B>The criminals should be on the station, we have special huds implanted to recognize them.</B>")
			to_chat(owner, "<B>As we have lost pretty much all power over these damned lawless megacorporations, it's a mystery if their security will cooperate with us.</B>")
		if(HUNTER_PACK_RUSSIAN)
			to_chat(owner, span_danger("Ay blyat. I am a space-russian smuggler! We were mid-flight when our cargo was beamed off our ship!"))
			to_chat(owner, span_danger("We were hailed by a man in a green uniform, promising the safe return of our goods in exchange for a favor:"))
			to_chat(owner, span_danger("There is a local station housing fugitives that the man is after, he wants them returned; dead or alive."))
			to_chat(owner, span_danger("We will not be able to make ends meet without our cargo, so we must do as he says and capture them."))
		if(HUNTER_PACK_BOUNTY)
			to_chat(owner, span_danger("Time to clock in. I am a bounty hunter! We should be arriving at our mark's hideout shortly."))
			to_chat(owner, span_danger("The briefing mentioned our destination was a research station. An unusual place for a target to try and lay low."))
			to_chat(owner, span_danger("Our client promised us big bucks, and we intend to make good on our delivery. Let's hope this is an easy paycheck..."))
		if(HUNTER_PACK_PSYKER)
			to_chat(owner, span_danger("GOOD EVENING, WE ARE PSYKER HUNTE- NO, PSYKER SHIKARIS!"))
			to_chat(owner, span_danger("A brainling hit us up on the holopad with an offer we could NOT pass up. We kidnap some fools for them, and in exchange we get a LIFETIME SUPPLY OF GORE."))
			to_chat(owner, span_danger("Our gore supply has been running thin as of late -- How could we say no? The binge MUST go on!"))
		if(HUNTER_PACK_MI13)
			to_chat(owner, span_danger("Agents, we have detected a wanted fugitive in Nanotrasen controlled space."))
			to_chat(owner, span_danger("Your mission is simple. Infiltrate the facility and extract the target, dead or alive."))
			to_chat(owner, span_danger("This is a stealth infiltration mission in hostile enemy territory. Be wary, and avoid being caught if possible."))

	to_chat(owner, span_bolddanger("You are not an antagonist in that you may kill whomever you please, but you can do anything to ensure the capture of the fugitives, even if that means going through the station."))
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
		hunter_team.backstory = backstory
		hunter_team.update_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	hunter_team = new_team

/datum/antagonist/fugitive_hunter/get_team()
	return hunter_team

/datum/antagonist/fugitive_hunter/apply_innate_effects(mob/living/mob_override)
	add_team_hud(mob_override || owner.current)
	if(backstory == HUNTER_PACK_RUSSIAN)
		var/mob/living/owner_mob = mob_override || owner.current
		owner_mob.grant_language(/datum/language/spinwarder, source = LANGUAGE_BOUNTYHUNTER)
		owner_mob.set_active_language(/datum/language/spinwarder)

/datum/antagonist/fugitive_hunter/remove_innate_effects(mob/living/mob_override)
	var/mob/living/owner_mob = mob_override || owner.current
	owner_mob.remove_language(/datum/language/spinwarder, source = LANGUAGE_BOUNTYHUNTER)
	return ..()

/datum/team/fugitive_hunters
	var/backstory = "error"

/datum/team/fugitive_hunters/proc/update_objectives(initial = FALSE)
	objectives = list()
	var/datum/objective/O = new()
	O.team = src
	objectives += O

/datum/team/fugitive_hunters/proc/assemble_fugitive_results()
	var/list/fugitives_counted = list()
	var/list/fugitives_dead = list()
	var/list/fugitives_captured = list()
	for(var/datum/antagonist/fugitive/A in GLOB.antagonists)
		if(!A.owner)
			stack_trace("Antagonist datum without owner in GLOB.antagonists: [A]")
			continue
		fugitives_counted += A
		if(A.owner.current.stat == DEAD)
			fugitives_dead += A
		if(A.is_captured)
			fugitives_captured += A
	. = list(fugitives_counted, fugitives_dead, fugitives_captured) //okay, check out how cool this is.

/datum/team/fugitive_hunters/proc/all_hunters_dead()
	var/dead_boys = 0
	for(var/I in members)
		var/datum/mind/hunter_mind = I
		if(!(ishuman(hunter_mind.current) || (hunter_mind.current.stat == DEAD)))
			dead_boys++
	return dead_boys >= members.len

/datum/team/fugitive_hunters/proc/get_result()
	var/list/fugitive_results = assemble_fugitive_results()
	var/list/fugitives_counted = fugitive_results[1]
	var/list/fugitives_dead = fugitive_results[2]
	var/list/fugitives_captured = fugitive_results[3]
	var/hunters_dead = all_hunters_dead()
	//this gets a little confusing so follow the comments if it helps
	if(!fugitives_counted.len)
		return
	if(fugitives_captured.len)//any captured
		if(fugitives_captured.len == fugitives_counted.len)//if the hunters captured all the fugitives, there's a couple special wins
			if(!fugitives_dead)//specifically all of the fugitives alive
				return FUGITIVE_RESULT_BADASS_HUNTER
			else if(hunters_dead)//specifically all of the hunters died (while capturing all the fugitives)
				return FUGITIVE_RESULT_POSTMORTEM_HUNTER
			else//no special conditional wins, so just the normal major victory
				return FUGITIVE_RESULT_MAJOR_HUNTER
		else if(!hunters_dead)//so some amount captured, and the hunters survived.
			return FUGITIVE_RESULT_HUNTER_VICTORY
		else//so some amount captured, but NO survivors.
			return FUGITIVE_RESULT_MINOR_HUNTER
	else//from here on out, hunters lost because they did not capture any fugitive dead or alive. there are different levels of getting beat though:
		if(!fugitives_dead)//all fugitives survived
			return FUGITIVE_RESULT_MAJOR_FUGITIVE
		else if(fugitives_dead < fugitives_counted)//at least ANY fugitive lived
			return FUGITIVE_RESULT_FUGITIVE_VICTORY
		else if(!hunters_dead)//all fugitives died, but none were taken in by the hunters. minor win
			return FUGITIVE_RESULT_MINOR_FUGITIVE
		else//all fugitives died, all hunters died, nobody brought back. seems weird to not give fugitives a victory if they managed to kill the hunters but literally no progress to either goal should lead to a nobody wins situation
			return FUGITIVE_RESULT_STALEMATE

/datum/team/fugitive_hunters/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	if(!members.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'>...And <B>[members.len]</B> [backstory]s tried to hunt them down!"

	for(var/datum/mind/M in members)
		result += "<b>[printplayer(M)]</b>"

	switch(get_result())
		if(FUGITIVE_RESULT_BADASS_HUNTER)//use defines
			result += "<span class='greentext big'>Badass [capitalize(backstory)] Victory!</span>"
			result += "<B>The [backstory]s managed to capture every fugitive, alive!</B>"
		if(FUGITIVE_RESULT_POSTMORTEM_HUNTER)
			result += "<span class='greentext big'>Postmortem [capitalize(backstory)] Victory!</span>"
			result += "<B>The [backstory]s managed to capture every fugitive, but all of them died! Spooky!</B>"
		if(FUGITIVE_RESULT_MAJOR_HUNTER)
			result += "<span class='greentext big'>Major [capitalize(backstory)] Victory</span>"
			result += "<B>The [backstory]s managed to capture every fugitive, dead or alive.</B>"
		if(FUGITIVE_RESULT_HUNTER_VICTORY)
			result += "<span class='greentext big'>[capitalize(backstory)] Victory</span>"
			result += "<B>The [backstory]s managed to capture a fugitive, dead or alive.</B>"
		if(FUGITIVE_RESULT_MINOR_HUNTER)
			result += "<span class='greentext big'>Minor [capitalize(backstory)] Victory</span>"
			result += "<B>All the [backstory]s died, but managed to capture a fugitive, dead or alive.</B>"
		if(FUGITIVE_RESULT_STALEMATE)
			result += "<span class='neutraltext big'>Bloody Stalemate</span>"
			result += "<B>Everyone died, and no fugitives were recovered!</B>"
		if(FUGITIVE_RESULT_MINOR_FUGITIVE)
			result += "<span class='redtext big'>Minor Fugitive Victory</span>"
			result += "<B>All the fugitives died, but none were recovered!</B>"
		if(FUGITIVE_RESULT_FUGITIVE_VICTORY)
			result += "<span class='redtext big'>Fugitive Victory</span>"
			result += "<B>A fugitive survived, and no bodies were recovered by the [backstory]s.</B>"
		if(FUGITIVE_RESULT_MAJOR_FUGITIVE)
			result += "<span class='redtext big'>Major Fugitive Victory</span>"
			result += "<B>All of the fugitives survived and avoided capture!</B>"
		else //get_result returned null- either bugged or no fugitives showed
			result += "<span class='neutraltext big'>Prank Call!</span>"
			result += "<B>[capitalize(backstory)]s were called, yet there were no fugitives...?</B>"

	result += "</div>"

	return result.Join("<br>")
