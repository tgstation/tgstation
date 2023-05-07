/datum/wires/modular_shield_gen
	proper_name = "Modular shield generator"
	randomize = FALSE
	holder_type = /obj/machinery/modular_shield_gen

/datum/wires/modular_shield_gen/New(atom/holder)
	wires = list(WIRE_HACK)
	..()

/datum/wires/modular_shield_gen/on_pulse(wire)

	var/obj/machinery/modular_shield_gen/G = holder
	switch(wire)
		if(WIRE_HACK)
			G.toggle_shields()
			return
	..()
