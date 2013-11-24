//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:
RCD
*/
/obj/item/weapon/pipe_dispenser
	name = "Rapid Piping Device (RPD)"
	desc = "A device used to rapidly pipe things."
	icon = 'icons/obj/items.dmi'
	icon_state = "rpd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 50000
	origin_tech = "engineering=4;materials=2"
	var/datum/effect/effect/system/spark_spread/spark_system
	var/working = 0
	var/p_type = 0
	var/p_conntype = 0
	var/p_dir = 1
	var/p_class = 0


/obj/item/weapon/pipe_dispenser/New()
	src.spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/weapon/pipe_dispenser/attack_self(mob/user as mob)
	show_menu(user)

/obj/item/weapon/pipe_dispenser/proc/show_menu(mob/user as mob)
	if(!user || !src)	return 0
	var/dat = {"
<h2>Type</h2>
<b>Utilities:</b><br />
<A href='?src=\ref[src];eatpipes=1;type=-1'>Eat Pipes</A><BR>
<b>Regular pipes:</b><BR>
<A href='?src=\ref[src];makepipe=0;dir=1;type=0'>Pipe</A><BR>
<A href='?src=\ref[src];makepipe=1;dir=5;type=1'>Bent Pipe</A><BR>
<A href='?src=\ref[src];makepipe=5;dir=1;type=2'>Manifold</A><BR>
<A href='?src=\ref[src];makepipe=8;dir=1;type=0'>Manual Valve</A><BR>
<A href='?src=\ref[src];makepipe=18;dir=1;type=0'>Digital Valve</A><BR>
<A href='?src=\ref[src];makepipe=21;dir=1;type=3'>Pipe Cap</A><BR>
<A href='?src=\ref[src];makepipe=20;dir=-1'>4-Way Manifold</A><BR>
<A href='?src=\ref[src];makepipe=19;dir=2'>Manual T-Valve</A><BR>
<b>Devices:</b><BR>
<A href='?src=\ref[src];makepipe=4;dir=1;type=3'>Connector</A><BR>
<A href='?src=\ref[src];makepipe=7;dir=1;type=3'>Unary Vent</A><BR>
<A href='?src=\ref[src];makepipe=9;dir=1;type=3'>Gas Pump</A><BR>
<A href='?src=\ref[src];makepipe=15;dir=1;type=3'>Passive Gate</A><BR>
<A href='?src=\ref[src];makepipe=16;dir=1;type=3'>Volume Pump</A><BR>
<A href='?src=\ref[src];makepipe=10;dir=1;type=3'>Scrubber</A><BR>
<A href='?src=\ref[src];makemeter=1;type=3'>Meter</A><BR>
<A href='?src=\ref[src];makepipe=13;dir=1;type=2'>Gas Filter</A><BR>
<A href='?src=\ref[src];makepipe=14;dir=1;type=2'>Gas Mixer</A><BR>
<A href='?src=\ref[src];makepipe=[PIPE_THERMAL_PLATE];dir=1;type=3'>Thermal Plate</A><BR>
<b>Heat exchange:</b><BR>
<A href='?src=\ref[src];makepipe=2;dir=1;type=0'>Pipe</A><BR>
<A href='?src=\ref[src];makepipe=3;dir=5;type=1'>Bent Pipe</A><BR>
<A href='?src=\ref[src];makepipe=6;dir=1;type=0'>Junction</A><BR>
<A href='?src=\ref[src];makepipe=17;dir=1;type=3'>Heat Exchanger</A><BR>
<b>Insulated pipes:</b><BR>
<A href='?src=\ref[src];makepipe=11;dir=1;type=0'>Pipe</A><BR>
<A href='?src=\ref[src];makepipe=12;dir=5;type=1'>Bent Pipe</A><BR>

<b>Disposal Pipes</b><br><br>
<A href='?src=\ref[src];dmake=0;type=0'>Pipe</A><BR>
<A href='?src=\ref[src];dmake=1;type=1'>Bent Pipe</A><BR>
<A href='?src=\ref[src];dmake=2;type=2'>Junction</A><BR>
<A href='?src=\ref[src];dmake=3;type=2'>Y-Junction</A><BR>
<A href='?src=\ref[src];dmake=4;type=2'>Trunk</A><BR>
<A href='?src=\ref[src];dmake=5;type=3'>Bin</A><BR>
<A href='?src=\ref[src];dmake=6;type=3'>Outlet</A><BR>
<A href='?src=\ref[src];dmake=7;type=3'>Chute</A><BR>
"}

	var/dirsel="<h2>Direction</h2>"
	switch(p_conntype)
		if(0) // Straight, N-S, W-E
			dirsel+={"
		<p>
			<a href="?src=\ref[src];setdir=1" title="vertical">&#8597;</a>
			<a href="?src=\ref[src];setdir=4" title="horizontal">&harr;</a>
		</p>
			"}
		if(1) // Bent, N-W, N-E etc
			dirsel+={"
		<p>
			<a href="?src=\ref[src];setdir=9" title="West to North">&#9565;</a>
			<a href="?src=\ref[src];setdir=5" title="North to East">&#9562;</a>
			<br />
			<a href="?src=\ref[src];setdir=10" title="South to West">&#9559;</a>
			<a href="?src=\ref[src];setdir=6" title="East to South">&#9556;</a>
		</p>
			"}
		if(2) // Manifold
			dirsel+={"
		<p>
			<a href="?src=\ref[src];setdir=1" title="West, South, East">&#9574;</a>
			<a href="?src=\ref[src];setdir=4" title="North, West, South">&#9571;</a>
			<br />
			<a href="?src=\ref[src];setdir=2" title="East, North, West">&#9577;</a>
			<a href="?src=\ref[src];setdir=8" title="South, East, North">&#9568;</a>
		</p>
			"}
		if(3) // Unary
			dirsel+={"
		<p>
			<a href="?src=\ref[src];setdir=[NORTH]" title="North">&uarr;</a>
			<a href="?src=\ref[src];setdir=[EAST]" title="East">&rarr;</a>
			<a href="?src=\ref[src];setdir=[SOUTH]" title="South">&darr;</a>
			<a href="?src=\ref[src];setdir=[WEST]" title="West">&larr;</a>
		</p>
			"}
	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><body>[dirsel][dat]</body>", "window=pipedispenser")
	onclose(user, "pipedispenser")
	return

/obj/item/weapon/pipe_dispenser/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		usr << browse(null, "window=pipedispenser")
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["setdir"])
		p_dir= text2num(href_list["setdir"])
		show_menu(usr)

	if(href_list["eatpipes"])
		p_class = -1
		p_conntype=-1
		p_dir=1
		src.spark_system.start()
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)

	if(href_list["makepipe"])
		p_type = text2num(href_list["makepipe"])
		p_dir = text2num(href_list["dir"])
		p_conntype = text2num(href_list["type"])
		p_class = 0
		src.spark_system.start()
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)

	if(href_list["makemeter"])
		p_class = 1
		p_conntype=-1
		p_dir=1
		src.spark_system.start()
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)

	if(href_list["dmake"])
		p_type = text2num(href_list["dmake"])
		p_conntype = text2num(href_list["type"])
		p_dir = 1
		p_class = 2
		src.spark_system.start()
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)


