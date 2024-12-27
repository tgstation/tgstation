/// Intercepts attacks from mobs with this component to instead repair specified structures.
/datum/element/structure_repair
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// How much to heal structures by
	var/heal_amount
	/// Typecache of types of structures to repair
	var/list/structure_types_typecache

/datum/element/structure_repair/Attach(
	datum/target,
	heal_amount = 5,
	structure_types_typecache = typecacheof(list(/obj/structure)),
)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.heal_amount = heal_amount
	src.structure_types_typecache = structure_types_typecache
	RegisterSignals(target, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET), PROC_REF(try_repair))

/datum/element/structure_repair/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/// If the target is of a valid type, interrupt the attack chain to repair it instead
/datum/element/structure_repair/proc/try_repair(mob/living/fixer, atom/target, proximity)
	SIGNAL_HANDLER

	if (!proximity || !is_type_in_typecache(target, structure_types_typecache))
		return NONE

	if (target.get_integrity() >= target.max_integrity)
		target.balloon_alert(fixer, "not damaged!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	target.repair_damage(heal_amount)
	fixer.Beam(target, icon_state = "sendbeam", time = 0.4 SECONDS)
	fixer.visible_message(
		span_danger("[fixer] repairs [target]."),
		span_danger("You repair [target], leaving it at <b>[round(target.get_integrity() * 100 / target.max_integrity)]%</b> stability."),
	)

	return COMPONENT_CANCEL_ATTACK_CHAIN
