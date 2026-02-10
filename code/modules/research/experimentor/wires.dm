#define WIRE_POKE "poke"
#define WIRE_IRRADIATE "irradiate"
#define WIRE_GAS "gas"
#define WIRE_HEAT "heat"
#define WIRE_COLD "cold"
#define WIRE_OBLITERATE "obliterate"
#define WIRE_DISCOVER "discover"
#define WIRE_EJECT "eject"

#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6
#define SCANTYPE_DISCOVER 7

/datum/wires/rnd/experimentor
	holder_type = /obj/machinery/rnd/experimentor
	wire_count = 8
	proper_name = "E.X.P.E.R.I-MENTOR"

/datum/wires/rnd/New(atom/holder)
	wires = list(
		WIRE_POKE,
		WIRE_IRRADIATE,
		WIRE_GAS,
		WIRE_HEAT,
		WIRE_COLD,
		WIRE_OBLITERATE,
		WIRE_DISCOVER,
		WIRE_EJECT
	)
	return ..()

/datum/wires/rnd/experimentor/on_pulse(wire)
	var/obj/machinery/rnd/experimentor/experimentor = holder
	if(!experimentor.loaded_item)
		return

	switch(wire)
		if(WIRE_POKE)
			experimentor.run_experiment(SCANTYPE_POKE)
		if(WIRE_IRRADIATE)
			experimentor.run_experiment(SCANTYPE_IRRADIATE)
		if(WIRE_GAS)
			experimentor.run_experiment(SCANTYPE_GAS)
		if(WIRE_HEAT)
			experimentor.run_experiment(SCANTYPE_HEAT)
		if(WIRE_COLD)
			experimentor.run_experiment(SCANTYPE_COLD)
		if(WIRE_OBLITERATE)
			experimentor.run_experiment(SCANTYPE_OBLITERATE)
		if(WIRE_DISCOVER)
			experimentor.run_experiment(SCANTYPE_DISCOVER)
		if(WIRE_EJECT)
			experimentor.item_eject()

#undef WIRE_POKE
#undef WIRE_IRRADIATE
#undef WIRE_GAS
#undef WIRE_HEAT
#undef WIRE_COLD
#undef WIRE_OBLITERATE
#undef WIRE_DISCOVER
#undef WIRE_EJECT

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER
