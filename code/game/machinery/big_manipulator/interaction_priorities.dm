/// Prioritizes the type of atom that the manipulator interact with.
/datum/manipulator_priority
	/// Name that user will see in ui.
	var/name
	/// What type carries this priority.
	var/what_type
	/// Order of priority.
	var/number

/datum/manipulator_priority/for_drop/on_floor
	name = "DROP ON FLOOR"
	what_type = /turf
	number = 1

/datum/manipulator_priority/for_drop/in_storage
	name = "DROP IN STORAGE"
	what_type = /obj/item/storage
	number = 2

/datum/manipulator_priority/for_use/on_living
	name = "USE ON LIVING"
	what_type = /mob/living
	number = 1

/datum/manipulator_priority/for_use/on_structure
	name = "USE ON STRUCTURE"
	what_type = /obj/structure
	number = 2

/datum/manipulator_priority/for_use/on_machinery
	name = "USE ON MACHINERY"
	what_type = /obj/machinery
	number = 3

/datum/manipulator_priority/for_use/on_items
	name = "USE ON ITEM"
	what_type = /obj/item
	number = 4
