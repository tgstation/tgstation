/// ## A bunch of turf subtypes used to really make this ruin work.

/// Define of the specific gas mix we want across all of the turfs.
#define CO2_PRESSURIZED_MIX GAS_O2 + "=22;" + GAS_N2 + "=82;" + GAS_CO2 + "=500;TEMP=T20C"

/turf/open/floor/iron/co2_pressurized
	initial_gas_mix = CO2_PRESSURIZED_MIX

/turf/open/floor/iron/dark/co2_pressurized
	initial_gas_mix = CO2_PRESSURIZED_MIX

/turf/open/floor/iron/dark/corner/co2_pressurized
	initial_gas_mix = CO2_PRESSURIZED_MIX

/turf/open/floor/iron/dark/side/co2_pressurized
	initial_gas_mix = CO2_PRESSURIZED_MIX

/turf/open/floor/plating/co2_pressurized
	initial_gas_mix = CO2_PRESSURIZED_MIX

/turf/open/floor/engine/co2/equalized_with_regular_air // you come up with a better name and we can change this
	initial_gas_mix = CO2_PRESSURIZED_MIX

#undef CO2_PRESSURIZED_MIX
