/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	var/btype = 0 // 0=radio, 1=prox, 2=time
	var/btemp1 = 1500
	var/btemp2 = 1000	// tank temperatures

/obj/effect/spawner/newbomb/timer
	btype = 2

	syndicate
		btemp1 = 150
		btemp2 = 20

/obj/effect/spawner/newbomb/proximity
	btype = 1

/obj/effect/spawner/newbomb/radio
	btype = 0


/obj/effect/spawner/newbomb/New()
	..()

	switch (src.btype)
		// radio
		if (0)

			var/obj/item/device/transfer_valve/V = new(src.loc)
			var/obj/item/weapon/tank/internals/plasma/PT = new(V)
			var/obj/item/weapon/tank/internals/oxygen/OT = new(V)

			var/obj/item/device/assembly/signaler/S = new(V)

			V.tank_one = PT
			V.tank_two = OT
			V.attached_device = S

			S.holder = V
			S.toggle_secure()
			PT.master = V
			OT.master = V

			PT.air_contents.temperature = btemp1 + T0C
			OT.air_contents.temperature = btemp2 + T0C

			V.update_icon()

		// proximity
		if (1)

			var/obj/item/device/transfer_valve/V = new(src.loc)
			var/obj/item/weapon/tank/internals/plasma/PT = new(V)
			var/obj/item/weapon/tank/internals/oxygen/OT = new(V)

			var/obj/item/device/assembly/prox_sensor/P = new(V)

			V.tank_one = PT
			V.tank_two = OT
			V.attached_device = P

			P.holder = V
			P.toggle_secure()
			PT.master = V
			OT.master = V


			PT.air_contents.temperature = btemp1 + T0C
			OT.air_contents.temperature = btemp2 + T0C

			V.update_icon()


		// timer
		if (2)
			var/obj/item/device/transfer_valve/V = new(src.loc)
			var/obj/item/weapon/tank/internals/plasma/PT = new(V)
			var/obj/item/weapon/tank/internals/oxygen/OT = new(V)

			var/obj/item/device/assembly/timer/T = new(V)

			V.tank_one = PT
			V.tank_two = OT
			V.attached_device = T

			T.holder = V
			T.toggle_secure()
			PT.master = V
			OT.master = V
			T.time = 30

			PT.air_contents.temperature = btemp1 + T0C
			OT.air_contents.temperature = btemp2 + T0C

			V.update_icon()
	qdel(src)