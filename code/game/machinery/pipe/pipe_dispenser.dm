/obj/machinery/pipedispenser
	name = "pipe dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	desc = "Dispenses countless types of pipes. Very useful if you need pipes."
	density = TRUE
	anchored = TRUE
	var/wait = 0
	var/piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/pipedispenser/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/pipedispenser/attack_hand(mob/user)
	if(..())
		return 1
	var/dat = {"
PIPING LAYER: <A href='?src=\ref[src];layer_down=1'>--</A><b>[piping_layer]</b><A href='?src=\ref[src];layer_up=1'>++</A><BR>
<b>Pipes:</b><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/pipe/simple];dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/pipe/simple];dir=5'>Bent Pipe</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/pipe/manifold];dir=1'>Manifold</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/pipe/layer_manifold];dir=1'>Layer Manifold</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/pipe/manifold4w];dir=1'>4-Way Manifold</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/binary/valve];dir=1'>Manual Valve</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/binary/valve/digital];dir=1'>Digital Valve</A><BR>
<b>Devices:</b><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/unary/portables_connector];dir=1'>Connector</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/unary/vent_pump];dir=1'>Vent</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/binary/pump];dir=1'>Gas Pump</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/binary/passive_gate];dir=1'>Passive Gate</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/binary/volume_pump];dir=1'>Volume Pump</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/unary/vent_scrubber];dir=1'>Scrubber</A><BR>
<A href='?src=\ref[src];makemeter=1'>Meter</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/trinary/filter];dir=1'>Gas Filter</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/trinary/mixer];dir=1'>Gas Mixer</A><BR>
<b>Heat exchange:</b><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/pipe/heat_exchanging/simple];dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/pipe/heat_exchanging/simple];dir=5'>Bent Pipe</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/pipe/heat_exchanging/manifold];dir=1'>Manifold</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w];dir=1'>4-Way Manifold</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/pipe/heat_exchanging/junction];dir=1'>Junction</A><BR>
<A href='?src=\ref[src];make=[/obj/machinery/atmospherics/components/unary/heat_exchanger];dir=1'>Heat Exchanger</A><BR>
"}


	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	onclose(user, "pipedispenser")
	return

