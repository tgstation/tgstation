/**
 * Makes a reagent boilable
 */
/datum/element/boilable
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2

	/// The temperature the reagent boils at
	var/boiling_temp = INFINITY
	/// The path of the resulting gas
	var/datum/gas/vapor_path

/datum/element/boilable/Attach(datum/reagent/target, _temp, _gas)
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	if(!GLOB.meta_gas_info[_gas])
		return ELEMENT_INCOMPATIBLE

	boiling_temp = _temp
	vapor_path = _gas
	RegisterSignal(target, COMSIG_REAGENT_TEMP_CHANGE, .proc/try_boil)
	. = ..()
	try_boil(target, target.holder?.chem_temp)

/datum/element/boilable/Detach(datum/source, force)
	UnregisterSignal(source, COMSIG_REAGENT_TEMP_CHANGE)
	return ..()

/// Attempts to boil the source reagent
/datum/element/boilable/proc/try_boil(datum/reagent/source, _temp)
	SIGNAL_HANDLER
	if(_temp < boiling_temp)
		return NONE
	var/datum/reagents/holder = source.holder
	if(!(holder?.flags & (DRAINABLE)))
		return NONE
	var/turf/location = get_turf(holder.my_atom)
	if(!location)
		return NONE

	location.atmos_spawn_air("[vapor_path]=[source.volume * REAGENT_MOLE_DENSITY];TEMP=[_temp]")
	holder.del_reagent(source.type)
	return NONE
