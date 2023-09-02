/datum/wires/ecto_sniffer
	proper_name = "Ectoscopic Sniffer"
	randomize = TRUE //Only one wire don't need blueprints
	holder_type = /obj/machinery/ecto_sniffer

/datum/wires/ecto_sniffer/New(atom/holder)
	wires = list(WIRE_ACTIVATE)
	..()

/datum/wires/ecto_sniffer/on_pulse(wire)
	var/obj/machinery/ecto_sniffer/our_sniffer = holder
	our_sniffer.activate()
	..()

/datum/wires/ecto_sniffer/on_cut(wire, mend, source)
	var/obj/machinery/ecto_sniffer/our_sniffer = holder
	our_sniffer.sensor_enabled = mend
