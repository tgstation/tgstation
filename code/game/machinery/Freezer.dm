/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "Freezer"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer_0"
	density = 1
	var/opened = 0

	anchored = 1.0

	current_heat_capacity = 1000

	var/list/rotate_verbs=list(
		/obj/machinery/atmospherics/unary/cold_sink/freezer/verb/rotate,
		/obj/machinery/atmospherics/unary/cold_sink/freezer/verb/rotate_ccw,
	)

	New()
		. = ..()

		component_parts = newlist(
			/obj/item/weapon/circuitboard/freezer,
			/obj/item/weapon/stock_parts/manipulator,
			/obj/item/weapon/stock_parts/manipulator,
			/obj/item/weapon/stock_parts/manipulator,
			/obj/item/weapon/stock_parts/scanning_module,
			/obj/item/weapon/stock_parts/scanning_module,
			/obj/item/weapon/stock_parts/micro_laser,
			/obj/item/weapon/stock_parts/console_screen
		)

		RefreshParts()

		if(anchored)
			verbs -= rotate_verbs

		initialize_directions = dir

	update_icon()
		if(src.node)
			if(src.on)
				icon_state = "freezer_1"
			else
				icon_state = "freezer"
		else
			icon_state = "freezer_0"
		return

	attack_ai(mob/user as mob)
		src.add_hiddenprint(user)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench))
			if(src.on)
				user << "You have to turn off the [src] first!"
				return
			if(anchored)
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				user << "You begin to unfasten the [src]..."
				if (do_after(user, 40))
					verbs += rotate_verbs
					user.visible_message( \
						"[user] unfastens \the [src].", \
						"\blue You have unfastened \the [src]. Now it can be pulled somewhere else.", \
						"You hear ratchet.")
					src.anchored = 0

					// From Destroy()
					// Disconnect
					if(node)
						node.disconnect(src)
						del(network)
					node = null
			else
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				user << "You begin to fasten [src]."
				if(do_after(user, 40))
					verbs -= rotate_verbs
					user.visible_message( \
						"[user] fastens \the [src].", \
						"\blue You have fastened \the [src]. Now it can be pulled somewhere else.", \
						"You hear ratchet.")
					src.anchored = 1

					// Connect to network
					initialize_directions = dir
					initialize()
					build_network()
					if (node)
						node.initialize()
						node.build_network()
			return 1
		if(istype(W, /obj/item/weapon/screwdriver))
			if(anchored)
				user << "You have to unanchor the [src] first!"
				return
			if(src.on)
				user << "You have to turn off the [src]!"
				return
			if(!opened)
				src.opened = 1
				//src.icon_state = "freezer_t"
				user << "You open the maintenance hatch of [src]."
			else
				src.opened = 0
				//src.icon_state = "freezer"
				user << "You close the maintenance hatch of [src]."
			return 1
		if(opened)
			if(src.on || anchored)
				return
			if(istype(W, /obj/item/weapon/crowbar))
				user << "You begin to remove the circuits from the [src]."
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				if(do_after(user, 50))
					var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
					M.state = 2
					M.icon_state = "box_1"
					for(var/obj/I in component_parts)
						if(I.reliability != 100 && crit_fail)
							I.crit_fail = 1
						I.loc = src.loc
					del(src)
					return 1


	attack_hand(mob/user as mob)
		user.set_machine(src)
		var/temp_text = ""
		if(air_contents.temperature > (T0C - 20))
			temp_text = "<FONT color=red>[air_contents.temperature]</FONT>"
		else if(air_contents.temperature < (T0C - 20) && air_contents.temperature > (T0C - 100))
			temp_text = "<FONT color=black>[air_contents.temperature]</FONT>"
		else
			temp_text = "<FONT color=blue>[air_contents.temperature]</FONT>"

		var/dat = {"<B>Cryo gas cooling system</B><BR>
		Current status: [ on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
		Current gas temperature: [temp_text]<BR>
		Current air pressure: [air_contents.return_pressure()]<BR>
		Target gas temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
		"}

		user << browse(dat, "window=freezer;size=400x500")
		onclose(user, "freezer")

	Topic(href, href_list)
		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
			usr.set_machine(src)
			if (href_list["start"])
				if(isobserver(usr) && !canGhostWrite(usr,src,"turned [on?"off":"on"]"))
					return
				src.on = !src.on
				update_icon()
			if(href_list["temp"])
				if(isobserver(usr) && !canGhostWrite(usr,src,"set temperature of"))
					return
				var/amount = text2num(href_list["temp"])
				if(amount > 0)
					src.current_temperature = min(T20C, src.current_temperature+amount)
				else
					src.current_temperature = max((T0C - 200), src.current_temperature+amount)
		src.updateUsrDialog()
		src.add_fingerprint(usr)
		return

	process()
		..()
		src.updateUsrDialog()


/obj/machinery/atmospherics/unary/cold_sink/freezer/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, 270)
	return 1

/obj/machinery/atmospherics/unary/cold_sink/freezer/verb/rotate_ccw()
	set name = "Rotate Counter Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, 90)
	return 1


/obj/machinery/atmospherics/unary/heat_reservoir/heater
	name = "Heater"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer_0"
	density = 1
	var/opened = 0

	anchored = 1.0

	current_heat_capacity = 1000

	var/list/rotate_verbs=list(
		/obj/machinery/atmospherics/unary/heat_reservoir/heater/verb/rotate,
		/obj/machinery/atmospherics/unary/heat_reservoir/heater/verb/rotate_ccw,
	)

	New()
		. = ..()

		component_parts = newlist(
			/obj/item/weapon/circuitboard/heater,
			/obj/item/weapon/stock_parts/manipulator,
			/obj/item/weapon/stock_parts/manipulator,
			/obj/item/weapon/stock_parts/manipulator,
			/obj/item/weapon/stock_parts/scanning_module,
			/obj/item/weapon/stock_parts/scanning_module,
			/obj/item/weapon/stock_parts/micro_laser,
			/obj/item/weapon/stock_parts/console_screen
		)

		RefreshParts()

		if(anchored)
			verbs -= rotate_verbs

		initialize_directions = dir

	update_icon()
		if(src.node)
			if(src.on)
				icon_state = "heater_1"
			else
				icon_state = "heater"
		else
			icon_state = "heater_0"
		return

	attack_ai(mob/user as mob)
		src.add_hiddenprint(user)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench))
			if(src.on)
				user << "You have to turn off the [src] first!"
				return
			if(anchored)
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				user << "You begin to unfasten the [src]..."
				if (do_after(user, 40))
					verbs += rotate_verbs
					user.visible_message( \
						"[user] unfastens \the [src].", \
						"\blue You have unfastened \the [src]. Now it can be pulled somewhere else.", \
						"You hear ratchet.")
					src.anchored = 0

					// From Destroy()
					// Disconnect
					if(node)
						node.disconnect(src)
						del(network)
					node = null
			else
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				user << "You begin to fasten [src]."
				if(do_after(user, 40))
					verbs -= rotate_verbs
					user.visible_message( \
						"[user] fastens \the [src].", \
						"\blue You have fastened \the [src]. Now it can be pulled somewhere else.", \
						"You hear ratchet.")
					src.anchored = 1

					// Connect to network
					initialize_directions = dir
					initialize()
					build_network()
					if (node)
						node.initialize()
						node.build_network()
			return 1
		if(istype(W, /obj/item/weapon/screwdriver))
			if(anchored)
				user << "You have to unanchor the [src] first!"
				return
			if(src.on)
				user << "You have to turn off the [src]!"
				return
			if(!opened)
				src.opened = 1
				//src.icon_state = "freezer_t"
				user << "You open the maintenance hatch of [src]."
			else
				src.opened = 0
				//src.icon_state = "freezer"
				user << "You close the maintenance hatch of [src]."
			return 1
		if(opened)
			if(src.on || anchored)
				return
			if(istype(W, /obj/item/weapon/crowbar))
				user << "You begin to remove the circuits from the [src]."
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				if(do_after(user, 50))
					var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
					M.state = 2
					M.icon_state = "box_1"
					for(var/obj/I in component_parts)
						if(I.reliability != 100 && crit_fail)
							I.crit_fail = 1
						I.loc = src.loc
					del(src)
					return 1

	attack_hand(mob/user as mob)
		user.set_machine(src)
		var/temp_text = ""
		if(air_contents.temperature > (T20C+40))
			temp_text = "<FONT color=red>[air_contents.temperature]</FONT>"
		else
			temp_text = "<FONT color=black>[air_contents.temperature]</FONT>"

		var/dat = {"<B>Heating system</B><BR>
		Current status: [ on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
		Current gas temperature: [temp_text]<BR>
		Current air pressure: [air_contents.return_pressure()]<BR>
		Target gas temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
		"}

		user << browse(dat, "window=heater;size=400x500")
		onclose(user, "heater")

	Topic(href, href_list)
		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
			usr.set_machine(src)
			if (href_list["start"])
				if(isobserver(usr) && !canGhostWrite(usr,src,"turned [on?"off":"on"]"))
					return
				src.on = !src.on
				update_icon()
			if(href_list["temp"])
				if(isobserver(usr) && !canGhostWrite(usr,src,"set temperature of"))
					return
				var/amount = text2num(href_list["temp"])
				if(amount > 0)
					src.current_temperature = min((T20C+280), src.current_temperature+amount)
				else
					src.current_temperature = max(T20C, src.current_temperature+amount)
		src.updateUsrDialog()
		src.add_fingerprint(usr)
		return

	process()
		..()
		src.updateUsrDialog()



/obj/machinery/atmospherics/unary/heat_reservoir/heater/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, 270)
	return 1

/obj/machinery/atmospherics/unary/heat_reservoir/heater/verb/rotate_ccw()
	set name = "Rotate Counter Clockwise"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, 90)
	return 1