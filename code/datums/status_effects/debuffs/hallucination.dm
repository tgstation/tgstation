/// Hallucination status effect. How most hallucinations end up happening.
/// Hallucinations are drawn from the global weighted list, random_hallucination_weighted_list
/datum/status_effect/hallucination
	id = "hallucination"
	alert_type = null
	tick_interval = 2 SECONDS
	remove_on_fullheal = TRUE
	/// Biotypes which cannot hallucinate.
	var/barred_biotypes = NO_HALLUCINATION_BIOTYPES
	/// The lower range of when the next hallucination will trigger after one occurs.
	var/lower_tick_interval = 10 SECONDS
	/// The upper range of when the next hallucination will trigger after one occurs.
	var/upper_tick_interval = 60 SECONDS
	/// The cooldown for when the next hallucination can occur
	COOLDOWN_DECLARE(hallucination_cooldown)

/datum/status_effect/hallucination/on_creation(mob/living/new_owner, duration, lower_tick_interval, upper_tick_interval)
	if(isnum(duration))
		src.duration = duration
	if(isnum(lower_tick_interval))
		src.lower_tick_interval = lower_tick_interval
	if(isnum(upper_tick_interval))
		src.upper_tick_interval = upper_tick_interval
	return ..()

/datum/status_effect/hallucination/on_apply()
	if(owner.mob_biotypes & barred_biotypes)
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_HALLUCINATION_IMMUNE))
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_HEALTHSCAN,  PROC_REF(on_health_scan))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_HALLUCINATION_IMMUNE), PROC_REF(delete_self))
	if(iscarbon(owner))
		RegisterSignal(owner, COMSIG_CARBON_CHECKING_BODYPART, PROC_REF(on_check_bodypart))
		RegisterSignal(owner, COMSIG_CARBON_BUMPED_AIRLOCK_OPEN, PROC_REF(on_bump_airlock))

	return TRUE

/datum/status_effect/hallucination/proc/delete_self()
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/hallucination/on_remove()
	UnregisterSignal(owner, list(
		COMSIG_LIVING_HEALTHSCAN,
		COMSIG_CARBON_CHECKING_BODYPART,
		COMSIG_CARBON_BUMPED_AIRLOCK_OPEN,
		SIGNAL_ADDTRAIT(TRAIT_HALLUCINATION_IMMUNE),
	))

/// Signal proc for [COMSIG_LIVING_HEALTHSCAN]. Show we're hallucinating to (advanced) scanners.
/datum/status_effect/hallucination/proc/on_health_scan(datum/source, list/render_list, advanced, mob/user, mode, tochat)
	SIGNAL_HANDLER

	if(!advanced)
		return
	render_list += conditional_tooltip("<span class='info ml-1'>Subject is hallucinating.</span>", "Supply antipsychotic medication, such as [/datum/reagent/medicine/haloperidol::name] or [/datum/reagent/medicine/synaptizine::name].", tochat)
	render_list += "<br>"

/// Signal proc for [COMSIG_CARBON_CHECKING_BODYPART],
/// checking bodyparts while hallucinating can cause them to appear more damaged than they are
/datum/status_effect/hallucination/proc/on_check_bodypart(mob/living/carbon/source, obj/item/bodypart/examined, list/check_list, list/limb_damage)
	SIGNAL_HANDLER

	if(prob(30))
		limb_damage[BRUTE] += rand(30, 40)
	if(prob(30))
		limb_damage[BURN] += rand(30, 40)

/// Signal proc for [COMSIG_CARBON_BUMPED_AIRLOCK_OPEN], bumping an airlock can cause a fake zap.
/// This only happens on airlock bump, future TODO - make this chance roll for attack_hand opening airlocks too
/datum/status_effect/hallucination/proc/on_bump_airlock(mob/living/carbon/source, obj/machinery/door/airlock/bumped)
	SIGNAL_HANDLER

	// 1% chance to fake a shock.
	if(prob(99) || !source.should_electrocute() || bumped.operating)
		return

	source.cause_hallucination(/datum/hallucination/shock, "hallucinated shock from [bumped]",)
	return STOP_BUMP

/datum/status_effect/hallucination/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		return
	if(!COOLDOWN_FINISHED(src, hallucination_cooldown))
		return

	var/datum/hallucination/picked_hallucination = pick_weight(GLOB.random_hallucination_weighted_list)
	owner.cause_hallucination(picked_hallucination, "[id] status effect")
	COOLDOWN_START(src, hallucination_cooldown, rand(lower_tick_interval, upper_tick_interval))

// Sanity related hallucinations
/datum/status_effect/hallucination/sanity
	id = "low sanity"
	status_type = STATUS_EFFECT_REFRESH
	duration = STATUS_EFFECT_PERMANENT // This lasts "forever", only goes away with sanity gain

/datum/status_effect/hallucination/sanity/on_health_scan(datum/source, list/render_list, advanced, mob/user, mode, tochat)
	return

/datum/status_effect/hallucination/sanity/on_apply()
	if(!owner.mob_mood)
		return FALSE

	update_intervals()
	return ..()

/datum/status_effect/hallucination/sanity/refresh(...)
	update_intervals()

/datum/status_effect/hallucination/sanity/tick(seconds_between_ticks)
	// Using psicodine / happiness / whatever to become fearless will stop sanity based hallucinations
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return

	return ..()

/// Updates our upper and lower intervals based on our owner's current sanity level.
/datum/status_effect/hallucination/sanity/proc/update_intervals()
	switch(owner.mob_mood.sanity_level)
		if(SANITY_LEVEL_CRAZY)
			upper_tick_interval = 8 MINUTES
			lower_tick_interval = 4 MINUTES

		if(SANITY_LEVEL_INSANE)
			upper_tick_interval = 4 MINUTES
			lower_tick_interval = 2 MINUTES

		else
			stack_trace("[type] was assigned a mob which was not crazy or insane. (was: [owner.mob_mood.sanity_level])")
			qdel(src)
