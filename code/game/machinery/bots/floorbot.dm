//Floorbot assemblies
/obj/item/weapon/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS
	var/created_name = "Floorbot"

/obj/item/weapon/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon = 'aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS
	var/created_name = "Floorbot"

//Floorbot
/obj/machinery/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'aibots.dmi'
	icon_state = "floorbot0"
	layer = 5.0
	density = 0
	anchored = 0
	health = 25
	maxhealth = 25
	//weight = 1.0E7
	var/amount = 10
	var/repairing = 0
	var/improvefloors = 0
	var/eattiles = 0
	var/maketiles = 0
	var/locked = 1
	var/turf/target
	var/turf/oldtarget
	var/oldloc = null
	req_access = list(access_atmospherics)
	var/path[] = new()
	var/targetdirection


/obj/machinery/bot/floorbot/New()
	..()
	src.updateicon()

/obj/machinery/bot/floorbot/turn_on()
	. = ..()
	src.updateicon()
	src.updateUsrDialog()

/obj/machinery/bot/floorbot/turn_off()
	..()
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.updateicon()
	src.path = new()
	src.updateUsrDialog()

/obj/machinery/bot/floorbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	usr.machine = src
	interact(user)

/obj/machinery/bot/floorbot/proc/interact(mob/user as mob)
	var/dat
	dat += "<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A><BR>"
	dat += "Tiles left: [src.amount]<BR>"
	dat += "Behvaiour controls are [src.locked ? "locked" : "unlocked"]<BR>"
	if(!src.locked)
		dat += "Improves floors: <A href='?src=\ref[src];operation=improve'>[src.improvefloors ? "Yes" : "No"]</A><BR>"
		dat += "Finds tiles: <A href='?src=\ref[src];operation=tiles'>[src.eattiles ? "Yes" : "No"]</A><BR>"
		dat += "Make singles pieces of metal into tiles when empty: <A href='?src=\ref[src];operation=make'>[src.maketiles ? "Yes" : "No"]</A><BR>"
		var/bmode
		if (src.targetdirection)
			bmode = dir2text(src.targetdirection)
		else
			bmode = "Disabled"
		dat += "<BR><BR>Bridge Mode : <A href='?src=\ref[src];operation=bridgemode'>[bmode]</A><BR>"

	user << browse("<HEAD><TITLE>Repairbot v1.0 controls</TITLE></HEAD>[dat]", "window=autorepair")
	onclose(user, "autorepair")
	return


