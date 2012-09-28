/obj/machinery/pipedispenser
	name = "Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	anchored = 1
	var/unwrenched = 0
	var/wait = 0

/obj/machinery/pipedispenser/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/pipedispenser/attack_hand(user as mob)
	if(..())
		return
	var/dat = {"
<b>Regular pipes:</b><BR>
<A href='?src=\ref[src];make=0;dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];make=1;dir=5'>Bent Pipe</A><BR>
<A href='?src=\ref[src];make=5;dir=1'>Manifold</A><BR>
<A href='?src=\ref[src];make=8;dir=1'>Manual Valve</A><BR>
<b>Devices:</b><BR>
<A href='?src=\ref[src];make=4;dir=1'>Connector</A><BR>
<A href='?src=\ref[src];make=7;dir=1'>Unary Vent</A><BR>
<A href='?src=\ref[src];make=9;dir=1'>Gas Pump</A><BR>
<A href='?src=\ref[src];make=10;dir=1'>Scrubber</A><BR>
<A href='?src=\ref[src];makemeter=1'>Meter</A><BR>
<A href='?src=\ref[src];make=13;dir=1'>Gas Filter</A><BR>
<A href='?src=\ref[src];make=14;dir=1'>Gas Mixer</A><BR>
<b>Heat exchange:</b><BR>
<A href='?src=\ref[src];make=2;dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];make=3;dir=5'>Bent Pipe</A><BR>
<A href='?src=\ref[src];make=6;dir=1'>Junction</A><BR>
<b>Insulated pipes:</b><BR>
<A href='?src=\ref[src];make=11;dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];make=12;dir=5'>Bent Pipe</A><BR>
"}


	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	onclose(user, "pipedispenser")
	return

/obj/machinery/pipedispenser/Topic(href, href_list)
	if(..())
		return
	if(unwrenched || !usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=pipedispenser")
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["make"])
		if(!wait)
			var/p_type = text2num(href_list["make"])
			var/p_dir = text2num(href_list["dir"])
			var/obj/item/pipe/P = new (/*usr.loc*/ src.loc, pipe_type=p_type, dir=p_dir)
			P.update()
			P.add_fingerprint(usr)
			wait = 1
			spawn(10)
				wait = 0
	if(href_list["makemeter"])
		if(!wait)
			new /obj/item/pipe_meter(/*usr.loc*/ src.loc)
			wait = 1
			spawn(15)
				wait = 0
	return

/obj/machinery/pipedispenser/attackby(var/obj/item/W as obj, var/mob/user as mob)
	src.add_fingerprint(usr)
	if (istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter))
		usr << "\blue You put [W] back to [src]."
		user.drop_item()
		del(W)
		return
	else if (istype(W, /obj/item/weapon/wrench))
		if (unwrenched==0)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user << "\blue You begin to unfasten \the [src] from the floor..."
			if (do_after(user, 40))
				user.visible_message( \
					"[user] unfastens \the [src].", \
					"\blue You have unfastened \the [src]. Now it can be pulled somewhere else.", \
					"You hear ratchet.")
				src.anchored = 0
				src.stat |= MAINT
				src.unwrenched = 1
				if (usr.machine==src)
					usr << browse(null, "window=pipedispenser")
		else /*if (unwrenched==1)*/
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user << "\blue You begin to fasten \the [src] to the floor..."
			if (do_after(user, 20))
				user.visible_message( \
					"[user] fastens \the [src].", \
					"\blue You have fastened \the [src]. Now it can dispense pipes.", \
					"You hear ratchet.")
				src.anchored = 1
				src.stat &= ~MAINT
				src.unwrenched = 0
				power_change()
	else
		return ..()


/obj/machinery/pipedispenser/disposal
	name = "Disposal Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	anchored = 1.0

/*
//Allow you to push disposal pipes into it (for those with density 1)
/obj/machinery/pipedispenser/disposal/HasEntered(var/obj/structure/disposalconstruct/pipe as obj)
	if(istype(pipe) && !pipe.anchored)
		del(pipe)

Nah
*/

//Allow you to drag-drop disposal pipes into it
/obj/machinery/pipedispenser/disposal/MouseDrop_T(var/obj/structure/disposalconstruct/pipe as obj, mob/usr as mob)
	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if (!istype(pipe) || get_dist(usr, src) > 1 || get_dist(src,pipe) > 1 )
		return

	if (pipe.anchored)
		return

	del(pipe)

/obj/machinery/pipedispenser/disposal/attack_hand(user as mob)
	if(..())
		return

	var/dat = {"<b>Disposal Pipes</b><br><br>
<A href='?src=\ref[src];ptype=0'>Pipe</A><BR>
<A href='?src=\ref[src];ptype=1'>Bent Pipe</A><BR><BR>

<A href='?src=\ref[src];ptype=2'>Junction</A><BR>
<A href='?src=\ref[src];ptype=4'>Y-Junction</A><BR>
<A href='?src=\ref[src];ptype=9'>Sorting Junction</A><BR><BR>

<A href='?src=\ref[src];ptype=5'>Trunk</A><BR>
<A href='?src=\ref[src];ptype=6;density=1'>Bin</A><BR>
<A href='?src=\ref[src];ptype=7;density=1'>Outlet</A><BR>
<A href='?src=\ref[src];ptype=8;density=1'>Chute</A><BR>
"}

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return

// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk


/obj/machinery/pipedispenser/disposal/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["ptype"])
		if(unwrenched || !usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			usr << browse(null, "window=pipedispenser")
			return
		if(!wait)
			var/obj/structure/disposalconstruct/C = new (src.loc)

			var/p_type = text2num(href_list["ptype"])
			C.ptype = p_type

			if(href_list["density"])
				var/p_density = text2num(href_list["density"])
				C.density = p_density

			C.add_fingerprint(usr)
			C.update()
			wait = 1
			spawn(15)
				wait = 0
	return

