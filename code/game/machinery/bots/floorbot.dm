//Floorbot assemblies
/obj/item/weapon/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	var/created_name = "Floorbot"

/obj/item/weapon/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	var/created_name = "Floorbot"

//Floorbot
/obj/machinery/bot/floorbot
	name = "\improper Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "floorbot0"
	layer = 5.0
	density = 0
	anchored = 0
	health = 25
	maxhealth = 25
	//weight = 1.0E7
	var/amount = 10
	var/replacetiles = 0
	var/eattiles = 0
	var/maketiles = 0
	var/fixfloors = 0
	var/autotile = 0
	var/nag_on_empty = 1
	var/nagged = 0 //Prevents the Floorbot nagging more than once per refill.
	var/max_targets = 50
	var/turf/target
	var/turf/oldtarget
	var/oldloc = null
	req_one_access = list(access_construction, access_robotics)
	var/targetdirection
	radio_frequency = 1357 //Engineering channel
	bot_type = FLOOR_BOT
	bot_filter = RADIO_FLOORBOT

/obj/machinery/bot/floorbot/New()
	..()
	updateicon()
	var/datum/job/engineer/J = new/datum/job/engineer
	botcard.access = J.get_access()
	prev_access = botcard.access

	spawn(5)
		add_to_beacons(bot_filter)

/obj/machinery/bot/floorbot/turn_on()
	. = ..()
	updateicon()
	updateUsrDialog()

/obj/machinery/bot/floorbot/turn_off()
	..()
	updateicon()
	updateUsrDialog()

/obj/machinery/bot/floorbot/bot_reset()
	..()
	target = null
	oldtarget = null
	oldloc = null
	ignore_list = list()
	nagged = 0
	anchored = 0

/obj/machinery/bot/floorbot/set_custom_texts()
	text_hack = "You corrupt [name]'s construction protocols."
	text_dehack = "You detect errors in [name] and reset his programming."
	text_dehack_fail = "[name] is not responding to reset commands!"

/obj/machinery/bot/floorbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/bot/floorbot/interact(mob/user as mob)
	var/dat
	dat += hack(user)
	dat += "<TT><B>Floor Repairer Controls v1.1</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "Tiles left: [amount]<BR>"
	dat += "Behvaiour controls are [locked ? "locked" : "unlocked"]<BR>"
	if(!locked || issilicon(user))
		dat += "Add tiles to new hull plating: <A href='?src=\ref[src];operation=autotile'>[autotile ? "Yes" : "No"]</A><BR>"
		dat += "Replace floor tiles: <A href='?src=\ref[src];operation=replace'>[replacetiles ? "Yes" : "No"]</A><BR>"
		dat += "Finds tiles: <A href='?src=\ref[src];operation=tiles'>[eattiles ? "Yes" : "No"]</A><BR>"
		dat += "Make pieces of metal into tiles when empty: <A href='?src=\ref[src];operation=make'>[maketiles ? "Yes" : "No"]</A><BR>"
		dat += "Transmit notice when empty: <A href='?src=\ref[src];operation=emptynag'>[nag_on_empty ? "Yes" : "No"]</A><BR>"
		dat += "Repair damaged tiles and platings: <A href='?src=\ref[src];operation=fix'>[fixfloors ? "Yes" : "No"]</A><BR>"
		dat += "Patrol Station: <A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A><BR>"
		var/bmode
		if (targetdirection)
			bmode = dir2text(targetdirection)
		else
			bmode = "Disabled"
		dat += "<BR><BR>Bridge Mode : <A href='?src=\ref[src];operation=bridgemode'>[bmode]</A><BR>"

	var/datum/browser/popup = new(user, "autofloor", "Automatic Station Floor Repairer v1.1")
	popup.set_content(dat)
	popup.open()
	return


