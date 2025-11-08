/// Status effect that is tied to the existence of a reagent in a mob's system
/datum/status_effect/reagent_effect
	abstract_type = /datum/status_effect/reagent_effect
	id = STATUS_EFFECT_ID_ABSTRACT
	alert_type = null
	tick_interval = STATUS_EFFECT_NO_TICK
	/// We need this reagent type
	var/reagent_typepath
	/// Whether subtypes of the reagent are allowed to keep the effect active
	var/subtypes_allowed

/datum/status_effect/reagent_effect/on_creation(mob/living/new_owner, reagent_typepath, subtypes_allowed = TRUE)
	if(isnull(src.reagent_typepath))
		if(isnull(reagent_typepath))
			stack_trace("Reagent effect [src] created without a reagent typepath!")
		src.reagent_typepath = reagent_typepath
	if(isnull(src.subtypes_allowed))
		src.subtypes_allowed = subtypes_allowed
	return ..()

/datum/status_effect/reagent_effect/on_apply()
	if(isnull(owner.reagents) || isnull(reagent_typepath) || !can_effect())
		return FALSE

	RegisterSignal(owner.reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(check_reagents))
	add_effect()
	return TRUE

/datum/status_effect/reagent_effect/on_remove()
	remove_effect()
	UnregisterSignal(owner.reagents, COMSIG_REAGENTS_HOLDER_UPDATED)

/datum/status_effect/reagent_effect/proc/check_reagents(datum/reagents/updated_reagents)
	SIGNAL_HANDLER

	if(owner.reagents?.has_reagent(reagent_typepath, check_subtypes = subtypes_allowed))
		return
	qdel(src)

/// Can we add this effect to the owner?
/datum/status_effect/reagent_effect/proc/can_effect()
	return TRUE

/// Add the side effect to the owner
/datum/status_effect/reagent_effect/proc/add_effect()
	return

/// Remove the side effect from the owner
/datum/status_effect/reagent_effect/proc/remove_effect()
	return

/datum/status_effect/reagent_effect/fakedeath
	id = "reagent_fake_death"

/datum/status_effect/reagent_effect/fakedeath/add_effect()
	owner.fakedeath(type)

/datum/status_effect/reagent_effect/fakedeath/remove_effect()
	owner.cure_fakedeath(type)

/datum/status_effect/reagent_effect/freeze
	id = "reagent_freeze"

/datum/status_effect/reagent_effect/freeze/can_effect()
	return !HAS_TRAIT(owner, TRAIT_RESISTCOLD)

/datum/status_effect/reagent_effect/freeze/add_effect()
	owner.apply_status_effect(/datum/status_effect/frozenstasis/irresistable)
	owner.apply_status_effect(/datum/status_effect/grouped/stasis, type)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(escape_prison))

/datum/status_effect/reagent_effect/freeze/remove_effect()
	owner.remove_status_effect(/datum/status_effect/frozenstasis/irresistable)
	owner.remove_status_effect(/datum/status_effect/grouped/stasis, type)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/datum/status_effect/reagent_effect/freeze/proc/escape_prison(...)
	SIGNAL_HANDLER

	if(isturf(owner.loc)) // we escaped ice prison
		owner.reagents?.del_reagent(reagent_typepath)
	if(!QDELETED(src))
		stack_trace("Despite nuking the reagent from the mob, [owner] still has [type]")
		qdel(src)
