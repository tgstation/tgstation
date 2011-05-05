//Cleanbot assembly
/obj/item/weapon/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS
	var/created_name = "Cleanbot"


//Cleanbot
/obj/machinery/bot/cleanbot
	name = "Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'aibots.dmi'
	icon_state = "cleanbot0"
	layer = 5.0
	density = 0
	anchored = 0
	//weight = 1.0E7
	health = 25
	maxhealth = 25
	var/cleaning = 0
	var/locked = 1
	var/screwloose = 0
	var/oddbutton = 0
	var/blood = 1
	var/panelopen = 0
	var/list/target_types = list()
	var/obj/decal/cleanable/target
	var/obj/decal/cleanable/oldtarget
	var/oldloc = null
	req_access = list(access_janitor)
	var/path[] = new()

/obj/machinery/bot/cleanbot/New()
	..()
	src.get_targets()
	src.icon_state = "cleanbot[src.on]"


/obj/machinery/bot/cleanbot/turn_on()
	. = ..()
	src.icon_state = "cleanbot[src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/cleanbot/turn_off()
	..()
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.icon_state = "cleanbot[src.on]"
	src.path = new()
	src.updateUsrDialog()

/obj/machinery/bot/cleanbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	usr.machine = src
	interact(user)

/obj/machinery/bot/cleanbot/proc/interact(mob/user as mob)
	var/dat
	dat += text({"
<TT><B>Automatic Station Cleaner v1.0</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]""},
text("<A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A>"))
	if(!src.locked)
		dat += text({"<BR>
Cleans Blood: []<BR>"},
text("<A href='?src=\ref[src];operation=blood'>[src.blood ? "Yes" : "No"]</A>"))
	if(src.panelopen && !src.locked)
		dat += text({"
Odd looking screw twiddled: []<BR>
Weird button pressed: []"},
text("<A href='?src=\ref[src];operation=screw'>[src.screwloose ? "Yes" : "No"]</A>"),
text("<A href='?src=\ref[src];operation=oddbutton'>[src.oddbutton ? "Yes" : "No"]</A>"))

	user << browse("<HEAD><TITLE>Cleaner v1.0 controls</TITLE></HEAD>[dat]", "window=autocleaner")
	onclose(user, "autocleaner")
	return

/obj/machinery/bot/cleanbot/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	switch(href_list["operation"])
		if("start")
			if (src.on)
				turn_off()
			else
				turn_on()
		if("blood")
			src.blood =!src.blood
			src.get_targets()
			src.updateUsrDialog()
		if("screw")
			src.screwloose = !src.screwloose
			usr << "You twiddle the screw."
			src.updateUsrDialog()
		if("oddbutton")
			src.oddbutton = !src.oddbutton
			usr << "You press the weird button."
			src.updateUsrDialog()

/obj/machinery/bot/cleanbot/attackby(obj/item/weapon/W, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(src.allowed(usr))
			src.locked = !src.locked
			user << "You [ src.locked ? "lock" : "unlock"] the [src] behaviour controls."
		else
			user << "\red This [src] doesn't seem to accept your authority."
	else if (istype(W, /obj/item/weapon/screwdriver))
		if(!src.locked)
			src.panelopen = !src.panelopen
			user << "You [ src.panelopen ? "open" : "close"] the hidden panel on [src]."
	/*if (istype(W, /obj/item/weapon/card/cryptographic_sequencer))
		user << "The [src] buzzes and beeps."
		src.oddbutton = 1
		src.screwloose = 1
		src.panelopen = 0
		src.locked = 1*/
	else
		return ..()

/obj/machinery/bot/cleanbot/process()
	set background = 1

	if(!src.on)
		return
	if(src.cleaning)
		return
	var/list/cleanbottargets = list()
	if(!src.target || src.target == null)
		for(var/obj/machinery/bot/cleanbot/bot in world)
			if(bot != src)
				cleanbottargets += bot.target

	if(prob(5) && !src.screwloose && !src.oddbutton)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("[src] makes an excited beeping booping sound!"), 1)

	if(src.screwloose && prob(5))
		for(var/mob/O in viewers(src, null))
			O.show_message(text("[src] leaks a drop of water. How strange."), 1)
		var/turf/U = src.loc
		U:wet = 1
		//U.overlays += /obj/effects/wet_floor
		spawn(800)
			U:wet = 0
			U.overlays = null
	if(src.oddbutton && prob(5))
		for(var/mob/O in viewers(src, null))
			O.show_message(text("Something flies out of [src]. He seems to be acting oddly."), 1)
		var/obj/decal/cleanable/blood/gibs/gib = new /obj/decal/cleanable/blood/gibs(src.loc)
		//gib.streak(list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		src.oldtarget = gib
	if(!src.target || src.target == null)
		for (var/obj/decal/cleanable/D in view(7,src))
			for(var/T in src.target_types)
				if(!(D in cleanbottargets) && (D.type == T || D.parent_type == T) && D != src.oldtarget)
					src.oldtarget = D
					src.target = D
					return

	if(!src.target || src.target == null)
		if(src.loc != src.oldloc)
			src.oldtarget = null
		return

	if(src.target && (src.target != null) && src.path.len == 0)
		spawn(0)
			src.path = AStar(src.loc, src.target.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 0, 30)
			src.path = reverselist(src.path)
			if(src.path.len == 0)
				src.oldtarget = src.target
				src.target = null
		return
	if(src.path.len > 0 && src.target && (src.target != null))
		step_to(src, src.path[1])
		src.path -= src.path[1]
	else if(src.path.len == 1)
		step_to(src, target)

	if(src.target && (src.target != null))
		if(src.loc == src.target.loc)
			clean(src.target)
			src.path = new()
			src.target = null
			return

	src.oldloc = src.loc

/obj/machinery/bot/cleanbot/proc/get_targets()
	src.target_types = new/list()
	if(src.blood)

		target_types += /obj/decal/cleanable/xenoblood/
		target_types += /obj/decal/cleanable/xenoblood/xgibs
		target_types += /obj/decal/cleanable/blood/
		target_types += /obj/decal/cleanable/blood/gibs/
		target_types += /obj/decal/cleanable/oil
		target_types += /obj/decal/cleanable/robot_debris
		target_types += /obj/decal/cleanable/crayon

/obj/machinery/bot/cleanbot/proc/clean(var/obj/decal/cleanable/target)
	src.anchored = 1
	src.icon_state = "cleanbot-c"
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red [src] begins to clean up the [target]"), 1)
	src.cleaning = 1
	spawn(50)
		src.cleaning = 0
		del(target)
		src.icon_state = "cleanbot[src.on]"
		src.anchored = 0
		src.target = null

/obj/machinery/bot/cleanbot/explode()
	src.on = 0
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)

	new /obj/item/device/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	del(src)
	return

/obj/item/weapon/bucket_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		var/obj/machinery/bot/cleanbot/A = new /obj/machinery/bot/cleanbot
		if(user.r_hand == src || user.l_hand == src)
			A.loc = user.loc
		else
			A.loc = src.loc
		A.name = src.created_name
		user << "You add the robot arm to the bucket and sensor assembly! Beep boop!"
		del(W)
		del(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t






