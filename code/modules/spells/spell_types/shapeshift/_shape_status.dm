// A status effect for having a mob temporarily (usually) change form into that of another mob.
// When the status effect is removed, the mob is reverted back to their human form in most cases.
// If you want a more permanent polymorph, see [/proc/wabbajack].
/datum/status_effect/shapechange_mob
	id = "shapechange_mob"
	alert_type = /atom/movable/screen/alert/status_effect/shapeshifted
	// When the mob's deleted on_remove() will handle our references
	on_remove_on_mob_delete = TRUE

	/// The caster's mob. Who has transformed into us
	/// This reference is handled in [/proc/restore_caster], which is always called if we delete
	var/mob/living/caster_mob
	/// Whether we're currently undoing the change
	var/already_restored = FALSE

/datum/status_effect/shapechange_mob/on_creation(mob/living/new_owner, mob/living/caster)
	// If any type or subtype of shapeshift mob is on the new_owner already throw an error and self-delete
	if(locate(type) in new_owner.status_effects)
		stack_trace("Mob shapechange status effect applied to a mob which already was shapechanged, which will definitely cause issues.")
		qdel(src)
		return

	// No caster mob, no one to put in the mob. Self-delete
	if(!istype(caster))
		stack_trace("Mob shapechange status effect applied without a proper caster.")
		qdel(src)
		return

	src.caster_mob = caster
	return ..()

/datum/status_effect/shapechange_mob/on_apply()
	caster_mob.mind?.transfer_to(owner)
	caster_mob.forceMove(owner)
	ADD_TRAIT(caster_mob, TRAIT_NO_TRANSFORM, TRAIT_STATUS_EFFECT(id))
	caster_mob.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_SHAPECHANGE_EFFECT)

	RegisterSignal(owner, COMSIG_LIVING_PRE_WABBAJACKED, PROC_REF(on_pre_wabbajack))
	RegisterSignal(owner, COMSIG_PRE_MOB_CHANGED_TYPE, PROC_REF(on_pre_type_change))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_shape_death))
	RegisterSignal(caster_mob, COMSIG_LIVING_DEATH, PROC_REF(on_caster_death))
	RegisterSignal(caster_mob, COMSIG_QDELETING, PROC_REF(on_caster_deleted))

	SEND_SIGNAL(caster_mob, COMSIG_LIVING_SHAPESHIFTED, owner)
	return TRUE

/datum/status_effect/shapechange_mob/on_remove()
	// If the owner was straight up deleted we shouldn't restore anyone
	// (the caster's stored in the owner's contents so if it's qdel'd so is the caster)
	if(!QDELETED(owner))
		restore_caster()

	// Either restore_caster() or other signals should have handled this reference by now,
	// but juuust in case make sure nothing sticks around.
	caster_mob = null

/// Called when we're shot by the Wabbajack but before we change into a different mob
/datum/status_effect/shapechange_mob/proc/on_pre_wabbajack(mob/living/source)
	SIGNAL_HANDLER
	on_mob_transformed(source)
	return STOP_WABBAJACK

/// Called when we're turned into a different mob via the change_mob_type proc
/datum/status_effect/shapechange_mob/proc/on_pre_type_change(mob/living/source)
	SIGNAL_HANDLER
	on_mob_transformed(source)
	return COMPONENT_BLOCK_MOB_CHANGE

/// Called when the transformed mob tries to change into a different kind of mob, we wouldn't handle this well so we'll just turn back
/datum/status_effect/shapechange_mob/proc/on_mob_transformed(mob/living/source)
	var/mob/living/revealed_mob = caster_mob
	source.visible_message(span_warning("[revealed_mob] gets pulled back to their normal form!"))
	restore_caster()
	revealed_mob.Paralyze(10 SECONDS, ignore_canstun = TRUE)

