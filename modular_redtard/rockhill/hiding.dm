/// Ratwood's hiding spots (datums/components/hiding_spot.dm): in sneak mode one hides under a table, a bench or a bed, in a
/// bush, inside an old log or behind a bookcase by clicking it - 5 seconds, a second less a rank of Sneaking, at least one.
/// Clicking the spot again or moving leaves it; anyone who examines it up close finds the one hiding there.
/datum/component/rockhill_hiding_spot
	var/datum/weakref/hider
	/// How one hides at this spot: "under", "in", "inside" or "behind" it (Ratwood's messages of each spot).
	var/preposition

/datum/component/rockhill_hiding_spot/Initialize(preposition)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	src.preposition = preposition || default_preposition()

/datum/component/rockhill_hiding_spot/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_RELAYMOVE, PROC_REF(on_relaymove))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_deleting))

/datum/component/rockhill_hiding_spot/UnregisterFromParent()
	var/mob/living/current = hider?.resolve()
	if(current)
		release(current)
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_RELAYMOVE, COMSIG_ATOM_EXAMINE, COMSIG_ATOM_EXITED, COMSIG_QDELETING))

/// Ratwood's wording of each spot: one hides in a bush, inside an old log, behind a bookcase and under the furniture.
/datum/component/rockhill_hiding_spot/proc/default_preposition()
	if(istype(parent, /obj/structure/flora/roguegrass/bush))
		return "in"
	if(istype(parent, /obj/structure/flora/roguetree/stump/log))
		return "inside"
	if(istype(parent, /obj/structure/bookcase))
		return "behind"
	return "under"

/// How one comes out of the spot: "from under", "from inside", "from behind" - and plainly "from" a bush, as in Ratwood.
/datum/component/rockhill_hiding_spot/proc/exit_words()
	return preposition == "in" ? "from" : "from [preposition]"

/// Ratwood's time to hide: 5 seconds less a second a rank of Sneaking, at least a second.
/datum/component/rockhill_hiding_spot/proc/hide_time(mob/living/user)
	var/rank = user.rogue_skill_rank(/datum/attribute/skill/misc/sneaking)
	return max(rogue_value("hiding_time") - rank * rogue_value("hiding_time_per_rank"), rogue_value("hiding_time_min"))

/datum/component/rockhill_hiding_spot/proc/on_attack_hand(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(user))
		return
	if(user.loc == parent)
		release(user)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	var/mob/living/carbon/human/sneaker = user
	if(!istype(sneaker) || !sneaker.rogue_sneaking || user.combat_mode || user.pulling || user.buckled)
		return
	if(locate(/obj/structure/bars) in get_turf(parent))
		to_chat(user, span_warning("This hiding spot is blocked!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(hider?.resolve())
		to_chat(user, span_warning("Someone is already hiding [preposition] [parent]!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	INVOKE_ASYNC(src, PROC_REF(hide), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/rockhill_hiding_spot/proc/hide(mob/living/user)
	if(!do_after(user, hide_time(user), parent) || hider?.resolve() || user.pulling || user.buckled)
		return
	hider = WEAKREF(user)
	user.forceMove(parent)
	to_chat(user, span_warning("I hide [preposition] [parent]!"))

/datum/component/rockhill_hiding_spot/proc/release(mob/living/current)
	hider = null
	var/turf/exit_turf = get_turf(parent)
	if(!exit_turf || current.loc != parent)
		return
	current.forceMove(exit_turf)
	to_chat(current, span_warning("I come out [exit_words()] [parent]!"))

/datum/component/rockhill_hiding_spot/proc/on_relaymove(datum/source, mob/living/user, direction)
	SIGNAL_HANDLER
	if(user != hider?.resolve())
		return
	release(user)
	return COMSIG_BLOCK_RELAYMOVE

/datum/component/rockhill_hiding_spot/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!isliving(user) || user.loc == parent || get_dist(user, parent) > 1)
		return
	var/mob/living/current = hider?.resolve()
	if(!current)
		examine_list += span_notice("I could hide [preposition] it: switch to sneaking, then click it.")
		return
	release(current)
	examine_list += span_warning("Someone was hiding [preposition] it!")

/datum/component/rockhill_hiding_spot/proc/on_exited(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(gone == hider?.resolve())
		hider = null

/datum/component/rockhill_hiding_spot/proc/on_parent_deleting(datum/source)
	SIGNAL_HANDLER
	var/mob/living/current = hider?.resolve()
	if(current)
		release(current)
