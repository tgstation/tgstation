/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x"
	var/temp_p = 1500
	var/temp_o = 1000	// tank temperatures
	var/pressure_p = 10 * ONE_ATMOSPHERE
	var/assembly_type

/obj/effect/spawner/newbomb/Initialize()
	. = ..()
	var/obj/item/transfer_valve/V = new(src.loc)
	var/obj/item/tank/internals/plasma/PT = new(V)

	PT.air_contents.assert_gas(/datum/gas/tritium)
	PT.air_contents.assert_gas(/datum/gas/oxygen)
	PT.air_contents.temperature = T20C
	PT.air_contents.gases[/datum/gas/tritium][MOLES] = 2
	PT.air_contents.gases[/datum/gas/oxygen][MOLES] = 3
	
	V.payload = PT
	PT.master = V

	if(assembly_type)
		var/obj/item/assembly/A = new assembly_type(V)
		V.attached_device = A
		A.holder = V

	V.update_icon()

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/newbomb/timer/syndicate/Initialize()
	. = ..()

/obj/effect/spawner/newbomb/timer
	assembly_type = /obj/item/assembly/timer

/obj/effect/spawner/newbomb/proximity
	assembly_type = /obj/item/assembly/prox_sensor

/obj/effect/spawner/newbomb/radio
	assembly_type = /obj/item/assembly/signaler
