//preset comms, taken from MiniStation

/obj/machinery/telecomms/receiver/preset_left/birdstation
	name = "Receiver"
	freq_listening = list()

/obj/machinery/telecomms/bus/preset_one/birdstation
	name = "Bus"
	autolinkers = list("processor1", "common")
	freq_listening = list()

/obj/machinery/telecomms/processor/preset_one/birdstation
	name = "Processor"

/obj/machinery/telecomms/server/presets/common/birdstation/New()
	..()
	freq_listening = list()

/obj/machinery/telecomms/broadcaster/preset_left/birdstation
	name = "Broadcaster"
