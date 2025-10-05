
/**
 * Checks if we have stun immunity. Godmode always passes this check.
 *
 * * check_flags - bitflag of status flags that must be set in order for the stun to succeed. Passing NONE will always return false.
 * * force_stun - whether we ignore stun immunity with the exception of godmode
 *
 * returns TRUE if stun immune, FALSE otherwise
 */
/mob/living/proc/check_stun_immunity(check_flags = CANSTUN, force_stun = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return TRUE

	if(force_stun) // Does not take priority over god mode? I guess
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_LIVING_GENERIC_STUN_CHECK, check_flags, force_stun) & COMPONENT_NO_STUN)
		return TRUE

	if(HAS_TRAIT(src, TRAIT_STUNIMMUNE))
		return TRUE

	// Do we have the correct flag set to allow this status?
	// This checks that ALL flags are set, not just one of them.
	if((status_flags & check_flags) == check_flags)
		return FALSE

	return TRUE

/* STUN */
/mob/living/proc/IsStun() //If we're stunned
	return has_status_effect(/datum/status_effect/incapacitating/stun)

/mob/living/proc/AmountStun() //How many deciseconds remain in our stun
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	if(S)
		return S.duration - world.time
	return 0

/mob/living/proc/Stun(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	if(S)
		S.duration = max(world.time + amount, S.duration)
	else if(amount > 0)
		S = apply_status_effect(/datum/status_effect/incapacitating/stun, amount)
	return S

/mob/living/proc/SetStun(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	if(amount <= 0)
		if(S)
			qdel(S)
	else
		if(S)
			S.duration = world.time + amount
		else
			S = apply_status_effect(/datum/status_effect/incapacitating/stun, amount)
	return S

/mob/living/proc/AdjustStun(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	if(S)
		S.duration += amount
	else if(amount > 0)
		S = apply_status_effect(/datum/status_effect/incapacitating/stun, amount)
	return S

/* KNOCKDOWN */
/mob/living/proc/IsKnockdown() //If we're knocked down
	return has_status_effect(/datum/status_effect/incapacitating/knockdown)

/mob/living/proc/AmountKnockdown() //How many deciseconds remain in our knockdown
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(K)
		return K.duration - world.time
	return 0

/mob/living/proc/Knockdown(amount, daze_amount = 0, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANKNOCKDOWN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(K)
		K.duration = max(world.time + amount, K.duration)
	else if(amount > 0)
		K = apply_status_effect(/datum/status_effect/incapacitating/knockdown, amount)
	if(daze_amount > 0)
		apply_status_effect(/datum/status_effect/dazed, daze_amount)
	return K

/mob/living/proc/SetKnockdown(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANKNOCKDOWN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(amount <= 0)
		if(K)
			qdel(K)
	else
		if(K)
			K.duration = world.time + amount
		else
			K = apply_status_effect(/datum/status_effect/incapacitating/knockdown, amount)
	return K

/mob/living/proc/AdjustKnockdown(amount, daze_amount = 0, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANKNOCKDOWN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(K)
		K.duration += amount
	else if(amount > 0)
		K = apply_status_effect(/datum/status_effect/incapacitating/knockdown, amount)
	if(daze_amount > 0)
		apply_status_effect(/datum/status_effect/dazed, daze_amount)
	return K

/* IMMOBILIZED */
/mob/living/proc/IsImmobilized() //If we're immobilized
	return has_status_effect(/datum/status_effect/incapacitating/immobilized)

/mob/living/proc/AmountImmobilized() //How many deciseconds remain in our Immobilized status effect
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(I)
		return I.duration - world.time
	return 0

/mob/living/proc/Immobilize(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_IMMOBILIZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(I)
		I.duration = max(world.time + amount, I.duration)
	else if(amount > 0)
		I = apply_status_effect(/datum/status_effect/incapacitating/immobilized, amount)
	return I

/mob/living/proc/SetImmobilized(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_IMMOBILIZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(amount <= 0)
		if(I)
			qdel(I)
	else
		if(I)
			I.duration = world.time + amount
		else
			I = apply_status_effect(/datum/status_effect/incapacitating/immobilized, amount)
	return I

/mob/living/proc/AdjustImmobilized(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_IMMOBILIZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(I)
		I.duration += amount
	else if(amount > 0)
		I = apply_status_effect(/datum/status_effect/incapacitating/immobilized, amount)
	return I

/* PARALYZED */
/mob/living/proc/IsParalyzed() //If we're paralyzed
	return has_status_effect(/datum/status_effect/incapacitating/paralyzed)

/mob/living/proc/AmountParalyzed() //How many deciseconds remain in our Paralyzed status effect
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
	if(P)
		return P.duration - world.time
	return 0

/mob/living/proc/Paralyze(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN|CANKNOCKDOWN, ignore_canstun)) // this requires both can stun and can knockdown
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
	if(P)
		P.duration = max(world.time + amount, P.duration)
	else if(amount > 0)
		P = apply_status_effect(/datum/status_effect/incapacitating/paralyzed, amount)
	return P

/mob/living/proc/SetParalyzed(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN|CANKNOCKDOWN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
	if(amount <= 0)
		if(P)
			qdel(P)
	else
		if(P)
			P.duration = world.time + amount
		else
			P = apply_status_effect(/datum/status_effect/incapacitating/paralyzed, amount)
	return P

/mob/living/proc/AdjustParalyzed(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN|CANKNOCKDOWN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
	if(P)
		P.duration += amount
	else if(amount > 0)
		P = apply_status_effect(/datum/status_effect/incapacitating/paralyzed, amount)
	return P

/* INCAPACITATED */


/// Proc that returns the remaining duration of the status efect in deciseconds.
/mob/living/proc/amount_incapacitated()
	var/datum/status_effect/incapacitating/incapacitated/incapacitated_status_effect = has_status_effect(/datum/status_effect/incapacitating/incapacitated)
	if (incapacitated_status_effect)
		return incapacitated_status_effect.duration - world.time
	else
		return 0

/** Proc that actually applies the status effect.
 * Applies the Incapacitated status effect to a mob/living.
 * * amount - Amount of time the status effect should be applied for, in deciseconds.
 * * ignore_canstun - If TRUE, the mob's resistance to stuns is ignored.
 */
/mob/living/proc/incapacitate(amount, ignore_canstun = FALSE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_INCAPACITATE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/incapacitated/incapacitated_status_effect = has_status_effect(/datum/status_effect/incapacitating/incapacitated)
	if(incapacitated_status_effect)
		incapacitated_status_effect.duration = max(world.time + amount, incapacitated_status_effect.duration)
	else if(amount > 0)
		incapacitated_status_effect = apply_status_effect(/datum/status_effect/incapacitating/incapacitated, amount)
	return incapacitated_status_effect

/** Proc that set the incapacitated status effect's remaining duration to a certain time.
 * Checks if the mob has the status effect. If yes, it sets the duration to the amount passed in arguments. If not, applies the status effect
 * and sets the duration to the amount passed in arguments.
 * * amount - Amount of time the status effect should be set to, in deciseconds.
 * * ignore_canstun - If TRUE, the mob's resistance to stuns is ignored.
 */
/mob/living/proc/set_incapacitated(amount, ignore_canstun = FALSE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_INCAPACITATE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/incapacitated/incapacitated_status_effect = has_status_effect(/datum/status_effect/incapacitating/incapacitated)
	if(amount <= 0)
		if(incapacitated_status_effect)
			qdel(incapacitated_status_effect)
	else
		if(incapacitated_status_effect)
			incapacitated_status_effect.duration = world.time + amount
		else
			incapacitated_status_effect = apply_status_effect(/datum/status_effect/incapacitating/incapacitated, amount)
	return incapacitated_status_effect

/** Proc that adds duration to an incapacitated status effect.
 * Checks if the mob has the status effect. If yes, it adds the amount passed in arguments to the remaining duration. If not, applies the status effect
 * and sets the duration to the amount passed in arguments.
 * * amount - Amount of time the status effect should be set to, in deciseconds.
 * * ignore_canstun - If TRUE, the mob's resistance to stuns is ignored.
 */
/mob/living/proc/adjust_incapacitated(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_INCAPACITATE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANSTUN, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/incapacitated/incapacitated_status_effect = has_status_effect(/datum/status_effect/incapacitating/incapacitated)
	if(incapacitated_status_effect)
		incapacitated_status_effect.duration += amount
	else if(amount > 0)
		incapacitated_status_effect = apply_status_effect(/datum/status_effect/incapacitating/incapacitated, amount)
	return incapacitated_status_effect

//Blanket
/mob/living/proc/AllImmobility(amount)
	Paralyze(amount)
	Knockdown(amount)
	Stun(amount)
	Immobilize(amount)
	Unconscious(amount)


/mob/living/proc/SetAllImmobility(amount)
	SetParalyzed(amount)
	SetKnockdown(amount)
	SetStun(amount)
	SetImmobilized(amount)
	SetUnconscious(amount)


/mob/living/proc/AdjustAllImmobility(amount)
	AdjustParalyzed(amount)
	AdjustKnockdown(amount)
	AdjustStun(amount)
	AdjustImmobilized(amount)
	AdjustUnconscious(amount)


/* UNCONSCIOUS */
/mob/living/proc/IsUnconscious() //If we're unconscious
	return has_status_effect(/datum/status_effect/incapacitating/unconscious)

/mob/living/proc/AmountUnconscious() //How many deciseconds remain in our unconsciousness
	var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
	if(U)
		return U.duration - world.time
	return 0

/mob/living/proc/Unconscious(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANUNCONSCIOUS, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
	if(U)
		U.duration = max(world.time + amount, U.duration)
	else if(amount > 0)
		U = apply_status_effect(/datum/status_effect/incapacitating/unconscious, amount)
	return U

/mob/living/proc/SetUnconscious(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANUNCONSCIOUS, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
	if(amount <= 0)
		if(U)
			qdel(U)
	else if(U)
		U.duration = world.time + amount
	else
		U = apply_status_effect(/datum/status_effect/incapacitating/unconscious, amount)
	return U

/mob/living/proc/AdjustUnconscious(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(check_stun_immunity(CANUNCONSCIOUS, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/unconscious/U = IsUnconscious()
	if(U)
		U.duration += amount
	else if(amount > 0)
		U = apply_status_effect(/datum/status_effect/incapacitating/unconscious, amount)
	return U

/* SLEEPING */
/mob/living/proc/IsSleeping() //If we're asleep
	if(!HAS_TRAIT(src, TRAIT_SLEEPIMMUNE))
		return has_status_effect(/datum/status_effect/incapacitating/sleeping)

/mob/living/proc/AmountSleeping() //How many deciseconds remain in our sleep
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		return S.duration - world.time
	return 0

/mob/living/proc/Sleeping(amount) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount) & COMPONENT_NO_STUN)
		return
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration = max(world.time + amount, S.duration)
	else if(amount > 0)
		S = apply_status_effect(/datum/status_effect/incapacitating/sleeping, amount)
	return S

/mob/living/proc/SetSleeping(amount) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount) & COMPONENT_NO_STUN)
		return
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(amount <= 0)
		if(S)
			qdel(S)
	else if(S)
		S.duration = world.time + amount
	else
		S = apply_status_effect(/datum/status_effect/incapacitating/sleeping, amount)
	return S

/mob/living/proc/AdjustSleeping(amount) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount) & COMPONENT_NO_STUN)
		return
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration += amount
	else if(amount > 0)
		S = apply_status_effect(/datum/status_effect/incapacitating/sleeping, amount)
	return S

///////////////////////// CLEAR STATUS /////////////////////////

/mob/living/proc/adjust_status_effects_on_shake_up()
	AdjustStun(-6 SECONDS)
	AdjustKnockdown(-6 SECONDS)
	AdjustUnconscious(-6 SECONDS)
	AdjustSleeping(-10 SECONDS)
	AdjustParalyzed(-6 SECONDS)
	AdjustImmobilized(-6 SECONDS)

///////////////////////////////// FROZEN /////////////////////////////////////

/* FROZEN */
/mob/living/proc/IsFrozen()
	return has_status_effect(/datum/status_effect/freon)

/**
 * Adds the passed quirk to the mob
 *
 * Arguments
 * * quirktype - Quirk typepath to add to the mob
 * If not passed, defaults to this mob's client.
 *
 * Returns TRUE on success, FALSE on failure (already has the quirk, etc)
 */
/mob/living/proc/add_quirk(datum/quirk/quirktype, client/override_client, add_unique = TRUE, announce = TRUE)
	if(has_quirk(quirktype))
		return FALSE
	var/qname = initial(quirktype.name)
	if(!SSquirks || !SSquirks.quirks[qname])
		return FALSE
	var/datum/quirk/quirk = new quirktype()
	if(quirk.add_to_holder(new_holder = src, client_source = override_client, unique = add_unique, announce = announce))
		return TRUE
	qdel(quirk)
	return FALSE

/mob/living/proc/remove_quirk(quirktype)
	for(var/datum/quirk/quirk in quirks)
		if(quirk.type == quirktype)
			qdel(quirk)
			return TRUE
	return FALSE

/mob/living/proc/has_quirk(quirktype)
	for(var/datum/quirk/quirk in quirks)
		if(quirk.type == quirktype)
			return TRUE
	return FALSE

/**
 * Getter function for a mob's quirk
 *
 * Arguments:
 * * quirktype - the type of the quirk to acquire e.g. /datum/quirk/some_quirk
 *
 * Returns the mob's quirk datum if the mob this is called on has the quirk, null on failure
 */
/mob/living/proc/get_quirk(quirktype)
	for(var/datum/quirk/quirk in quirks)
		if(quirk.type == quirktype)
			return quirk
	return null

/// Helper to easily add a personality by a typepath
/mob/living/proc/add_personality(personality_type)
	var/datum/personality/personality = SSpersonalities.personalities_by_type[personality_type]
	personality.apply_to_mob(src)

/// Helper to easily add multiple personalities by a list of typepaths
/mob/living/proc/add_personalities(list/new_personalities)
	for(var/personality_type in new_personalities)
		add_personality(personality_type)

/// Helper to easily remove a personality by a typepath
/mob/living/proc/remove_personality(personality_type)
	var/datum/personality/personality = SSpersonalities.personalities_by_type[personality_type]
	personality.remove_from_mob(src)

/// Helper to clear all personalities from a mob
/mob/living/proc/clear_personalities()
	for(var/personality_type in personalities)
		remove_personality(personality_type)

/mob/living/proc/cure_husk(source)
	REMOVE_TRAIT(src, TRAIT_HUSK, source)
	if(HAS_TRAIT(src, TRAIT_HUSK))
		return FALSE
	REMOVE_TRAIT(src, TRAIT_DISFIGURED, "husk")
	update_body()
	UnregisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_UNHUSKABLE))
	return TRUE

/mob/living/proc/become_husk(source)
	if(HAS_TRAIT(src, TRAIT_UNHUSKABLE))
		return
	var/was_husk = HAS_TRAIT(src, TRAIT_HUSK)
	ADD_TRAIT(src, TRAIT_HUSK, source)
	if (was_husk)
		return
	ADD_TRAIT(src, TRAIT_DISFIGURED, "husk")
	update_body()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_UNHUSKABLE), PROC_REF(became_unhuskable))

/// Called when we become unhuskable while already husked
/mob/living/proc/became_unhuskable()
	SIGNAL_HANDLER
	cure_husk()

/mob/living/proc/cure_fakedeath(source)
	remove_traits(list(TRAIT_FAKEDEATH, TRAIT_DEATHCOMA), source)
	if(stat != DEAD)
		station_timestamp_timeofdeath = null

/// Induces fake death on a living mob.
/mob/living/proc/fakedeath(source, silent = FALSE)
	if(stat != DEAD)
		if(!silent)
			emote("deathgasp")
		station_timestamp_timeofdeath = station_time_timestamp()

	if(!HAS_TRAIT(src, TRAIT_FAKEDEATH) && !silent)
		send_death_moodlets(/datum/mood_event/see_death)
	add_traits(list(TRAIT_FAKEDEATH, TRAIT_DEATHCOMA), source)

///Unignores all slowdowns that lack the IGNORE_NOSLOW flag.
/mob/living/proc/unignore_slowdown(source)
	REMOVE_TRAIT(src, TRAIT_IGNORESLOWDOWN, source)
	update_movespeed()

///Ignores all slowdowns that lack the IGNORE_NOSLOW flag.
/mob/living/proc/ignore_slowdown(source)
	ADD_TRAIT(src, TRAIT_IGNORESLOWDOWN, source)
	update_movespeed()

///Ignores specific slowdowns. Accepts a list of slowdowns.
/mob/living/proc/add_movespeed_mod_immunities(source, slowdown_type, update = TRUE)
	if(islist(slowdown_type))
		for(var/listed_type in slowdown_type)
			if(ispath(listed_type))
				listed_type = "[listed_type]" //Path2String
			LAZYADDASSOCLIST(movespeed_mod_immunities, listed_type, source)
	else
		if(ispath(slowdown_type))
			slowdown_type = "[slowdown_type]" //Path2String
		LAZYADDASSOCLIST(movespeed_mod_immunities, slowdown_type, source)
	if(update)
		update_movespeed()

///Unignores specific slowdowns. Accepts a list of slowdowns.
/mob/living/proc/remove_movespeed_mod_immunities(source, slowdown_type, update = TRUE)
	if(islist(slowdown_type))
		for(var/listed_type in slowdown_type)
			if(ispath(listed_type))
				listed_type = "[listed_type]" //Path2String
			LAZYREMOVEASSOC(movespeed_mod_immunities, listed_type, source)
	else
		if(ispath(slowdown_type))
			slowdown_type = "[slowdown_type]" //Path2String
		LAZYREMOVEASSOC(movespeed_mod_immunities, slowdown_type, source)
	if(update)
		update_movespeed()

/**
 * Adjusts a timed status effect on the mob,taking into account any existing timed status effects.
 * This can be any status effect that takes into account "duration" with their initialize arguments.
 *
 * Positive durations will add deciseconds to the duration of existing status effects
 * or apply a new status effect of that duration to the mob.
 *
 * Negative durations will remove deciseconds from the duration of an existing version of the status effect,
 * removing the status effect entirely if the duration becomes less than zero (less than the current world time).
 *
 * duration - the duration, in deciseconds, to add or remove from the effect
 * effect - the type of status effect being adjusted on the mob
 * max_duration - optional - if set, positive durations will only be added UP TO the passed max duration
 */
/mob/living/proc/adjust_timed_status_effect(duration, effect, max_duration)
	if(!isnum(duration))
		CRASH("adjust_timed_status_effect: called with an invalid duration. (Got: [duration])")

	if(!ispath(effect, /datum/status_effect))
		CRASH("adjust_timed_status_effect: called with an invalid effect type. (Got: [effect])")

	// If we have a max duration set, we need to check our duration does not exceed it
	if(isnum(max_duration))
		if(max_duration <= 0)
			CRASH("adjust_timed_status_effect: Called with an invalid max_duration. (Got: [max_duration])")

		if(duration >= max_duration)
			duration = max_duration

	var/datum/status_effect/existing = has_status_effect(effect)
	if(existing)
		if(isnum(max_duration) && duration > 0)
			// Check the duration remaining on the existing status effect
			// If it's greater than / equal to our passed max duration, we don't need to do anything
			var/remaining_duration = existing.duration - world.time
			if(remaining_duration >= max_duration)
				return

			// Otherwise, add duration up to the max (max_duration - remaining_duration),
			// or just add duration if it doesn't exceed our max at all
			existing.duration += min(max_duration - remaining_duration, duration)

		else
			existing.duration += duration

		// If the duration was decreased and is now less 0 seconds,
		// qdel it / clean up the status effect immediately
		// (rather than waiting for the process tick to handle it)
		if(existing.duration <= world.time)
			qdel(existing)

	else if(duration > 0)
		apply_status_effect(effect, duration)

/**
 * Sets a timed status effect of some kind on a mob to a specific value.
 * If only_if_higher is TRUE, it will only set the value up to the passed duration,
 * so any pre-existing status effects of the same type won't be reduced down
 *
 * duration - the duration, in deciseconds, of the effect. 0 or lower will either remove the current effect or do nothing if none are present
 * effect - the type of status effect given to the mob
 * only_if_higher - if TRUE, we will only set the effect to the new duration if the new duration is longer than any existing duration
 */
/mob/living/proc/set_timed_status_effect(duration, effect, only_if_higher = FALSE)
	if(!isnum(duration))
		CRASH("set_timed_status_effect: called with an invalid duration. (Got: [duration])")

	if(!ispath(effect, /datum/status_effect))
		CRASH("set_timed_status_effect: called with an invalid effect type. (Got: [effect])")

	var/datum/status_effect/existing = has_status_effect(effect)
	if(existing)
		// set_timed_status_effect to 0 technically acts as a way to clear effects,
		// though remove_status_effect would achieve the same goal more explicitly.
		if(duration <= 0)
			qdel(existing)
			return

		if(only_if_higher)
			// If the existing status effect has a higher remaining duration
			// than what we aim to set it to, don't downgrade it - do nothing (return)
			var/remaining_duration = existing.duration - world.time
			if(remaining_duration >= duration)
				return

		// Set the duration accordingly
		existing.duration = world.time + duration

	else if(duration > 0)
		apply_status_effect(effect, duration)

/**
 * Gets how many deciseconds are remaining in
 * the duration of the passed status effect on this mob.
 *
 * If the mob is unaffected by the passed effect, returns 0.
 */
/mob/living/proc/get_timed_status_effect_duration(effect)
	if(!ispath(effect, /datum/status_effect))
		CRASH("get_timed_status_effect_duration: called with an invalid effect type. (Got: [effect])")

	var/datum/status_effect/existing = has_status_effect(effect)
	if(!existing)
		return 0
	// Infinite duration status effects technically are not "timed status effects"
	// by name or nature, but support is included just in case.
	if(existing.duration == STATUS_EFFECT_PERMANENT)
		return INFINITY

	return existing.duration - world.time

/**
 * Adjust the "drunk value" the mob is currently experiencing,
 * or applies a drunk effect if the mob isn't currently drunk (or tipsy)
 *
 * The drunk effect doesn't have a set duration, like dizziness or drugginess,
 * but instead relies on a value that decreases every status effect tick (2 seconds) by:
 * 4% the current drunk_value + 0.01
 *
 * A "drunk value" of 6 is the border between "tipsy" and "drunk".
 *
 * amount - the amount of "drunkness" to apply to the mob.
 * down_to - the lower end of the clamp, when adding the value
 * up_to - the upper end of the clamp, when adding the value
 */
/mob/living/proc/adjust_drunk_effect(amount, down_to = 0, up_to = INFINITY)
	if(!isnum(amount))
		CRASH("adjust_drunk_effect: called with an invalid amount. (Got: [amount])")

	var/datum/status_effect/inebriated/inebriation = has_status_effect(/datum/status_effect/inebriated)
	if(inebriation)
		inebriation.set_drunk_value(clamp(inebriation.drunk_value + amount, down_to, up_to))
	else if(amount > 0)
		apply_status_effect(/datum/status_effect/inebriated/tipsy, amount)


/**
 * Directly sets the "drunk value" the mob is currently experiencing to the passed value,
 * or applies a drunk effect with the passed value if the mob isn't currently drunk
 *
 * set_to - the amount of "drunkness" to set on the mob.
 */
/mob/living/proc/set_drunk_effect(set_to)
	if(!isnum(set_to) || set_to < 0)
		CRASH("set_drunk_effect: called with an invalid value. (Got: [set_to])")

	var/datum/status_effect/inebriated/inebriation = has_status_effect(/datum/status_effect/inebriated)
	if(inebriation)
		inebriation.set_drunk_value(set_to)
	else if(set_to > 0)
		apply_status_effect(/datum/status_effect/inebriated/tipsy, set_to)

/// Helper to get the amount of drunkness the mob's currently experiencing.
/mob/living/proc/get_drunk_amount()
	var/datum/status_effect/inebriated/inebriation = has_status_effect(/datum/status_effect/inebriated)
	return inebriation?.drunk_value || 0

/// Helper to check if we seem to be alive or not
/mob/living/proc/appears_alive()
	return stat != DEAD && !HAS_TRAIT(src, TRAIT_FAKEDEATH)
