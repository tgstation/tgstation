/datum/religion_rites/slumber_party
	name = "Slumber Party"
	desc = "Put all nearby creatures to sleep. All affected creatures share the same dream and heal rapidly while sleeping."
	favor_cost = 200
	rite_flags = RITE_AUTO_DELETE

/datum/religion_rites/slumber_party/post_invoke_effects(mob/living/user, atom/religious_tool)
	. = ..()
	var/datum/dream/random/base_dream = new()
	for(var/mob/living/carbon/nearby_guy in view(5, get_turf(religious_tool)))
		nearby_guy.apply_status_effect(/datum/status_effect/slumber_party, base_dream.GenerateDream(user))
	qdel(base_dream)

/datum/status_effect/slumber_party
	id = "slumber_party"
	duration = 20 SECONDS
	alert_type = null
	/// Dream fragments we share between all sleepers
	var/list/shared_dream
	/// How much we heal per second while sleepin - holy people heal more
	var/healing = 2

/datum/status_effect/slumber_party/on_creation(mob/living/new_owner, list/shared_dream)
	src.shared_dream = shared_dream
	return ..()

/datum/status_effect/slumber_party/on_apply()
	if(IS_CULTIST(owner))
		var/datum/antagonist/cult/cultist = GET_CULTIST(owner)
		if(cultist.cult_team.cult_ascendent)
			return FALSE

	if(IS_HERETIC(owner))
		var/datum/antagonist/heretic/heretic = GET_HERETIC(owner)
		if(heretic.ascended)
			return FALSE

	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return FALSE

	if(!owner.SetSleeping(duration))
		return FALSE

	if(owner.mind?.holy_role)
		healing *= 2

	RegisterSignal(user, COMSIG_PRE_DREAMING, PROC_REF(add_shared_dream))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_applied))
	if(iscarbon(owner))
		addtimer(CALLBACK(src, PROC_REF(force_dream)), rand(2, 4) SECONDS, TIMER_DELETE_ME)
	return TRUE

/datum/status_effect/slumber_party/on_remove()
	UnregisterSignal(owner, COMSIG_PRE_DREAMING)
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
	REMOVE_TRAIT(owner, TRAIT_DREAMING, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/slumber_party/tick(seconds_between_ticks)
	if(!owner.IsSleeping())
		qdel(src)
		return

	owner.heal_overall_damage(healing * seconds_between_ticks, healing * seconds_between_ticks, required_bodytype = BODYTYPE_ORGANIC)
	owner.adjust_tox_loss(healing * seconds_between_ticks * 0.5)
	owner.adjust_oxy_loss(healing * seconds_between_ticks * 0.25)

/datum/status_effect/slumber_party/proc/force_dream()
	var/mob/living/carbon/dreamer = owner
	if(HAS_TRAIT(dreamer, TRAIT_DREAMING))
		return

	dreamer.dream()
	ADD_TRAIT(dreamer, TRAIT_DREAMING, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/slumber_party/proc/add_shared_dream(datum/source, list/dream_pool)
	SIGNAL_HANDLER

	dream_pool[new /datum/dream/shared(shared_dream)] = 2000

/datum/status_effect/slumber_party/proc/damage_applied(mob/living/source, damage_amount, ...)
	SIGNAL_HANDLER
	owner.AdjustSleeping(-damage_amount * 0.5 SECONDS)

/datum/dream/shared
	sleep_until_finished = TRUE
	/// Dream shared between everyone
	var/list/generated_dream

/datum/dream/shared/New(list/shared_dream)
	. = ..()
	generated_dream = LAZYLISTDUPLICATE(shared_dream)

/datum/dream/shared/GenerateDream(mob/living/carbon/dreamer)
	if(!LAZYLEN(generated_dream))
		CRASH("Shared dream has no generated dream fragments!")
	return generated_dream
