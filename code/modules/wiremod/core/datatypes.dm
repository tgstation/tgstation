// An assoc list of all the possible datatypes.
GLOBAL_LIST_INIT_TYPED(circuit_datatypes, /datum/circuit_datatype, generate_circuit_datatypes())

/proc/generate_circuit_datatypes()
	var/list/datatypes_by_key = list()
	for(var/datum/circuit_datatype/type as anything in subtypesof(/datum/circuit_datatype))
		if(!initial(type.datatype) || initial(type.abstract))
			continue
		datatypes_by_key[initial(type.datatype)] = new type()
	return datatypes_by_key

/**
 * A circuit datatype. Used to determine the datatype of a port and also handle any additional behaviour.
 */
/datum/circuit_datatype
	/// The key. Used to identify the datatype. Should be a define.
	var/datatype

	/// The color of the port in the UI. Doesn't work with hex colours.
	var/color = "blue"

	/// The flags of the circuit datatype
	var/datatype_flags = 0

	/// The datatypes that this datatype can receive from.
	var/list/can_receive_from = list()

	/// Whether this datatype should be loaded into the global circuit_datatypes list.
	var/abstract = FALSE

	/// Whether we should extensively convert this datatype, important for composite lists who may not have datatypes that need implicit conversions
	var/is_extensive = FALSE

/**
 * Returns the value to be set for the port
 *
 * Used for implicit conversions between outputs and inputs (e.g. number -> string)
 * and applying/removing signals on inputs
 */
/datum/circuit_datatype/proc/convert_value(datum/port/port, value_to_convert, force = FALSE)
	return value_to_convert

/**
 * Similar to convert value, however it doesn't get called by a port when a value is set. Useful for extensive conversions that may only need to be done for player inputs (e.g. lists)
 */
/datum/circuit_datatype/proc/convert_value_extensive(datum/port/port, value_to_convert, force = FALSE)
	return convert_value(port, value_to_convert, force)

/**
 * Determines if a datatype is compatible with another port of a different type.
 * Note: This is ALWAYS called on the input port, never on the output port.
 * Inputs need to care about what types they're receiving, output ports don't have to care.
 *
 * Arguments:
 * * datatype_to_check - The datatype to check
 */
/datum/circuit_datatype/proc/can_receive_from_datatype(datatype_to_check)
	return datatype == datatype_to_check || (datatype_to_check in can_receive_from)

/**
 * Called when the datatype is given to a port.
 *
 * Arguments:
 * * gained_port - The gained port.
 */
/datum/circuit_datatype/proc/on_gain(datum/port/gained_port)
	return

/**
 * Called when the datatype is removed from a port.
 *
 * Arguments:
 * * lost_port - The removed port.
 */
/datum/circuit_datatype/proc/on_loss(datum/port/lost_port)
	return

/**
 * Determines if a port is compatible with this datatype.
 * This WILL throw a runtime if it returns false. This is for sanity checking and it should not return false
 * unless under extraordinary circumstances or people fail to write proper code.
 *
 * Arguments:
 * * port - The port to check if it is compatible.
 */
/datum/circuit_datatype/proc/is_compatible(datum/port/port)
	return TRUE

/**
 * The data to send to the UI attached to the port. Received by the type in FUNDAMENTAL_PORT_TYPES
 *
 * Arguments:
 * * port - The port sending the data.
 */
/datum/circuit_datatype/proc/datatype_ui_data(datum/port/port)
	return

/**
 * When an input is manually set by a player. This is where extra sanitizing can happen. Will still call convert_value()
 *
 * Arguments:
 * * port - The port sending the data.
 * *
 */
/datum/circuit_datatype/proc/handle_manual_input(datum/port/input/port, mob/user, user_input)
	return user_input

/**
 * Used by composite datatypes. Returns all the datatypes that build this datatype up.
 */
/datum/circuit_datatype/proc/get_datatypes()
	return list()

/**
 * Used by composite datatypes. Returns a single datatype from the list if it exists by index.
 */
/datum/circuit_datatype/proc/get_datatype(index)
	return
