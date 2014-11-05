//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:
RPD
*/
#define PIPE_BINARY   0
#define PIPE_BENT     1
#define PIPE_TRINARY  2
#define PIPE_UNARY    3

/datum/pipe_info
	var/id=-1
	var/dir=SOUTH
	var/dirtype=PIPE_BINARY
	var/icon = 'icons/obj/pipe-item.dmi'
	var/icon_state=""
	var/selected=0

/datum/pipe_info/New(var/pid,var/direction,var/dt)
	src.id=pid
	src.icon_state=pipeID2State[pid+1]
	src.dir=direction
	src.dirtype=dt

/datum/pipe_info/proc/Render(var/dispenser,var/label)
	return "<li><a href='?src=\ref[dispenser];makepipe=[id];dir=[dir];type=[dirtype]'>[label]</a></li>"

/datum/pipe_info/meter
	icon = 'icons/obj/pipes.dmi'
	icon_state = "meterX"

/datum/pipe_info/meter/New()
	return

/datum/pipe_info/meter/Render(var/dispenser,var/label)
	return "<li><a href='?src=\ref[dispenser];makemeter=1;type=3'>[label]</a></li>"

/datum/pipe_info/gsensor
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"

/datum/pipe_info/gsensor/New()
	return

/datum/pipe_info/gsensor/Render(var/dispenser,var/label)
	return "<li><a href='?src=\ref[dispenser];makegsensor=1;type=3'>[label]</a></li>"

var/global/list/disposalpipeID2State=list(
	"pipe-s",
	"pipe-c",
	"pipe-j1",
	"pipe-j2",
	"pipe-y",
	"pipe-t",
	"condisposal",
	"outlet",
	"intake",
	"pipe-j1s",
	"pipe-j2s"
)
/datum/pipe_info/disposal
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "meterX"

/datum/pipe_info/disposal/New(var/pid,var/dt)
	src.id=pid
	src.icon_state=disposalpipeID2State[pid+1]
	src.dir=2
	src.dirtype=dt
	if(pid<6 || pid>8)
		icon_state = "con[icon_state]"

/datum/pipe_info/disposal/Render(var/dispenser,var/label)
	return "<li><a href='?src=\ref[dispenser];dmake=[id];type=3'>[label]</a></li>"

