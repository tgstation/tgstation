#define MIN_MAJOR_OBJECTIVES 1
#define MAX_MAJOR_OBJECTIVES 2
#define MIN_MINOR_OBJECTIVES 3
#define MAX_MINOR_OBJECTIVES 4

/datum/team/infiltrator
	name = "Syndicate Infiltration Unit"
	member_name = "syndicate infiltrator"

/datum/team/infiltrator/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>Syndicate Infiltrators</span>"

	var/text = "<br><span class='header'>The syndicate infiltrators were:</span>"
	var/purchases = ""
	var/TC_uses = 0
	if(LAZYLEN(GLOB.uplink_purchase_logs_by_key))
		for(var/I in members)
			var/datum/mind/syndicate = I
			if(!istype(syndicate) || !GLOB.uplink_purchase_logs_by_key[syndicate.key])
				continue
			var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[syndicate.key]
			if(H)
				TC_uses += H.total_spent
				purchases += H.generate_render(show_key = FALSE)
	text += printplayerlist(members)
	text += "<br>"
	text += "(Syndicates used [TC_uses] TC) [purchases]"
	text += "<br><br>"
	parts += text

	var/objectives_text = ""
	var/count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
		else
			objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
		count++

	parts += objectives_text
	return parts.Join("<br>")

/datum/team/infiltrator/is_gamemode_hero()
	return SSticker.mode.name == "infiltration"

/datum/team/infiltrator/proc/add_objective(type)
	var/datum/objective/O = new type
	O.find_target()
	O.team = src
	objectives += O

/datum/team/infiltrator/proc/update_objectives()
	if(LAZYLEN(objectives))
		return
	var/list/major_objectives = subtypesof(/datum/objective/infiltrator)
	var/major = rand(MIN_MAJOR_OBJECTIVES, MAX_MAJOR_OBJECTIVES)
	var/minor = rand(MIN_MINOR_OBJECTIVES, MAX_MINOR_OBJECTIVES)
	for(var/i in 1 to major)
		add_objective(pick_n_take(major_objectives))
	for(var/i in 1 to minor)
		forge_single_objective()
	for(var/datum/mind/M in members)
		var/datum/antagonist/infiltrator/I = M.has_antag_datum(/datum/antagonist/infiltrator)
		if(I)
			I.objectives |= objectives
			M.announce_objectives()

/datum/team/infiltrator/proc/forge_single_objective() // Complete traitor copypasta!
	if(prob(50))
		if(prob(30))
			add_objective(/datum/objective/maroon)
		else
			add_objective(/datum/objective/assassinate)
	else
		if(prob(15) && !(locate(/datum/objective/download) in objectives))
			add_objective(/datum/objective/download)
		else
			add_objective(/datum/objective/steal)

/datum/team/infiltrator/proc/get_result()
	var/objectives_complete = 0
	var/objectives_failed = 0

	for(var/datum/objective/O in objectives)
		if(O.check_completion())
			objectives_complete++
		else
			objectives_failed++

	if(objectives_failed == 0 && objectives_complete > 0)
		return INFILTRATION_ALLCOMPLETE
	else if (objectives_complete > objectives_failed)
		return INFILTRATION_MOSTCOMPLETE
	else if((objectives_complete == objectives_failed) || (objectives_complete > 0 && objectives_failed > objectives_complete))
		return INFILTRATION_SOMECOMPLETE
	else
		return INFILTRATION_NONECOMPLETE
