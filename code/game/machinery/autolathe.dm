/obj/machinery/autolathe/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/weapon/screwdriver))
		if (!opened)
			src.opened = 1
			src.icon_state = "autolathef"
		else
			src.opened = 0
			src.icon_state = "autolathe"
		return
	if (opened)
		user << "You can't load the autolathe while it's opened."
		return
/*
	if (istype(O, /obj/item/weapon/grab) && src.hacked)
		var/obj/item/weapon/grab/G = O
		if (prob(25) && G.affecting)
			G.affecting.gib()
			m_amount += 50000
		return
*/
	if (istype(O, /obj/item/weapon/sheet/metal))
		if (src.m_amount < 150000.0)
			spawn(16) {
				flick("autolathe_c",src)
				src.m_amount += O:height * O:width * O:length * 100000.0
				O:amount--
				if (O:amount < 1)
					del(O)
			}
		else
			user << "The autolathe is full. Please remove metal from the autolathe in order to insert more."
	else if (istype(O, /obj/item/weapon/sheet/glass) || istype(O, /obj/item/weapon/sheet/rglass))
		if (src.g_amount < 75000.0)
			spawn(16) {
				flick("autolathe_c",src)
				src.g_amount += O:height * O:width * O:length * 100000.0
				O:amount--
				if (O:amount < 1)
					del(O)
			}
		else
			user << "The autolathe is full. Please remove glass from the autolathe in order to insert more."

	else if (O.g_amt || O.m_amt)
		spawn(16) {
			flick("autolathe_c",src)
			if(O.g_amt)					// Added null checks to avoid runtime errors when an item doesn't have an expected variable -- TLE
				src.g_amount += O.g_amt
			if(O.m_amt)
				src.m_amount += O.m_amt
			del O
		}
	else
		user << "This object does not contain significant amounts of metal or glass, or cannot be accepted by the autolathe due to size or hazardous materials."

/obj/machinery/autolathe/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/autolathe/attack_hand(user as mob)
	var/dat
	if(..())
		return
	if (src.shocked)
		src.shock(user)
	if (src.opened)
		dat += "Autolathe Wires:<BR>"
		var/wire
		for(wire in src.wires)
			dat += text("[wire] Wire: <A href='?src=\ref[src];wire=[wire];act=wire'>[src.wires[wire] ? "Mend" : "Cut"]</A> <A href='?src=\ref[src];wire=[wire];act=pulse'>Pulse</A><BR>")

		dat += text("The red light is [src.disabled ? "off" : "on"].<BR>")
		dat += text("The green light is [src.shocked ? "off" : "on"].<BR>")
		dat += text("The blue light is [src.hacked ? "off" : "on"].<BR>")
		user << browse("<HEAD><TITLE>Autolathe Hacking</TITLE></HEAD>[dat]","window=autolathe_hack")
		onclose(user, "autolathe_hack")
		return
	if (src.disabled)
		user << "You press the button, but nothing happens."
		return
	if (src.temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];temp=1'>Clear Screen</A>", src.temp, src)
	else
		dat = text("<B>Metal Amount:</B> [src.m_amount] cm<sup>3</sup> (MAX: 150,000)<BR>\n<FONT color = blue><B>Glass Amount:</B></FONT> [src.g_amount] cm<sup>3</sup> (MAX: 75,000)<HR>")
		var/list/objs = list()
		objs += src.L
		if (src.hacked)
			objs += src.LL
		for(var/obj/t in objs)
			dat += text("<A href='?src=\ref[src];make=\ref[t]'>[t.name] ([t.m_amt] cc metal/[t.g_amt] cc glass)<BR>")
	user << browse("<HEAD><TITLE>Autolathe Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=autolathe_regular")
	onclose(user, "autolathe_regular")
	return

