//DO NOT USE THESE FOR ACCESSING ATMOS DATA, THEY MUTATE THINGS WHEN CALLED. I WILL BEAT YOU WITH A STICK. See the actual proc for more details
///Check if an atom (A) and a turf (O) allow gas passage based on the atom's can_atmos_pass var, do not use.
///(V) is if the share is vertical or not. True or False
#define CANATMOSPASS(A, O, V) ( A.can_atmos_pass == ATMOS_PASS_PROC ? A.can_atmos_pass(O, V) : ( A.can_atmos_pass == ATMOS_PASS_DENSITY ? !A.density : A.can_atmos_pass ) )

//Helpers
///Moves the icon of the device based on the piping layer and on the direction
#define PIPING_LAYER_SHIFT(T, PipingLayer) \
	if(T.layer > -1) { \
		if(T.dir & (NORTH|SOUTH)) { \
			T.pixel_x = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X;\
		} \
		if(T.dir & (EAST|WEST)) { \
			T.pixel_y = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y;\
		} \
	} else { \
		if(T.dir & (NORTH|SOUTH)) { \
			T.pixel_w = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X;\
		} \
		if(T.dir & (EAST|WEST)) { \
			T.pixel_z = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y;\
		} \
	}

///Moves the icon of the device based on the piping layer and on the direction, the shift amount is dictated by more_shift
#define PIPING_FORWARD_SHIFT(T, PipingLayer, more_shift) \
	if(T.layer > -1) { \
		if(T.dir & (NORTH|SOUTH)) { \
			T.pixel_y += more_shift * (PipingLayer - PIPING_LAYER_DEFAULT);\
		} \
		if(T.dir & (EAST|WEST)) { \
			T.pixel_x += more_shift * (PipingLayer - PIPING_LAYER_DEFAULT);\
		} \
	} else { \
		if(T.dir & (NORTH|SOUTH)) { \
			T.pixel_z += more_shift * (PipingLayer - PIPING_LAYER_DEFAULT);\
		} \
		if(T.dir & (EAST|WEST)) { \
			T.pixel_w += more_shift * (PipingLayer - PIPING_LAYER_DEFAULT);\
		} \
	}

///Moves the icon of the device based on the piping layer on both x and y
#define PIPING_LAYER_DOUBLE_SHIFT(T, PipingLayer) \
	if(T.layer > -1) { \
		T.pixel_x = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X;\
		T.pixel_y = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y; \
	} else { \
		T.pixel_w = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X;\
		T.pixel_z = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y; \
	}

///Calculate the thermal energy of the selected gas (J)
#define THERMAL_ENERGY(gas) (gas.temperature * gas.heat_capacity())

///Directly adds a gas to a gas mixture without checking for its presence beforehand, use only if is certain the absence of said gas
#define ADD_GAS(gas_id, out_list)\
	var/list/tmp_gaslist = GLOB.gaslist_cache[gas_id]; out_list[gas_id] = tmp_gaslist.Copy();

///Adds a gas to a gas mixture but checks if is already present, faster than the same proc
#define ASSERT_GAS(gas_id, gas_mixture) ASSERT_GAS_IN_LIST(gas_id, gas_mixture.gases)

///Adds a gas to a gas LIST but checks if is already present, accepts a list instead of a datum, so faster if the list is locally cached
#define ASSERT_GAS_IN_LIST(gas_id, gases) if (!gases[gas_id]) { ADD_GAS(gas_id, gases) };

//prefer this to gas_mixture/total_moles in performance critical areas
///Calculate the total moles of the gas mixture, faster than the proc, good for performance critical areas
#define TOTAL_MOLES(cached_gases, out_var)\
	out_var = 0;\
	for(var/total_moles_id in cached_gases){\
		out_var += cached_gases[total_moles_id][MOLES];\
	}

GLOBAL_LIST_INIT(nonoverlaying_gases, typecache_of_gases_with_no_overlays())
///Returns a list of overlays of every gas in the mixture
#define GAS_OVERLAYS(gases, out_var, z_layer_turf)\
	do { \
		out_var = list();\
		var/offset = GET_TURF_PLANE_OFFSET(z_layer_turf) + 1;\
		for(var/_ID in gases){\
			if(GLOB.nonoverlaying_gases[_ID]) continue;\
			var/_GAS = gases[_ID];\
			var/_GAS_META = _GAS[GAS_META];\
			if(_GAS[MOLES] <= _GAS_META[META_GAS_MOLES_VISIBLE]) continue;\
			var/_GAS_OVERLAY = _GAS_META[META_GAS_OVERLAY][offset];\
			out_var += _GAS_OVERLAY[min(TOTAL_VISIBLE_STATES, CEILING(_GAS[MOLES] / MOLES_GAS_VISIBLE_STEP, 1))];\
		} \
	}\
	while (FALSE)

