// Prioritizes the type of atom that the manipulator interact with. Interaction lists get built on the points themselves.

/datum/manipulator_priority
	/// The name of the priority for the UI display.
	var/name
	/// Which typepath does this priority handle.
	var/atom_typepath
	/// Is this priority active? If not, it will be ignored.
	var/active = TRUE

/datum/manipulator_priority/drop/on_floor
	name = "DROP ON FLOOR"
	atom_typepath = /turf

/datum/manipulator_priority/drop/in_storage
	name = "DROP IN STORAGE"
	atom_typepath = /obj/item/storage

/datum/manipulator_priority/interact/with_living
	name = "USE ON LIVING"
	atom_typepath = /mob/living

/datum/manipulator_priority/interact/with_structure
	name = "USE ON STRUCTURE"
	atom_typepath = /obj/structure

/datum/manipulator_priority/interact/with_machinery
	name = "USE ON MACHINERY"
	atom_typepath = /obj/machinery

/datum/manipulator_priority/interact/with_items
	name = "USE ON ITEM"
	atom_typepath = /obj/item

/datum/manipulator_priority/interact/with_vehicles
	name = "USE ON VEHICLES"
	atom_typepath = /obj/vehicle
