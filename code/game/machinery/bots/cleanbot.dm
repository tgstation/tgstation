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
	var/obj/effect/decal/cleanable/target
	var/obj/effect/decal/cleanable/oldtarget
	var/oldloc = null
	req_access = list(ACCESS_JANITOR)
	var/path[] = new()
	var/patrol_path[] = null
	var/beacon_freq = 1445		// navigation beacon frequency
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/should_patrol
	var/next_dest
	var/next_dest_loc

/obj/machinery/bot/cleanbot/New()
	..()
	src.get_targets()
	src.icon_state = "cleanbot[src.on]"

	should_patrol = 1

	src.botcard = new /obj/item/weapon/card/id(src)
	src.botcard.access = get_access("Janitor")

	if(radio_controller)
		radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)


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
Behaviour controls are [src.locked ? "locked" : "unlocked"]"},
text("<A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A>"))
	if(!src.locked)
		dat += text({"<BR>Cleans Blood: []<BR>"}, text("<A href='?src=\ref[src];operation=blood'>[src.blood ? "Yes" : "No"]</A>"))
		dat += text({"<BR>Patrol station: []<BR>"}, text("<A href='?src=\ref[src];operation=patrol'>[src.should_patrol ? "Yes" : "No"]</A>"))
	//	dat += text({"<BR>Beacon frequency: []<BR>"}, text("<A href='?src=\ref[src];operation=freq'>[src.beacon_freq]</A>"))
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
		if("patrol")
			src.should_patrol =!src.should_patrol
			src.patrol_path = null
			src.updateUsrDialog()
		if("freq")
			var/freq = text2num(input("Select frequency for  navigation beacons", "Frequnecy", num2text(beacon_freq / 10))) * 10
			if (freq > 0)
				src.beacon_freq = freq
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
	else
		return ..()

/obj/machinery/bot/cleanbot/Emag(mob/user as mob)
	..()
	if(user) user << "The [src] buzzes and beeps."
	src.oddbutton = 1
	src.screwloose = 1
	src.panelopen = 0
	src.locked = 1

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
		if(istype(loc,/turf/simulated))
			var/turf/simulated/T = src.loc
			if(T.wet < 1)
				T.wet = 1
				if(T.wet_overlay)
					T.overlays -= T.wet_overlay
					T.wet_overlay = null
				T.wet_overlay = image('water.dmi',T,"wet_floor")
				T.overlays += T.wet_overlay
				spawn(800)
					if (istype(T) && T.wet < 2)
						T.wet = 0
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null
	if(src.oddbutton && prob(5))
		for(var/mob/O in viewers(src, null))
			O.show_message(text("Something flies out of [src]. He seems to be acting oddly."), 1)
		var/obj/effect/decal/cleanable/blood/gibs/gib = new /obj/effect/decal/cleanable/blood/gibs(src.loc)
		//gib.streak(list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		src.oldtarget = gib
	if(!src.target || src.target == null)
		for (var/obj/effect/decal/cleanable/D in view(7,src))
			for(var/T in src.target_types)
				if(!(D in cleanbottargets) && (D.type == T || D.parent_type == T) && D != src.oldtarget)
					src.oldtarget = D
					src.target = D
					return

	if(!src.target || src.target == null)
		if(src.loc != src.oldloc)
			src.oldtarget = null

		if (!should_patrol)
			return

		if (!patrol_path || patrol_path.len < 1)
			var/datum/radio_frequency/frequency = radio_controller.return_frequency(beacon_freq)

			if(!frequency) return

			closest_dist = 9999
			closest_loc = null
			next_dest_loc = null

			var/datum/signal/signal = new()
			signal.source = src
			signal.transmission_method = 1
			signal.data = list("findbeacon" = "patrol")
			frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
			spawn(5)
				if (!next_dest_loc)
					next_dest_loc = closest_loc
				if (next_dest_loc)
					src.patrol_path = AStar(src.loc, next_dest_loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_ortho, 0, 120, id=botcard, exclude=null)
					src.patrol_path = reverselist(src.patrol_path)
		else
			patrol_move()
			spawn(5)
				patrol_move()

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
		patrol_path = null
		if(src.loc == src.target.loc)
			clean(src.target)
			src.path = new()
			src.target = null
			return

	src.oldloc = src.loc

/obj/machinery/bot/cleanbot/proc/patrol_move()
	if (src.patrol_path.len <= 0)
		return

	var/next = src.patrol_path[1]
	src.patrol_path -= next
	if (next == src.loc)
		return

	var/moved = step_towards(src, next)
	if (!moved)
		failed_steps++
	if (failed_steps > 4)
		patrol_path = null
		next_dest = null
		failed_steps = 0
	else
		failed_steps = 0

/obj/machinery/bot/cleanbot/receive_signal(datum/signal/signal)
	var/recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	var/dist = get_dist(src, signal.source.loc)
	if (dist < closest_dist && signal.source.loc != src.loc)
		closest_dist = dist
		closest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]

	if (recv == next_dest)
		next_dest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]

/obj/machinery/bot/cleanbot/proc/get_targets()
	src.target_types = new/list()

	target_types += /obj/effect/decal/cleanable/oil
	target_types += /obj/effect/decal/cleanable/vomit
	target_types += /obj/effect/decal/cleanable/robot_debris
	target_types += /obj/effect/decal/cleanable/crayon
	target_types += /obj/effect/decal/cleanable/mucus
	target_types += /obj/effect/decal/cleanable/robot_debris
	target_types += /obj/effect/decal/cleanable/molten_item
	target_types += /obj/effect/decal/cleanable/tomato_smudge
	target_types += /obj/effect/decal/cleanable/egg_smudge
	target_types += /obj/effect/decal/cleanable/pie_smudge

	if(src.blood)
		target_types += /obj/effect/decal/cleanable/xenoblood/
		target_types += /obj/effect/decal/cleanable/xenoblood/xgibs
		target_types += /obj/effect/decal/cleanable/blood/
		target_types += /obj/effect/decal/cleanable/blood/gibs/
		target_types += /obj/effect/decal/cleanable/dirt

/obj/machinery/bot/cleanbot/proc/clean(var/obj/effect/decal/cleanable/target)
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

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	del(src)
	return

/obj/item/weapon/bucket_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		var/cleanbots = 0
		for(var/obj/machinery/bot/cleanbot in world)
			cleanbots++
		if(cleanbots >= 6) //For some reason it starts at 4, so max limit is actually 2.
			user << "\red The station frequencies can't handle anymore cleanbots!" //TOO MANY GODDAMN CLEANBOTS
			cleanbots = 0
			return
		var/obj/machinery/bot/cleanbot/A = new /obj/machinery/bot/cleanbot
		A.loc = get_turf(src.loc)
		A.name = src.created_name
		user << "You add the robot arm to the bucket and sensor assembly! Beep boop!"
		del(W)
		del(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		t = copytext(sanitize(t), 1, MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t