///////////////////////////////////////////////////////////////
//Deity Link, giving a new meaning to the Adminbus since 2014//
///////////////////////////////////////////////////////////////
/obj/structure/stool/bed/chair/vehicle/adminbus//Fucking release the passengers and unbuckle yourself from the bus before you delete it.
	name = "\improper Adminbus"
	desc = "Shit just got fucking real."
	icon = 'icons/obj/bus.dmi'
	icon_state = "adminbus"
	can_spacemove=1
	var/can_move=1
	layer = FLY_LAYER
	pixel_x = -32
	pixel_y = -32
	var/list/overlays_bus[4]//1=underlay 2=roadlights 3=ad 4=door
	var/list/passengers[] = list()
	var/unloading = 0
	var/capture_mode = 1//1=capture mobs 2=roll over mobs(deals light brute damage and push them down) 3=gib mobs
	var/door_mode = 0//0=closed door, players cannot climb or leave on their own 1=openned door, players can climb and leave on their own
	var/spawned_mobs[] = list()//keeps track of every mobs spawned by the bus, so we can remove them all with the push of a button in needed
	var/hook = 1
	var/hookshot[] = list()
	var/obj/structure/singulo_chain/chain_base = null
	var/chain[] = list()
	var/obj/machinery/singularity/singulo = null
	var/roadlights = 0
	var/obj/structure/buslight/lightsource = null
	var/spawnedbombs[] = list()
	var/spawnedlasers[] = list()
	var/obj/structure/teleportwarp/warp = null

/obj/structure/stool/bed/chair/vehicle/adminbus/New()
	..()
	var/turf/T = get_turf(src)
	T.busteleport(0)
	var/image/underbus = image(icon,"underbus",MOB_LAYER-1)
	var/image/roadlights = image(icon,"roadlights",LIGHTING_LAYER+1)
	var/image/advertisement = image(icon,"ad")
	var/image/opendoor = image(icon,"opendoor")
	overlays_bus[1] = underbus
	overlays_bus[2] = roadlights
	overlays_bus[3] = advertisement
	overlays_bus[4] = opendoor
	overlays += overlays_bus[1]
	overlays += overlays_bus[3]
	src.dir = 4
	playsound(src, 'sound/misc/adminbus.ogg', 50, 0, 0)
	lightsource = new/obj/structure/buslight(src.loc)
	lightsource.x += 2
	warp = new/obj/structure/teleportwarp(src.loc)