/obj/machinery/bot/floorbot/attackby(var/obj/item/W , mob/user as mob)
	if(istype(W, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/T = W
		if(amount >= 50)
			return
		var/loaded = min(50-amount, T.amount)
		T.use(loaded)
		amount += loaded
		if (loaded > 0)
			user << "<span class='notice'>You load [loaded] tiles into the floorbot. He now contains [amount] tiles.</span>"
			nagged = 0
			updateicon()
		else
			user << "<span class='warning'>You need at least one floor tile to put into [src]</span>"
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(user) && !open && !emagged)
			locked = !locked
			user << "<span class='notice'>You [locked ? "lock" : "unlock"] \the [src] behaviour controls.</span>"
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='warning'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='warning'>Access denied.</span>"
		updateUsrDialog()
	else
		..()

/obj/machinery/bot/floorbot/Emag(mob/user as mob)
	..()
	if(emagged == 2)
		if(user) user << "<span class='danger'>[src] buzzes and beeps.</span>"

/obj/machinery/bot/floorbot/Topic(href, href_list)
	..()
	switch(href_list["operation"])
		if("replace")
			replacetiles = !replacetiles
		if("tiles")
			eattiles = !eattiles
		if("make")
			maketiles = !maketiles
		if("fix")
			fixfloors = !fixfloors
		if("autotile")
			autotile = !autotile
		if("emptynag")
			nag_on_empty = !nag_on_empty

		if("bridgemode")
			switch(targetdirection)
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
	updateUsrDialog()

/obj/machinery/bot/floorbot/process()
	if (!..())
		return

	if(mode == BOT_REPAIRING)
		return

	if(mode == BOT_SUMMON)
		bot_summon()
		return

	if(amount <= 0 && !target)
		if(eattiles)
			for(var/obj/item/stack/tile/plasteel/T in view(7, src))
				if(T != oldtarget && !(target in ignore_list))
					oldtarget = T
					target = T
					break
		if(!target)
			if(maketiles)
				if(!target)
					for(var/obj/item/stack/sheet/metal/M in view(7, src))
						if(!(M in ignore_list) && M != oldtarget && !(istype(M.loc, /turf/simulated/wall)))
							oldtarget = M
							target = M
							break
		else
			return
		if(nag_on_empty) //Floorbot is empty and cannot acquire more tiles, nag the engineers for more!
			nag()
	if(prob(5))
		visible_message("[src] makes an excited booping beeping sound!")

	if(!target && emagged < 2 && amount > 0)
		if(targetdirection != null) //The bot is in bridge mode.

			for (var/turf/space/D in view(7,src))
				if(!(D in ignore_list) && D != oldtarget)			// Added for bridging mode
					if(get_dir(src, D) == targetdirection)
						oldtarget = D
						target = D
						anchored = 1
						break

			var/turf/T = get_step(src, targetdirection)
			if(istype(T, /turf/space))
				oldtarget = T
				target = T
		if(!target)
			for (var/turf/space/D in view(7,src)) //Ensures the floorbot does not try to "fix" space areas or shuttle docking zones.
				if(!(D in ignore_list) && D != oldtarget && is_hull_breach(D))
					mode = BOT_MOVING
					oldtarget = D
					target = D
					anchored = 1 //Prevent the floorbot being blown off-course while trying to reach a hull breach.
					break
		if(!target && replacetiles) //Finds a floor without a tile and gives it one.
			for (var/turf/simulated/floor/F in view(7,src))
					//The target must be the floor and not a tile. The floor must not already have a floortile.
				if(!(F in ignore_list) && F != oldtarget && F.is_plating())
					oldtarget = F
					target = F
					mode = BOT_MOVING
					break
		if(!target && fixfloors) //Repairs damaged floors and tiles.
			for(var/turf/simulated/floor/F in view(7, src))
				if(!(F in ignore_list) && F != oldtarget && (F.broken || F.burnt))
					oldtarget = F
					target = F
					mode = BOT_MOVING
					break

	if(!target && emagged == 2)
		if(!target)
			for (var/turf/simulated/floor/D in view(7,src))
				if(!(D in ignore_list) && D != oldtarget && D.floor_tile)
					oldtarget = D
					target = D
					mode = BOT_MOVING
					break

	if(!target)

		if(auto_patrol)
			if(mode == BOT_IDLE || mode == BOT_START_PATROL)
				start_patrol()

			if(mode == BOT_PATROL)
				bot_patrol()

	if(!target)
		if(loc != oldloc)
			oldtarget = null
		return

	if(target && path.len == 0)
		spawn(0)
			if(!istype(target, /turf/))
				var/turf/TL = get_turf(target)
				path = AStar(loc, TL, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30, id=botcard)
			else
				path = AStar(loc, target, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance, 0, 30, id=botcard)
			if(!path)
				path = list()
			if(path.len == 0)
				add_to_ignore(target)
				oldtarget = target
				target = null
				mode = BOT_IDLE
		return
	if(path.len > 0 && target)
		step_to(src, path[1])
		path -= path[1]
	else if(path.len == 1)
		step_to(src, target)
		path = new()

	if(loc == target || loc == target.loc)
		if(istype(target, /obj/item/stack/tile/plasteel))
			eattile(target)
		else if(istype(target, /obj/item/stack/sheet/metal))
			maketile(target)
		else if(istype(target, /turf/) && emagged < 2)
			repair(target)
		else if(emagged == 2 && istype(target,/turf/simulated/floor))
			var/turf/simulated/floor/F = target
			anchored = 1
			mode = BOT_REPAIRING
			if(prob(90))
				F.break_tile_to_plating()
			else
				F.ReplaceWithLattice()
			visible_message("<span class='danger'>[src] makes an excited booping sound.</span>")
			spawn(50)
				amount ++
				anchored = 0
				mode = BOT_IDLE
				target = null
		path = new()
		return

	oldloc = loc

/obj/machinery/bot/floorbot/proc/nag() //Annoy everyone on the channel to refill us!
	if(!nagged)
		speak("Requesting refill at <b>[get_area(src)]</b>!", radio_frequency)
		nagged = 1

/obj/machinery/bot/floorbot/proc/is_hull_breach(var/turf/t) //Ignore space tiles not considered part of a structure, also ignores shuttle docking areas.
	var/area/t_area = get_area(t)
	if (t_area && (t_area.name == "Space" || findtext(t_area.name, "huttle")))
		return 0
	else
		return 1

/obj/machinery/bot/floorbot/proc/repair(var/turf/target)

	if(istype(target, /turf/space/))
		 //Must be a hull breach or in bridge mode to continue.
		if(!is_hull_breach(target) && !targetdirection)
			target = null
			return
	else if(!istype(target, /turf/simulated/floor))
		return
	if(amount <= 0)
		mode = BOT_IDLE
		target = null
		return
	var/turf/simulated/floor/F
	var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
	anchored = 1
	icon_state = "floorbot-c"
	if(istype(target, /turf/space/)) //If we are fixing an area not part of pure space, it is
		visible_message("<span class='notice'> [targetdirection ? "[src] begins installing a bridge plating." : "[src] begins to repair the hole."] </span>")
		mode = BOT_REPAIRING
		spawn(50)
			if(mode == BOT_REPAIRING)
				if(autotile) //Build the floor and include a tile.
					F = target.ChangeTurf(/turf/simulated/floor)
				else //Build a hull plating without a floor tile.
					T.build(loc)

				mode = BOT_IDLE
				amount -= 1
				updateicon()
				anchored = 0
				src.target = null
	else

		F = target

		mode = BOT_REPAIRING
		visible_message("<span class='notice'> [src] begins repairing the floor.</span>")
		spawn(50)
			if(mode == BOT_REPAIRING)
				F = target
				F.make_plasteel_floor(T)
				mode = BOT_IDLE
				amount -= 1
				updateicon()
				anchored = 0
				src.target = null

/obj/machinery/bot/floorbot/proc/eattile(var/obj/item/stack/tile/plasteel/T)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		return
	visible_message("<span class='notice'> [src] begins to collect tiles.</span>")
	mode = BOT_REPAIRING
	spawn(20)
		if(isnull(T))
			target = null
			mode = BOT_IDLE
			return
		if(amount + T.amount > 50)
			var/i = 50 - amount
			amount += i
			T.amount -= i
		else
			amount += T.amount
			qdel(T)
		updateicon()
		target = null
		mode = BOT_IDLE

/obj/machinery/bot/floorbot/proc/maketile(var/obj/item/stack/sheet/metal/M)
	if(!istype(M, /obj/item/stack/sheet/metal))
		return
	visible_message("<span class='notice'> [src] begins to create tiles.</span>")
	mode = BOT_REPAIRING
	spawn(20)
		if(isnull(M))
			target = null
			mode = BOT_IDLE
			return
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		T.amount = 4
		T.loc = M.loc
		if(M.amount > 1)
			M.amount--
		else
			qdel(M)
		target = null
		mode = BOT_IDLE

/obj/machinery/bot/floorbot/proc/updateicon()
	if(amount > 0)
		icon_state = "floorbot[on]"
	else
		icon_state = "floorbot[on]e"

/obj/machinery/bot/floorbot/explode()
	on = 0
	visible_message("<span class='userdanger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/storage/toolbox/mechanical/N = new /obj/item/weapon/storage/toolbox/mechanical(Tsec)
	N.contents = list()

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	while (amount)//Dumps the tiles into the appropriate sized stacks
		if(amount >= 16)
			var/obj/item/stack/tile/plasteel/T = new (Tsec)
			T.amount = 16
			amount -= 16
		else
			var/obj/item/stack/tile/plasteel/T = new (Tsec)
			T.amount = amount
			amount = 0

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return


/obj/item/weapon/storage/toolbox/mechanical/attackby(var/obj/item/stack/tile/plasteel/T, mob/user as mob)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		..()
		return
	if(contents.len >= 1)
		user << "<span class='alert'>They won't fit in, as there is already stuff inside.</span>"
		return
	if(T.use(10))
		if(user.s_active)
			user.s_active.close(user)
		var/obj/item/weapon/toolbox_tiles/B = new /obj/item/weapon/toolbox_tiles
		user.put_in_hands(B)
		user << "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>"
		user.unEquip(src, 1)
		qdel(src)
	else
		user << "<span class='alert'>You need 10 floor tiles to start building a floorbot.</span>"
		return

/obj/item/weapon/toolbox_tiles/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(isprox(W))
		qdel(W)
		var/obj/item/weapon/toolbox_tiles_sensor/B = new /obj/item/weapon/toolbox_tiles_sensor()
		B.created_name = created_name
		user.put_in_hands(B)
		user << "<span class='notice'>You add the sensor to the toolbox and tiles!</span>"
		user.unEquip(src, 1)
		qdel(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && loc != usr)
			return

		created_name = t

/obj/item/weapon/toolbox_tiles_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		qdel(W)
		var/turf/T = get_turf(user.loc)
		var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot(T)
		A.name = created_name
		user << "<span class='notice'>You add the robot arm to the odd looking toolbox assembly! Boop beep!</span>"
		user.unEquip(src, 1)
		qdel(src)
	else if (istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name)

		if (!t)
			return
		if (!in_range(src, usr) && loc != usr)
			return

		created_name = t