/// Restores the caster back to their human form.
/// if kill_caster_after is TRUE, the caster will have death() called on them after restoring.
/datum/status_effect/shapechange_mob/proc/restore_caster(kill_caster_after = FALSE)
	if(already_restored || !caster_mob)
		return

	if(QDELETED(owner))
		CRASH("Mob shapechange effect called restore_caster while the owner was qdeleted, this shouldn't happen.")

	already_restored = TRUE
	UnregisterSignal(owner, list(COMSIG_LIVING_PRE_WABBAJACKED, COMSIG_LIVING_DEATH))
	UnregisterSignal(caster_mob, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))

	REMOVE_TRAIT(caster_mob, TRAIT_NO_TRANSFORM, TRAIT_STATUS_EFFECT(id))
	caster_mob.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_SHAPECHANGE_EFFECT)

	var/atom/former_loc = owner.loc
	owner.moveToNullspace()
	caster_mob.forceMove(former_loc) // This is to avoid crushing our former cockroach body

	if(kill_caster_after)
		caster_mob.death()

	after_unchange()

	// We're about to remove the status effect and clear owner so we need to cache this
	var/mob/living/former_body = owner

	// Do this late as it will destroy the status effect we are in and null a bunch of values we are trying to use
	owner.mind?.transfer_to(caster_mob)

	// Destroy the owner after all's said and done, this will also destroy our status effect (src)
	// retore_caster() should never reach this point while either the owner or the effect is being qdeleted
	qdel(former_body)

/// Effects done after the casting mob has reverted to their human form.
/datum/status_effect/shapechange_mob/proc/after_unchange()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(owner, COMSIG_LIVING_UNSHAPESHIFTED, caster_mob)

/// Signal proc for [COMSIG_LIVING_DEATH] from our owner.
/// If our owner mob is killed, we should revert back to normal.
/datum/status_effect/shapechange_mob/proc/on_shape_death(datum/source, gibbed)
	SIGNAL_HANDLER

	// gibbed = deleted = nothing to restore
	if(gibbed)
		return

	restore_caster()

/// Signal proc for [COMSIG_LIVING_DEATH] from our caster.
/// If our internal caster is killed, kill our owner, too (which causes the above signal).
/// This should very rarely end up being called but you never know
/datum/status_effect/shapechange_mob/proc/on_caster_death(datum/source, gibbed)
	SIGNAL_HANDLER

	// Our caster inside was gibbed, mirror the gib to our mob
	if(gibbed)
		owner.gib(DROP_ALL_REMAINS)

	// Otherwise our caster died, just make our mob die
	else
		owner.death()

/// Signal proc for [COMSIG_QDELETING] from our caster, delete us / our owner if we get deleted
/datum/status_effect/shapechange_mob/proc/on_caster_deleted(datum/source)
	SIGNAL_HANDLER

	caster_mob = null
	if(QDELETED(owner))
		return

	qdel(owner)

// A subtype for a shapechange sourced from a shapeshift spell.
/datum/status_effect/shapechange_mob/from_spell
	id = "shapechange_from_spell"
	/// The shapechange spell that's caused our change
	var/datum/weakref/source_weakref

/datum/status_effect/shapechange_mob/from_spell/on_creation(mob/living/new_owner, mob/living/caster, datum/action/cooldown/spell/shapeshift/source_spell)
	if(!istype(source_spell))
		stack_trace("Mob shapechange \"from spell\" status effect applied without a source spell.")
		qdel(src)
		return

	source_weakref = WEAKREF(source_spell)
	return ..()

/datum/status_effect/shapechange_mob/from_spell/on_apply()
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref.resolve()
	if(source_spell.owner == caster_mob)
		// Assuming the spell is owned by the caster, give it over to the shapeshifted mob
		// so they can actually transform back to their original form
		source_spell.Grant(owner)

		if(source_spell.convert_damage)
			var/damage_to_apply = owner.maxHealth * (caster_mob.get_total_damage() / caster_mob.maxHealth)

			owner.apply_damage(damage_to_apply, source_spell.convert_damage_type, forced = TRUE, spread_damage = TRUE, wound_bonus = CANT_WOUND)
			// Only transfer blood if both mobs are supposed to have a blood volume
			if (initial(owner.blood_volume) > 0 && initial(caster_mob.blood_volume) > 0 && !HAS_TRAIT(owner, TRAIT_NOBLOOD) && !HAS_TRAIT(caster_mob, TRAIT_NOBLOOD))
				owner.blood_volume = caster_mob.blood_volume

	for(var/datum/action/bodybound_action as anything in caster_mob.actions)
		if(bodybound_action.target != caster_mob)
			continue
		bodybound_action.Grant(owner)

	return ..()

