/**
 * ## death gases element!
 *
 * Bespoke element that spawns one type of gas when a mob is killed
 */
/datum/element/death_gases
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 3
	///What gas the target spawns when killed
	var/datum/gas/gas_type
	///The amount of gas spawned on death
	var/amount_of_gas

/datum/element/death_gases/Attach(datum/target, datum/gas/gas_type, amount_of_gas = 10)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!gas_type)
		stack_trace("[type] added to [target] with NO GAS TYPE.")
	src.gas_type = gas_type
	src.amount_of_gas = amount_of_gas
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/element/death_gases/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)

///signal called by the stat of the target changing
/datum/element/death_gases/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	var/datum/gas_mixture/mix_to_spawn = new()
	mix_to_spawn.add_gas(gas_type)
	mix_to_spawn.gases[gas_type][MOLES] = amount_of_gas
	mix_to_spawn.temperature = T20C
	var/turf/open/our_turf = get_turf(target)
	our_turf.assume_air(mix_to_spawn)
