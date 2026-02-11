#define SCANTYPE_POKE "Poke"
#define SCANTYPE_IRRADIATE "Irradiate"
#define SCANTYPE_GAS "Gas"
#define SCANTYPE_HEAT "Heat"
#define SCANTYPE_COLD "Freeze"
#define SCANTYPE_OBLITERATE "Obliterate"
#define SCANTYPE_DISCOVER "Discover"

#define WIRE_EJECT "Eject"

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
		WIRE_EJECT
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

#undef WIRE_EJECT

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER
