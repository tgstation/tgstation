#define CELSIUS_TO_KELVIN(T_K)	((T_K) + T0C)

#define OPTIMAL_TEMP_K_PLA_BURN_SCALE(PRESSURE_P,PRESSURE_O,TEMP_O)	(((PRESSURE_P) * GLOB.meta_gas_info[/datum/gas/plasma][META_GAS_SPECIFIC_HEAT]) / (((PRESSURE_P) * GLOB.meta_gas_info[/datum/gas/plasma][META_GAS_SPECIFIC_HEAT] + (PRESSURE_O) * GLOB.meta_gas_info[/datum/gas/oxygen][META_GAS_SPECIFIC_HEAT]) / PLASMA_UPPER_TEMPERATURE - (PRESSURE_O) * GLOB.meta_gas_info[/datum/gas/oxygen][META_GAS_SPECIFIC_HEAT] / CELSIUS_TO_KELVIN(TEMP_O)))
#define OPTIMAL_TEMP_K_PLA_BURN_RATIO(PRESSURE_P,PRESSURE_O,TEMP_O)	(CELSIUS_TO_KELVIN(TEMP_O) * PLASMA_OXYGEN_FULLBURN * (PRESSURE_P) / (PRESSURE_O))

/atom/movable/spawner/newbomb
	name = "bomb"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x"
	var/temp_p = 1500
	var/temp_o = 1000	// tank temperatures
	var/pressure_p = 10 * ONE_ATMOSPHERE
	var/pressure_o = 10 * ONE_ATMOSPHERE	//tank pressures
	var/assembly_type

/atom/movable/spawner/newbomb/Initialize()
	. = ..()
	var/obj/item/transfer_valve/V = new(src.loc)
	var/obj/item/tank/internals/plasma/PT = new(V)
	var/obj/item/tank/internals/oxygen/OT = new(V)

	PT.air_contents.assert_gas(/datum/gas/plasma)
	PT.air_contents.gases[/datum/gas/plasma][MOLES] = pressure_p*PT.volume/(R_IDEAL_GAS_EQUATION*CELSIUS_TO_KELVIN(temp_p))
	PT.air_contents.temperature = CELSIUS_TO_KELVIN(temp_p)

	OT.air_contents.assert_gas(/datum/gas/oxygen)
	OT.air_contents.gases[/datum/gas/oxygen][MOLES] = pressure_o*OT.volume/(R_IDEAL_GAS_EQUATION*CELSIUS_TO_KELVIN(temp_o))
	OT.air_contents.temperature = CELSIUS_TO_KELVIN(temp_o)

	V.tank_one = PT
	V.tank_two = OT
	PT.master = V
	OT.master = V

	if(assembly_type)
		var/obj/item/assembly/A = new assembly_type(V)
		V.attached_device = A
		A.holder = V

	V.update_icon()

	return INITIALIZE_HINT_QDEL

/atom/movable/spawner/newbomb/timer/syndicate/Initialize()
	temp_p = (OPTIMAL_TEMP_K_PLA_BURN_SCALE(pressure_p, pressure_o, temp_o)/2 + OPTIMAL_TEMP_K_PLA_BURN_RATIO(pressure_p, pressure_o, temp_o)/2) - T0C
	. = ..()

/atom/movable/spawner/newbomb/timer
	assembly_type = /obj/item/assembly/timer

/atom/movable/spawner/newbomb/timer/syndicate
	pressure_o = TANK_LEAK_PRESSURE - 1
	temp_o = 20

	pressure_p = TANK_LEAK_PRESSURE - 1

/atom/movable/spawner/newbomb/proximity
	assembly_type = /obj/item/assembly/prox_sensor

/atom/movable/spawner/newbomb/radio
	assembly_type = /obj/item/assembly/signaler


#undef CELSIUS_TO_KELVIN

#undef OPTIMAL_TEMP_K_PLA_BURN_SCALE
#undef OPTIMAL_TEMP_K_PLA_BURN_RATIO