var/global/list/RPD_recipes=list(
	"Regular Pipes" = list(
		"Pipe"           = new /datum/pipe_info(0,  1, PIPE_BINARY),
		"Bent Pipe"      = new /datum/pipe_info(1,  5, PIPE_BENT),
		"Manifold"       = new /datum/pipe_info(5,  1, PIPE_TRINARY),
		"Manual Valve"   = new /datum/pipe_info(8,  1, PIPE_BINARY),
		"Digital Valve"  = new /datum/pipe_info(18, 1, PIPE_BINARY),
		"Pipe Cap"       = new /datum/pipe_info(21, 1, PIPE_UNARY),
		"4-Way Manifold" = new /datum/pipe_info(20,-1, PIPE_BINARY),
		"Manual T-Valve" = new /datum/pipe_info(19, 2, PIPE_TRINARY),
	),
	"Devices"=list(
		"Connector"      = new /datum/pipe_info(4, 1, PIPE_UNARY),
		"Unary Vent"     = new /datum/pipe_info(7, 1, PIPE_UNARY),
		"Passive Vent"   = new /datum/pipe_info(PIPE_PASV_VENT,    1, PIPE_UNARY),
		"Gas Pump"       = new /datum/pipe_info(9, 1, PIPE_UNARY),
		"Passive Gate"   = new /datum/pipe_info(15,1, PIPE_UNARY),
		"Volume Pump"    = new /datum/pipe_info(16,1, PIPE_UNARY),
		"Scrubber"       = new /datum/pipe_info(10,1, PIPE_UNARY),
		"Meter"          = new /datum/pipe_info/meter(),
		"Gas Sensor"     = new /datum/pipe_info/gsensor(),
		"Gas Filter"     = new /datum/pipe_info(13,1, PIPE_TRINARY),
		"Gas Mixer"      = new /datum/pipe_info(14,1, PIPE_TRINARY),
		"Thermal Plate"  = new /datum/pipe_info(PIPE_THERMAL_PLATE,1, PIPE_UNARY),
		"Injector"       = new /datum/pipe_info(PIPE_INJECTOR,     1, PIPE_UNARY),
	),
	"Heat Exchange" = list(
		"Pipe"           = new /datum/pipe_info(2, 1, PIPE_BINARY),
		"Bent Pipe"      = new /datum/pipe_info(3, 5, PIPE_BENT),
		"Junction"       = new /datum/pipe_info(6, 1, PIPE_UNARY),
		"Heat Exchanger" = new /datum/pipe_info(17,1, PIPE_UNARY),
	),
	"Insulated Pipes" = list(
		"Pipe"           = new /datum/pipe_info(11,1, PIPE_BINARY),
		"Bent Pipe"      = new /datum/pipe_info(12,5, PIPE_BENT),
	),
	"Disposal Pipes" = list(
		"Pipe"       = new /datum/pipe_info/disposal(0, PIPE_BINARY),
		"Bent Pipe"  = new /datum/pipe_info/disposal(1, PIPE_BENT),
		"Junction"   = new /datum/pipe_info/disposal(2, PIPE_TRINARY),
		"Y-Junction" = new /datum/pipe_info/disposal(3, PIPE_TRINARY),
		"Trunk"      = new /datum/pipe_info/disposal(4, PIPE_TRINARY),
		"Bin"        = new /datum/pipe_info/disposal(5, PIPE_UNARY),
		"Outlet"     = new /datum/pipe_info/disposal(6, PIPE_UNARY),
		"Chute"      = new /datum/pipe_info/disposal(7, PIPE_UNARY),
	)
)
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
	m_amt = 75000
	g_amt = 37500
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "engineering=4;materials=2"
	var/datum/effect/effect/system/spark_spread/spark_system
	var/working = 0
	var/p_type = 0
	var/p_conntype = 0
	var/p_dir = 1
	var/p_class = 0
	var/p_disposal = 0
	var/list/paint_colors = list(
		"grey"   = "#cccccc",
		"red"    = "#800000",
		"blue"   = "#000080",
		"cyan"   = "#1C94C4",
		"green"  = "#00CC00",
		"yellow" = "#FFCC00",
		"purple" = "purple"
	)
	var/paint_color="grey"

/obj/item/weapon/pipe_dispenser/New()
	. = ..()
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/weapon/pipe_dispenser/attack_self(mob/user as mob)
	show_menu(user)

/obj/item/weapon/pipe_dispenser/proc/render_dir_img(var/_dir,var/pic,var/title)
	var/selected=""
	if(_dir==p_dir)
		selected=" class=\"selected\""
	return "<a href=\"?src=\ref[src];setdir=[_dir]\" title=\"[title]\"[selected]><img src=\"[pic]\" /></a>"

