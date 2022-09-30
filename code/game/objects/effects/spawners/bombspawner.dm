/**
 * Spawns a TTV.
 *
 */
/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x"
	/// The initial temperature of the plasma tank.
	var/temp_p = 1413
	/// The initial temperature of the oxygen tank.
	var/temp_o = 141.3
	/// The initial pressure of the plasma tank.
	var/pressure_p = TANK_LEAK_PRESSURE - 1
	/// The initial pressure of the oxygen tank.
	var/pressure_o = TANK_LEAK_PRESSURE - 1
	/// The typepath of the assembly to attach to the TTV.
	var/assembly_type

/obj/effect/spawner/newbomb/Initialize(mapload)
	. = ..()
	var/obj/item/transfer_valve/ttv = new(loc)
	var/obj/item/tank/internals/plasma/plasma_tank = new(ttv)
	var/obj/item/tank/internals/oxygen/oxygen_tank = new(ttv)

	var/datum/gas_mixture/plasma_mix = plasma_tank.return_air()
	plasma_mix.assert_gas(/datum/gas/plasma)
	plasma_mix.gases[/datum/gas/plasma][MOLES] = pressure_p*plasma_mix.volume/(R_IDEAL_GAS_EQUATION*temp_p)
	plasma_mix.temperature = temp_p

	var/datum/gas_mixture/oxygen_mix = oxygen_tank.return_air()
	oxygen_mix.assert_gas(/datum/gas/oxygen)
	oxygen_mix.gases[/datum/gas/oxygen][MOLES] = pressure_o*oxygen_mix.volume/(R_IDEAL_GAS_EQUATION*temp_o)
	oxygen_mix.temperature = temp_o

	ttv.tank_one = plasma_tank
	ttv.tank_two = oxygen_tank
	plasma_tank.master = ttv
	oxygen_tank.master = ttv

	if(assembly_type)
		var/obj/item/assembly/detonator = new assembly_type(ttv)
		ttv.attached_device = detonator
		detonator.holder = ttv

	ttv.update_appearance()

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/newbomb/timer
	assembly_type = /obj/item/assembly/timer

/obj/effect/spawner/newbomb/proximity
	assembly_type = /obj/item/assembly/prox_sensor

/obj/effect/spawner/newbomb/radio
	assembly_type = /obj/item/assembly/signaler
