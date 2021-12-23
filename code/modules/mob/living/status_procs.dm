//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting, jitteriness, dizziness,
// eye damage, eye_blind, eye_blurry, druggy, TRAIT_BLIND trait, and TRAIT_NEARSIGHT trait.

#define IS_STUN_IMMUNE(source, ignore_canstun) ((source.status_flags & GODMODE) || (!ignore_canstun && (!(source.status_flags & CANKNOCKDOWN) || HAS_TRAIT(source, TRAIT_STUNIMMUNE))))

/* STUN */
/mob/living/proc/IsStun() //If we're stunned
	return has_status_effect(STATUS_EFFECT_STUN)

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
		S = apply_status_effect(STATUS_EFFECT_STUN, amount)
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
			S = apply_status_effect(STATUS_EFFECT_STUN, amount)
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
		S = apply_status_effect(STATUS_EFFECT_STUN, amount)
	return S

/* KNOCKDOWN */
/mob/living/proc/IsKnockdown() //If we're knocked down
	return has_status_effect(STATUS_EFFECT_KNOCKDOWN)

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
		K = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)
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
			K = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)
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
		K = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)
	return K

/* IMMOBILIZED */
/mob/living/proc/IsImmobilized() //If we're immobilized
	return has_status_effect(STATUS_EFFECT_IMMOBILIZED)

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
		I = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)
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
			I = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)
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
		I = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)
	return I

/* PARALYZED */
/mob/living/proc/IsParalyzed() //If we're paralyzed
	return has_status_effect(STATUS_EFFECT_PARALYZED)

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
		P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)
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
			P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)
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
		P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)
	return P

/* INCAPACITATED */


/// Proc that returns the remaining duration of the status efect in deciseconds.
/mob/living/proc/amount_incapacitated()
	var/datum/status_effect/incapacitating/incapacitated/incapacitated_status_effect = has_status_effect(STATUS_EFFECT_INCAPACITATED)
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
	var/datum/status_effect/incapacitating/incapacitated/incapacitated_status_effect = has_status_effect(STATUS_EFFECT_INCAPACITATED)
	if(incapacitated_status_effect)
		incapacitated_status_effect.duration = max(world.time + amount, incapacitated_status_effect.duration)
	else if(amount > 0)
		incapacitated_status_effect = apply_status_effect(STATUS_EFFECT_INCAPACITATED, amount)
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
	var/datum/status_effect/incapacitating/incapacitated/incapacitated_status_effect = has_status_effect(STATUS_EFFECT_INCAPACITATED)
	if(amount <= 0)
		if(incapacitated_status_effect)
			qdel(incapacitated_status_effect)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(incapacitated_status_effect)
			incapacitated_status_effect.duration = world.time + amount
		else
			incapacitated_status_effect = apply_status_effect(STATUS_EFFECT_INCAPACITATED, amount)
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
	var/datum/status_effect/incapacitating/incapacitated/incapacitated_status_effect = has_status_effect(STATUS_EFFECT_INCAPACITATED)
	if(incapacitated_status_effect)
		incapacitated_status_effect.duration += amount
	else if(amount > 0)
		incapacitated_status_effect = apply_status_effect(STATUS_EFFECT_INCAPACITATED, amount)
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
	return has_status_effect(STATUS_EFFECT_UNCONSCIOUS)

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
		U = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount)
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
		U = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount)
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
		U = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount)
	return U

/* SLEEPING */
/mob/living/proc/IsSleeping() //If we're asleep
	if(!HAS_TRAIT(src, TRAIT_SLEEPIMMUNE))
		return has_status_effect(STATUS_EFFECT_SLEEPING)

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
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)
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
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)
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
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)
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
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, -1)
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

/mob/living/proc/add_quirk(quirktype) //separate proc due to the way these ones are handled
	if(HAS_TRAIT(src, quirktype))
		return
	var/datum/quirk/quirk = quirktype
	var/qname = initial(quirk.name)
	if(!SSquirks || !SSquirks.quirks[qname])
		return
	quirk = new quirktype()
	if(quirk.add_to_holder(src))
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

/* TRAIT PROCS */
/mob/living/proc/cure_blind(source)
	if(source)
		REMOVE_TRAIT(src, TRAIT_BLIND, source)
	else
		REMOVE_TRAIT_NOT_FROM(src, TRAIT_BLIND, list(QUIRK_TRAIT, EYES_COVERED, BLINDFOLD_TRAIT))
	if(!HAS_TRAIT(src, TRAIT_BLIND))
		update_blindness()

/mob/living/proc/become_blind(source)
	if(!HAS_TRAIT(src, TRAIT_BLIND)) // not blind already, add trait then overlay
		ADD_TRAIT(src, TRAIT_BLIND, source)
		update_blindness()
	else
		ADD_TRAIT(src, TRAIT_BLIND, source)

/mob/living/proc/cure_nearsighted(source)
	REMOVE_TRAIT(src, TRAIT_NEARSIGHT, source)
	if(!HAS_TRAIT(src, TRAIT_NEARSIGHT))
		clear_fullscreen("nearsighted")

/mob/living/proc/become_nearsighted(source)
	if(!HAS_TRAIT(src, TRAIT_NEARSIGHT))
		overlay_fullscreen("nearsighted", /atom/movable/screen/fullscreen/impaired, 1)
	ADD_TRAIT(src, TRAIT_NEARSIGHT, source)

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
/mob/living/proc/fakedeath(source, comatose = FALSE, silent = FALSE)
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

/// Gets the amount of confusion on the mob.
/mob/living/proc/get_confusion()
	var/datum/status_effect/confusion/confusion = has_status_effect(STATUS_EFFECT_CONFUSION)
	return confusion ? confusion.strength : 0

/// Set the confusion of the mob. Confusion will make the mob walk randomly.
/mob/living/proc/set_confusion(new_confusion)
	new_confusion = max(new_confusion, 0)

	if (new_confusion)
		var/datum/status_effect/confusion/confusion_status = has_status_effect(STATUS_EFFECT_CONFUSION) || apply_status_effect(STATUS_EFFECT_CONFUSION)
		confusion_status.set_strength(new_confusion)
	else
		remove_status_effect(STATUS_EFFECT_CONFUSION)

/// Add confusion to the mob. Confusion will make the mob walk randomly.
/// Shorthand for set_confusion(confusion + x).
/mob/living/proc/add_confusion(confusion_to_add)
	set_confusion(get_confusion() + confusion_to_add)

/**
 * Sets the [SHOCKED_1] flag on this mob.
 */
/mob/living/proc/set_shocked()
	flags_1 |= SHOCKED_1

/**
 * Unsets the [SHOCKED_1] flag on this mob.
 */
/mob/living/proc/reset_shocked()
	flags_1 &= ~ SHOCKED_1
