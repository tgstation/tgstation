/datum/wires/experimentor
	holder_type = /obj/machinery/rnd/experimentor
	proper_name = "E.X.P.E.R.I-MENTOR"
	randomize = TRUE

/datum/wires/experimentor/New(atom/holder)
	wires = list(
		SCANTYPE_POKE,
		SCANTYPE_IRRADIATE,
		SCANTYPE_GAS,
		SCANTYPE_HEAT,
		SCANTYPE_COLD,
		SCANTYPE_OBLITERATE,
		SCANTYPE_DISCOVER,
		WIRE_EJECT,
	)
	return ..()

/datum/wires/experimentor/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/rnd/experimentor/R = holder
	if(R.panel_open)
		return TRUE

/datum/wires/experimentor/on_pulse(wire)
	var/obj/machinery/rnd/experimentor/experimentor = holder
	if(!experimentor.loaded_item)
		return

	if(wire == WIRE_EJECT)
		experimentor.item_eject()
	else
		experimentor.try_perform_experiment(wire)
