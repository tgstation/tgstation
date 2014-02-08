/obj/machinery/telecomms/receiver/preset_left/ministation
	name = "Receiver"
	freq_listening = list()

/obj/machinery/telecomms/bus/preset_one/ministation
	name = "Bus"
	autolinkers = list("processor1", "common")
	freq_listening = list()

/obj/machinery/telecomms/processor/preset_one/ministation
	name = "Processor"

/obj/machinery/telecomms/server/presets/common/ministation/New()
	..()
	freq_listening = list()

/obj/machinery/telecomms/broadcaster/preset_left/ministation
	name = "Broadcaster"
