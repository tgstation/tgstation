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
	var/list/minor_objectives = GLOB.minor_infiltrator_objectives.Copy()
	var/major = rand(MIN_MAJOR_OBJECTIVES, MAX_MAJOR_OBJECTIVES)
	var/minor = rand(MIN_MINOR_OBJECTIVES, MAX_MINOR_OBJECTIVES)
	for(var/i in 1 to major)
		add_objective(pick_n_take(major_objectives))
	for(var/i in 1 to minor)
		add_objective(pick(minor_objectives))
	for(var/datum/mind/M in members)
		M.objectives |= objectives