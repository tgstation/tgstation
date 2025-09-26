// Prioritizes the type of atom that the manipulator interact with. Interaction lists get built on the points themselves.

/datum/manipulator_priority
	/// The name of teh priority for the UI display.
	var/name
	/// Which typepath does this priority handle.
	var/atom_typepath
	/// Priority index.
	var/number

/datum/manipulator_priority/drop/on_floor
	name = "DROP ON FLOOR"
	atom_typepath = /turf
	number = 1

/datum/manipulator_priority/drop/in_storage
	name = "DROP IN STORAGE"
	atom_typepath = /obj/item/storage
	number = 2

/datum/manipulator_priority/interact/with_living
	name = "USE ON LIVING"
	atom_typepath = /mob/living
	number = 1

/datum/manipulator_priority/interact/with_structure
	name = "USE ON STRUCTURE"
	atom_typepath = /obj/structure
	number = 2

/datum/manipulator_priority/interact/with_machinery
	name = "USE ON MACHINERY"
	atom_typepath = /obj/machinery
	number = 3

/datum/manipulator_priority/interact/with_items
	name = "USE ON ITEM"
	atom_typepath = /obj/item
	number = 4
