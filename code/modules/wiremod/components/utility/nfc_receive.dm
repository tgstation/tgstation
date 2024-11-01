/**
 * # NFC Receiver Component
 *
 * Sends a data package through NFC directly to a shell
 * if we ever get more shells like BCI's that are nested, keep in mind this may not work correctly unless adjusted
 */


/obj/item/circuit_component/nfc_receive
	display_name = "NFC Receiver"
	desc = "Receives data packages through NFC. If Encryption Key is set then only signals with the same Encryption Key will be received."
	category = "Utility"

	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL //trigger_output

	/// The list type
	var/datum/port/input/option/list_options

	/// Data being received
	var/datum/port/output/data_package

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/nfc_receive/populate_options()
	list_options = add_option_port("List Type", GLOB.wiremod_basic_types)

/obj/item/circuit_component/nfc_receive/populate_ports()
	data_package = add_output_port("Data Package", PORT_TYPE_LIST(PORT_TYPE_ANY))
	enc_key = add_input_port("Encryption Key", PORT_TYPE_STRING)

/obj/item/circuit_component/nfc_receive/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_CIRCUIT_NFC_DATA_SENT, PROC_REF(nfc_receive))
	RegisterSignal(shell, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))

/obj/item/circuit_component/nfc_receive/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(
		COMSIG_CIRCUIT_NFC_DATA_SENT,
		COMSIG_ORGAN_IMPLANTED,
		COMSIG_ORGAN_REMOVED,
	))

/obj/item/circuit_component/nfc_receive/proc/on_organ_implanted(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	RegisterSignal(owner, COMSIG_CIRCUIT_NFC_DATA_SENT, PROC_REF(nfc_receive))

/obj/item/circuit_component/nfc_receive/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	UnregisterSignal(owner, COMSIG_CIRCUIT_NFC_DATA_SENT)


/obj/item/circuit_component/nfc_receive/pre_input_received(datum/port/input/port)
	if(port == list_options)
		var/new_datatype = list_options.value
		data_package.set_datatype(PORT_TYPE_LIST(new_datatype))


/obj/item/circuit_component/nfc_receive/proc/nfc_receive(obj/item/circuit_component/source,obj/sender, list/data)
	SIGNAL_HANDLER

	if(get_dist(sender,parent) >= 10)
		return

	if(data["enc_key"] != enc_key.value)
		return

	var/datum/weakref/ref = data["port"]
	var/datum/port/input/port = ref?.resolve()
	if(!port)
		return

	var/datum/circuit_datatype/datatype_handler = data_package.datatype_handler
	if(!datatype_handler?.can_receive_from_datatype(port.datatype))
		return

	data_package.set_output(data["data"])
	trigger_output.set_output(COMPONENT_SIGNAL)