/obj/structure/stool/bed/chair/vehicle/adminbus/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		if(iscorgi(buckled_mob))//Hail Ian
			switch(dir)
				if(SOUTH)
					buckled_mob.pixel_x = 6
					buckled_mob.pixel_y = -4
				if(WEST)
					buckled_mob.pixel_x = -16
					buckled_mob.pixel_y = 9
				if(NORTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 0
				if(EAST)
					buckled_mob.pixel_x = 16
					buckled_mob.pixel_y = 9
		else
			switch(dir)
				if(SOUTH)
					buckled_mob.pixel_x = 7
					buckled_mob.pixel_y = -12
				if(WEST)
					buckled_mob.pixel_x = -25
					buckled_mob.pixel_y = 1
				if(NORTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 0
				if(EAST)
					buckled_mob.pixel_x = 25
					buckled_mob.pixel_y = 1

	for(var/i=1;i<=passengers.len;i++)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/L = A
			if((i==1)||(i==5)||(i==9)||(i==13))
				switch(dir)
					if(SOUTH)
						L.pixel_x = -6
						L.pixel_y = 0
					if(WEST)
						L.pixel_x = -13
						L.pixel_y = 4
					if(NORTH)
						L.pixel_x = -6
						L.pixel_y = 0
					if(EAST)
						L.pixel_x = 12
						L.pixel_y = 4
			else if((i==2)||(i==6)||(i==10)||(i==14))
				switch(dir)
					if(SOUTH)
						L.pixel_x = 6
						L.pixel_y = 0
					if(WEST)
						L.pixel_x = -1
						L.pixel_y = 4
					if(NORTH)
						L.pixel_x = 6
						L.pixel_y = 0
					if(EAST)
						L.pixel_x = 1
						L.pixel_y = 4
			else if((i==3)||(i==7)||(i==11)||(i==15))
				switch(dir)
					if(SOUTH)
						L.pixel_x = -3
						L.pixel_y = 8
					if(WEST)
						L.pixel_x = 11
						L.pixel_y = 4
					if(NORTH)
						L.pixel_x = -3
						L.pixel_y = 8
					if(EAST)
						L.pixel_x = -11
						L.pixel_y = 4
			else if((i==4)||(i==8)||(i==12)||(i==16))
				switch(dir)
					if(SOUTH)
						L.pixel_x = 7
						L.pixel_y = -12
					if(WEST)
						L.pixel_x = 22
						L.pixel_y = 4
					if(NORTH)
						L.pixel_x = -3
						L.pixel_y = 8
					if(EAST)
						L.pixel_x = -22
						L.pixel_y = 4
			L.dir = dir

/obj/structure/stool/bed/chair/vehicle/adminbus/Move()
	var/turf/T = get_turf(src)
	..()
	update_lightsource()
	handle_mob_bumping()
	if(warp)
		warp.loc = src.loc
	if(chain_base)
		chain_base.move_child(T)
	for(var/i=1;i<=passengers.len;i++)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/M = A
			M.loc = src.loc
		else if(isbot(A))
			var/obj/machinery/bot/B = A
			B.loc = src.loc
	for(var/obj/structure/hookshot/H in hookshot)
		H.forceMove(get_step(H,src.dir))

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/update_lightsource()
	lightsource.z = z
	switch(dir)
		if(SOUTH)
			lightsource.x = x
			lightsource.y = y-2
		if(WEST)
			lightsource.x = x-2
			lightsource.y = y
		if(NORTH)
			lightsource.x = x
			lightsource.y = y+2
		if(EAST)
			lightsource.x = x+2
			lightsource.y = y

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/handle_mob_bumping()
	var/turf/S = get_turf(src)
	switch(capture_mode)
		if(1)
			for(var/mob/living/L in S)
				if(L.isolated)
					continue
				if(passengers.len < 16)
					capture_mob(L)
				else
					buckled_mob << "<span class='warning'>There is no place in the bus for any additional passenger.</span>"
			for(var/obj/machinery/bot/B in S)
				if(B.isolated)
					continue
				if(passengers.len < 16)
					capture_mob(B)
		if(2)
			var/hit_sound = list('sound/weapons/genhit1.ogg','sound/weapons/genhit2.ogg','sound/weapons/genhit3.ogg')
			for(var/mob/living/L in S)
				if(L.isolated)
					continue
				L.take_overall_damage(5,0)
				if(L.buckled)
					L.buckled = 0
				L.Stun(5)
				L.Weaken(5)
				L.apply_effect(STUTTER, 5)
				playsound(src, pick(hit_sound), 50, 0, 0)
		if(3)
			for(var/mob/living/L in S)
				if(L.isolated)
					continue
				L.gib()
				playsound(src, 'sound/weapons/bloodyslice.ogg', 50, 0, 0)
			for(var/obj/machinery/bot/B in S)
				if(B.isolated)
					continue
				B.explode()
/obj/structure/stool/bed/chair/vehicle/adminbus/handle_rotation()
	layer = FLY_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null
			buckled_mob.buckled = src

	update_mob()

/obj/structure/stool/bed/chair/vehicle/adminbus/HealthCheck()
	health = 100//THE ADMINBUS HAS NO BRAKES

/obj/structure/stool/bed/chair/vehicle/adminbus/Bump(var/atom/obstacle)
	if(istype(obstacle,/obj/machinery/teleport/hub))
		var/obj/machinery/teleport/hub/H = obstacle
		spawn()
			if (H.icon_state == "tele1")
				H.teleport(src)
				H.use_power(5000)
				src.Move()
	if(can_move)
		can_move = 0
		forceMove(get_step(src,src.dir))
		if(buckled_mob)
			if(buckled_mob.loc != loc)
				buckled_mob.buckled = null //Temporary, so Move() succeeds.
				buckled_mob.buckled = src //Restoring
		sleep(1)
		can_move = 1
	else
		. = ..()
	return

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/capture_mob(atom/A, var/selfclimb=0)
	if(passengers.len >= 16)
		A << "<span class='warning'>The bus is full!</span>"
		return
	if(unloading)
		return
	if(isliving(A))
		var/mob/living/M = A
		if(M.faction == "admin")
			return
		if(M.isolated)
			return
		M.captured = 1
		M.isolated = 1
		M.loc = src.loc
		M.dir = src.dir
		M.update_canmove()
		passengers += M
		if(!selfclimb)
			M << "<span class='warning'>The Adminbus picks you up!</span>"
			if(buckled_mob)
				buckled_mob << "[M.name] captured!"
		M << "<span class='notice'>Welcome aboard the Adminbus. Please keep your hands and arms inside the bus at all times.</span>"
		src.add_fingerprint(M)
	else if(isbot(A))
		var/obj/machinery/bot/B = A
		if(B.isolated)
			return
		B.turn_off()
		B.isolated = 1
		B.anchored = 1
		B.loc = src.loc
		B.dir = src.dir
		passengers += B
	update_mob()

/obj/structure/stool/bed/chair/vehicle/adminbus/buckle_mob(mob/M, mob/user)
	if(M != user || !ismob(M) || get_dist(src, user) > 1 || user.restrained() || user.lying || user.stat || M.buckled || istype(user, /mob/living/silicon) || destroyed)
		return

	if(!(istype(user,/mob/living/carbon/human/dummy) || istype(user,/mob/living/simple_animal/corgi/Ian)))
		if(!buckled_mob)
			user << "<span class='warning'>Only the gods have the power to drive this monstrosity.</span>"//Yes, Ian is a god. He doesn't have his own religion for nothing.
			return
		else
			if(door_mode)
				capture_mob(usr,1)
				return
			else
				usr << "<span class='notice'>You may not climb into the Adminbus while its door is closed.</span>"
				return
	else
		if(buckled_mob)//if you are a Test Dummy and there is already a driver, you'll climb in as a passenger.
			capture_mob(M,1)
			return
		else
			user.visible_message(\
				"<span class='notice'>[user] climbs onto the Adminbus!</span>",\
				"<span class='notice'>You climb onto the Adminbus!</span>")
			user.buckled = src
			user.loc = loc
			user.dir = dir
			user.update_canmove()
			user.isolated = 1
			buckled_mob = user
			update_mob()
			add_fingerprint(user)
			if(!roadlights)
				overlays += overlays_bus[2]
				roadlights = 1
				lightsource.SetLuminosity(2)
			playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
			return


/obj/structure/stool/bed/chair/vehicle/adminbus/manual_unbuckle(mob/user as mob)
	if((buckled_mob) && (buckled_mob == user))	//Are you the driver?
		buckled_mob.visible_message(\
			"<span class='notice'>[buckled_mob.name] unbuckled \himself!</span>",\
			"You unbuckle yourself from the Adminbus.")
		unbuckle()
		src.add_fingerprint(user)
		return
	else
		if(door_mode)
			if(locate(usr) in passengers)
				freed(usr)
				return
			else
				capture_mob(usr,1)
				return
		else
			if(istype(user,/mob/living/carbon/human/dummy) || istype(user,/mob/living/simple_animal/corgi/Ian))
				if(locate(usr) in passengers)
					freed(usr)
					return
				else
					capture_mob(usr,1)
					return
			else
				if(locate(usr) in passengers)
					usr << "<span class='notice'>You may not leave the Adminbus at the current time.</span>"
					return
				else
					usr << "<span class='notice'>You may not climb into the Adminbus while its door is closed.</span>"
					return

/obj/structure/stool/bed/chair/vehicle/adminbus/unbuckle()
	if(buckled_mob)
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_canmove()
		buckled_mob.isolated = 0
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
		buckled_mob = null
		if(roadlights)
			overlays -= overlays_bus[2]
			roadlights = 0
			lightsource.SetLuminosity(0)
	return

/obj/structure/stool/bed/chair/vehicle/adminbus/emp_act(severity)
	return

/obj/structure/stool/bed/chair/vehicle/adminbus/bullet_act(var/obj/item/projectile/Proj)
	visible_message("<span class='warning'>The projectile harmlessly bounces off the bus.</span>")
	return

/obj/structure/stool/bed/chair/vehicle/adminbus/ex_act(severity)
	visible_message("<span class='warning'>The bus withstands the explosion with no damage.</span>")
	return

/obj/structure/stool/bed/chair/vehicle/adminbus/cultify()
	return

/////HOOKSHOT/////////

/obj/structure/hookshot
	name = "\improper admin chain"
	desc = "Who knows what these chains can hold..."
	icon = 'icons/obj/singulo_chain.dmi'
	icon_state = "chain"
	pixel_x = -32
	pixel_y = -32
	density = 0
	layer = 6.9
	var/max_distance = 7
	var/obj/structure/stool/bed/chair/vehicle/adminbus/abus = null
	var/dropped = 0

/obj/structure/hookshot/claw
	name = "\improper admin claw"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "singulo_catcher"
	pixel_x = -32
	pixel_y = -32
	layer = 7

/obj/structure/hookshot/claw/proc/launchin(var/toward)
	max_distance--
	var/obj/machinery/singularity/S = locate(/obj/machinery/singularity) in src.loc
	if(S)
		return S
	else
		var/obj/structure/hookshot/H = new/obj/structure/hookshot(src.loc)
		abus.hookshot += H
		H.dir = toward
		H.max_distance = max_distance
		H.abus = abus
	if(max_distance > 0)
		forceMove(get_step(src,toward))
		sleep(2)
		var/obj/machinery/singularity/S2 = launchin(toward)
		if(S2)
			return S2
		else
			return null
	else
		return null

/obj/structure/hookshot/proc/returnin()
	forceMove(get_step_towards(src,abus))
	max_distance++
	if(max_distance >= 7)
		del(src)
		return
	sleep(2)
	returnin()

/obj/structure/hookshot/claw/returnin()
	if(!dropped)
		var/obj/machinery/singularity/S = locate(/obj/machinery/singularity) in src.loc
		if(S)
			abus.capture_singulo(S)
	forceMove(get_step_towards(src,abus))
	max_distance++
	if(max_distance >= 7)
		abus.hook = 1
		del(src)
		return
	sleep(2)
	returnin()

/obj/structure/hookshot/ex_act(severity)
	return

/obj/structure/hookshot/cultify()
	return

/////SINGULO CHAIN/////////

/obj/structure/singulo_chain
	name = "\improper singularity chain"
	desc = "Admins are above all logic"
	icon = 'icons/obj/singulo_chain.dmi'
	icon_state = "chain"
	pixel_x = -32
	pixel_y = -32
	density = 0
	var/obj/structure/singulo_chain/child = null

/obj/structure/singulo_chain/anchor
	icon_state = ""
	var/obj/machinery/singularity/target = null

/obj/structure/singulo_chain/ex_act(severity)
	return

/obj/structure/singulo_chain/proc/move_child(var/turf/parent)
	var/turf/T = get_turf(src)
	if(parent)//I don't see how this could be null but a sanity check won't hurt
		src.loc = parent
	if(child)
		if(get_dist(src,child) > 1)
			child.move_child(T)
		dir = get_dir(child,src)
	else
		dir = get_dir(T,src)

/obj/structure/singulo_chain/anchor/move_child(var/turf/parent)
	var/turf/T = get_turf(src)
	if(parent)
		src.loc = parent
	else
		dir = get_dir(T,src)
	if(target)
		target.loc = src.loc

/obj/structure/singulo_chain/cultify()
	return

/////ROADLIGHTS/////////

/obj/structure/buslight//the things you have to do to pretend that your bus has directional lights...
	name = ""
	desc = ""
	anchored = 1
	density = 0

/obj/structure/buslight/ex_act(severity)
	return

/obj/structure/buslight/cultify()
	return

/////TELEPORT WARP/////////

/obj/structure/teleportwarp
	name = "\improper teleportation warp"
	desc = "The bus is about to jump..."
	icon = 'icons/effects/160x160.dmi'
	icon_state = ""
	pixel_x = -64
	pixel_y = -64
	layer = MOB_LAYER-1
	anchored = 1
	density = 0

/obj/structure/teleportwarp/ex_act(severity)
	return

/obj/structure/teleportwarp/cultify()
	return