/datum/status_effect/shapechange_mob/from_spell/restore_caster(kill_caster_after)
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref.resolve()
	// The owner = owner check here is specifically for edge cases in which the owner of the spell
	// is no longer in control of the shapeshifted mob, such as mindswapping out of a shapeshift
	if(!QDELETED(source_spell) && source_spell.owner == owner)
		source_spell.Grant(caster_mob)
	if(owner?.contents)
		// Prevent round removal and consuming stuff when losing shapeshift
		for(var/atom/movable/thing as anything in owner.contents)
			if(thing == caster_mob || HAS_TRAIT(thing, TRAIT_NOT_BARFABLE))
				continue
			thing.forceMove(get_turf(owner))

	for(var/datum/action/bodybound_action as anything in owner.actions)
		if(bodybound_action.target != caster_mob)
			continue
		bodybound_action.Grant(caster_mob)

	return ..()

/datum/status_effect/shapechange_mob/from_spell/after_unchange()
	. = ..()
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref?.resolve()
	if(QDELETED(source_spell) || !source_spell.convert_damage)
		return

	caster_mob.fully_heal(HEAL_DAMAGE) // Remove all of our damage before setting our health to a proportion of the former transformed mob's health
	var/damage_to_apply = caster_mob.maxHealth * (owner.get_total_damage() / owner.maxHealth)
	caster_mob.apply_damage(damage_to_apply, source_spell.convert_damage_type, forced = TRUE, spread_damage = TRUE, wound_bonus = CANT_WOUND)
	// Only transfer blood if both mobs are supposed to have a blood volume
	if (initial(owner.blood_volume) > 0 && initial(caster_mob.blood_volume) > 0 && !HAS_TRAIT(owner, TRAIT_NOBLOOD) && !HAS_TRAIT(caster_mob, TRAIT_NOBLOOD))
		caster_mob.blood_volume = owner.blood_volume

/datum/status_effect/shapechange_mob/from_spell/on_shape_death(datum/source, gibbed)
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref.resolve()
	// If our spell dictates our wizard dies when our shape dies, we won't restore by default
	if(!QDELETED(source_spell) && source_spell.die_with_shapeshifted_form)
		// (But if our spell says we should revert on death anyways, we'll also do that)
		if(source_spell.revert_on_death)
			restore_caster(kill_caster_after = TRUE)
		// Otherwise, we just do nothing - we dead
		return

	return ..() // Restore like normal

/datum/status_effect/shapechange_mob/from_spell/on_caster_death(datum/source)
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref.resolve()
	// If our spell does not have revert_on_death, don't do anything when our caster dies
	if(!QDELETED(source_spell) && !source_spell.revert_on_death)
		return

	return ..() // Kill our owner and revert, like normal

/atom/movable/screen/alert/status_effect/shapeshifted
	name = "Shapeshifted"
	desc = "Your form is not your own... you're shapeshifted into another creature! \
		A wizard could turn you back - or maybe you're stuck like this for good?"
	icon_state = "shapeshifted"
	clickable_glow = TRUE

/atom/movable/screen/alert/status_effect/shapeshifted/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/mob/living/living_user = usr
	if(!istype(living_user))
		return

	// Clicking the action will try to cast whatever spell shifted us in the first place
	for(var/datum/action/cooldown/spell/shapeshift/shift_spell in living_user.actions)
		if(istype(living_user, shift_spell.shapeshift_type))
			shift_spell.Trigger()
			return TRUE
