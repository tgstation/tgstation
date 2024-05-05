/// Designates the atom as a "point of interest", meaning it can be directly orbited.
/// Also handles updating the ghost orbit menu whenever the PoI has a change that might appear on the menu.
/datum/element/point_of_interest
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/should_update = FALSE
	var/static/list/update_signals = list(
		COMSIG_ATOM_ORBIT_BEGIN,
		COMSIG_ATOM_ORBIT_STOP,
		COMSIG_MOB_STATCHANGE,
		COMSIG_MOB_ANTAGONIST_GAINED,
		COMSIG_MOB_ANTAGONIST_REMOVED,
		COMSIG_HUMAN_SECHUD_SET_ID,
		SIGNAL_ADDTRAIT(TRAIT_UNKNOWN)
	) + COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES

/datum/element/point_of_interest/New()
	START_PROCESSING(SSdcs, src)

/datum/element/point_of_interest/Attach(datum/target)
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

	// New players are abstract mobs assigned to people who are still in the lobby screen.
	// As a result, they are not a valid POI and should never be a valid POI. If they
	// somehow get this element attached to them, there's something we need to debug.
	if(isnewplayer(target))
		return ELEMENT_INCOMPATIBLE

	SSpoints_of_interest.on_poi_element_added(target)
	RegisterSignals(target, update_signals, PROC_REF(flag_updated))
	flag_updated()
	return ..()

/datum/element/point_of_interest/Detach(datum/target)
	SSpoints_of_interest.on_poi_element_removed(target)
	UnregisterSignal(target, update_signals)
	flag_updated()
	return ..()

/datum/element/point_of_interest/process(seconds_per_tick)
	if(should_update)
		INVOKE_ASYNC(GLOB.orbit_menu, TYPE_PROC_REF(/datum/orbit_menu, update_static_data_for_all_viewers))
		should_update = FALSE

/datum/element/point_of_interest/proc/flag_updated()
	SIGNAL_HANDLER
	should_update = TRUE
