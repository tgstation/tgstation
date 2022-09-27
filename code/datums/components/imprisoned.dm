/// Add this component whenever we send someone to Admin Prison to make them totally unable to teleport out until they exit the Admin Prison area.
/datum/component/imprisoned
	/// The area of the admin prison.
	var/prison_area = /area/centcom/central_command_areas/prison/cells
	/// Detect any movement of the container
	var/datum/movement_detector/move_tracker

/datum/component/imprisoned/Initialize()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	move_tracker = new(parent, CALLBACK(src, .proc/verify_imprisonment))
	ADD_TRAIT(parent, TRAIT_NO_TELEPORT, ADMIN_TRAIT)


/// Check to see if our area changes at all. If it changes, remove all the no_teleport traits and delete the component.
/datum/component/imprisoned/proc/verify_imprisonment()
	var/prisoner_area = get_area(parent)
	if(prisoner_area == prison_area)
		return
	// they're no longer in the prison area, let's automatically remove that trait so they can engage in normal play
	REMOVE_TRAIT(parent, TRAIT_NO_TELEPORT, ADMIN_TRAIT)
	qdel(src)

/datum/component/itembound/Destroy(force, silent)
	QDEL_NULL(move_tracker)
	return ..()
