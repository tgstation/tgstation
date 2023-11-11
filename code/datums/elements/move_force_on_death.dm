/**
 * Element to change a mob's move forces on death and reset them on living
 */
/datum/element/change_force_on_death
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///Our move force
	var/move_force
	/// our resist move force
	var/move_resist
	/// how much we resist pulling
	var/pull_force

/datum/element/change_force_on_death/Attach(datum/target, move_force, move_resist, pull_force)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(target, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))

	if(!isnull(move_force))
		src.move_force = move_force
	if(!isnull(move_resist))
		src.move_resist = move_resist
	if(!isnull(pull_force))
		src.pull_force = pull_force

/datum/element/change_force_on_death/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE))

/datum/element/change_force_on_death/proc/on_death(mob/living/source)
	SIGNAL_HANDLER

	if(!isnull(move_force))
		source.move_force = move_force
	if(!isnull(move_resist))
		source.move_resist = move_resist
	if(!isnull(pull_force))
		source.pull_force = pull_force

/datum/element/change_force_on_death/proc/on_revive(mob/living/source)
	SIGNAL_HANDLER

	source.move_force = initial(source.move_force)
	source.move_resist = initial(source.move_resist)
	source.pull_force = initial(source.pull_force)
