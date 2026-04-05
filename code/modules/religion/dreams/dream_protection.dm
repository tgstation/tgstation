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
	tick_interval = 1 SECONDS
	alert_type = null
	/// Damage reduction when sleeping/dreaming, multiplicative
	var/damage_mod = 0.75
	/// If the filter has been applied
	VAR_PRIVATE/has_filter = FALSE

/datum/status_effect/dream_protection/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(modify_damage))
	ADD_TRAIT(owner, TRAIT_HOLY, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/dream_protection/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	REMOVE_TRAIT(owner, TRAIT_HOLY, TRAIT_STATUS_EFFECT(id))
	owner.remove_filter(owner, id)

/datum/status_effect/dream_protection/tick(seconds_between_ticks)
	. = ..()
	if(owner.IsSleeping())
		if(!has_filter)
			owner.add_filter(id, 3, outline_filter(color = "#bde0dc"))
			var/filter = owner.get_filter(id)
			animate(filter, size = 2, 2 SECONDS, easing = SINE_EASING|EASE_IN, loop = -1)
			animate(size = 0, 2 SECONDS, easing = SINE_EASING|EASE_OUT, loop = -1)
			has_filter = TRUE

	else
		if(has_filter)
			owner.transition_filter(id, outline_filter(size = 0), 1 SECONDS, easing = SINE_EASING|EASE_OUT)
			has_filter = FALSE

/datum/status_effect/dream_protection/proc/modify_damage(mob/living/source, list/damage_mods, ...)
	SIGNAL_HANDLER
	if(owner.IsSleeping())
		damage_mods += damage_mod
	if(HAS_TRAIT(owner, TRAIT_DREAMING))
		damage_mods += damage_mod

/datum/status_effect/dream_protection/get_examine_text()
	if(owner.IsSleeping() || HAS_TRAIT(owner, TRAIT_DREAMING))
		return "A soft cyan glow envelops [owner.p_them()], reflecting light."

/datum/status_effect/dream_protection/temporary
	id = "temporary_dream_protection"
	damage_mod = 0.9

/datum/status_effect/dream_protection/temporary/tick()
	. = ..()
	if(!owner.IsSleeping())
		qdel(src)
