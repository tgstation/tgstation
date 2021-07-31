/datum/circuit_variable
	var/name
	var/datatype
	var/color

	var/value
	var/list/obj/item/circuit_component/listeners

/datum/circuit_variable/New(name, datatype)
	. = ..()
	src.name = name
	src.datatype = datatype

	var/datum/circuit_datatype/circuit_datatype = GLOB.circuit_datatypes[datatype]

	src.listeners = list()
	src.color = circuit_datatype.color


/datum/circuit_variable/Destroy(force, ...)
	listeners = null
	return ..()

/datum/circuit_variable/proc/set_value(new_value)
	value = new_value
	for(var/obj/item/circuit_component/component as anything in listeners)
		TRIGGER_CIRCUIT_COMPONENT(component, null)

/datum/circuit_variable/proc/add_listener(obj/item/circuit_component/to_add)
	listeners += to_add

/datum/circuit_variable/proc/remove_listener(obj/item/circuit_component/to_remove)
	listeners -= to_remove
