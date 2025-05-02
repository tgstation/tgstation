///List of all the gases, used in labelling the canisters
GLOBAL_LIST_INIT(gas_id_to_canister, init_gas_id_to_canister())

///Returns a map of canister id to its type path
/proc/init_gas_id_to_canister()
	return sort_list(list(
		GAS_N2 = /obj/machinery/portable_atmospherics/canister/nitrogen,
		GAS_O2 = /obj/machinery/portable_atmospherics/canister/oxygen,
		GAS_CO2 = /obj/machinery/portable_atmospherics/canister/carbon_dioxide,
		GAS_PLASMA = /obj/machinery/portable_atmospherics/canister/plasma,
		GAS_N2O = /obj/machinery/portable_atmospherics/canister/nitrous_oxide,
		GAS_NITRIUM = /obj/machinery/portable_atmospherics/canister/nitrium,
		GAS_BZ = /obj/machinery/portable_atmospherics/canister/bz,
		GAS_AIR = /obj/machinery/portable_atmospherics/canister/air,
		GAS_WATER_VAPOR = /obj/machinery/portable_atmospherics/canister/water_vapor,
		GAS_TRITIUM = /obj/machinery/portable_atmospherics/canister/tritium,
		GAS_HYPER_NOBLIUM = /obj/machinery/portable_atmospherics/canister/nob,
		GAS_PLUOXIUM = /obj/machinery/portable_atmospherics/canister/pluoxium,
		"caution" = /obj/machinery/portable_atmospherics/canister,
		GAS_MIASMA = /obj/machinery/portable_atmospherics/canister/miasma,
		GAS_FREON = /obj/machinery/portable_atmospherics/canister/freon,
		GAS_HYDROGEN = /obj/machinery/portable_atmospherics/canister/hydrogen,
		GAS_HEALIUM = /obj/machinery/portable_atmospherics/canister/healium,
		GAS_PROTO_NITRATE = /obj/machinery/portable_atmospherics/canister/proto_nitrate,
		GAS_ZAUKER = /obj/machinery/portable_atmospherics/canister/zauker,
		GAS_HELIUM = /obj/machinery/portable_atmospherics/canister/helium,
		GAS_ANTINOBLIUM = /obj/machinery/portable_atmospherics/canister/antinoblium,
		GAS_HALON = /obj/machinery/portable_atmospherics/canister/halon,
	))