#ifdef TESTING
GLOBAL_LIST_INIT(atmos_adjacent_savings, list(0,0))
#define CALCULATE_ADJACENT_TURFS(T, state) if (SSair.adjacent_rebuild[T]) { GLOB.atmos_adjacent_savings[1] += 1 } else { GLOB.atmos_adjacent_savings[2] += 1; SSair.adjacent_rebuild[T] = state}
#else
#define CALCULATE_ADJACENT_TURFS(T, state) SSair.adjacent_rebuild[T] = state
#endif

//If you're doing spreading things related to atmos, DO NOT USE CANATMOSPASS, IT IS NOT CHEAP. use this instead, the info is cached after all. it's tweaked just a bit to allow for circular checks
#define TURFS_CAN_SHARE(T1, T2) (LAZYACCESS(T2.atmos_adjacent_turfs, T1) || LAZYLEN(T1.atmos_adjacent_turfs & T2.atmos_adjacent_turfs))
//Use this to see if a turf is fully blocked or not, think windows or firelocks. Fails with 1x1 non full tile windows, but it's not worth the cost.
#define TURF_SHARES(T) (LAZYLEN(T.atmos_adjacent_turfs))

#define LINDA_CYCLE_ARCHIVE(turf)\
	turf.air.archive();\
	turf.archived_cycle = SSair.times_fired;\
	turf.temperature_archived = turf.temperature;

/* Fetch the energy transferred when two gas mixtures' temperature equalize.
 *
 * To equalize two gas mixtures, we simply pool the energy and divide it by the pooled heat capacity.
 * T' = (W1+W2) / (C1+C2)
 * But if we want to moderate this conduction, maybe we can calculate the energy transferred
 * and multiply a coefficient to it instead.
 * This is the energy transferred:
 * W = T' * C1 - W1
 * W = (W1+W2) / (C1+C2) * C1 - W1
 * W = (W1C1 + W2C1) / (C1+C2) - W1
 * W = ((W1C1 + W2C1) - (W1 * (C1+C2))) / (C1+C2)
 * W = ((W1C1 + W2C1) - (W1C1 + W1C2)) / (C1+C2)
 * W = (W1C1 - W1C1 + W2C1 - W1C2) / (C1+C2)
 * W = (W2C1 - W1C2) / (C1+C2)
 * W = (T2*C2*C1 - T1*C1*C2) / (C1+C2)
 * W = (C1*C2) * (T2-T1) / (C1+C2)
 *
 * W: Energy involved in the operation
 * T': Combined temperature
 * T1, C1, W1: Temp, heat cap, and thermal energy of the first gas mixture
 * T2, C2, W2: Temp, heat cap, and thermal energy of the second gas mixture
 *
 * Not immediately obvious, but saves us operation time.
 *
 * We put a lot of parentheses here because the numbers get really really big.
 * By prioritizing the division we try to tone the number down so we don't get overflows.
 *
 * Arguments:
 * * temperature_delta: T2 - T1. [/datum/gas_mixture/var/temperature]
 * If you have any moderating (less than 1) coefficients and are dealing with very big numbers
 * multiply the temperature_delta by it first before passing so we get even more breathing room.
 * * heat_capacity_one:  gasmix one's [/datum/gas_mixture/proc/heat_capacity]
 * * heat_capacity_two: gasmix two's [/datum/gas_mixture/proc/heat_capacity]
 * Returns: The energy gained by gas mixture one. Negative if gas mixture one loses energy.
 * Honestly the heat capacity is interchangeable, just make sure the delta is right.
 */
#define CALCULATE_CONDUCTION_ENERGY(temperature_delta, heat_capacity_one, heat_capacity_two)\
	((temperature_delta) * ((heat_capacity_one) * ((heat_capacity_two) / ((heat_capacity_one) + (heat_capacity_two)))))
