/**
 * # SSinterfaces
 *
 * A subsystem for checking for interface implementations.
 */
SUBSYSTEM_DEF(interfaces)
	name = "Interfaces"
	flags = SS_NO_FIRE

	/// Assoc list of typecaches of types that implement interfaces.
	var/list/implementations

/datum/controller/subsystem/interfaces/Initialize(start_timeofday)
	. = ..()
	init_implementations()

/**
 * Initializes the interface implementation cache.
 */
/datum/controller/subsystem/interfaces/proc/init_implementations()
	var/list/cached_implementations = list()
	var/list/raw_aggregate = aggregate_implementations()
	for(var/interface in raw_aggregate)
		cached_implementations[interface] = typecacheof(raw_aggregate[interface])
	implementations = cached_implementations

/**
 * Aggregates and returns a list of all interface implementations.
 */
/datum/controller/subsystem/interfaces/proc/aggregate_implementations()
	. = list()
	for(var/interface_type in subtypesof(/datum/interface))
		.[interface_type] = list()


/**
 * Checks whether a given instance or typepath implements an interface
 *
 * Arguments:
 * - instance_or_type: The instance or typepath to check.
 * - interface: The interface to check.
 */
/datum/controller/subsystem/interfaces/proc/_implements(instance_or_type, interface)
	if(!implementations)
		init_implementations()
	return is_type_in_typecache(instance_or_type, implementations[interface])