/obj/machinery/autolathe/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["make"])
		var/obj/template = locate(href_list["make"])
		if(src.m_amount >= template.m_amt && src.g_amount >= template.g_amt)
			spawn(16)
				flick("autolathe_c",src)
				spawn(16)
					flick("autolathe_o",src)
					spawn(16)
						src.m_amount -= template.m_amt
						src.g_amount -= template.g_amt
						if(src.m_amount < 0)
							src.m_amount = 0
						if(src.g_amount < 0)
							src.g_amount = 0
						new template.type(usr.loc)
	if(href_list["act"])
		if(href_list["act"] == "pulse")
			if (!istype(usr.equipped(), /obj/item/device/multitool))
				usr << "You need a multitool!"
			else
				if(src.wires[href_list["wire"]])
					usr << "You can't pulse a cut wire."
				else
					if(src.hack_wire == href_list["wire"])
						src.hacked = !src.hacked
						spawn(100) src.hacked = !src.hacked
					if(src.disable_wire == href_list["wire"])
						src.disabled = !src.disabled
						src.shock(usr)
						spawn(100) src.disabled = !src.disabled
					if(src.shock_wire == href_list["wire"])
						src.shocked = !src.shocked
						src.shock(usr)
						spawn(100) src.shocked = !src.shocked
		if(href_list["act"] == "wire")
			if (!istype(usr.equipped(), /obj/item/weapon/wirecutters))
				usr << "You need wirecutters!"
			else
				if(src.hack_wire == href_list["wire"])
					src.hacked = !src.hacked
				if(src.disable_wire == href_list["wire"])
					src.disabled = !src.disabled
					src.shock(usr)
				if(src.shock_wire == href_list["wire"])
					src.shocked = !src.shocked
					src.shock(usr)

	if (href_list["temp"])
		src.temp = null

	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	src.updateUsrDialog()
	return

/obj/machinery/autolathe/New()
	..()
	// screwdriver removed
	src.L += new /obj/item/weapon/wirecutters(src)
	src.L += new /obj/item/weapon/wrench(src)
	src.L += new /obj/item/weapon/crowbar(src)
	src.L += new /obj/item/weapon/weldingtool(src)
	src.L += new /obj/item/clothing/head/helmet/welding(src)
	src.L += new /obj/item/device/multitool(src)
	src.L += new /obj/item/device/flashlight(src)
	src.L += new /obj/item/weapon/extinguisher(src)
	src.L += new /obj/item/weapon/sheet/metal(src)
	src.L += new /obj/item/weapon/sheet/glass(src)
	src.L += new /obj/item/weapon/sheet/r_metal(src)
	src.L += new /obj/item/weapon/sheet/rglass(src)
	src.L += new /obj/item/weapon/rods(src)
	src.L += new /obj/item/weapon/rcd_ammo(src)
	src.L += new /obj/item/weapon/scalpel(src)
	src.L += new /obj/item/weapon/circular_saw(src)
	src.L += new /obj/item/device/t_scanner(src)
	src.L += new /obj/item/weapon/reagent_containers/glass/bucket(src)
	src.LL += new /obj/item/weapon/flamethrower(src)
	src.LL += new /obj/item/device/igniter(src)
	src.LL += new /obj/item/device/timer(src)
	src.LL += new /obj/item/weapon/rcd(src)
	src.LL += new /obj/item/device/infra(src)
	src.LL += new /obj/item/device/infra_sensor(src)
	src.LL += new /obj/item/weapon/handcuffs(src)
	src.LL += new /obj/item/weapon/ammo/a357(src)
	src.LL += new /obj/item/weapon/ammo/a38(src)
	src.wires["Light Red"] = 0
	src.wires["Dark Red"] = 0
	src.wires["Blue"] = 0
	src.wires["Green"] = 0
	src.wires["Yellow"] = 0
	src.wires["Black"] = 0
	src.wires["White"] = 0
	src.wires["Gray"] = 0
	src.wires["Orange"] = 0
	src.wires["Pink"] = 0
	var/list/w = list("Light Red","Dark Red","Blue","Green","Yellow","Black","White","Gray","Orange","Pink")
	src.hack_wire = pick(w)
	w -= src.hack_wire
	src.shock_wire = pick(w)
	w -= src.shock_wire
	src.disable_wire = pick(w)
	w -= src.disable_wire

/obj/machinery/autolathe/proc/get_connection()
	var/turf/T = src.loc
	if(!istype(T, /turf/simulated/floor))
		return

	for(var/obj/cable/C in T)
		if(C.d1 == 0)
			return C.netnum

	return 0

/obj/machinery/autolathe/proc/shock(M as mob)
	return src.electrocute(M, 50, get_connection())