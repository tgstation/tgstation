/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	var/btemp1 = 1500
	var/btemp2 = 1000	// tank temperatures
	var/assembly_type

/obj/effect/spawner/newbomb/Initialize()
	. = ..()
	var/obj/item/device/transfer_valve/V = new(src.loc)
	var/obj/item/weapon/tank/internals/plasma/full/PT = new(V)
	var/obj/item/weapon/tank/internals/oxygen/OT = new(V)

	PT.air_contents.temperature = btemp1 + T0C
	OT.air_contents.temperature = btemp2 + T0C

	V.tank_one = PT
	V.tank_two = OT
	PT.master = V
	OT.master = V
	
	if(assembly_type)
		var/obj/item/device/assembly/A = new assembly_type(V)
		V.attached_device = A
		A.holder = V
		A.toggle_secure()

	V.update_icon()
	
	qdel(src)

/obj/effect/spawner/newbomb/timer
	assembly_type = /obj/item/device/assembly/timer

/obj/effect/spawner/newbomb/timer/syndicate
	btemp1 = 150
	btemp2 = 20

/obj/effect/spawner/newbomb/proximity
	assembly_type = /obj/item/device/assembly/prox_sensor

/obj/effect/spawner/newbomb/radio
	assembly_type = /obj/item/device/assembly/signaler
	

