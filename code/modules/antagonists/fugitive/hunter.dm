//The hunters!!
/datum/antagonist/fugitive_hunter
	name = "Fugitive Hunter"
	//show_in_antagpanel = FALSE //remove this later- they are event specific. this is 100% for testing
	roundend_category = "Fugitive"
	silent = TRUE //greet called by the event as well
	var/datum/team/fugitive_hunters/hunter_team

/datum/antagonist/fugitive_hunter/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_added(M)

/datum/antagonist/fugitive_hunter/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_removed(M)

/datum/antagonist/fugitive_hunter/greet(backstory)
	switch(backstory)
		if("space cop")
			to_chat(owner, "<span class='boldannounce'>Justice has arrived. I am a member of the Spacepol!</span>")
			to_chat(owner, "<B>The criminals should be on the station, we have special huds implanted to recognize them.</B>")
			to_chat(owner, "<B>As we have lost pretty much all power over these damned lawless megacorporations, it's a mystery if their security will cooperate with us.</B>")
		if("russian")
			to_chat(src, "<span class='danger'>Ay blyat. I am a space-russian smuggler! We were mid-flight when our cargo was beamed off our ship!</span>")
			to_chat(src, "<span class='danger'>We were hailed by a man in a green uniform, promising the safe return of our goods in exchange for a favor:</span>")
			to_chat(src, "<span class='danger'>There is a local station housing fugitives that the man is after, he wants them returned; dead or alive.</span>")
			to_chat(src, "<span class='danger'>We will not be able to make ends meet without our cargo, so we must do as he says and capture them.</span>")

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

/datum/team/fugitive_hunters
	var/backstory = "error"

/datum/team/fugitive_hunters/proc/update_objectives(initial = FALSE)
	objectives = list()
	var/datum/objective/O = new()
	O.team = src
	objectives += O

/datum/team/fugitive_hunters/proc/get_all_fugitives()
	. = list()
	for(var/mob/crew in GLOB.mob_list)
		if(crew.mind)
			if(crew.mind.has_antag_datum(/datum/antagonist/fugitive))
				. += crew

/datum/team/fugitive_hunters/proc/fugitives_dead(list/fugitives_counted)
	. = 0
	for(var/mob/living/L in fugitives_counted)
		if(!istype(L))
			.++
		if(L.stat != DEAD)
			.++

/datum/team/fugitive_hunters/proc/fugitives_captured(list/fugitives_counted)
	. = 0
	for(var/mob/living/L in fugitives_counted)
		var/datum/antagonist/fugitive/fug = L.mind.has_antag_datum(/datum/antagonist/fugitive)
		if(fug.is_captured == TRUE)
			.++

/datum/team/fugitive_hunters/proc/all_hunters_dead()
	var/dead_boys = 0
	for(var/I in members)
		var/datum/mind/hunter_mind = I
		if(!(ishuman(hunter_mind.current) || (hunter_mind.current.stat == DEAD)))
			dead_boys++
	return dead_boys >= members.len

/datum/team/fugitive_hunters/proc/get_result()
	var/list/fugitives_counted = get_all_fugitives()
	var/fugitives_captured = fugitives_captured(fugitives_counted)
	var/fugitives_dead = fugitives_dead(fugitives_counted)
	var/hunters_dead = all_hunters_dead()
	if(fugitives_captured)
		if(fugitives_captured == fugitives_counted)
			if(!fugitives_dead)
				return FUGITIVE_RESULT_BADASS_HUNTER
			else if(hunters_dead)
				return FUGITIVE_RESULT_POSTMORTEM_HUNTER
			else
				return FUGITIVE_RESULT_MAJOR_HUNTER
		else if(!hunters_dead)
			return FUGITIVE_RESULT_HUNTER_VICTORY
		else
			return FUGITIVE_RESULT_MINOR_HUNTER
	else
		if(!fugitives_dead)
			return FUGITIVE_RESULT_MAJOR_FUGITIVE
		else if(fugitives_dead < fugitives_counted)
			return FUGITIVE_RESULT_FUGITIVE_VICTORY
		else if(!hunters_dead)
			return FUGITIVE_RESULT_MINOR_FUGITIVE
		else
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
			result += "<span class='greentext big'>Badass [uppertext(backstory)] Victory!</span>"
			result += "<B>These extraordinary [backstory] managed to capture every fugitive, alive!</B>"
		if(FUGITIVE_RESULT_POSTMORTEM_HUNTER)
			result += "<span class='greentext big'>Postmortem [uppertext(backstory)] Victory!</span>"
			result += "<B>The [backstory]s managed to capture every fugitive, but all of them died! Spooky!</B>"
		if(FUGITIVE_RESULT_MAJOR_HUNTER)
			result += "<span class='greentext big'>Major [uppertext(backstory)] Victory</span>"
			result += "<B>The [backstory] managed to capture every fugitive, dead or alive.</B>"
		if(FUGITIVE_RESULT_HUNTER_VICTORY)
			result += "<span class='greentext big'>[uppertext(backstory)] Victory</span>"
			result += "<B>The [backstory] managed to capture a fugitive, dead or alive.</B>"
		if(FUGITIVE_RESULT_MINOR_HUNTER)
			result += "<span class='greentext big'>Minor [uppertext(backstory)] Victory</span>"
			result += "<B>All the [backstory] died, but managed to capture a fugitive, dead or alive.</B>"
		if(FUGITIVE_RESULT_STALEMATE)
			result += "<span class='neutraltext big'>Bloody Stalemate</span>"
			result += "<B>Everyone died, and no fugitives were recovered!</B>"
		if(FUGITIVE_RESULT_MINOR_FUGITIVE)
			result += "<span class='redtext big'>Minor Fugitive Victory</span>"
			result += "<B>All the fugitives died, but none were recovered!</B>"
		if(FUGITIVE_RESULT_FUGITIVE_VICTORY)
			result += "<span class='redtext big'>Fugitive Victory</span>"
			result += "<B>A fugitive survived, and no bodies were recovered by the [backstory].</B>"
		if(FUGITIVE_RESULT_MAJOR_FUGITIVE)
			result += "<span class='redtext big'>Major Fugitive Victory</span>"
			result += "<B>All of the fugitives survived and avoided capture!</B>"
		else //get_result returned null when it shouldn't
			result += "<span class='neutraltext big'>Bugged Victory</span>"
			result += "<B>Well, shit. Someone, anyone report this to github so I can see it. No duplicate reports!</B>"

	return result.Join("<br>")

/datum/antagonist/fugitive_hunter/proc/update_fugitive_icons_added(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.join_hud(fugitive)
	//fughud.add_hud_to(fugitive) //can detect who the fugitives are, and see other hunters. fugitives don't get this
	set_antag_hud(fugitive, "fugitive")

/datum/antagonist/fugitive_hunter/proc/update_fugitive_icons_removed(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.leave_hud(fugitive)
	//fughud.remove_hud_from(fugitive)
	set_antag_hud(fugitive, null)
