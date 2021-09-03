/**
 * # SDQL Component
 *
 * A component that performs an sdql operation
 */
/obj/item/circuit_component/sdql_operation
	display_name = "SDQL Operation"
	desc = "A component that performs an SDQL operation when invoked."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// SDQL Operation to invoke
	var/datum/port/input/sdql_operation

	var/datum/port/output/results


/obj/item/circuit_component/sdql_operation/populate_ports()
	sdql_operation = add_input_port("SDQL String", PORT_TYPE_STRING)
	results = add_output_port("Result", PORT_TYPE_LIST)

/obj/item/circuit_component/sdql_operation/input_received(datum/port/input/port)
	if(GLOB.AdminProcCaller)
		return TRUE

	INVOKE_ASYNC(src, .proc/execute_sdql, port)

/obj/item/circuit_component/sdql_operation/proc/execute_sdql(datum/port/input/port)
	var/operation = sdql_operation.value

	if(GLOB.AdminProcCaller || !operation)
		return

	GLOB.AdminProcCaller = "CHAT_[parent.display_name]" //_ won't show up in ckeys so it'll never match with a real admin
	var/list/result = world.SDQL2_query(operation, parent.get_creator_admin(), parent.get_creator())
	GLOB.AdminProcCaller = null

	results.set_output(result)