/obj/item/weapon/pipe_dispenser/afterattack(atom/A, mob/user)
	if(!isrobot(user) && !ishuman(user))
		return 0
	if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
		return 0

	switch(p_class)
		if(-1) // Eating pipes
			// Must click on an actual pipe or meter.
			if(istype(A,/obj/item/pipe) || istype(A,/obj/item/pipe_meter) || istype(A,/obj/structure/disposalconstruct))
				user << "Destroying Pipe..."
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				if(do_after(user, 5))
					activate()
					del(A)
					return 1
				return 0

			// Avoid spewing errors about invalid mode -1 when clicking on stuff that aren't pipes.
			user << "The [src]'s error light flickers.  Perhaps you need to only use it on pipes and pipe meters?"
			return 0
		if(0)
			if(!(istype(A, /turf)))
				return 0
			user << "Building Pipes ..."
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 20))
				activate()
				var/obj/item/pipe/P = new (A, pipe_type=p_type, dir=p_dir)
				P.update()
				P.add_fingerprint(usr)
				return 1
			return 0

		if(1)
			if(!(istype(A, /turf)))
				return 0
			user << "Building Meter..."
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 20))
				activate()
				new /obj/item/pipe_meter(A)
				return 1
			return 0

		if(2)
			if(!(istype(A, /turf)))
				return 0
			user << "Building Pipes..."
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 20))
				activate()
				var/obj/structure/disposalconstruct/C = new (A)
				// This may still produce runtimes, but I checked and /obj/structure/disposalconstruct
				//  DOES have a dir property, inherited from /obj/structure. - N3X
				C.dir=p_dir
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
				return 1
			return 0
		else
			..()
			return 0


/obj/item/weapon/pipe_dispenser/proc/activate()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

