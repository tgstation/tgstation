/obj/machinery/atmoalter/heater/proc/setstate()

	if(stat & NOPOWER)
		icon_state = "heater-p"
		return

	if (src.holding)
		src.icon_state = "heater1-h"
	else
		src.icon_state = "heater1"
	return

/obj/machinery/atmoalter/heater/process()
	/*
	if(stat & NOPOWER)	return
	use_power(5)

	var/turf/T = src.loc
	if (istype(T, /turf))
		if (locate(/obj/move, T))
			T = locate(/obj/move, T)
	else
		T = null
	if (src.h_status)
		var/t1 = src.gas.total_moles()
		if ((t1 > 0 && src.gas.temperature < (src.h_tar+T0C)))
			var/increase = src.heatrate / t1
			var/n_temp = src.gas.temperature + increase
			src.gas.temperature = min(n_temp, (src.h_tar+T0C))
			use_power( src.h_tar*8)
	switch(src.t_status)
		if(1.0)
			if (src.holding)
				var/t1 = src.gas.total_moles()
				var/t2 = t1
				var/t = src.t_per
				if (src.t_per > t2)
					t = t2
				src.holding.gas.transfer_from(src.gas, t)
			else
				src.t_status = 3
		if(2.0)
			if (src.holding)
				var/t1 = src.gas.total_moles()
				var/t2 = src.maximum - t1
				var/t = src.t_per
				if (src.t_per > t2)
					t = t2
				src.gas.transfer_from(src.holding.gas, t)
			else
				src.t_status = 3
		else

	src.updateDialog()
	src.setstate()
	return
	*/

/obj/machinery/atmoalter/heater/New()
	..()
	src.gas = new /datum/gas_mixture()
	return

/obj/machinery/atmoalter/heater/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/atmoalter/heater/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/atmoalter/heater/attack_hand(var/mob/user as mob)
	/*
	if(stat & (BROKEN|NOPOWER))
		return

	user.machine = src
	var/tt
	switch(src.t_status)
		if(1.0)
			tt = text("Releasing <A href='?src=\ref[];t=2'>Siphon</A> <A href='?src=\ref[];t=3'>Stop</A>", src, src)
		if(2.0)
			tt = text("<A href='?src=\ref[];t=1'>Release</A> Siphoning<A href='?src=\ref[];t=3'>Stop</A>", src, src)
		if(3.0)
			tt = text("<A href='?src=\ref[];t=1'>Release</A> <A href='?src=\ref[];t=2'>Siphon</A> Stopped", src, src)
		else
	var/ht = null
	if (src.h_status)
		ht = text("Heating <A href='?src=\ref[];h=2'>Stop</A>", src)
	else
		ht = text("<A href='?src=\ref[];h=1'>Heat</A> Stopped", src)
	var/ct = null
	switch(src.c_status)
		if(1.0)
			ct = text("Releasing <A href='?src=\ref[];c=2'>Accept</A> <A href='?src=\ref[];ct=3'>Stop</A>", src, src)
		if(2.0)
			ct = text("<A href='?src=\ref[];c=1'>Release</A> Accepting <A href='?src=\ref[];c=3'>Stop</A>", src, src)
		if(3.0)
			ct = text("<A href='?src=\ref[];c=1'>Release</A> <A href='?src=\ref[];c=2'>Accept</A> Stopped", src, src)
		else
			ct = "Disconnected"
	var/dat = text("<TT><B>Canister Valves</B><BR>\n<FONT color = 'blue'><B>Contains/Capacity</B> [] / []</FONT><BR>\nUpper Valve Status: [][]<BR>\n\t<A href='?src=\ref[];tp=-[]'>M</A> <A href='?src=\ref[];tp=-10000'>-</A> <A href='?src=\ref[];tp=-1000'>-</A> <A href='?src=\ref[];tp=-100'>-</A> <A href='?src=\ref[];tp=-1'>-</A> [] <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=100'>+</A> <A href='?src=\ref[];tp=1000'>+</A> <A href='?src=\ref[];tp=10000'>+</A> <A href='?src=\ref[];tp=[]'>M</A><BR>\nHeater Status: [] - []<BR>\n\tTrg Tmp: <A href='?src=\ref[];ht=-50'>-</A> <A href='?src=\ref[];ht=-5'>-</A> <A href='?src=\ref[];ht=-1'>-</A> [] <A href='?src=\ref[];ht=1'>+</A> <A href='?src=\ref[];ht=5'>+</A> <A href='?src=\ref[];ht=50'>+</A><BR>\n<BR>\nPipe Valve Status: []<BR>\n\t<A href='?src=\ref[];cp=-[]'>M</A> <A href='?src=\ref[];cp=-10000'>-</A> <A href='?src=\ref[];cp=-1000'>-</A> <A href='?src=\ref[];cp=-100'>-</A> <A href='?src=\ref[];cp=-1'>-</A> [] <A href='?src=\ref[];cp=1'>+</A> <A href='?src=\ref[];cp=100'>+</A> <A href='?src=\ref[];cp=1000'>+</A> <A href='?src=\ref[];cp=10000'>+</A> <A href='?src=\ref[];cp=[]'>M</A><BR>\n<BR>\n<A href='?src=\ref[];mach_close=canister'>Close</A><BR>\n</TT>", src.gas.total_moles(), src.maximum, tt, (src.holding ? text("<BR><A href='?src=\ref[];tank=1'>Tank ([]</A>)", src, src.holding.gas.total_moles()) : null), src, num2text(1000000.0, 7), src, src, src, src, src.t_per, src, src, src, src, src, num2text(1000000.0, 7), ht, (src.gas.total_moles() ? (src.gas.temperature-T0C) : 20), src, src, src, src.h_tar, src, src, src, ct, src, num2text(1000000.0, 7), src, src, src, src, src.c_per, src, src, src, src, src, num2text(1000000.0, 7), user)
	user << browse(dat, "window=canister;size=600x300")
	onclose(user, "canister")
	return */ //TODO: FIX

