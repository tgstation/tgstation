/obj/machinery/power/solar/panel
	icon_state = "sp_base"
	var/id_tag = 0
	var/health = 15 //Fragile shit, even with state-of-the-art reinforced glass
	var/maxhealth = 15 //If ANYONE ever makes it so that solars can be directly repaired without glass, also used for fancy calculations
	var/obscured = 0
	var/sunfrac = 0
	var/adir = SOUTH
	var/ndir = SOUTH
	var/turn_angle = 0
	var/glass_quality_factor = 1 //Rglass is average. Glass is shite. Tinted glass is "Are you even trying ?" tier if anyone ever makes a sheet version
	var/tracker = 0
	var/obj/machinery/power/solar/control/control
	var/obj/machinery/power/solar_assembly/solar_assembly

/obj/machinery/power/solar/panel/New(loc, var/obj/machinery/power/solar_assembly/S)
	..(loc)
	make(S)

/obj/machinery/power/solar/panel/proc/make(var/obj/machinery/power/solar_assembly/S)
	if(!S)
		solar_assembly = new /obj/machinery/power/solar_assembly()
		solar_assembly.glass_type = /obj/item/stack/sheet/glass/rglass
		solar_assembly.anchored = 1
		solar_assembly.density = 1
		solar_assembly.tracker = tracker
	else
		solar_assembly = S
		var/obj/item/stack/sheet/glass/G = solar_assembly.glass_type //This is how you call up variables from an object without making one
		src.glass_quality_factor = initial(G.glass_quality) //Don't use istype checks kids
		src.maxhealth = initial(G.shealth)
		src.health = initial(G.shealth)
	solar_assembly.loc = src
	update_icon()

/obj/machinery/power/solar/panel/attackby(obj/item/weapon/W, mob/user)
	if(iscrowbar(W))
		var/turf/T = get_turf(src)
		var/obj/item/stack/sheet/glass/G = solar_assembly.glass_type
		user << "<span class='notice'>You begin taking the [initial(G.name)] off the [src].</span>"
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, 50))
			if(solar_assembly)
				solar_assembly.loc = T
				solar_assembly.give_glass()
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] takes the [initial(G.name)] off the [src].</span>",\
			"<span class='notice'>You takes the [initial(G.name)] off the [src].</span>")
			qdel(src)
	else if(W)
		add_fingerprint(user)
		health -= W.force
		healthcheck()
	..()

/obj/machinery/power/solar/panel/blob_act()
	if(prob(30))
		broken() //Good hit
	else
		health--

	healthcheck()

/obj/machinery/power/solar/panel/proc/healthcheck()
	if(health <= 0)
		if(!(stat & BROKEN))
			broken()
		else
			var/obj/item/stack/sheet/glass/G = solar_assembly.glass_type
			var/shard = initial(G.shard_type)
			solar_assembly.glass_type = null //The glass you're looking for is below pal
			solar_assembly.loc = get_turf(src)
			getFromPool(shard, loc)
			getFromPool(shard, loc)
			qdel(src)

/obj/machinery/power/solar/panel/update_icon()
	..()
	if(!tracker)
		overlays.len = 0
		var/obj/item/stack/sheet/glass/G = solar_assembly.glass_type
		var/icon = "solar_panel_" + initial(G.sname)
		if(stat & BROKEN)
			icon += "-b"
		overlays += image('icons/obj/power.dmi', icon_state = icon, layer = FLY_LAYER)
		src.dir = angle2dir(adir)
	return

/obj/machinery/power/solar/panel/proc/update_solar_exposure()
	if(!sun)
		return

	if(obscured)
		sunfrac = 0
		return

	var/p_angle = abs((360 + adir) % 360 - (360 + sun.angle) % 360)

	if(p_angle > 90)			//If facing more than 90deg from sun, zero output
		sunfrac = 0
		return

	sunfrac = cos(p_angle) ** 2

/obj/machinery/power/solar/panel/process()//TODO: remove/add this from machines to save on processing as needed ~Carn PRIORITY
	if(stat & BROKEN)
		return

	if(!control)
		return

	if(adir != ndir)
		adir = (360 + adir + Clamp(ndir - adir, -10, 10)) % 360
		update_icon()
		update_solar_exposure()

	if(obscured)
		return

	var/sgen = SOLARGENRATE * sunfrac * glass_quality_factor * (health / maxhealth) //Raw generating power * Sun angle effect * Glass quality * Current panel health. Simple but thorough

	add_avail(sgen)

	if(powernet && control)
		if(powernet.nodes.Find(control))
			control.gen += sgen

/obj/machinery/power/solar/panel/proc/broken()
	stat |= BROKEN
	update_icon()

	if(health > 1)
		health = 1 //Only holding up on shards and scrap

/obj/machinery/power/solar/panel/meteorhit()
	if(stat & !BROKEN)
		broken()
	else
		kill()

/obj/machinery/power/solar/panel/ex_act(severity)
	switch(severity)
		if(1.0)
			solar_assembly.glass_type = null //The glass you're looking for is below pal
			if(prob(15))
				getFromPool(/obj/item/weapon/shard, loc)
			kill()
		if(2.0)
			if(prob(25))
				solar_assembly.glass_type = null //The glass you're looking for is below pal
				getFromPool(/obj/item/weapon/shard, loc)
				kill()
			else
				broken()
		if(3.0)
			if(prob(35))
				broken()
			else
				health-- //Let shrapnel have its effect

/obj/machinery/power/solar/panel/proc/kill() //To make sure you eliminate the assembly as well
	if(solar_assembly)
		var/obj/machinery/power/solar_assembly/assembly = solar_assembly
		solar_assembly = null
		qdel(assembly)
	qdel(src)

/obj/machinery/power/solar/panel/disconnect_from_network()
	. = ..()

	if(.)
		control = null