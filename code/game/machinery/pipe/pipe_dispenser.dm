/obj/machinery/pipedispenser
	name = "Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	anchored = 1
	var/wait = 0
	machine_flags = WRENCHMOVE | FIXED2WORK

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/pipedispenser/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/pipedispenser,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)

	RefreshParts()

/obj/machinery/pipedispenser/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/pipedispenser/attack_hand(user as mob)
	if(..())
		return
	var/dat = {"
<b>Regular pipes:</b>
<ul>
	<li><a href='?src=\ref[src];make=[PIPE_SIMPLE_STRAIGHT];dir=1'>Pipe</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_SIMPLE_BENT];dir=5'>Bent Pipe</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_MANIFOLD];dir=1'>Manifold</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_MVALVE];dir=1'>Manual Valve</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_DVALVE];dir=1'>Digital Valve</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_CAP];dir=1'>Pipe Cap</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_MANIFOLD4W];dir=1'>4-Way Manifold</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_MTVALVE];dir=1'>Manual T-Valve</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_MTVALVE];dir=9'>Manual T-Valve \[M]</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_DTVALVE];dir=1'>Digital T-Valve</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_DTVALVE];dir=9'>Digital T-Valve \[M]</a></li>
</ul>
<b>Devices:</b>
<ul>
	<li><a href='?src=\ref[src];make=[PIPE_CONNECTOR];dir=1'>Connector</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_UVENT];dir=1'>Unary Vent</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_PASV_VENT];dir=1'>Passive Vent</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_PUMP];dir=1'>Gas Pump</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_PASSIVE_GATE];dir=1'>Passive Gate</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_VOLUME_PUMP];dir=1'>Volume Pump</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_SCRUBBER];dir=1'>Scrubber</a></li>
	<li><a href='?src=\ref[src];makemeter=1'>Meter</a></li>
	<li><a href='?src=\ref[src];makegsensor=1'>Gas Sensor</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_GAS_FILTER];dir=1'>Gas Filter</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_GAS_FILTER];dir=9'>Gas Filter \[M]</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_GAS_MIXER];dir=1'>Gas Mixer</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_GAS_MIXER];dir=9'>Gas Mixer \[M]</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_THERMAL_PLATE];dir=1'>Thermal Plate</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_INJECTOR];dir=1'>Injector</a></li>
</ul>
<b>Heat exchange:</b>
<ul>
	<li><a href='?src=\ref[src];make=[PIPE_HE_STRAIGHT];dir=1'>Pipe</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_HE_BENT];dir=5'>Bent Pipe</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_JUNCTION];dir=1'>Junction</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_HEAT_EXCHANGE];dir=1'>Heat Exchanger</a></li>
</ul>
<b>Insulated pipes:</b>
<ul>
	<li><a href='?src=\ref[src];make=[PIPE_INSULATED_STRAIGHT];dir=1'>Pipe</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_INSULATED_BENT];dir=5'>Bent Pipe</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_INSUL_MANIFOLD];dir=1'>Manifold</a></li>
	<li><a href='?src=\ref[src];make=[PIPE_INSUL_MANIFOLD4W];dir=1'>4-Way Manifold</a></li>
</ul>
"}
//What number the make points to is in the define # at the top of construction.dm in same folder

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	onclose(user, "pipedispenser")
	return

/obj/machinery/pipedispenser/Topic(href, href_list)
	if(..())
		return
	if(!anchored || !usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=pipedispenser")
		return
	usr.set_machine(src)
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
	if(href_list["makegsensor"])
		if(!wait)
			new /obj/item/pipe_gsensor(/*usr.loc*/ src.loc)
			wait = 1
			spawn(15)
				wait = 0
	return

/obj/machinery/pipedispenser/attackby(var/obj/item/W as obj, var/mob/user as mob)
	src.add_fingerprint(usr)
	if (istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter) || istype(W, /obj/item/pipe_gsensor))
		usr << "\blue You put [W] back to [src]."
		user.drop_item()
		del(W)
		return
	else
		return ..()

/obj/machinery/pipedispenser/wrenchAnchor(mob/user)
	if(..() == 1)
		if(anchored)
			src.stat &= ~MAINT
			power_change()
		else
			src.stat |= MAINT
			if (user.machine==src)
				user << browse(null, "window=pipedispenser")


/obj/machinery/pipedispenser/disposal
	name = "Disposal Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	anchored = 1.0

/obj/machinery/pipedispenser/disposal/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/pipedispenser/disposal,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator
	)

	RefreshParts()

/*
//Allow you to push disposal pipes into it (for those with density 1)
/obj/machinery/pipedispenser/disposal/Crossed(var/obj/structure/disposalconstruct/pipe as obj)
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
<A href='?src=\ref[src];dmake=[DISP_PIPE_STRAIGHT]'>Pipe</A><BR>
<A href='?src=\ref[src];dmake=[DISP_PIPE_BENT]'>Bent Pipe</A><BR>
<A href='?src=\ref[src];dmake=[DISP_JUNCTION]'>Junction</A><BR>
<A href='?src=\ref[src];dmake=[DISP_YJUNCTION]'>Y-Junction</A><BR>
<A href='?src=\ref[src];dmake=[DISP_END_TRUNK]'>Trunk</A><BR>
<A href='?src=\ref[src];dmake=[DISP_END_BIN]'>Bin</A><BR>
<A href='?src=\ref[src];dmake=[DISP_END_OUTLET]'>Outlet</A><BR>
<A href='?src=\ref[src];dmake=[DISP_END_CHUTE]'>Chute</A><BR>
"}

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return

// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk


/obj/machinery/pipedispenser/disposal/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["dmake"])
		if(!anchored || !usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			usr << browse(null, "window=pipedispenser")
			return
		if(!wait)
			var/p_type = text2num(href_list["dmake"])
			var/obj/structure/disposalconstruct/C = new (src.loc)
			switch(p_type)
				if(0)
					C.ptype = 0
				if(1)
					C.ptype = 1
				if(2)
					C.ptype = 2
				if(3)
					C.ptype = 4
				if(4)
					C.ptype = 5
				if(5)
					C.ptype = 6
					C.density = 1
				if(6)
					C.ptype = 7
					C.density = 1
				if(7)
					C.ptype = 8
					C.density = 1
			C.add_fingerprint(usr)
			C.update()
			wait = 1
			spawn(15)
				wait = 0
	return

