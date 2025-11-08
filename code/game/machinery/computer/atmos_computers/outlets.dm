/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored
	on = TRUE
	icon_state = "vent_map_siphon_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/Initialize(mapload)
	. = ..()
	//we dont want people messing with these special vents using the air alarm interface
	disconnect_from_area()

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/plasma_output
	name = "plasma tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/oxygen_output
	name = "oxygen tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/nitrogen_output
	name = "nitrogen tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/mix_output
	name = "mix tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/nitrous_output
	name = "nitrous oxide tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/carbon_output
	name = "carbon dioxide tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/bz_output
	name = "bz tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/freon_output
	name = "freon tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/halon_output
	name = "halon tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/healium_output
	name = "healium tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/hydrogen_output
	name = "hydrogen tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/hypernoblium_output
	name = "hypernoblium tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/miasma_output
	name = "miasma tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/nitrium_output
	name = "nitrium tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/pluoxium_output
	name = "pluoxium tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/proto_nitrate_output
	name = "proto-nitrate tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/tritium_output
	name = "tritium tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/water_vapor_output
	name = "water vapor tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/zauker_output
	name = "zauker tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/helium_output
	name = "helium tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/antinoblium_output
	name = "antinoblium tank output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/incinerator_output
	name = "incinerator chamber output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/ordnance_burn_chamber_output
	name = "ordnance burn chamber output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/ordnance_freezer_chamber_output
	name = "ordnance freezer chamber output inlet"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/monitored
	on = TRUE
	icon_state = "vent_map_siphon_on-3"

// Same as the rest, but bigger volume.
/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/monitored/Initialize(mapload)
	. = ..()
	//we dont want people messing with these special vents using the air alarm interface
	disconnect_from_area()

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/monitored/air_output
	name = "air mix tank output inlet"
