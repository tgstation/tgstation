#define MIN_POWER_DRAIN 25000000
#define MAX_POWER_DRAIN 100000000

GLOBAL_LIST_INIT(minor_infiltrator_objectives, list(/datum/objective/assassinate, /datum/objective/steal, /datum/objective/download))
GLOBAL_LIST_INIT(infiltrator_kidnap_areas, typecacheof(list(/area/shuttle/stealthcruiser, /area/infiltrator_base)))

/datum/objective/infiltrator
	explanation_text = "Generic Infiltrator Objective!"
	martyr_compatible = FALSE
	var/item_type

/datum/objective/infiltrator/New()
	..()
	if(item_type)
		for(var/turf/T in GLOB.infiltrator_objective_items)
			if(!(item_type in T.contents))
				new item_type(T)

/datum/objective/infiltrator/exploit
	explanation_text = "Exploit the station's Nanotrasen AI and make it loyal to the Syndicate."
	item_type = /obj/item/ai_hijack_device

/datum/objective/infiltrator/exploit/find_target()
	var/list/possible_targets = active_ais(1)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/infiltrator/exploit/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Hijack [station_name()]'s AI unit, [target.name]."
	else
		explanation_text = "Free Objective"

/datum/objective/infiltrator/exploit/check_completion()
	if(isAI(target))
		var/mob/living/silicon/ai/A = target
		return A && A.mind && A.mind.has_antag_datum(/datum/antagonist/hijacked_ai)
	return FALSE


/datum/objective/infiltrator/power
	explanation_text = "Drain power from the station with a power sink."
	item_type = /obj/item/device/powersink/infiltrator

/datum/objective/infiltrator/power/New()
	target_amount = rand(MIN_POWER_DRAIN, MAX_POWER_DRAIN)
	update_explanation_text()

/datum/objective/infiltrator/power/update_explanation_text()
	..()
	if(target_amount)
		explanation_text = "Drain [DisplayPower(target_amount)] from [station_name()]'s powernet with a special transmitter powersink. You do not need to bring the powersink back once the objective is complete."
	else
		explanation_text = "Free Objective"

/datum/objective/infiltrator/power/check_completion()
	return GLOB.powersink_transmitted >= target_amount


/datum/objective/infiltrator/kidnap
	explanation_text = "Kidnap a member of security or command"

/datum/objective/infiltrator/kidnap/find_target()
	var/list/heads = SSjob.get_living_heads()
	if(heads && heads.len > 1 && prob(55)) //command
		target = pick(heads)
	else
		var/security_staff = list()
		for(var/datum/mind/M in SSticker.minds)
			if(!M || !considered_alive(M) || considered_afk(M) || !M.current || !M.current.client)
				continue
			if("Head of Security" in get_department_heads(M.assigned_role))
				security_staff += M
		target = pick(security_staff)
	update_explanation_text()
	return target

/datum/objective/infiltrator/kidnap/update_explanation_text()
	if(target && target.current)
		explanation_text = "Kidnap [target.name], the [target.assigned_role], and hold [target.current.p_them()] on the shuttle or base."
	else
		explanation_text = "Free Objective"

/datum/objective/infiltrator/kidnap/check_completion()
	return (considered_alive(target) && is_type_in_typecache(get_area(target), GLOB.infiltrator_kidnap_areas))