/obj/machinery/pipedispenser/Topic(href, href_list)
	if(..())
		return 1
	if(!anchored|| !usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=pipedispenser")
		return 1
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["make"])
		if(wait < world.time)
			var/p_type = text2path(href_list["make"])
			var/p_dir = text2num(href_list["dir"])
			var/obj/item/pipe/P = new (loc, p_type, p_dir)
			P.setPipingLayer(piping_layer)
			P.add_fingerprint(usr)
			wait = world.time + 10
	if(href_list["makemeter"])
		if(wait < world.time )
			new /obj/item/pipe_meter(loc)
			wait = world.time + 15
	if(href_list["layer_up"])
		piping_layer = Clamp(++piping_layer, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	if(href_list["layer_down"])
		piping_layer = Clamp(--piping_layer, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	return

/obj/machinery/pipedispenser/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if (istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter))
		to_chat(usr, "<span class='notice'>You put [W] back into [src].</span>")
		qdel(W)
		return
	else if (istype(W, /obj/item/wrench))
		if (!anchored && !isinspace())
			playsound(src, W.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You begin to fasten \the [src] to the floor...</span>")
			if (do_after(user, 40*W.toolspeed, target = src))
				add_fingerprint(user)
				user.visible_message( \
					"[user] fastens \the [src].", \
					"<span class='notice'>You fasten \the [src]. Now it can dispense pipes.</span>", \
					"<span class='italics'>You hear ratchet.</span>")
				anchored = TRUE
				stat &= MAINT
				if (usr.machine==src)
					usr << browse(null, "window=pipedispenser")
		else if(anchored)
			playsound(src, W.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You begin to unfasten \the [src] from the floor...</span>")
			if (do_after(user, 20*W.toolspeed, target = src))
				add_fingerprint(user)
				user.visible_message( \
					"[user] unfastens \the [src].", \
					"<span class='notice'>You unfasten \the [src]. Now it can be pulled somewhere else.</span>", \
					"<span class='italics'>You hear ratchet.</span>")
				anchored = FALSE
				stat |= ~MAINT
				power_change()
	else
		return ..()


/obj/machinery/pipedispenser/disposal
	name = "disposal pipe dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	desc = "Dispenses pipes that will ultimately be used to move trash around."
	density = TRUE
	anchored = TRUE

/*
//Allow you to push disposal pipes into it (for those with density 1)
/obj/machinery/pipedispenser/disposal/Crossed(var/obj/structure/disposalconstruct/pipe as obj)
	if(istype(pipe) && !pipe.anchored)
		qdel(pipe)

Nah
*/

//Allow you to drag-drop disposal pipes and transit tubes into it
/obj/machinery/pipedispenser/disposal/MouseDrop_T(obj/structure/pipe, mob/usr)
	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if (!istype(pipe, /obj/structure/disposalconstruct) && !istype(pipe, /obj/structure/c_transit_tube) && !istype(pipe, /obj/structure/c_transit_tube_pod))
		return

	if (get_dist(usr, src) > 1 || get_dist(src,pipe) > 1 )
		return

	if (pipe.anchored)
		return

	qdel(pipe)

/obj/machinery/pipedispenser/disposal/attack_hand(mob/user)
	if(..())
		return 1

	var/dat = {"<b>Disposal Pipes</b><br><br>
<A href='?src=\ref[src];dmake=[DISP_PIPE_STRAIGHT]'>Pipe</A><BR>
<A href='?src=\ref[src];dmake=[DISP_PIPE_BENT]'>Bent Pipe</A><BR>
<A href='?src=\ref[src];dmake=[DISP_JUNCTION]'>Junction</A><BR>
<A href='?src=\ref[src];dmake=[DISP_YJUNCTION]'>Y-Junction</A><BR>
<A href='?src=\ref[src];dmake=[DISP_END_TRUNK]'>Trunk</A><BR>
<A href='?src=\ref[src];dmake=[DISP_END_BIN]'>Bin</A><BR>
<A href='?src=\ref[src];dmake=[DISP_END_OUTLET]'>Outlet</A><BR>
<A href='?src=\ref[src];dmake=[DISP_END_CHUTE]'>Chute</A><BR>
<A href='?src=\ref[src];dmake=[DISP_SORTJUNCTION]'>Sort Junction</A><BR>
"}

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return


/obj/machinery/pipedispenser/disposal/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["dmake"])
		if(wait < world.time)
			var/p_type = text2num(href_list["dmake"])
			var/obj/structure/disposalconstruct/C = new (loc,p_type)

			if(!C.can_place())
				to_chat(usr, "<span class='warning'>There's not enough room to build that here!</span>")
				qdel(C)
				return

			C.add_fingerprint(usr)
			C.update_icon()
			wait = world.time + 15
	return

//transit tube dispenser
//inherit disposal for the dragging proc
/obj/machinery/pipedispenser/disposal/transit_tube
	name = "transit tube dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = TRUE
	desc = "Dispenses pipes that will move beings around."
	anchored = TRUE

/obj/machinery/pipedispenser/disposal/transit_tube/attack_hand(mob/user)
	if(..())
		return 1

	var/dat = {"<B>Transit Tubes:</B><BR>
<A href='?src=\ref[src];tube=[TRANSIT_TUBE_STRAIGHT]'>Straight Tube</A><BR>
<A href='?src=\ref[src];tube=[TRANSIT_TUBE_STRAIGHT_CROSSING]'>Straight Tube with Crossing</A><BR>
<A href='?src=\ref[src];tube=[TRANSIT_TUBE_CURVED]'>Curved Tube</A><BR>
<A href='?src=\ref[src];tube=[TRANSIT_TUBE_DIAGONAL]'>Diagonal Tube</A><BR>
<A href='?src=\ref[src];tube=[TRANSIT_TUBE_DIAGONAL_CROSSING]'>Diagonal Tube with Crossing</A><BR>
<A href='?src=\ref[src];tube=[TRANSIT_TUBE_JUNCTION]'>Junction</A><BR>
<b>Station Equipment:</b><BR>
<A href='?src=\ref[src];tube=[TRANSIT_TUBE_STATION]'>Through Tube Station</A><BR>
<A href='?src=\ref[src];tube=[TRANSIT_TUBE_TERMINUS]'>Terminus Tube Station</A><BR>
<A href='?src=\ref[src];tube=[TRANSIT_TUBE_POD]'>Transit Tube Pod</A><BR>
"}

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return


/obj/machinery/pipedispenser/disposal/transit_tube/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	add_fingerprint(usr)
	if(wait < world.time)
		if(href_list["tube"])
			var/tube_type = text2num(href_list["tube"])
			var/obj/structure/C
			switch(tube_type)
				if(TRANSIT_TUBE_STRAIGHT)
					C = new /obj/structure/c_transit_tube(loc)
				if(TRANSIT_TUBE_STRAIGHT_CROSSING)
					C = new /obj/structure/c_transit_tube/crossing(loc)
				if(TRANSIT_TUBE_CURVED)
					C = new /obj/structure/c_transit_tube/curved(loc)
				if(TRANSIT_TUBE_DIAGONAL)
					C = new /obj/structure/c_transit_tube/diagonal(loc)
				if(TRANSIT_TUBE_DIAGONAL_CROSSING)
					C = new /obj/structure/c_transit_tube/diagonal/crossing(loc)
				if(TRANSIT_TUBE_JUNCTION)
					C = new /obj/structure/c_transit_tube/junction(loc)
				if(TRANSIT_TUBE_STATION)
					C = new /obj/structure/c_transit_tube/station(loc)
				if(TRANSIT_TUBE_TERMINUS)
					C = new /obj/structure/c_transit_tube/station/reverse(loc)
				if(TRANSIT_TUBE_POD)
					C = new /obj/structure/c_transit_tube_pod(loc)
			if(C)
				C.add_fingerprint(usr)
			wait = world.time + 15
	return