/obj/item/weapon/pipe_dispenser/proc/show_menu(mob/user as mob)
	if(!user || !src)	return 0
	var/dat = {"<h2>Type</h2>
<b>Utilities:</b>
<ul>
	<li><a href='?src=\ref[src];eatpipes=1;type=-1'>Eat Pipes</a></li>
	<li><a href='?src=\ref[src];paintpipes=1;type=-1'>Paint Pipes</a></li>
</ul>"}
	var/icon/preview=null
	for(var/category in RPD_recipes)
		dat += "<b>[category]:</b><ul>"
		var/list/cat=RPD_recipes[category]
		for(var/label in cat)
			var/datum/pipe_info/I = cat[label]
			var/found=0
			if(I.id == p_type)
				if(p_class==0 && I.type==/datum/pipe_info)
					found=1
				else if(p_class==2 && I.type==/datum/pipe_info/disposal)
					found=1
			if(found)
				preview=new /icon(I.icon,I.icon_state)
			dat += I.Render(src,label)
		dat += "</ul>"

	var/color_css=""
	var/color_picker=""
	for(var/color_name in paint_colors)
		var/color=paint_colors[color_name]
		color_css += {"
			a.color.[color_name] {
				color: [color];
			}
			a.color.[color_name]:hover {
				border:1px solid [color];
			}
			a.color.[color_name].selected {
				background-color: [color];
			}
		"}
		var/selected=""
		if(color_name==paint_color)
			selected = " selected"
		color_picker += {"<a class="color [color_name][selected]" href="?src=\ref[src];set_color=[color_name]">&bull;</a>"}

	var/dirsel="<h2>Direction</h2>"
	switch(p_conntype)
		if(-1)
			if(p_class==-2)
				dirsel = "<h2>Direction</h2>[color_picker]"

		if(PIPE_BINARY) // Straight, N-S, W-E
			if(preview)
				user << browse_rsc(new /icon(preview, dir=NORTH), "vertical.png")
				user << browse_rsc(new /icon(preview, dir=EAST), "horizontal.png")

				dirsel += "<p>"
				dirsel += render_dir_img(1,"vertical.png","Vertical")
				dirsel += render_dir_img(4,"horizontal.png","Horizontal")
				dirsel += "</p>"
			else
				dirsel+={"
		<p>
			<a href="?src=\ref[src];setdir=1" title="vertical">&#8597;</a>
			<a href="?src=\ref[src];setdir=4" title="horizontal">&harr;</a>
		</p>
				"}
		if(PIPE_BENT) // Bent, N-W, N-E etc
			if(preview)
				user << browse_rsc(new /icon(preview, dir=NORTHWEST),  "nw.png")
				user << browse_rsc(new /icon(preview, dir=NORTHEAST),  "ne.png")
				user << browse_rsc(new /icon(preview, dir=SOUTHWEST),  "sw.png")
				user << browse_rsc(new /icon(preview, dir=SOUTHEAST),  "se.png")

				dirsel += "<p>"
				dirsel += render_dir_img(9,"nw.png","West to North")
				dirsel += render_dir_img(5,"ne.png","North to East")
				dirsel += "<br />"
				dirsel += render_dir_img(10,"sw.png","South to West")
				dirsel += render_dir_img(6,"se.png","East to South")
				dirsel += "</p>"
			else
				dirsel+={"
		<p>
			<a href="?src=\ref[src];setdir=9" title="West to North">&#9565;</a>
			<a href="?src=\ref[src];setdir=5" title="North to East">&#9562;</a>
			<br />
			<a href="?src=\ref[src];setdir=10" title="South to West">&#9559;</a>
			<a href="?src=\ref[src];setdir=6" title="East to South">&#9556;</a>
		</p>
				"}
		if(PIPE_TRINARY) // Manifold
			if(preview)
				user << browse_rsc(new /icon(preview, dir=NORTH), "s.png")
				user << browse_rsc(new /icon(preview, dir=EAST),  "w.png")
				user << browse_rsc(new /icon(preview, dir=SOUTH), "n.png")
				user << browse_rsc(new /icon(preview, dir=WEST),  "e.png")

				dirsel += "<p>"
				dirsel += render_dir_img(1,"s.png","West South East")
				dirsel += render_dir_img(4,"w.png","North West South")
				dirsel += "<br />"
				dirsel += render_dir_img(2,"n.png","East North West")
				dirsel += render_dir_img(8,"e.png","South East North")
				dirsel += "</p>"
			else
				dirsel+={"
		<p>
			<a href="?src=\ref[src];setdir=1" title="West, South, East">&#9574;</a>
			<a href="?src=\ref[src];setdir=4" title="North, West, South">&#9571;</a>
			<br />
			<a href="?src=\ref[src];setdir=2" title="East, North, West">&#9577;</a>
			<a href="?src=\ref[src];setdir=8" title="South, East, North">&#9568;</a>
		</p>
				"}
		if(PIPE_UNARY) // Unary
			if(preview)
				user << browse_rsc(new /icon(preview, dir=NORTH), "n.png")
				user << browse_rsc(new /icon(preview, dir=EAST),  "e.png")
				user << browse_rsc(new /icon(preview, dir=SOUTH), "s.png")
				user << browse_rsc(new /icon(preview, dir=WEST),  "w.png")

				dirsel += "<p>"
				dirsel += render_dir_img(NORTH,"n.png","North")
				dirsel += render_dir_img(EAST, "e.png","East")
				dirsel += render_dir_img(SOUTH,"s.png","South")
				dirsel += render_dir_img(WEST, "w.png","West")
				dirsel += "</p>"
			else
				dirsel+={"
		<p>
			<a href="?src=\ref[src];setdir=[NORTH]" title="North">&uarr;</a>
			<a href="?src=\ref[src];setdir=[EAST]" title="East">&rarr;</a>
			<a href="?src=\ref[src];setdir=[SOUTH]" title="South">&darr;</a>
			<a href="?src=\ref[src];setdir=[WEST]" title="West">&larr;</a>
		</p>
					"}

	dat = {"
<html>
	<head>
		<title>[name]</title>
		<style type="text/css">
			html {
				font-family:sans-serif;
				font-size:small;
			}
			a{
				color:#0066cc;
				text-decoration:none;
			}

			a img {
				border:1px solid #0066cc;
				background:#dfdfdf;
			}

			a.color {
				padding: 5px 10px;
				font-size: large;
				font-weight: bold;
				border:1px solid white;
			}

			a.selected img,
			a:hover {
				background: #0066cc;
				color: #ffffff;
			}
			[color_css]
		</style>
	</head>
	<body>
[dirsel][dat]
	</body>
</html>
"}
	user << browse(dat, "window=pipedispenser")
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
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)

	if(href_list["paintpipes"])
		p_class = -2
		p_conntype=-1
		p_dir=1
		src.spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)

	if(href_list["set_color"])
		paint_color=href_list["set_color"]
		src.spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)

	if(href_list["makepipe"])
		p_type = text2num(href_list["makepipe"])
		p_dir = text2num(href_list["dir"])
		p_conntype = text2num(href_list["type"])
		p_class = 0
		src.spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)

	if(href_list["makemeter"])
		p_class = 1
		p_conntype=-1
		p_dir=1
		src.spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)

	if(href_list["makegsensor"])
		p_class = 3
		p_conntype=-1
		p_dir=1
		src.spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)

	if(href_list["dmake"])
		p_type = text2num(href_list["dmake"])
		p_conntype = text2num(href_list["type"])
		p_dir = 1
		p_class = 2
		src.spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		show_menu(usr)


/obj/item/weapon/pipe_dispenser/afterattack(atom/A, mob/user)
	if(!in_range(A,user))
		return
	if(loc != user)
		return
	if(!isrobot(user) && !ishuman(user))
		return 0
	if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
		return 0

	switch(p_class)
		if(-2) // Paint pipes
			if(!istype(A,/obj/machinery/atmospherics/pipe) || istype(A,/obj/machinery/atmospherics/pipe/tank) || istype(A,/obj/machinery/atmospherics/pipe/vent) || istype(A,/obj/machinery/atmospherics/pipe/simple/heat_exchanging) || istype(A,/obj/machinery/atmospherics/pipe/simple/insulated))
				// Avoid spewing errors about invalid mode -2 when clicking on stuff that aren't pipes.
				user << "\The [src]'s error light flickers.  Perhaps you need to only use it on pipes and pipe meters?"
				return 0
			var/obj/machinery/atmospherics/pipe/P = A
			if(!(paint_color in P.available_colors))
				user << "\red This [P] can't be painted [paint_color]. Available colors: [english_list(P.available_colors)]"
				return 0
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			P._color = paint_color
			user.visible_message("<span class='notice'>[user] paints \the [P] [paint_color].</span>","<span class='notice'>You paint \the [P] [paint_color].</span>")
			P.update_icon()
			return 1
		if(-1) // Eating pipes
			// Must click on an actual pipe or meter.
			if(istype(A,/obj/item/pipe) || istype(A,/obj/item/pipe_meter) || istype(A,/obj/structure/disposalconstruct) || istype(A,/obj/item/pipe_gsensor))
				user << "Destroying Pipe..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
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
				user << "The [src]'s error light flickers."
				return 0
			user << "Building Pipes ..."
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 20))
				activate()
				var/obj/item/pipe/P = new (A, pipe_type=p_type, dir=p_dir)
				P.update()
				P.add_fingerprint(usr)
				return 1
			return 0

		if(1)
			if(!(istype(A, /turf)))
				user << "The [src]'s error light flickers."
				return 0
			user << "Building Meter..."
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 20))
				activate()
				new /obj/item/pipe_meter(A)
				return 1
			return 0

		if(2)
			if(!(istype(A, /turf)))
				user << "The [src]'s error light flickers."
				return 0
			user << "Building Pipes..."
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
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
		if(3)
			if(!(istype(A, /turf)))
				user << "The [src]'s error light flickers."
				return 0
			user << "Building Sensor..."
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 20))
				activate()
				new /obj/item/pipe_gsensor(A)
				return 1
			return 0
		else
			..()
			return 0


/obj/item/weapon/pipe_dispenser/proc/activate()
	playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)

