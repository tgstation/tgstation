/obj/machinery/robotic_fabricator
	name = "Robotic Fabricator"
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	density = 1
	anchored = 1
	var/metal_amount = 0
	var/operating = 0
	var/obj/item/robot_parts/being_built = null
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000

/obj/machinery/robotic_fabricator/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/stack/sheet/metal))
		if (src.metal_amount < 150000.0)
			var/count = 0
			src.overlays += "fab-load-metal"
			spawn(15)
				if(O)
					if(!O:amount)
						return
					while(metal_amount < 150000 && O:amount)
						src.metal_amount += O:m_amt /*O:height * O:width * O:length * 100000.0*/
						O:amount--
						count++

					if (O:amount < 1)
						del(O)

					user << "You insert [count] metal sheet\s into the fabricator."
					src.overlays -= "fab-load-metal"
					updateDialog()
		else
			user << "The robot part maker is full. Please remove metal from the robot part maker in order to insert more."

/obj/machinery/robotic_fabricator/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/obj/machinery/robotic_fabricator/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/robotic_fabricator/attack_hand(user as mob)
	var/dat
	if (..())
		return

	if (src.operating)
		dat = {"
<TT>Building [src.being_built.name].<BR>
Please wait until completion...</TT><BR>
<BR>
"}
	else
		dat = {"
<B>Metal Amount:</B> [min(150000, src.metal_amount)] cm<sup>3</sup> (MAX: 150,000)<BR><HR>
<BR>
<A href='?src=\ref[src];make=1'>Left Arm (25,000 cc metal.)<BR>
<A href='?src=\ref[src];make=2'>Right Arm (25,000 cc metal.)<BR>
<A href='?src=\ref[src];make=3'>Left Leg (25,000 cc metal.)<BR>
<A href='?src=\ref[src];make=4'>Right Leg (25,000 cc metal).<BR>
<A href='?src=\ref[src];make=5'>Chest (50,000 cc metal).<BR>
<A href='?src=\ref[src];make=6'>Head (50,000 cc metal).<BR>
<A href='?src=\ref[src];make=7'>Robot Frame (75,000 cc metal).<BR>
"}

	user << browse("<HEAD><TITLE>Robotic Fabricator Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=robot_fabricator")
	onclose(user, "robot_fabricator")
	return

/obj/machinery/robotic_fabricator/Topic(href, href_list)
	if (..())
		return

	usr.machine = src
	src.add_fingerprint(usr)

	if (href_list["make"])
		if (!src.operating)
			var/part_type = text2num(href_list["make"])

			var/build_type = ""
			var/build_time = 200
			var/build_cost = 25000

			switch (part_type)
				if (1)
					build_type = "/obj/item/robot_parts/l_arm"
					build_time = 200
					build_cost = 25000

				if (2)
					build_type = "/obj/item/robot_parts/r_arm"
					build_time = 200
					build_cost = 25000

				if (3)
					build_type = "/obj/item/robot_parts/l_leg"
					build_time = 200
					build_cost = 25000

				if (4)
					build_type = "/obj/item/robot_parts/r_leg"
					build_time = 200
					build_cost = 25000

				if (5)
					build_type = "/obj/item/robot_parts/chest"
					build_time = 350
					build_cost = 50000

				if (6)
					build_type = "/obj/item/robot_parts/head"
					build_time = 350
					build_cost = 50000

				if (7)
					build_type = "/obj/item/robot_parts/robot_suit"
					build_time = 600
					build_cost = 75000

			var/building = text2path(build_type)
			if (!isnull(building))
				if (src.metal_amount >= build_cost)
					src.operating = 1
					src.use_power = 2

					src.metal_amount = max(0, src.metal_amount - build_cost)

					src.being_built = new building(src)

					src.overlays += "fab-active"
					src.updateUsrDialog()

					spawn (build_time)
						if (!isnull(src.being_built))
							src.being_built.loc = get_turf(src)
							src.being_built = null
						src.use_power = 1
						src.operating = 0
						src.overlays -= "fab-active"
		return

	for (var/mob/M in viewers(1, src))
		if (M.client && M.machine == src)
			src.attack_hand(M)
