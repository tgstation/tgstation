/**
 * # SDQL Component
 *
 * A component that performs an sdql operation
 */
/obj/item/circuit_component/sdql_operation
	display_name = "SDQL Operation"
	desc = "A component that performs an SDQL operation when invoked."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// SDQL Operation to invoke
	var/datum/port/input/sdql_operation

	var/datum/port/output/results


/obj/item/circuit_component/sdql_operation/populate_ports()
	sdql_operation = add_input_port("SDQL String", PORT_TYPE_STRING)
	results = add_output_port("Result", PORT_TYPE_LIST(PORT_TYPE_STRING))

/obj/item/circuit_component/sdql_operation/input_received(datum/port/input/port)
	if(GLOB.AdminProcCaller)
		return TRUE

	INVOKE_ASYNC(src, .proc/execute_sdql, port)

/obj/item/circuit_component/sdql_operation/proc/execute_sdql(datum/port/input/port)
	var/operation = sdql_operation.value

	if(!operation)
		return

	log_admin_circuit("[parent.get_creator()] performed SDQL query [operation].")
	var/result = HandleUserlessSDQL(parent.get_creator(), operation)
	results.set_output(result)
