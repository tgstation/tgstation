/**
 * The processor is a very simple machine that decompresses subspace signals and
 * transfers them back to the original bus. It is essential in producing audible
 * data.
 *
 * They'll link to servers if bus is not present, with some delay added to it.
 */
/obj/machinery/telecomms/processor
	name = "processor unit"
	icon_state = "processor"
	desc = "This machine is used to process large quantities of information."
	telecomms_type = /obj/machinery/telecomms/processor
	density = TRUE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.01
	circuit = /obj/item/circuitboard/machine/telecomms/processor
	/// Whether this processor is currently compressing the data,
	/// or actually decompressing it. Defaults to `FALSE`.
	var/compressing = FALSE

#define COMPRESSION_AMOUNT_COMPRESSING 100
#define COMPRESSION_AMOUNT_DECOMPRESSING 0

/obj/machinery/telecomms/processor/receive_information(datum/signal/subspace/signal, obj/machinery/telecomms/machine_from)
	if(!is_freq_listening(signal))
		return

	if(compressing)
		signal.data["compression"] = COMPRESSION_AMOUNT_COMPRESSING // We compress the signal even further.
	// Otherwise we just fully decompress it if it was compressed to begin with.
	else if(signal.data["compression"])
		signal.data["compression"] = COMPRESSION_AMOUNT_DECOMPRESSING

	if(istype(machine_from, /obj/machinery/telecomms/bus))
		relay_direct_information(signal, machine_from) // send the signal back to the machine
	else // no bus detected - send the signal to servers instead
		signal.data["slow"] += rand(5, 10) // slow the signal down
		relay_information(signal, signal.server_type)

#undef COMPRESSION_AMOUNT_COMPRESSING
#undef COMPRESSION_AMOUNT_DECOMPRESSING

// Preset Processors

/obj/machinery/telecomms/processor/preset_one
	id = "Processor 1"
	network = "tcommsat"
	autolinkers = list("processor1") // processors are sort of isolated; they don't need backward links

/obj/machinery/telecomms/processor/preset_two
	id = "Processor 2"
	network = "tcommsat"
	autolinkers = list("processor2")

/obj/machinery/telecomms/processor/preset_three
	id = "Processor 3"
	network = "tcommsat"
	autolinkers = list("processor3")

/obj/machinery/telecomms/processor/preset_four
	id = "Processor 4"
	network = "tcommsat"
	autolinkers = list("processor4")

/obj/machinery/telecomms/processor/preset_one/birdstation
	name = "Processor"