/obj/machinery/bot/floorbot/attackby(var/obj/item/W , mob/user as mob)
	if(istype(W, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/T = W
		if(src.amount >= 50)
			return
		var/loaded = min(50-src.amount, T.amount)
		T.use(loaded)
		src.amount += loaded
		user << "\red You load [loaded] tiles into the floorbot. He now contains [src.amount] tiles!"
		src.updateicon()
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(src.allowed(usr))
			src.locked = !src.locked
			user << "You [src.locked ? "lock" : "unlock"] the [src] behaviour controls."
		else
			user << "The [src] doesn't seem to accept your authority."
		src.updateUsrDialog()
	else
		..()


/obj/machinery/bot/floorbot/Topic(href, href_list)
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
		if("improve")
			src.improvefloors = !src.improvefloors
			src.updateUsrDialog()
		if("tiles")
			src.eattiles = !src.eattiles
			src.updateUsrDialog()
		if("make")
			src.maketiles = !src.maketiles
			src.updateUsrDialog()
		if("bridgemode")
			switch(src.targetdirection)
				if(null)
					targetdirection = 1
				if(1)
					targetdirection = 2
				if(2)
					targetdirection = 4
				if(4)
					targetdirection = 8
				if(8)
					targetdirection = null
				else
					targetdirection = null
			src.updateUsrDialog()

/obj/machinery/bot/floorbot/process()
	set background = 1

	if(!src.on)
		return
	if(src.repairing)
		return
	var/list/floorbottargets = list()
	if(!src.target)
		for(var/obj/machinery/bot/floorbot/bot in world)
			if(bot != src)
				floorbottargets += bot.target
	if(src.amount <= 0 && !src.target)
		if(src.eattiles)
			for(var/obj/item/stack/tile/plasteel/T in view(7, src))
				if(T != src.oldtarget && !(target in floorbottargets))
					src.oldtarget = T
					src.target = T
					break
		if(!src.target && src.maketiles)
			for(var/obj/item/stack/sheet/metal/M in view(7, src))
				if(!(M in floorbottargets) && M != src.oldtarget && M.amount == 1 && !(istype(M.loc, /turf/simulated/wall)))
					src.oldtarget = M
					src.target = M
					break
		else
			return
	if(prob(5))
		for(var/mob/O in viewers(src, null))
			O.show_message(text("[src] makes an excited booping beeping sound!"), 1)

	if(!src.target == null)
		if(targetdirection != null)
			/*
			for (var/turf/space/D in view(7,src))
				if(!(D in floorbottargets) && D != src.oldtarget)			// Added for bridging mode -- TLE
					if(get_dir(src, D) == targetdirection)
						src.oldtarget = D
						src.target = D
						break
			*/
			var/turf/T = get_step(src, targetdirection)
			if(istype(T, /turf/space))
				src.oldtarget = T
				src.target = T
		if(!src.target)
			for (var/turf/space/D in view(7,src))
				if(!(D in floorbottargets) && D != src.oldtarget && (D.loc.name != "Space") && !istype(D.loc, /area/shuttle))
					src.oldtarget = D
					src.target = D
					break
		if(!src.target && src.improvefloors)
			for (var/turf/simulated/floor/F in view(7,src))
				if(!(F in floorbottargets) && F != src.oldtarget && F.icon_state == "Floor1" && !(istype(F, /turf/simulated/floor/plating)))
					src.oldtarget = F
					src.target = F
					break
		if(!src.target && src.eattiles)
			for(var/obj/item/stack/tile/plasteel/T in view(7, src))
				if(!(T in floorbottargets) && T != src.oldtarget)
					src.oldtarget = T
					src.target = T
					break

	if(!src.target)
		if(src.loc != src.oldloc)
			src.oldtarget = null
		return

	if(src.target && src.path.len == 0)
		spawn(0)
			if(!istype(src.target, /turf/))
				src.path = AStar(src.loc, src.target.loc, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30)
			else
				src.path = AStar(src.loc, src.target, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30)
			src.path = reverselist(src.path)
			if(src.path.len == 0)
				src.oldtarget = src.target
				src.target = null
		return
	if(src.path.len > 0 && src.target)
		step_to(src, src.path[1])
		src.path -= src.path[1]
	else if(src.path.len == 1)
		step_to(src, target)
		src.path = new()

	if(src.loc == src.target || src.loc == src.target.loc)
		if(istype(src.target, /obj/item/stack/tile/plasteel))
			src.eattile(src.target)
		else if(istype(src.target, /obj/item/stack/sheet/metal))
			src.maketile(src.target)
		else if(istype(src.target, /turf/))
			repair(src.target)
		src.path = new()
		return

	src.oldloc = src.loc


/obj/machinery/bot/floorbot/proc/repair(var/turf/target)
	if(istype(target, /turf/space/))
		if(target.loc.name == "Space")
			return
	else if(!istype(target, /turf/simulated/floor))
		return
	if(src.amount <= 0)
		return
	src.anchored = 1
	src.icon_state = "floorbot-c"
	if(istype(target, /turf/space/))
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\red [src] begins to repair the hole"), 1)
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		src.repairing = 1
		spawn(50)
			T.build(src.loc)
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = 0
			src.target = null
	else
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\red [src] begins to improve the floor."), 1)
		src.repairing = 1
		spawn(50)
			src.loc.icon_state = "floor"
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = 0
			src.target = null

/obj/machinery/bot/floorbot/proc/eattile(var/obj/item/stack/tile/plasteel/T)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		return
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red [src] begins to collect tiles."), 1)
	src.repairing = 1
	spawn(20)
		if(isnull(T))
			src.target = null
			src.repairing = 0
			return
		if(src.amount + T.amount > 50)
			var/i = 50 - src.amount
			src.amount += i
			T.amount -= i
		else
			src.amount += T.amount
			del(T)
		src.updateicon()
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/maketile(var/obj/item/stack/sheet/metal/M)
	if(!istype(M, /obj/item/stack/sheet/metal))
		return
	if(M.amount > 1)
		return
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red [src] begins to create tiles."), 1)
	src.repairing = 1
	spawn(20)
		if(isnull(M))
			src.target = null
			src.repairing = 0
			return
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		T.amount = 4
		T.loc = M.loc
		del(M)
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/updateicon()
	if(src.amount > 0)
		src.icon_state = "floorbot[src.on]"
	else
		src.icon_state = "floorbot[src.on]e"

/obj/machinery/bot/floorbot/explode()
	src.on = 0
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/storage/toolbox/mechanical/N = new /obj/item/weapon/storage/toolbox/mechanical(Tsec)
	N.contents = list()

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	if (amount)
		new /obj/item/stack/tile/plasteel(Tsec) // only one tile, yes

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	del(src)
	return


/obj/item/weapon/storage/toolbox/mechanical/attackby(var/obj/item/stack/tile/plasteel/T, mob/user as mob)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		..()
		return
	if(src.contents.len >= 1)
		user << "They wont fit in as there is already stuff inside!"
		return
	if (user.s_active)
		user.s_active.close(user)
	var/obj/item/weapon/toolbox_tiles/B = new /obj/item/weapon/toolbox_tiles
	B.loc = user
	if (user.r_hand == T)
		user.u_equip(T)
		user.r_hand = B
	else
		user.u_equip(T)
		user.l_hand = B
	B.layer = 20
	user << "You add the tiles into the empty toolbox. They stick oddly out the top."
	del(T)
	del(src)

/obj/item/weapon/toolbox_tiles/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(isprox(W))
		var/obj/item/weapon/toolbox_tiles_sensor/B = new /obj/item/weapon/toolbox_tiles_sensor
		B.loc = user
		if (user.r_hand == W)
			user.u_equip(W)
			user.r_hand = B
		else
			user.u_equip(W)
			user.l_hand = B
		B.created_name = src.created_name
		B.layer = 20
		user << "You add the sensor to the toolbox and tiles!"
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

/obj/item/weapon/toolbox_tiles_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot
		if(user.r_hand == src || user.l_hand == src)
			A.loc = user.loc
		else
			A.loc = src.loc
		A.name = src.created_name
		user << "You add the robot arm to the odd looking toolbox assembly! Boop beep!"
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