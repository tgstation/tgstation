/datum/status_effect/shapechange_mob
	/// The caster's mob. Who has transformed into us
	var/mob/living/caster_mob
	/// Whether we're currently undoing the change
	var/already_restored = FALSE

/datum/status_effect/shapechange_mob/Destroy()
	caster_mob = null
	return ..()

/datum/status_effect/shapechange_mob/on_creation(mob/living/new_owner, mob/living/caster)
	if(!istype(caster))
		stack_trace("Mob shapechange status effect applied without a proper caster.")
		qdel(src)
		return

	src.caster_mob = caster
	return ..()

/datum/status_effect/shapechange_mob/on_apply()
	caster_mob.mind?.transfer_to(owner)
	caster_mob.forceMove(owner)
	caster_mob.notransform = TRUE
	caster_mob.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_SHAPECHANGE_EFFECT)

	RegisterSignal(owner, COMSIG_LIVING_PRE_WABBAJACKED, .proc/on_wabbajacked)
	RegisterSignal(owner, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), .proc/on_shape_death)
	RegisterSignal(caster_mob, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), .proc/on_caster_death)
	return TRUE

/datum/status_effect/shapechange_mob/on_remove()
	if(already_restored)
		return

	restore_caster()

/datum/status_effect/shapechange_mob/proc/on_wabbajacked(mob/living/source, randomized)
	SIGNAL_HANDLER

	source.visible_message(span_warning("[caster_mob] gets pulled back to their normal form!"))
	restore_caster()
	return STOP_WABBAJACK

/datum/status_effect/shapechange_mob/proc/restore_caster(kill_caster_after = FALSE)
	already_restored = TRUE
	UnregisterSignal(owner, list(COMSIG_LIVING_PRE_WABBAJACKED, COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	UnregisterSignal(caster_mob, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))

	caster_mob.forceMove(owner.loc)
	caster_mob.notransform = FALSE
	caster_mob.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_SHAPECHANGE_EFFECT)
	owner.mind?.transfer_to(caster_mob)

	if(kill_caster_after)
		caster_mob.death()

	after_unchange()

	// This guard is important because restore() can also be called on COMSIG_PARENT_QDELETING for shape, as well as on death.
	// This can happen in, for example, [/proc/wabbajack] where the mob hit is qdel'd.
	if(!QDELETED(owner))
		QDEL_NULL(owner)

	qdel(src)

/datum/status_effect/shapechange_mob/proc/after_unchange()
	return

/datum/status_effect/shapechange_mob/proc/on_shape_death(datum/source)
	SIGNAL_HANDLER

	restore_caster()

/datum/status_effect/shapechange_mob/proc/on_caster_death(datum/source)
	SIGNAL_HANDLER

	owner.death()

/datum/status_effect/shapechange_mob/from_spell
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
	. = ..()
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref?.resolve()
	if(!QDELETED(source_spell) && source_spell.owner == caster_mob)
		// Assuming the spell is owned by the caster, give it over to the shapeshifted mob
		// so they can actually transform back to their original form
		source_spell.Grant(owner)

		if(source_spell.convert_damage)
			var/damage_to_apply = owner.maxHealth * ((caster_mob.maxHealth - caster_mob.health) / caster_mob.maxHealth)

			owner.apply_damage(damage_to_apply, source_spell.convert_damage_type, forced = TRUE, wound_bonus = CANT_WOUND)
			owner.blood_volume = caster_mob.blood_volume

	for(var/datum/action/bodybound_action as anything in caster_mob.actions)
		if(bodybound_action.target != caster_mob)
			continue
		bodybound_action.Grant(owner)

/datum/status_effect/shapechange_mob/from_spell/restore_caster(kill_caster_after)
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref?.resolve()
	// The owner = owner check here is specifically for edge cases in which the owner of the spell
	// is no longer in control of the shapeshifted mob, such as mindswapping out of a shapeshift
	if(!QDELETED(source_spell) && source_spell.owner == owner)
		source_spell.Grant(caster_mob)

	for(var/datum/action/bodybound_action as anything in owner.actions)
		if(bodybound_action.target != caster_mob)
			continue
		bodybound_action.Grant(caster_mob)

	return ..()

/datum/status_effect/shapechange_mob/from_spell/after_unchange()
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref?.resolve()
	if(QDELETED(source_spell) || !source_spell.convert_damage)
		return

	if(caster_mob.stat != DEAD)
		caster_mob.revive(full_heal = TRUE, admin_revive = FALSE)

		var/damage_to_apply = caster_mob.maxHealth * ((owner.maxHealth - owner.health) / owner.maxHealth)
		caster_mob.apply_damage(damage_to_apply, source_spell.convert_damage_type, forced = TRUE, wound_bonus = CANT_WOUND)

	caster_mob.blood_volume = owner.blood_volume

/datum/status_effect/shapechange_mob/from_spell/on_shape_death(datum/source)
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref?.resolve()
	if(QDELETED(source_spell))
		return ..()

	if(source_spell.die_with_shapeshifted_form)
		if(source_spell.revert_on_death)
			restore_caster(kill_caster_after = TRUE)
		return

	return ..()

/datum/status_effect/shapechange_mob/from_spell/on_caster_death(datum/source)
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref?.resolve()
	if(QDELETED(source_spell))
		return ..()

	if(source_spell.revert_on_death)
		restore_caster(kill_caster_after = TRUE)
		return

	return ..()
