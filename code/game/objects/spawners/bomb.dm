/obj/spawner/bomb/New()
	..()

	switch (src.btype)
		// radio
		if (0)
			var/obj/item/assembly/r_i_ptank/R = new /obj/item/assembly/r_i_ptank(src.loc)
			var/obj/item/weapon/tank/plasma/p3 = new /obj/item/weapon/tank/plasma(R)
			var/obj/item/device/radio/signaler/p1 = new /obj/item/device/radio/signaler(R)
			var/obj/item/device/igniter/p2 = new /obj/item/device/igniter(R)
			R.part1 = p1
			R.part2 = p2
			R.part3 = p3
			p1.master = R
			p2.master = R
			p3.master = R
			R.status = explosive
			p1.b_stat = 0
			p2.status = 1
			p3.air_contents.temperature = btemp + T0C

		// proximity
		if (1)
			var/obj/item/assembly/m_i_ptank/R = new /obj/item/assembly/m_i_ptank(src.loc)
			var/obj/item/weapon/tank/plasma/p3 = new /obj/item/weapon/tank/plasma(R)
			var/obj/item/device/prox_sensor/p1 = new /obj/item/device/prox_sensor(R)
			var/obj/item/device/igniter/p2 = new /obj/item/device/igniter(R)
			R.part1 = p1
			R.part2 = p2
			R.part3 = p3
			p1.master = R
			p2.master = R
			p3.master = R
			R.status = explosive

			p3.air_contents.temperature = btemp +T0C
			p2.status = 1

			if(src.active)
				R.part1.state = 1
				R.part1.icon_state = text("motion[]", 1)
				R.c_state(1, src)

		// timer
		if (2)
			var/obj/item/assembly/t_i_ptank/R = new /obj/item/assembly/t_i_ptank(src.loc)
			var/obj/item/weapon/tank/plasma/p3 = new /obj/item/weapon/tank/plasma(R)
			var/obj/item/device/timer/p1 = new /obj/item/device/timer(R)
			var/obj/item/device/igniter/p2 = new /obj/item/device/igniter(R)
			R.part1 = p1
			R.part2 = p2
			R.part3 = p3
			p1.master = R
			p2.master = R
			p3.master = R
			R.status = explosive

			p3.air_contents.temperature = btemp +T0C
			p2.status = 1
		//bombvest
		if(3)
			var/obj/item/clothing/suit/armor/a_i_a_ptank/R = new /obj/item/clothing/suit/armor/a_i_a_ptank(src.loc)
			var/obj/item/weapon/tank/plasma/p4 = new /obj/item/weapon/tank/plasma(R)
			var/obj/item/device/healthanalyzer/p1 = new /obj/item/device/healthanalyzer(R)
			var/obj/item/device/igniter/p2 = new /obj/item/device/igniter(R)
			var/obj/item/clothing/suit/armor/vest/p3 = new /obj/item/clothing/suit/armor/vest(R)
			R.part1 = p1
			R.part2 = p2
			R.part3 = p3
			R.part4 = p4
			p1.master = R
			p2.master = R
			p3.master = R
			p4.master = R
			R.status = explosive

			p4.air_contents.temperature = btemp +T0C
			p2.status = 1

	del(src)