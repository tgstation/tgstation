/datum/antagonist/disease
	name = "Sentient Disease"
	roundend_category = "diseases"
	antagpanel_category = "Biohazards"
	show_to_ghosts = TRUE
	ui_name = "AntagInfoDisease"
	var/disease_name = ""

/datum/antagonist/disease/on_gain()
	owner.set_assigned_role(SSjob.GetJobType(/datum/job/sentient_disease))
	owner.special_role = ROLE_SENTIENT_DISEASE
	var/datum/objective/O = new /datum/objective/disease_infect()
	O.owner = owner
	objectives += O

	O = new /datum/objective/disease_infect_centcom()
	O.owner = owner
	objectives += O

	. = ..()

/datum/antagonist/disease/ui_static_data(mob/user)
	var/list/data = list()
	//will sometimes be null but will always have an owner if this data is being requested
	var/mob/camera/disease/disease_mob = owner.current
	//will sometimes be null like above, in that case we shouldn't send related data for that
	var/datum/disease/advance/sentient_disease/disease_template = disease_mob?.disease_template
	data["objectives"] = get_objectives()
	//total disease stats
	data["resist"] = disease_template ? disease_template.totalResistance() : "YOU'RE TOAST!"
	data["stealth"] = disease_template ? disease_template.totalStealth() : "YOU'RE TOAST!"
	data["speed"] = disease_template ? disease_template.totalStageSpeed() : "YOU'RE TOAST!"
	data["transmit"] = disease_template ? disease_template.totalTransmittable() : "YOU'RE TOAST!"
	data["cure"] = disease_template ? disease_template.cure_text : "YOU'VE BEEN CURED."
	var/list/abilities_data = list()
	for(var/datum/disease_ability/ability as anything in GLOB.disease_ability_singletons)
		var/list/single_ability_data = list(
			"purchased" = disease_mob.purchased_abilities[ability] ? TRUE : FALSE,
			"cost" = ability.cost,
			"total_requirement" = ability.required_total_points,
			"name" = ability.name,
			"category" = ability.category,
			"desc" = ability.desc,
			//stat block for this ability
			"resist"= ability.resistance,
			"stealth"= ability.stealth,
			"speed"= ability.stage_speed,
			"transmit"= ability.transmittable,
		)
		abilities_data += list(single_ability_data)
	data["abilities"] = abilities_data
	return data

/datum/antagonist/disease/ui_data(mob/user)
	var/list/data = list()
	//will sometimes be null but will always have an owner if this data is being requested
	var/mob/camera/disease/disease_mob = owner.current
	//point costs live update as you do things in the world
	data["points"] = disease_mob ? disease_mob.total_points : 0
	data["total_points"] = disease_mob ? disease_mob.total_points : 0

	return data

/datum/antagonist/disease/greet()
	to_chat(owner.current, span_notice("You are the [owner.special_role]!"))
	to_chat(owner.current, span_notice("Infect members of the crew to gain adaptation points, and spread your infection further."))
	owner.announce_objectives()

/datum/antagonist/disease/apply_innate_effects(mob/living/mob_override)
	if(!istype(owner.current, /mob/camera/disease))
		var/turf/T = get_turf(owner.current)
		T = T ? T : SSmapping.get_station_center()
		var/mob/camera/disease/D = new /mob/camera/disease(T)
		owner.transfer_to(D)

/datum/antagonist/disease/admin_add(datum/mind/new_owner,mob/admin)
	..()
	var/mob/camera/disease/D = new_owner.current
	D.pick_name()

/datum/antagonist/disease/roundend_report()
	var/list/result = list()

	result += "<b>Disease name:</b> [disease_name]"
	result += printplayer(owner)

	var/win = TRUE
	var/objectives_text = ""
	var/count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] [span_greentext("Success!")]"
		else
			objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] [span_redtext("Fail.")]"
			win = FALSE
		count++

	result += objectives_text

	var/special_role_text = lowertext(name)

	if(win)
		result += span_greentext("The [special_role_text] was successful!")
	else
		result += span_redtext("The [special_role_text] has failed!")

	if(istype(owner.current, /mob/camera/disease))
		var/mob/camera/disease/D = owner.current
		result += "<B>[disease_name] completed the round with [D.hosts.len] infected hosts, and reached a maximum of [D.total_points] concurrent infections.</B>"
		result += "<B>[disease_name] completed the round with the following adaptations:</B>"
		var/list/adaptations = list()
		for(var/V in D.purchased_abilities)
			var/datum/disease_ability/A = V
			adaptations += A.name
		result += adaptations.Join(", ")

	return result.Join("<br>")


/datum/objective/disease_infect
	explanation_text = "Survive and infect as many people as possible."

/datum/objective/disease_infect/check_completion()
	var/mob/camera/disease/D = owner.current
	if(istype(D) && D.hosts.len) //theoretically it should not exist if it has no hosts, but better safe than sorry.
		return TRUE
	return FALSE


/datum/objective/disease_infect_centcom
	explanation_text = "Ensure that at least one infected host escapes on the shuttle or an escape pod."

/datum/objective/disease_infect_centcom/check_completion()
	var/mob/camera/disease/D = owner.current
	if(!istype(D))
		return FALSE
	for(var/V in D.hosts)
		var/mob/living/L = V
		if(L.onCentCom() || L.onSyndieBase())
			return TRUE
	return FALSE
