//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/list/autolathe_recipes = list( \
		/* screwdriver removed*/ \
		new /obj/item/weapon/reagent_containers/glass/bucket(), \
		new /obj/item/weapon/crowbar(), \
		new /obj/item/device/flashlight(), \
		new /obj/item/weapon/extinguisher(), \
		new /obj/item/device/multitool(), \
		new /obj/item/device/t_scanner(), \
		new /obj/item/weapon/weldingtool(), \
		new /obj/item/weapon/screwdriver(), \
		new /obj/item/weapon/wirecutters(), \
		new /obj/item/weapon/wrench(), \
		new /obj/item/clothing/head/welding(), \
		new /obj/item/weapon/stock_parts/console_screen(), \
		new /obj/item/weapon/airlock_electronics(), \
		new /obj/item/stack/sheet/metal(), \
		new /obj/item/stack/sheet/glass(), \
		new /obj/item/stack/sheet/rglass(), \
		new /obj/item/stack/rods(), \
		new /obj/item/weapon/rcd_ammo(), \
		new /obj/item/weapon/kitchenknife(), \
		new /obj/item/weapon/scalpel(), \
		new /obj/item/weapon/circular_saw(), \
		new /obj/item/weapon/reagent_containers/glass/beaker(), \
		new /obj/item/weapon/reagent_containers/glass/large(), \
		new /obj/item/ammo_casing/shotgun/blank(), \
		new /obj/item/ammo_casing/shotgun/beanbag(), \
		new /obj/item/ammo_magazine/c38(), \
		new /obj/item/device/taperecorder(), \
		new /obj/item/device/assembly/igniter(), \
		new /obj/item/device/infra_sensor(), \
		new /obj/item/device/assembly/signaler(), \
		new /obj/item/device/radio/headset(), \
		new /obj/item/device/radio(), \
		new /obj/item/device/assembly/infra(), \
		new /obj/item/device/assembly/timer(), \
		new /obj/item/weapon/light/tube(), \
		new /obj/item/weapon/light/bulb(), \
	)

var/global/list/autolathe_recipes_hidden = list( \
		new /obj/item/weapon/flamethrower/full(), \
		new /obj/item/weapon/rcd(), \
		new /obj/item/device/radio/electropack(), \
		new /obj/item/weapon/weldingtool/largetank(), \
		new /obj/item/weapon/handcuffs(), \
		new /obj/item/ammo_magazine/a357(), \
		new /obj/item/ammo_casing/shotgun(), \
		new /obj/item/ammo_casing/shotgun/dart(), \
		/* new /obj/item/weapon/shield/riot(), */ \
	)

