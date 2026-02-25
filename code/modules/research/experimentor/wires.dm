/datum/wires/rnd/experimentor
	holder_type = /obj/machinery/rnd/experimentor
	proper_name = "E.X.P.E.R.I-MENTOR"

/datum/wires/rnd/New(atom/holder)
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

/datum/wires/rnd/experimentor/on_pulse(wire)
	var/obj/machinery/rnd/experimentor/experimentor = holder
	if(!experimentor.loaded_item)
		return

	if(wire == WIRE_EJECT)
		experimentor.item_eject()
	else
		experimentor.run_experiment(wire)
