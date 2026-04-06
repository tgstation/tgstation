/datum/religion_rites/dream_protection
	name = "Dream Protection"
	desc = "Bless you and all of your followers with protection in their slumber, \
		granting resistance to damage while asleep, which is further increased while dreaming."
	favor_cost = 200
	rite_flags = RITE_ONE_TIME_USE | RITE_AUTO_DELETE
	ritual_length = 15 SECONDS

/datum/religion_rites/dream_protection/New()
	. = ..()
	ritual_invocations = list(
		"Protect our flock from harm, great shepard [GLOB.deity]!..",
		"Grant us peaceful slumber, free from nightmares and those who would do us harm!..",
		"Our sleepers shall be safe to dream to their heart's desire!..",
	)

/datum/religion_rites/dream_protection/post_invoke_effects(mob/living/user, atom/religious_tool)
	. = ..()
	if(!istype(GLOB.religious_sect, /datum/religion_sect/dreams))
		return

	var/datum/religion_sect/dreams/sect = GLOB.religious_sect
	sect.dream_protection = TRUE

	for(var/mob/living/follower as anything in GLOB.mob_living_list)
		if(follower.mind?.holy_role)
			follower.apply_status_effect(/datum/status_effect/dream_protection)

/datum/status_effect/dream_protection
	id = "dream_protection"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	/// Damage reduction when sleeping/dreaming, multiplicative
	var/damage_mod = 0.75
	/// If the filter has been applied
	VAR_PRIVATE/has_filter = FALSE

/datum/status_effect/dream_protection/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(modify_damage))
	RegisterSignals(owner, list(
		COMSIG_MOB_STATCHANGE,
		SIGNAL_ADDTRAIT(TRAIT_DREAMING),
		SIGNAL_REMOVETRAIT(TRAIT_DREAMING),
	), PROC_REF(check_protection))
	check_protection()

/datum/status_effect/dream_protection/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	REMOVE_TRAIT(owner, TRAIT_HOLY, TRAIT_STATUS_EFFECT(id))

	if(!QDELING(owner))
		var/filter = owner.get_filter(id)
		animate(filter, size = 0, time = 1 SECONDS, easing = SINE_EASING|EASE_OUT)
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/datum, remove_filter), id), 1 SECONDS) // delay the filter removal to let the transition finish

/datum/status_effect/dream_protection/proc/check_protection()
	SIGNAL_HANDLER

	if(owner.stat == UNCONSCIOUS || HAS_TRAIT(owner, TRAIT_DREAMING))
		if(!has_filter)
			owner.add_filter(id, 2, outline_filter(size = 0, color = "#bde0dc96")) // melbert todo doesn't work
			var/filter = owner.get_filter(id)
			animate(filter, size = 2, time = 2 SECONDS, easing = SINE_EASING|EASE_IN, loop = -1)
			animate(size = 0, time = 2 SECONDS, easing = SINE_EASING|EASE_OUT)
			has_filter = TRUE
		ADD_TRAIT(owner, TRAIT_HOLY, TRAIT_STATUS_EFFECT(id))

	else
		if(has_filter)
			var/filter = owner.get_filter(id)
			animate(filter, size = 0, time = 1 SECONDS, easing = SINE_EASING|EASE_OUT)
			has_filter = FALSE
		REMOVE_TRAIT(owner, TRAIT_HOLY, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/dream_protection/proc/modify_damage(mob/living/source, list/damage_mods, ...)
	SIGNAL_HANDLER
	if(owner.stat == UNCONSCIOUS)
		damage_mods += damage_mod
	if(HAS_TRAIT(owner, TRAIT_DREAMING))
		damage_mods += damage_mod

/datum/status_effect/dream_protection/get_examine_text()
	if(owner.stat == UNCONSCIOUS || HAS_TRAIT(owner, TRAIT_DREAMING))
		return "A soft cyan glow envelops [owner.p_them()], reflecting light."

// Version that only lasts until they wake up (with a set duration backup)
/datum/status_effect/dream_protection/temporary
	id = "temporary_dream_protection"
	duration = 3 MINUTES // lasts until they wake up or if they're an especially long sleeper
	damage_mod = 0.9

/datum/status_effect/dream_protection/temporary/on_apply()
	if(owner.stat != UNCONSCIOUS)
		return FALSE
	if(owner.has_status_effect(/datum/status_effect/dream_protection))
		return FALSE

	return ..()

/datum/status_effect/dream_protection/temporary/check_protection()
	. = ..()
	if(!has_filter) // soon as it goes, we go
		qdel(src)

// Version that works on dead mobs and lasts until they revive (with a set duration backup)
/datum/status_effect/dream_protection/deceased
	id = "deceased_dream_protection"
	duration = 3 MINUTES // lasts until they wake up or if they're an especially long sleeper

/datum/status_effect/dream_protection/deceased/on_apply()
	if(owner.stat != DEAD)
		return FALSE
	if(owner.has_status_effect(/datum/status_effect/dream_protection))
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_REVIVE, PROC_REF(mob_revived))
	ADD_TRAIT(owner, TRAIT_DREAMING, TRAIT_STATUS_EFFECT(id)) // "permanent" dreaming
	return ..()

/datum/status_effect/dream_protection/deceased/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_REVIVE)
	REMOVE_TRAIT(owner, TRAIT_DREAMING, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/dream_protection/deceased/proc/mob_revived()
	SIGNAL_HANDLER
	qdel(src)
