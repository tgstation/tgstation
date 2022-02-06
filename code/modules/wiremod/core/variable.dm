/**
 * A circuit variable that holds the name, the datatype and the colour of the variable (taken from the datatype).
 *
 * Used in integrated circuits for setter and getter circuit components.
 */
/datum/circuit_variable
	/// The display name of the circuit variable
	var/name

	/// The datatype of the circuit variable. Used by the setter and getter circuit components
	var/datatype

	/// The datatype handler for the circuit variable.
	var/datum/circuit_datatype/datatype_handler

	/// The colour that appears in the UI. The value is set to the datatype's matching colour
	var/color

	/// The current value held by the variable.
	var/value

	/// The components that are currently listening. Triggers them when the value is updated.
	var/list/obj/item/circuit_component/listeners

/datum/circuit_variable/New(name, datatype)
	. = ..()
	src.name = name
	src.datatype = datatype

	src.datatype_handler = GLOB.circuit_datatypes[datatype]
	src.listeners = list()
	src.color = datatype_handler.color


/// Sets the value of the circuit component and triggers the appropriate listeners
/datum/circuit_variable/proc/set_value(new_value)
	value = new_value
	for(var/obj/item/circuit_component/component as anything in listeners)
		component.trigger_component()

/datum/circuit_variable/proc/on_listener_qdel(datum/listener)
	SIGNAL_HANDLER
	listeners -= listener

/// Adds a listener to receive inputs when the variable has a value that is set.
/datum/circuit_variable/proc/add_listener(obj/item/circuit_component/to_add)
	listeners += to_add
	RegisterSignal(to_add, COMSIG_PARENT_QDELETING, .proc/on_listener_qdel)

/// Removes a listener to receive inputs when the variable has a value that is set. Listener will usually clean themselves up
/datum/circuit_variable/proc/remove_listener(obj/item/circuit_component/to_remove)
	UnregisterSignal(to_remove, COMSIG_PARENT_QDELETING)
	listeners -= to_remove
