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
	var/obj/machinery/power/solar/control/control
	var/obj/machinery/power/solar_assembly/solar_assembly

/obj/machinery/power/solar/panel/New(loc)
	..(loc)
	make()

/obj/machinery/power/solar/panel/proc/make()
	if(!solar_assembly)
		solar_assembly = new /obj/machinery/power/solar_assembly()
		solar_assembly.glass_type = /obj/item/stack/sheet/rglass
		solar_assembly.anchored = 1

	solar_assembly.loc = src
	update_icon()

/obj/machinery/power/solar/panel/attackby(obj/item/weapon/W, mob/user)
	if(iscrowbar(W))
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, 50))
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] takes the glass off the solar panel.</span>")
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
			solar_assembly.glass_type = null //The glass you're looking for is below pal
			getFromPool(/obj/item/weapon/shard, loc)
			getFromPool(/obj/item/weapon/shard, loc)
			qdel(src)

/obj/machinery/power/solar/panel/update_icon()
	..()

	overlays.len = 0

	if(stat & BROKEN)
		if(solar_assembly.glass_type == /obj/item/stack/sheet/glass)
			overlays += image('icons/obj/power.dmi', icon_state = "solar_panel-b", layer = FLY_LAYER)
		else if(solar_assembly.glass_type == /obj/item/stack/sheet/rglass)
			overlays += image('icons/obj/power.dmi', icon_state = "solar_panel_ref-b", layer = FLY_LAYER)
		else if(solar_assembly.glass_type == /obj/item/stack/sheet/glass/plasmaglass)
			overlays += image('icons/obj/power.dmi', icon_state = "solar_panel_plasma-b", layer = FLY_LAYER)
		else if(solar_assembly.glass_type == /obj/item/stack/sheet/rglass/plasmarglass)
			overlays += image('icons/obj/power.dmi', icon_state = "solar_panel_plasma_ref-b", layer = FLY_LAYER)
	else if(solar_assembly.glass_type == /obj/item/stack/sheet/glass)
		overlays += image('icons/obj/power.dmi', icon_state = "solar_panel", layer = FLY_LAYER)
		src.dir = angle2dir(adir)
	else if(solar_assembly.glass_type == /obj/item/stack/sheet/rglass)
		overlays += image('icons/obj/power.dmi', icon_state = "solar_panel_ref", layer = FLY_LAYER)
		src.dir = angle2dir(adir)
	else if(solar_assembly.glass_type == /obj/item/stack/sheet/glass/plasmaglass)
		overlays += image('icons/obj/power.dmi', icon_state = "solar_panel_plasma", layer = FLY_LAYER)
		src.dir = angle2dir(adir)
	else if(solar_assembly.glass_type == /obj/item/stack/sheet/rglass/plasmarglass)
		overlays += image('icons/obj/power.dmi', icon_state = "solar_panel_plasma_ref", layer = FLY_LAYER)
		src.dir = angle2dir(adir)

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
		adir = (360 + adir + dd_range(-10, 10, ndir-adir)) % 360
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
		qdel(src)

/obj/machinery/power/solar/panel/ex_act(severity)
	switch(severity)
		if(1.0)
			solar_assembly.glass_type = null //The glass you're looking for is below pal
			if(prob(15))
				getFromPool(/obj/item/weapon/shard, loc)
			qdel(src)
		if(2.0)
			if(prob(25))
				solar_assembly.glass_type = null //The glass you're looking for is below pal
				getFromPool(/obj/item/weapon/shard, loc)
				qdel(src)
			else
				broken()
		if(3.0)
			if(prob(35))
				broken()
			else
				health-- //Let shrapnel have its effect

/obj/machinery/power/solar/panel/disconnect_from_network()
	. = ..()

	if(.)
		control = null
