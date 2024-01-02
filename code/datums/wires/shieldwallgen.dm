/datum/wires/shieldwallgen
	proper_name = "Shield Wall Generator"
	randomize = TRUE
	holder_type = /obj/machinery/power/shieldwallgen

/datum/wires/shieldwallgen/New(atom/holder)
	wires = list(WIRE_ACTIVATE)
	..()

/datum/wires/shieldwallgen/on_pulse(wire)
	var/obj/machinery/power/shieldwallgen/generator = holder
	if(generator.anchored && generator.powernet)
		generator.active = generator.active ? FALSE : TRUE //shield gens use some silly defines here but its usually just a true or false
	..()
