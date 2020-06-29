/datum/wires/conveyor
	holder_type = /obj/machinery/conveyor_switch
	proper_name = "conveyor"
	var/mob/fingerman

/datum/wires/conveyor/New(atom/holder)
	add_duds(1)
	..()

/datum/wires/conveyor/on_pulse(wire)
	var/obj/machinery/conveyor_switch/C = holder
	C.interact(fingerman)

/datum/wires/conveyor/interactable(mob/user)
	fingerman = user
	return TRUE

