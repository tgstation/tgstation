/datum/controller/subsystem/ticker/proc/generate_crew_objectives()
	for(var/datum/mind/crewMind in SSticker.minds)
		if(prob(5) && !issilicon(crewMind.current) && !jobban_isbanned(crewMind, "Syndicate") && GLOB.miscreants_allowed && ROLE_MISCREANT in crewMind.current.client.prefs.be_special)
			generate_miscreant_objectives(crewMind)
		else
			if(CONFIG_GET(flag/allow_crew_objectives))
				generate_individual_objectives(crewMind)
	return

/datum/controller/subsystem/ticker/proc/generate_individual_objectives(var/datum/mind/crewMind)
	if(!(CONFIG_GET(flag/allow_crew_objectives)))
		return
	if(!crewMind)
		return
	if(!crewMind.current || !crewMind.objectives || crewMind.special_role)
		return
	if(!crewMind.assigned_role)
		return
	var/list/validobjs = crewobjjobs["[ckey(crewMind.assigned_role)]"]
	if(!validobjs || !validobjs.len)
		return
	var/selectedObj = pick(validobjs)
	var/datum/objective/crew/newObjective = new selectedObj
	if(!newObjective)
		return
	newObjective.owner = crewMind
	crewMind.objectives += newObjective
	to_chat(crewMind, "<B>As a part of Nanotrasen's anti-tide efforts, you have been assigned an optional objective. It will be checked at the end of the shift. <font color=red>Performing traitorous acts in pursuit of your objective may result in termination of your employment.</font></B>")
	to_chat(crewMind, "<B>Your optional objective:</B> [newObjective.explanation_text]")

/datum/objective/crew/
	var/jobs = ""
	explanation_text = "Yell on the development discussion channel on Citadels discord if this ever shows up. Something just broke here, dude"

/datum/objective/crew/proc/setup()
