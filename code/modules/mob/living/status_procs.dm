//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting

#define IS_STUN_IMMUNE(source, ignore_canstun) ((source.status_flags & GODMODE) || (!ignore_canstun && (!(source.status_flags & CANKNOCKDOWN) || HAS_TRAIT(source, TRAIT_STUNIMMUNE))))

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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	if(amount <= 0)
		if(S)
			qdel(S)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(S)
			S.duration = world.time + amount
		else
			S = apply_status_effect(/datum/status_effect/incapacitating/stun, amount)
	return S

/mob/living/proc/AdjustStun(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
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

/mob/living/proc/Knockdown(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(K)
		K.duration = max(world.time + amount, K.duration)
	else if(amount > 0)
		K = apply_status_effect(/datum/status_effect/incapacitating/knockdown, amount)
	return K

/mob/living/proc/SetKnockdown(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(amount <= 0)
		if(K)
			qdel(K)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(K)
			K.duration = world.time + amount
		else
			K = apply_status_effect(/datum/status_effect/incapacitating/knockdown, amount)
	return K

/mob/living/proc/AdjustKnockdown(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
	if(K)
		K.duration += amount
	else if(amount > 0)
		K = apply_status_effect(/datum/status_effect/incapacitating/knockdown, amount)
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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(amount <= 0)
		if(I)
			qdel(I)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(I)
			I.duration = world.time + amount
		else
			I = apply_status_effect(/datum/status_effect/incapacitating/immobilized, amount)
	return I

/mob/living/proc/AdjustImmobilized(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_IMMOBILIZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
	if(amount <= 0)
		if(P)
			qdel(P)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(P)
			P.duration = world.time + amount
		else
			P = apply_status_effect(/datum/status_effect/incapacitating/paralyzed, amount)
	return P

/mob/living/proc/AdjustParalyzed(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/incapacitated/incapacitated_status_effect = has_status_effect(/datum/status_effect/incapacitating/incapacitated)
	if(amount <= 0)
		if(incapacitated_status_effect)
			qdel(incapacitated_status_effect)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
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


/mob/living/proc/SetAllImmobility(amount)
	SetParalyzed(amount)
	SetKnockdown(amount)
	SetStun(amount)
	SetImmobilized(amount)


/mob/living/proc/AdjustAllImmobility(amount)
	AdjustParalyzed(amount)
	AdjustKnockdown(amount)
	AdjustStun(amount)
	AdjustImmobilized(amount)


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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
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
	if(IS_STUN_IMMUNE(src, ignore_canstun))
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
	if(status_flags & GODMODE)
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
	if(status_flags & GODMODE)
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
	if(status_flags & GODMODE)
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration += amount
	else if(amount > 0)
		S = apply_status_effect(/datum/status_effect/incapacitating/sleeping, amount)
	return S

///Allows us to set a permanent sleep on a player (use with caution and remember to unset it with SetSleeping() after the effect is over)
/mob/living/proc/PermaSleeping()
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, -1) & COMPONENT_NO_STUN)
		return
	if(status_flags & GODMODE)
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration = -1
	else
		S = apply_status_effect(/datum/status_effect/incapacitating/sleeping, -1)
	return S

///////////////////////// CLEAR STATUS /////////////////////////

/mob/living/proc/adjust_status_effects_on_shake_up()
	AdjustStun(-60)
	AdjustKnockdown(-60)
	AdjustUnconscious(-60)
	AdjustSleeping(-100)
	AdjustParalyzed(-60)
	AdjustImmobilized(-60)

///////////////////////////////// FROZEN /////////////////////////////////////

/* FROZEN */
/mob/living/proc/IsFrozen()
	return has_status_effect(/datum/status_effect/freon)


/* STUN ABSORPTION*/
/mob/living/proc/add_stun_absorption(key, duration, priority, message, self_message, examine_message)
//adds a stun absorption with a key, a duration in deciseconds, its priority, and the messages it makes when you're stun/examined, if any
	if(!islist(stun_absorption))
		stun_absorption = list()
	if(stun_absorption[key])
		stun_absorption[key]["end_time"] = world.time + duration
		stun_absorption[key]["priority"] = priority
		stun_absorption[key]["stuns_absorbed"] = 0
	else
		stun_absorption[key] = list("end_time" = world.time + duration, "priority" = priority, "stuns_absorbed" = 0, \
		"visible_message" = message, "self_message" = self_message, "examine_message" = examine_message)

/mob/living/proc/absorb_stun(amount, ignoring_flag_presence)
	if(amount < 0 || stat || ignoring_flag_presence || !islist(stun_absorption))
		return FALSE
	if(!amount)
		amount = 0
	var/priority_absorb_key
	var/highest_priority
	for(var/i in stun_absorption)
		if(stun_absorption[i]["end_time"] > world.time && (!priority_absorb_key || stun_absorption[i]["priority"] > highest_priority))
			priority_absorb_key = stun_absorption[i]
			highest_priority = priority_absorb_key["priority"]
	if(priority_absorb_key)
		if(amount) //don't spam up the chat for continuous stuns
			if(priority_absorb_key["visible_message"] || priority_absorb_key["self_message"])
				if(priority_absorb_key["visible_message"] && priority_absorb_key["self_message"])
					visible_message(span_warning("[src][priority_absorb_key["visible_message"]]"), span_boldwarning("[priority_absorb_key["self_message"]]"))
				else if(priority_absorb_key["visible_message"])
					visible_message(span_warning("[src][priority_absorb_key["visible_message"]]"))
				else if(priority_absorb_key["self_message"])
					to_chat(src, span_boldwarning("[priority_absorb_key["self_message"]]"))
			priority_absorb_key["stuns_absorbed"] += amount
		return TRUE

/**
 * Adds the passed quirk to the mob
 *
 * Arguments
 * * quirktype - Quirk typepath to add to the mob
 * * override_client - optional, allows a client to be passed to the quirks on add procs.
 * If not passed, defaults to this mob's client.
 *
 * Returns TRUE on success, FALSE on failure (already has the quirk, etc)
 */
/mob/living/proc/add_quirk(datum/quirk/quirktype, client/override_client)
	if(has_quirk(quirktype))
		return FALSE
	var/qname = initial(quirktype.name)
	if(!SSquirks || !SSquirks.quirks[qname])
		return FALSE
	var/datum/quirk/quirk = new quirktype()
	if(quirk.add_to_holder(new_holder = src, client_source = override_client))
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

/mob/living/proc/cure_husk(source)
	REMOVE_TRAIT(src, TRAIT_HUSK, source)
	if(!HAS_TRAIT(src, TRAIT_HUSK))
		REMOVE_TRAIT(src, TRAIT_DISFIGURED, "husk")
		update_body()
		return TRUE

/mob/living/proc/become_husk(source)
	if(!HAS_TRAIT(src, TRAIT_HUSK))
		ADD_TRAIT(src, TRAIT_HUSK, source)
		ADD_TRAIT(src, TRAIT_DISFIGURED, "husk")
		update_body()
	else
		ADD_TRAIT(src, TRAIT_HUSK, source)

/mob/living/proc/cure_fakedeath(source)
	REMOVE_TRAIT(src, TRAIT_FAKEDEATH, source)
	REMOVE_TRAIT(src, TRAIT_DEATHCOMA, source)
	if(stat != DEAD)
		tod = null

/// Induces fake death on a living mob.
/mob/living/proc/fakedeath(source, silent = FALSE)
	if(stat == DEAD)
		return
	if(!silent)
		emote("deathgasp")
	ADD_TRAIT(src, TRAIT_FAKEDEATH, source)
	ADD_TRAIT(src, TRAIT_DEATHCOMA, source)
	tod = station_time_timestamp()


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
	if(existing.duration == -1)
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
	return health >= 0 && !HAS_TRAIT(src, TRAIT_FAKEDEATH)
