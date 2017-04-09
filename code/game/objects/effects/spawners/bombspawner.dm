/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	var/btemp1 = 1500
	var/btemp2 = 1000	// tank temperatures

/obj/effect/spawner/newbomb/Initialize()
	..()
	var/obj/item/device/transfer_valve/V = new(src.loc)
	var/obj/item/weapon/tank/internals/plasma/full/PT = new(V)
	var/obj/item/weapon/tank/internals/oxygen/OT = new(V)

	PT.air_contents.temperature = btemp1 + T0C
	OT.air_contents.temperature = btemp2 + T0C

	V.tank_one = PT
	V.tank_two = OT
	PT.master = V
	OT.master = V
	
	setup_assembly(V)

	V.update_icon()
	
	qdel(src)

/obj/effect/spawner/newbomb/proc/setup_assembly(obj/item/device/transfer_valve/V)
	return

/obj/effect/spawner/newbomb/timer

/obj/effect/spawner/newbomb/timer/setup_assembly(obj/item/device/transfer_valve/V)
	var/obj/item/device/assembly/timer/T = new(V)
	V.attached_device = T
	T.holder = V
	T.toggle_secure()
	T.time = 30

/obj/effect/spawner/newbomb/timer/syndicate
	btemp1 = 150
	btemp2 = 20

/obj/effect/spawner/newbomb/proximity

/obj/effect/spawner/newbomb/proximity/setup_assembly(obj/item/device/transfer_valve/V)
	var/obj/item/device/assembly/signaler/S = new(V)
	V.attached_device = S
	S.holder = V
	S.toggle_secure()

/obj/effect/spawner/newbomb/radio

/obj/effect/spawner/newbomb/radio/setup_assembly(obj/item/device/transfer_valve/V)
	var/obj/item/device/assembly/prox_sensor/P = new(V)
	V.attached_device = P
	P.holder = V
	P.toggle_secure()