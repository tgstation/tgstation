/// Hallucination status effect. How most hallucinations end up happening.
/// Hallucinations are drawn from the global weighted list, random_hallucination_weighted_list
/datum/status_effect/hallucination
	id = "hallucination"
	alert_type = null
	tick_interval = 2 SECONDS
	/// Can this hallucination apply to silicons?
	var/affects_silicons = FALSE
	/// The lower range of when the next hallucination will trigger after one occurs.
	var/lower_tick_interval = 10 SECONDS
	/// The upper range of when the next hallucination will trigger after one occurs.
	var/upper_tick_interval = 60 SECONDS
	/// The cooldown for when the next hallucination can occur
	COOLDOWN_DECLARE(hallucination_cooldown)

/datum/status_effect/hallucination/on_creation(
	mob/living/new_owner,
	duration = 10 SECONDS,
	affects_silicons = FALSE,
)

	src.duration = duration
	src.affects_silicons = affects_silicons
	return ..()

/datum/status_effect/hallucination/on_apply()
	if(affects_silicons && issilicon(owner))
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, .proc/remove_hallucinations)
	if(iscarbon(owner))
		RegisterSignal(owner, COMSIG_CARBON_CHECKING_BODYPART, .proc/on_check_bodypart)
	return TRUE

/datum/status_effect/hallucination/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_CARBON_CHECKING_BODYPART))

/// Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL], terminate on full heal
/datum/status_effect/hallucination/proc/remove_hallucinations(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/// Signal proc for [COMSIG_CARBON_CHECKING_BODYPART], checking bodyparts while hallucinating can cause them to appear more damaged than they are
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
