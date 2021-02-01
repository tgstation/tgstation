#define CELSIUS_TO_KELVIN(T_K)	((T_K) + T0C)

#define OPTIMAL_TEMP_K_PLA_BURN_SCALE(PRESSURE_P,PRESSURE_O,TEMP_O)	(((PRESSURE_P) * GLOB.meta_gas_info[/datum/gas/plasma][META_GAS_SPECIFIC_HEAT]) / (((PRESSURE_P) * GLOB.meta_gas_info[/datum/gas/plasma][META_GAS_SPECIFIC_HEAT] + (PRESSURE_O) * GLOB.meta_gas_info[/datum/gas/oxygen][META_GAS_SPECIFIC_HEAT]) / PLASMA_UPPER_TEMPERATURE - (PRESSURE_O) * GLOB.meta_gas_info[/datum/gas/oxygen][META_GAS_SPECIFIC_HEAT] / CELSIUS_TO_KELVIN(TEMP_O)))
#define OPTIMAL_TEMP_K_PLA_BURN_RATIO(PRESSURE_P,PRESSURE_O,TEMP_O)	(CELSIUS_TO_KELVIN(TEMP_O) * PLASMA_OXYGEN_FULLBURN * (PRESSURE_P) / (PRESSURE_O))

/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x"
	/// The initial temperature of the plasma tank.
	var/temp_p = 1500
	/// The initial temperature of the oxygen tank.
	var/temp_o = 1000
	/// The initial pressure of the plasma tank.
	var/pressure_p = 10 * ONE_ATMOSPHERE
	/// The initial pressure of the oxygen tank.
	var/pressure_o = 10 * ONE_ATMOSPHERE
	/// The typepath of the assembly to attach to the TTV.
	var/assembly_type

/obj/effect/spawner/newbomb/Initialize()
	. = ..()
	var/obj/item/transfer_valve/ttv = new(loc)
	var/obj/item/tank/internals/plasma/plasma_tank = new(ttv)
	var/obj/item/tank/internals/oxygen/oxygen_tank = new(ttv)

	var/datum/gas_mixture/plasma_mix = plasma_tank.air_contents
	plasma_mix.assert_gas(/datum/gas/plasma)
	plasma_mix.gases[/datum/gas/plasma][MOLES] = pressure_p*plasma_mix.volume/(R_IDEAL_GAS_EQUATION*CELSIUS_TO_KELVIN(temp_p))
	plasma_mix.temperature = CELSIUS_TO_KELVIN(temp_p)

	var/datum/gas_mixture/oxygen_mix = oxygen_tank.air_contents
	oxygen_mix.assert_gas(/datum/gas/oxygen)
	oxygen_mix.gases[/datum/gas/oxygen][MOLES] = pressure_o*oxygen_mix.volume/(R_IDEAL_GAS_EQUATION*CELSIUS_TO_KELVIN(temp_o))
	oxygen_mix.temperature = CELSIUS_TO_KELVIN(temp_o)

	ttv.tank_one = plasma_tank
	ttv.tank_two = oxygen_tank
	plasma_tank.master = ttv
	oxygen_tank.master = ttv

	if(assembly_type)
		var/obj/item/assembly/detonator = new assembly_type(ttv)
		ttv.attached_device = detonator
		detonator.holder = ttv

	ttv.update_icon()

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/newbomb/timer
	assembly_type = /obj/item/assembly/timer

/obj/effect/spawner/newbomb/timer/syndicate
	pressure_p = TANK_LEAK_PRESSURE - 1
	pressure_o = TANK_LEAK_PRESSURE - 1
	temp_o = 20

/obj/effect/spawner/newbomb/timer/syndicate/Initialize()
	temp_p = (OPTIMAL_TEMP_K_PLA_BURN_SCALE(pressure_p, pressure_o, temp_o)/2 + OPTIMAL_TEMP_K_PLA_BURN_RATIO(pressure_p, pressure_o, temp_o)/2) - T0C
	return ..()

/obj/effect/spawner/newbomb/proximity
	assembly_type = /obj/item/assembly/prox_sensor

/obj/effect/spawner/newbomb/radio
	assembly_type = /obj/item/assembly/signaler


#undef CELSIUS_TO_KELVIN
#undef OPTIMAL_TEMP_K_PLA_BURN_SCALE
#undef OPTIMAL_TEMP_K_PLA_BURN_RATIO