/obj/machinery/autolathe
	var/busy = 0
	var/max_m_amount = 150000.0
	var/max_g_amount = 75000.0

	proc
		wires_win(mob/user as mob)
			var/dat as text
			dat += "Autolathe Wires:<BR>"
			for(var/wire in src.wires)
				dat += text("[wire] Wire: <A href='?src=\ref[src];wire=[wire];act=wire'>[src.wires[wire] ? "Mend" : "Cut"]</A> <A href='?src=\ref[src];wire=[wire];act=pulse'>Pulse</A><BR>")

			dat += text("The red light is [src.disabled ? "off" : "on"].<BR>")
			dat += text("The green light is [src.shocked ? "off" : "on"].<BR>")
			dat += text("The blue light is [src.hacked ? "off" : "on"].<BR>")
			user << browse("<HTML><HEAD><TITLE>Autolathe Hacking</TITLE></HEAD><BODY>[dat]</BODY></HTML>","window=autolathe_hack")
			onclose(user, "autolathe_hack")

		regular_win(mob/user as mob)
			var/dat as text
			dat = text("<B>Metal Amount:</B> [src.m_amount] cm<sup>3</sup> (MAX: [max_m_amount])<BR>\n<FONT color=blue><B>Glass Amount:</B></FONT> [src.g_amount] cm<sup>3</sup> (MAX: [max_g_amount])<HR>")
			var/list/objs = list()
			objs += src.L
			if (src.hacked)
				objs += src.LL
			for(var/obj/t in objs)
				var/title = "[t.name] ([t.m_amt] m /[t.g_amt] g)"
				if (m_amount<t.m_amt || g_amount<t.g_amt)
					dat += title + "<br>"
					continue
				dat += "<A href='?src=\ref[src];make=\ref[t]'>[title]</A>"
				if (istype(t, /obj/item/stack))
					var/obj/item/stack/S = t
					var/max_multiplier = min(S.max_amount, S.m_amt?round(m_amount/S.m_amt):INFINITY, S.g_amt?round(g_amount/S.g_amt):INFINITY)
					if (max_multiplier>1)
						dat += " |"
					if (max_multiplier>10)
						dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[10]'>x[10]</A>"
					if (max_multiplier>25)
						dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[25]'>x[25]</A>"
					if (max_multiplier>1)
						dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[max_multiplier]'>x[max_multiplier]</A>"
				dat += "<br>"
			user << browse("<HTML><HEAD><TITLE>Autolathe Control Panel</TITLE></HEAD><BODY><TT>[dat]</TT></BODY></HTML>", "window=autolathe_regular")
			onclose(user, "autolathe_regular")

		interact(mob/user as mob)
			if(..())
				return
			if (src.shocked)
				src.shock(user,50)
			if (src.opened)
				wires_win(user,50)
				return
			if (src.disabled)
				user << "\red You press the button, but nothing happens."
				return
			regular_win(user)
			return

		shock(mob/user, prb)
			if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
				return 0
			if(!prob(prb))
				return 0
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()
			if (electrocute_mob(user, get_area(src), src, 0.7))
				return 1
			else
				return 0

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (stat)
			return 1
		if (busy)
			user << "\red The autolathe is busy. Please wait for completion of previous operation."
			return 1
		if (istype(O, /obj/item/weapon/screwdriver))
			if (!opened)
				src.opened = 1
				src.icon_state = "autolathe_t"
				user << "You open the maintenance hatch of [src]."
			else
				src.opened = 0
				src.icon_state = "autolathe"
				user << "You close the maintenance hatch of [src]."
			return 1
		if (opened)
			if(istype(O, /obj/item/weapon/crowbar))
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 2
				M.icon_state = "box_1"
				for(var/obj/I in component_parts)
					if(I.reliability != 100 && crit_fail)
						I.crit_fail = 1
					I.loc = src.loc
				if(m_amount >= 3750)
					var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal(src.loc)
					G.amount = round(m_amount / 3750)
				if(g_amount >= 3750)
					var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
					G.amount = round(g_amount / 3750)
				del(src)
				return 1
			else
				user.machine = src
				interact(user)
				return 1

		if (src.m_amount + O.m_amt > max_m_amount)
			user << "\red The autolathe is full. Please remove metal from the autolathe in order to insert more."
			return 1
		if (src.g_amount + O.g_amt > max_g_amount)
			user << "\red The autolathe is full. Please remove glass from the autolathe in order to insert more."
			return 1
		if (O.m_amt == 0 && O.g_amt == 0)
			user << "\red This object does not contain significant amounts of metal or glass, or cannot be accepted by the autolathe due to size or hazardous materials."
			return 1
	/*
		if (istype(O, /obj/item/weapon/grab) && src.hacked)
			var/obj/item/weapon/grab/G = O
			if (prob(25) && G.affecting)
				G.affecting.gib()
				m_amount += 50000
			return
	*/

		var/amount = 1
		var/obj/item/stack/stack
		var/m_amt = O.m_amt
		var/g_amt = O.g_amt
		if (istype(O, /obj/item/stack))
			stack = O
			amount = stack.amount
			if (m_amt)
				amount = min(amount, round((max_m_amount-src.m_amount)/m_amt))
				flick("autolathe_o",src)//plays metal insertion animation
			if (g_amt)
				amount = min(amount, round((max_g_amount-src.g_amount)/g_amt))
				flick("autolathe_r",src)//plays glass insertion animation
			stack.use(amount)
		else
			usr.before_take_item(O)
			O.loc = src
		icon_state = "autolathe"
		busy = 1
		use_power(max(1000, (m_amt+g_amt)*amount/10))
		src.m_amount += m_amt * amount
		src.g_amount += g_amt * amount
		user << "You insert [amount] sheet[amount>1 ? "s" : ""] to the autolathe."
		if (O && O.loc == src)
			del(O)
		busy = 0
		src.updateUsrDialog()

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		user.machine = src
		interact(user)


	Topic(href, href_list)
		if(..())
			return
		usr.machine = src
		src.add_fingerprint(usr)
		if (!busy)
			if(href_list["make"])
				var/turf/T = get_step(src.loc, get_dir(src,usr))
				var/obj/template = locate(href_list["make"])
				var/multiplier = text2num(href_list["multiplier"])
				if (!multiplier) multiplier = 1
				var/power = max(2000, (template.m_amt+template.g_amt)*multiplier/5)
				if(src.m_amount >= template.m_amt*multiplier && src.g_amount >= template.g_amt*multiplier)
					busy = 1
					use_power(power)
					icon_state = "autolathe"
					flick("autolathe_n",src)
					spawn(16)
						use_power(power)
						spawn(16)
							use_power(power)
							spawn(16)
								src.m_amount -= template.m_amt*multiplier
								src.g_amount -= template.g_amt*multiplier
								if(src.m_amount < 0)
									src.m_amount = 0
								if(src.g_amount < 0)
									src.g_amount = 0
								var/obj/new_item = new template.type(T)
								if (multiplier>1)
									var/obj/item/stack/S = new_item
									S.amount = multiplier
								busy = 0
								src.updateUsrDialog()
			if(href_list["act"])
				var/temp_wire = href_list["wire"]
				if(href_list["act"] == "pulse")
					if (!istype(usr.get_active_hand(), /obj/item/device/multitool))
						usr << "You need a multitool!"
					else
						if(src.wires[temp_wire])
							usr << "You can't pulse a cut wire."
						else
							if(src.hack_wire == temp_wire)
								src.hacked = !src.hacked
								spawn(100) src.hacked = !src.hacked
							if(src.disable_wire == temp_wire)
								src.disabled = !src.disabled
								src.shock(usr,50)
								spawn(100) src.disabled = !src.disabled
							if(src.shock_wire == temp_wire)
								src.shocked = !src.shocked
								src.shock(usr,50)
								spawn(100) src.shocked = !src.shocked
				if(href_list["act"] == "wire")
					if (!istype(usr.get_active_hand(), /obj/item/weapon/wirecutters))
						usr << "You need wirecutters!"
					else
						wires[temp_wire] = !wires[temp_wire]
						if(src.hack_wire == temp_wire)
							src.hacked = !src.hacked
						if(src.disable_wire == temp_wire)
							src.disabled = !src.disabled
							src.shock(usr,50)
						if(src.shock_wire == temp_wire)
							src.shocked = !src.shocked
							src.shock(usr,50)
		else
			usr << "\red The autolathe is busy. Please wait for completion of previous operation."
		src.updateUsrDialog()
		return


	RefreshParts()
		..()
		var/tot_rating = 0
		for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
			tot_rating += MB.rating
		tot_rating *= 25000
		max_m_amount = tot_rating * 2
		max_g_amount = tot_rating

	New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/circuitboard/autolathe(src)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
		component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
		RefreshParts()

		src.L = autolathe_recipes
		src.LL = autolathe_recipes_hidden
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
