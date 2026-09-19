/// Gives PASSGRILLE so long as all of the bodyparts are slime (and some other conditions)
/datum/status_effect/grouped/bodypart_effect/slime_passgrille
	id = "slime_passgrille"
	tick_interval = STATUS_EFFECT_NO_TICK

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/on_apply()
	. = ..()
	RegisterSignals(owner, list(COMSIG_CARBON_POST_REMOVE_LIMB, COMSIG_CARBON_POST_ATTACH_LIMB), PROC_REF(check_active))

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/on_remove()
	. = ..()
	UnregisterSignal(owner, list(
		COMSIG_ATOM_BUMPED,
		COMSIG_CARBON_POST_ATTACH_LIMB,
		COMSIG_CARBON_POST_REMOVE_LIMB,
		COMSIG_MOB_EQUIPPED_ITEM,
		COMSIG_MOB_UNEQUIPPED_ITEM,
		COMSIG_MOVABLE_MOVED,
	))
	if(is_active)
		deactivate()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/walking_through_grille)

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/should_activate()
	for(var/obj/item/bodypart/other_part as anything in owner.get_bodyparts())
		if(other_part.pass_flags & PASSGRILLE)
			continue
		if(IS_ROBOTIC_LIMB(other_part) || !(other_part.biological_state & BIO_JELLY))
			return FALSE

	for(var/obj/item/organ/other_organ as anything in astype(owner, /mob/living/carbon).organs) // safe assertion
		if(other_organ.pass_flags & PASSGRILLE)
			continue
		if(IS_ROBOTIC_ORGAN(other_organ)) // no check for jelly organs (yet), as half of their organs are normal fleshy things.
			return FALSE

	return TRUE

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/activate()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_BUMP, PROC_REF(on_bumped))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/deactivate()
	. = ..()
	UnregisterSignal(owner, list(
		COMSIG_MOVABLE_BUMP,
		COMSIG_MOVABLE_MOVED,
	))
	if(QDELING(owner))
		return

	if(owner.pass_flags & PASSGRILLE)
		clear_passgrille()
	if(try_spit_out())
		to_chat(owner, span_warning("You get squeezed out of the crevice you were within!"))

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/proc/try_spit_out()
	var/turf/start_loc = get_turf(owner)
	if(!isturf(start_loc) || !start_loc.is_blocked_turf(source_atom = owner))
		return FALSE

	if(spit_out(owner.dir))
		return TRUE

	if(spit_out(REVERSE_DIR(owner.dir)))
		return TRUE

	return FALSE

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/proc/on_bumped(datum/source, atom/bumped)
	SIGNAL_HANDLER

	if(!(bumped.pass_flags_self & PASSGRILLE))
		return
	if(DOING_INTERACTION_WITH_TARGET(owner, bumped))
		return
	var/turf/bump_turf = get_turf(bumped)
	if(bump_turf.is_blocked_turf(source_atom = owner, ignore_atoms = list(bumped)))
		return

	INVOKE_ASYNC(src, PROC_REF(try_squeeze_into), bumped)

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/proc/try_squeeze_into(atom/bumped)
	var/squeeze_time = 3 SECONDS
	var/warning_message = ""
	var/list/items = owner.get_equipped_items(INCLUDE_HELD)
	// squeeze time goes up if they have any items on - not for balance reasons, but just to let them now they're about to be stripped clean.
	if(length(items))
		squeeze_time += 2 SECONDS
		warning_message = " (This will drop all of your equipment!)"
	// another check is made for dangerous_unequip items, which will also add to the squeeze time and give a more specific warning message.
	for(var/obj/item/thing as anything in items)
		if(HAS_TRAIT(thing, TRAIT_DANGEROUS_UNEQUIP))
			squeeze_time += 3 SECONDS
			warning_message = " (This will drop ALL of your equipment, <b>including [thing]</b>!)"
			break

	owner.visible_message(
		span_warning("[owner] starts squeezing through the crevices within [bumped]..."),
		span_notice("You start squeezing through the crevices within [bumped]...[warning_message]"),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
	)

	if(!do_after(owner, squeeze_time, bumped) || QDELETED(src) || !is_active)
		return

	owner.visible_message(
		span_warning("[owner] squeezes into the crevices within [bumped]!"),
		span_notice("You squeeze into the crevices within [bumped]."),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
	)

	add_passgrille()
	owner.forceMove(bumped.loc)

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/proc/spit_out(in_direction)
	// intentionally uses range over range_turfs to get closest turfs first
	for(var/turf/open/nearby_open_turf in range(2, get_step(owner, in_direction)))
		if(nearby_open_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = owner))
			continue
		owner.forceMove(nearby_open_turf)
		owner.Paralyze(4 SECONDS)
		owner.Knockdown(8 SECONDS)
		owner.adjust_jitter(12 SECONDS)
		owner.bleed(36) // leaves a pool o jelly behind
		return TRUE

	return FALSE

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/proc/on_move(datum/source, atom/old_loc)
	SIGNAL_HANDLER

	if(!(owner.pass_flags & PASSGRILLE))
		return

	for(var/atom/blocker as anything in owner.loc)
		if(blocker.pass_flags_self & PASSGRILLE)
			return

	// leaving grilles = back to normal. (though the effect is still active)
	clear_passgrille()

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/proc/add_passgrille()
	owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_UNDENSE, TRAIT_PULL_BLOCKED, TRAIT_UI_BLOCKED), TRAIT_STATUS_EFFECT(id))
	owner.pass_flags |= PASSGRILLE
	owner.add_movespeed_modifier(/datum/movespeed_modifier/walking_through_grille)

	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.dna.species.update_no_equip_flags(owner, ALL)

/datum/status_effect/grouped/bodypart_effect/slime_passgrille/proc/clear_passgrille()
	owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_UNDENSE, TRAIT_PULL_BLOCKED, TRAIT_UI_BLOCKED), TRAIT_STATUS_EFFECT(id))
	owner.pass_flags &= ~PASSGRILLE
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/walking_through_grille)

	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.dna.species.update_no_equip_flags(owner, initial(carbon_owner.dna.species.no_equip_flags))

/datum/movespeed_modifier/walking_through_grille
	id = "walking_through_grille"
	multiplicative_slowdown = 3