/obj/machinery/atmoalter/heater/Topic(href, href_list)
	..()
	if (stat & (BROKEN|NOPOWER))
		return
	if (usr.stat || usr.restrained())
		return
	if (((get_dist(src, usr) <= 1 || usr.telekinesis == 1) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["c"])
			var/c = text2num(href_list["c"])
			switch(c)
				if(1.0)
					src.c_status = 1
				if(2.0)
					src.c_status = 2
				if(3.0)
					src.c_status = 3
				else
		else
			if (href_list["t"])
				var/t = text2num(href_list["t"])
				if (src.t_status == 0)
					return
				switch(t)
					if(1.0)
						src.t_status = 1
					if(2.0)
						src.t_status = 2
					if(3.0)
						src.t_status = 3
					else
			else
				if (href_list["h"])
					var/h = text2num(href_list["h"])
					if (h == 1)
						src.h_status = 1
					else
						src.h_status = null
				else
					if (href_list["tp"])
						var/tp = text2num(href_list["tp"])
						src.t_per += tp
						src.t_per = min(max(round(src.t_per), 0), 1000000.0)
					else
						if (href_list["cp"])
							var/cp = text2num(href_list["cp"])
							src.c_per += cp
							src.c_per = min(max(round(src.c_per), 0), 1000000.0)
						else
							if (href_list["ht"])
								var/cp = text2num(href_list["ht"])
								src.h_tar += cp
								src.h_tar = min(max(round(src.h_tar), 0), 500)
							else
								if (href_list["tank"])
									var/cp = text2num(href_list["tank"])
									if ((cp == 1 && src.holding))
										src.holding.loc = src.loc
										src.holding = null
										if (src.t_status == 2)
											src.t_status = 3
		src.updateUsrDialog()
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=canister")
		return
	return

/obj/machinery/atmoalter/heater/attackby(var/obj/W as obj, var/mob/user as mob)

	if (istype(W, /obj/item/weapon/tank))
		if (src.holding)
			return
		var/obj/item/weapon/tank/T = W
		user.drop_item()
		T.loc = src
		src.holding = T
	else
		if (istype(W, /obj/item/weapon/wrench))
			var/obj/machinery/connector/con = locate(/obj/machinery/connector, src.loc)

			if (src.c_status)
				src.anchored = initial(src.anchored)
				src.c_status = 0
				user.show_message("\blue You have disconnected the heater.", 1)
				if(con)
					con.connected = null
			else
				if (con && !con.connected)
					src.anchored = 1
					src.c_status = 3
					user.show_message("\blue You have connected the heater.", 1)
					con.connected = src
				else
					user.show_message("\blue There is no connector here to attach the heater to.", 1)
	return

