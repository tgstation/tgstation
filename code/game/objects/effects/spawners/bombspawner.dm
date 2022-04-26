/**
 * Spawns a TTV.
 *
 */
/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x"
	/* Gasmixes for tank_one and tank_two of the ttv respectively. 
	 * Populated on /obj/effect/spawner/newbomb/Initialize, depopulated right after by the children procs.
	 */
	var/datum/gas_mixture/first_gasmix
	var/datum/gas_mixture/second_gasmix

/** 
 * The part of code that actually spawns the bomb. Always call the parent's initialize first for subtypes of these.
 *
 * Arguments: 
 * * assembly - An assembly typepath to add to the ttv.
 */
/obj/effect/spawner/newbomb/Initialize(mapload, assembly = null)
	. = ..()
	var/obj/item/transfer_valve/ttv = new(loc)
	ttv.tank_one = new /obj/item/tank/internals/plasma (ttv)
	ttv.tank_two = new /obj/item/tank/internals/oxygen (ttv)
	first_gasmix = ttv.tank_one.return_air()
	second_gasmix = ttv.tank_two.return_air()
	first_gasmix.remove_ratio(1)
	second_gasmix.remove_ratio(1)
	if(ispath(assembly, /obj/item/assembly))
		var/obj/item/assembly/newassembly = new assembly (ttv)
		ttv.attached_device = newassembly
		newassembly.on_attach()
		newassembly.holder = ttv
	ttv.update_appearance()
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/newbomb/proc/calculate_pressure(datum/gas_mixture/gasmix, pressure)
	return pressure * gasmix.volume/(R_IDEAL_GAS_EQUATION*gasmix.temperature)

/obj/effect/spawner/newbomb/plasma

/obj/effect/spawner/newbomb/plasma/Initialize(mapload)
	. = ..()
	if(!first_gasmix || !second_gasmix)
		return

	first_gasmix.temperature = 1413
	second_gasmix.temperature = 141.3

	first_gasmix.assert_gas(/datum/gas/plasma)
	second_gasmix.assert_gas(/datum/gas/oxygen)

	first_gasmix.gases[/datum/gas/plasma][MOLES] = calculate_pressure(first_gasmix, TANK_LEAK_PRESSURE - 1)
	second_gasmix.gases[/datum/gas/oxygen][MOLES] = calculate_pressure(second_gasmix, TANK_LEAK_PRESSURE - 1)

/obj/effect/spawner/newbomb/tritium

/obj/effect/spawner/newbomb/tritium/Initialize(mapload, obj/item/assembly)
	. = ..()
	if(!first_gasmix || !second_gasmix)
		return

	first_gasmix.temperature = 8000
	second_gasmix.temperature = 43

	first_gasmix.assert_gas(/datum/gas/plasma)
	second_gasmix.assert_gas(/datum/gas/oxygen)
	second_gasmix.assert_gas(/datum/gas/tritium)

	first_gasmix.gases[/datum/gas/plasma][MOLES] = calculate_pressure(first_gasmix, TANK_LEAK_PRESSURE - 1)
	second_gasmix.gases[/datum/gas/oxygen][MOLES] = 0.67 * calculate_pressure(second_gasmix, TANK_LEAK_PRESSURE - 1)
	second_gasmix.gases[/datum/gas/tritium][MOLES] = 0.33 * calculate_pressure(second_gasmix, TANK_LEAK_PRESSURE - 1)

/obj/effect/spawner/newbomb/isolated_tritium

/obj/effect/spawner/newbomb/isolated_tritium/Initialize(mapload)
	. = ..()
	if(!first_gasmix || !second_gasmix)
		return

	first_gasmix.temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 1
	second_gasmix.temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 1

	first_gasmix.assert_gas(/datum/gas/hypernoblium)
	first_gasmix.assert_gas(/datum/gas/tritium)
	second_gasmix.assert_gas(/datum/gas/oxygen)
	
	first_gasmix.gases[/datum/gas/hypernoblium][MOLES] = REACTION_OPPRESSION_THRESHOLD - 0.01
	first_gasmix.gases[/datum/gas/tritium][MOLES] = 0.5 * calculate_pressure(first_gasmix, TANK_LEAK_PRESSURE - 1)
	second_gasmix.gases[/datum/gas/oxygen][MOLES] = calculate_pressure(second_gasmix, TANK_LEAK_PRESSURE-1)

/obj/effect/spawner/newbomb/noblium

/obj/effect/spawner/newbomb/noblium/Initialize(mapload)
	. = ..()
	if(!first_gasmix || !second_gasmix)
		return

	first_gasmix.temperature = 2.7
	second_gasmix.temperature = 2.7

	first_gasmix.assert_gas(/datum/gas/nitrogen)
	second_gasmix.assert_gas(/datum/gas/tritium)

	first_gasmix.gases[/datum/gas/nitrogen][MOLES] = calculate_pressure(first_gasmix, TANK_LEAK_PRESSURE - 1)
	second_gasmix.gases[/datum/gas/tritium][MOLES] = calculate_pressure(second_gasmix, TANK_LEAK_PRESSURE - 1)

/obj/effect/spawner/newbomb/pressure

/obj/effect/spawner/newbomb/pressure/Initialize(mapload)
	. = ..()
	if(!first_gasmix || !second_gasmix)
		return

	first_gasmix.temperature = 20000
	second_gasmix.temperature = 2.7

	first_gasmix.assert_gas(/datum/gas/hypernoblium)
	second_gasmix.assert_gas(/datum/gas/tritium)

	first_gasmix.gases[/datum/gas/hypernoblium][MOLES] = calculate_pressure(first_gasmix, TANK_LEAK_PRESSURE - 1)
	second_gasmix.gases[/datum/gas/tritium][MOLES] = calculate_pressure(second_gasmix, TANK_LEAK_PRESSURE - 1)
