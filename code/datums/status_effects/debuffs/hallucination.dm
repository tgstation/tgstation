/// Global weighted list of all hallucinations that can show up randomly.
GLOBAL_LIST_INIT(random_hallucination_weighted_list, generate_hallucination_weighted_list())

/// Generates the global weighted list of random hallucinations.
/proc/generate_hallucination_weighted_list()
	var/list/weighted_list = list()

	for(var/datum/hallucination/hallucination_type as anything in typesof(/datum/hallucination))
		if(hallucination_type == initial(hallucination_type.abstract_hallucination_parent))
			continue
		var/weight = initial(hallucination_type.random_hallucination_weight)
		if(weight <= 0)
			continue

		weighted_list[hallucination_type] = weight

	return weighted_list

/// Debug proc for getting the total weight of the random_hallucination_weighted_list
/proc/debug_hallucination_weighted_list()
	var/total_weight = 0
	for(var/datum/hallucination/hallucination_type as anything in GLOB.random_hallucination_weighted_list)
		total_weight += GLOB.random_hallucination_weighted_list[hallucination_type]

	message_admins("Total weight: [total_weight]")
	return total_weight

/// Debug proc for getting the weight of each distinct type within the random_hallucination_weighted_list
/proc/debug_hallucination_weighted_list_per_type()
	var/total_weight = debug_hallucination_weighted_list()

	var/last_type
	var/last_type_weight = 0
	for(var/datum/hallucination/hallucination_type as anything in GLOB.random_hallucination_weighted_list)
		var/this_weight = GLOB.random_hallucination_weighted_list[hallucination_type]
		if(last_type)
			if(ispath(hallucination_type, last_type))
				last_type_weight += this_weight
				continue

			else
				message_admins("[last_type]: [last_type_weight] / [total_weight] ([round(100 * (last_type_weight / total_weight), 0.01)]% chance)")

		last_type = initial(hallucination_type.abstract_hallucination_parent)
		if(last_type == /datum/hallucination)
			message_admins("[hallucination_type]: [this_weight] / [total_weight] ([100 * (this_weight / total_weight)])")
			last_type = null

		else
			last_type_weight = this_weight

/// Gets a random subtype of the passed hallucination type that has a random_hallucination_weight > 0.
/proc/get_random_valid_hallucination_subtype(passed_type)
	if(!ispath(passed_type, /datum/hallucination))
		CRASH("get_random_valid_hallucination_subtype - get_random_valid_hallucination_subtype passed not a hallucination subtype.")

	for(var/datum/hallucination/hallucination_type as anything in shuffle(subtypesof(passed_type)))
		if(initial(hallucination_type.random_hallucination_weight) <= 0)
			continue

		return hallucination_type

	return null

/datum/status_effect/hallucination
	id = "hallucination"
	alert_type = null
	tick_interval = 2 SECONDS
	/// The lower range of when the next hallucination will trigger after one occurs.
	var/lower_tick_interval = 10 SECONDS
	/// The upper range of when the next hallucination will trigger after one occurs.
	var/upper_tick_interval = 60 SECONDS
	/// The cooldown for when the next hallucination can occur
	COOLDOWN_DECLARE(hallucination_cooldown)

/datum/status_effect/hallucination/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/hallucination/on_apply()
	if(issilicon(owner))
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, .proc/remove_hallucinations)
	if(iscarbon(owner))
		RegisterSignal(owner, COMSIG_CARBON_CHECKING_BODYPART, .proc/on_check_bodypart)
	return TRUE

/datum/status_effect/hallucination/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_CARBON_CHECKING_BODYPART))

/datum/status_effect/hallucination/proc/remove_hallucinations(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/hallucination/proc/on_check_bodypart(mob/living/carbon/source, obj/item/bodypart/examined, list/check_list, list/limb_damage)
	SIGNAL_HANDLER

	if(prob(30))
		limb_damage[BRUTE] += rand(30, 40)
	if(prob(30))
		limb_damage[BURN] += rand(30, 40)

/datum/status_effect/hallucination/tick(delta_time, times_fired)
	if(owner.stat == DEAD)
		return
	if(!COOLDOWN_FINISHED(src, hallucination_cooldown))
		return

	var/datum/hallucination/picked_hallucination = pick_weight(GLOB.random_hallucination_weighted_list)
	owner.cause_hallucination(picked_hallucination, "[id] status effect")

	COOLDOWN_START(src, hallucination_cooldown, rand(lower_tick_interval, upper_tick_interval))
