///////////////////////////////////////////////////////////////
//Deity Link, giving a new meaning to the Adminbus since 2014//
///////////////////////////////////////////////////////////////

#define MAX_CAPACITY 16

/obj/structure/bed/chair/vehicle/adminbus//Fucking release the passengers and unbuckle yourself from the bus before you delete it.
	name = "\improper Adminbus"
	desc = "Shit just got fucking real."
	icon = 'icons/obj/bus.dmi'
	icon_state = "adminbus"
	can_spacemove=1
	layer = FLY_LAYER+1
	pixel_x = -32
	pixel_y = -32
	var/can_move=1
	var/list/passengers = list()
	var/unloading = 0
	var/bumpers = 1//1=capture mobs 2=roll over mobs(deals light brute damage and push them down) 3=gib mobs
	var/door_mode = 0//0=closed door, players cannot climb or leave on their own 1=openned door, players can climb and leave on their own
	var/list/spawned_mobs = list()//keeps track of every mobs spawned by the bus, so we can remove them all with the push of a button in needed
	var/hook = 1
	var/list/hookshot = list()
	var/obj/structure/singulo_chain/chain_base = null
	var/list/chain = list()
	var/obj/machinery/singularity/singulo = null
	var/roadlights = 0
	var/obj/structure/buslight/lightsource = null
	var/list/spawnedbombs = list()
	var/list/spawnedlasers = list()
	var/obj/structure/teleportwarp/warp = null
	var/obj/machinery/media/jukebox/superjuke/adminbus/busjuke = null

/obj/structure/bed/chair/vehicle/adminbus/New()
	..()
	var/turf/T = get_turf(src)
	T.turf_animation('icons/effects/160x160.dmi',"busteleport",-64,-32,MOB_LAYER+1,'sound/effects/busteleport.ogg')
	overlays += image(icon,"underbus",MOB_LAYER-1)
	overlays += image(icon,"ad")
	src.dir = EAST
	playsound(src, 'sound/misc/adminbus.ogg', 50, 0, 0)
	lightsource = new/obj/structure/buslight(src.loc)
	update_lightsource()
	warp = new/obj/structure/teleportwarp(src.loc)
	busjuke = new/obj/machinery/media/jukebox/superjuke/adminbus(src.loc)
	busjuke.dir = EAST
	layer = FLY_LAYER+1
	spawn(10)
		layer = FLY_LAYER+1

//Don't want the layer to change.
/obj/structure/bed/chair/vehicle/adminbus/handle_layer()
	return

/obj/structure/bed/chair/vehicle/adminbus/update_mob()
	if(occupant)
		if(iscorgi(occupant))//Hail Ian
			switch(dir)
				if(SOUTH)
					occupant.pixel_x = 6
					occupant.pixel_y = -4
				if(WEST)
					occupant.pixel_x = -16
					occupant.pixel_y = 9
				if(NORTH)
					occupant.pixel_x = 0
					occupant.pixel_y = 0
				if(EAST)
					occupant.pixel_x = 16
					occupant.pixel_y = 9
		else
			switch(dir)
				if(SOUTH)
					occupant.pixel_x = 7
					occupant.pixel_y = -12
				if(WEST)
					occupant.pixel_x = -25
					occupant.pixel_y = 1
				if(NORTH)
					occupant.pixel_x = 0
					occupant.pixel_y = 0
				if(EAST)
					occupant.pixel_x = 25
					occupant.pixel_y = 1

	for(var/i=1;i<=passengers.len;i++)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/L = A
			switch(i)
				if(1,5,9,13)
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
				if(2,6,10,14)
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
				if(3,7,11,15)
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
				if(4,8,12,16)
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

/obj/structure/bed/chair/vehicle/adminbus/Move()
	var/turf/T = get_turf(src)
	..()
	update_lightsource()
	handle_mob_bumping()
	if(warp)
		warp.forceMove(loc)
	if(busjuke)
		busjuke.forceMove(loc)
		busjuke.change_dir(dir)
		if(busjuke.icon_state)
			busjuke.repack()
	if(chain_base)
		chain_base.move_child(T)
	for(var/i=1;i<=passengers.len;i++)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/M = A
			M.forceMove(loc)
		else if(isbot(A))
			var/obj/machinery/bot/B = A
			B.forceMove(loc)
	for(var/obj/structure/hookshot/H in hookshot)
		H.forceMove(get_step(H,src.dir))

/obj/structure/bed/chair/vehicle/adminbus/proc/update_lightsource()
	var/turf/T = get_step(src,src.dir)
	if(T.opacity)
		lightsource.forceMove(T)
		switch(roadlights)							//if the bus is right against a wall, only the wall's tile is lit
			if(0)
				if(lightsource.light_range != 0)
					lightsource.set_light(0)
			if(1,2)
				if(lightsource.light_range != 1)
					lightsource.set_light(1)
	else
		T = get_step(T,src.dir)						//if there is a wall two tiles in front of the bus, the lightsource is right in front of the bus, though weaker
		if(T.opacity)
			lightsource.forceMove(get_step(src,src.dir))
			switch(roadlights)
				if(0)
					if(lightsource.light_range != 0)
						lightsource.set_light(0)
				if(1)
					if(lightsource.light_range != 1)
						lightsource.set_light(1)
				if(2)
					if(lightsource.light_range != 2)
						lightsource.set_light(2)
		else
			lightsource.forceMove(T)
			switch(roadlights)						//otherwise, the lightsource position itself two tiles in front of the bus and with regular light_range
				if(0)
					if(lightsource.light_range != 0)
						lightsource.set_light(0)
				if(1)
					if(lightsource.light_range != 2)
						lightsource.set_light(2)
				if(2)
					if(lightsource.light_range != 3)
						lightsource.set_light(3)


/obj/structure/bed/chair/vehicle/adminbus/proc/handle_mob_bumping()
	var/turf/S = get_turf(src)
	switch(bumpers)
		if(1)
			for(var/mob/living/L in S)
				if(L.flags & INVULNERABLE)
					continue
				if(passengers.len < MAX_CAPACITY)
					capture_mob(L)
				else
					if(occupant)
						to_chat(occupant, "<span class='warning'>There is no place in the bus for any additional passenger.</span>")
			for(var/obj/machinery/bot/B in S)
				if(B.flags & INVULNERABLE)
					continue
				if(passengers.len < MAX_CAPACITY)
					capture_mob(B)
		if(2)
			var/hit_sound = list('sound/weapons/genhit1.ogg','sound/weapons/genhit2.ogg','sound/weapons/genhit3.ogg')
			for(var/mob/living/L in S)
				if(L.flags & INVULNERABLE)
					continue
				L.take_overall_damage(5,0)
				if(L.locked_to)
					L.locked_to = 0
				L.Stun(5)
				L.Weaken(5)
				L.apply_effect(STUTTER, 5)
				playsound(src, pick(hit_sound), 50, 0, 0)
		if(3)
			for(var/mob/living/L in S)
				if(L.flags & INVULNERABLE)
					continue
				L.gib()
				playsound(src, 'sound/weapons/bloodyslice.ogg', 50, 0, 0)
			for(var/obj/machinery/bot/B in S)
				if(B.flags & INVULNERABLE)
					continue
				B.explode()

/obj/structure/bed/chair/vehicle/adminbus/HealthCheck()
	health = 9001//THE ADMINBUS HAS NO BRAKES

/obj/structure/bed/chair/vehicle/adminbus/Bump(var/atom/obstacle)
	if(istype(obstacle,/obj/machinery/teleport/hub))
		var/obj/machinery/teleport/hub/H = obstacle
		spawn()
			if (H.engaged)
				H.teleport(src)
				H.use_power(5000)
				src.Move()

	if(can_move)
		can_move = 0
		forceMove(get_step(src,src.dir))
		sleep(1)
		can_move = 1
	else
		return ..()

/obj/structure/bed/chair/vehicle/adminbus/proc/capture_mob(atom/A, var/selfclimb=0)
	if(passengers.len >= MAX_CAPACITY)
		to_chat(A, "<span class='warning'>\the [src] is full!</span>")
		return
	if(unloading)
		return
	if(isliving(A))
		var/mob/living/M = A
		if(M.faction == "adminbus mob")
			return
		if(M.flags & INVULNERABLE)
			return
		M.captured = 1
		M.flags |= INVULNERABLE
		M.forceMove(loc)
		M.change_dir(dir)
		M.update_canmove()
		passengers += M
		if(!selfclimb)
			to_chat(M, "<span class='warning'>\the [src] picks you up!</span>")
			if(occupant)
				to_chat(occupant, "[M.name] captured!")
		to_chat(M, "<span class='notice'>Welcome aboard \the [src]. Please keep your hands and arms inside the bus at all times.</span>")
		src.add_fingerprint(M)
	else if(isbot(A))
		var/obj/machinery/bot/B = A
		if(B.flags & INVULNERABLE)
			return
		B.turn_off()
		B.flags |= INVULNERABLE
		B.anchored = 1
		B.forceMove(loc)
		B.change_dir(dir)
		passengers += B
	update_mob()
	update_rearview()

/obj/structure/bed/chair/vehicle/adminbus/buckle_mob(mob/M, mob/user)
	if(M != user|| !ismob(M)|| get_dist(src, user) > 1|| user.restrained()|| user.lying|| user.stat|| M.locked_to|| istype(user, /mob/living/silicon)|| destroyed)
		return

	if(!(istype(user,/mob/living/carbon/human/dummy) || istype(user,/mob/living/simple_animal/corgi/Ian)))
		if(!occupant)
			to_chat(user, "<span class='warning'>Only the gods have the power to drive this monstrosity.</span>")//Yes, Ian is a god. He doesn't have his own religion for nothing.

			return
		else
			if(door_mode)
				capture_mob(user,1)
				return
			else
				to_chat(user, "<span class='notice'>You may not climb into \the [src] while its door is closed.</span>")

	else
		if(occupant)//if you are a Test Dummy and there is already a driver, you'll climb in as a passenger.
			capture_mob(M,1)
			return
		else
			if(!(user.check_rights(R_ADMINBUS)))
				to_chat(user, "<span class='notice'>Oh you are a god alright, but you don't seem to have your Adminbus driver license!</span>")
				return
			user.visible_message(
				"<span class='notice'>[user] climbs onto \the [src]!</span>",
				"<span class='notice'>You climb onto \the [src]!</span>")
			lock_atom(user)
			add_fingerprint(user)
			playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)

/obj/structure/bed/chair/vehicle/adminbus/lock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return

	var/mob/living/M = AM
	M.flags |= INVULNERABLE
	add_HUD(M)

/obj/structure/bed/chair/vehicle/adminbus/manual_unbuckle(mob/user as mob)
	if(occupant && occupant == user)	//Are you the driver?
		var/mob/living/M = occupant
		M.visible_message(
			"<span class='notice'>[M.name] unbuckles \himself!</span>",
			"You unbuckle yourself from \the [src].")
		unlock_atom(M)
		src.add_fingerprint(user)
	else
		if(door_mode)
			if(locate(user) in passengers)
				freed(user)
				return
			else
				capture_mob(user,1)
				return
		else
			if(istype(user,/mob/living/carbon/human/dummy) || istype(user,/mob/living/simple_animal/corgi/Ian))
				if(locate(user) in passengers)
					freed(user)
					return
				else
					capture_mob(user,1)
					return
			else
				if(locate(user) in passengers)
					to_chat(user, "<span class='notice'>You may not leave the Adminbus at the current time.</span>")
					return
				else
					to_chat(user, "<span class='notice'>You may not climb into \the [src] while its door is closed.</span>")
					return

/obj/structure/bed/chair/vehicle/adminbus/unlock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return

	var/mob/living/M = AM

	remove_HUD(M)
	M.flags &= ~INVULNERABLE

/obj/structure/bed/chair/vehicle/adminbus/proc/add_HUD(var/mob/M)
	if(!M || !(M.hud_used))	return

	M.hud_used.adminbus_hud()
	update_rearview()

/obj/structure/bed/chair/vehicle/adminbus/proc/remove_HUD(var/mob/M)
	if(!M || !(M.hud_used))	return

	M.hud_used.remove_adminbus_hud()

/obj/structure/bed/chair/vehicle/adminbus/proc/update_rearview()
	if(occupant)
		for(var/i=1;i<=MAX_CAPACITY;i++)
			var/mob/living/M = occupant
			M.client.screen -= M.gui_icons.rearviews[i]
			var/obj/screen/S = M.gui_icons.rearviews[i]
			var/icon/passenger_img = null
			var/atom/A = null
			if(i<=passengers.len)
				A = passengers[i]
			if(!A)
				S.icon = 'icons/adminbus/32x32.dmi'
				S.icon_state = ""
			else
				passenger_img = getFlatIcon(A,SOUTH,0)
				S.icon = passenger_img
				M.gui_icons.rearviews[i] = S
				M.client.screen += M.gui_icons.rearviews[i]

/obj/structure/bed/chair/vehicle/adminbus/emp_act(severity)
	return

/obj/structure/bed/chair/vehicle/adminbus/bullet_act(var/obj/item/projectile/Proj)
	visible_message("<span class='warning'>The projectile harmlessly bounces off the bus.</span>")
	return

/obj/structure/bed/chair/vehicle/adminbus/ex_act(severity)
	visible_message("<span class='warning'>The bus withstands the explosion with no damage.</span>")
	return

/obj/structure/bed/chair/vehicle/adminbus/cultify()
	return

/obj/structure/bed/chair/vehicle/adminbus/singuloCanEat()
	return 0

/obj/structure/bed/chair/vehicle/adminbus/singularity_act()
	return 0

/obj/structure/bed/chair/vehicle/adminbus/singularity_pull()
	return 0

/////HOOKSHOT/////////

/obj/structure/hookshot
	name = "admin chain"
	desc = "Who knows what these chains can hold..."
	icon = 'icons/obj/singulo_chain.dmi'
	icon_state = "chain"
	pixel_x = -32
	pixel_y = -32
	density = 0
	layer = 6.9
	var/max_distance = 7
	var/obj/structure/bed/chair/vehicle/adminbus/abus = null
	var/dropped = 0

/obj/structure/hookshot/claw
	name = "admin claw"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "singulo_catcher"
	pixel_x = -32
	pixel_y = -32
	layer = 7

/obj/structure/hookshot/claw/proc/hook_throw(var/toward)
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
		var/obj/machinery/singularity/S2 = hook_throw(toward)
		if(S2)
			return S2
		else
			return null
	else
		return null

/obj/structure/hookshot/proc/hook_back()
	forceMove(get_step_towards(src,abus))
	max_distance++
	if(max_distance >= 7)
		qdel(src)
		return
	sleep(2)
	.()

/obj/structure/hookshot/claw/hook_back()
	if(!dropped)
		var/obj/machinery/singularity/S = locate(/obj/machinery/singularity) in src.loc
		if(S)
			if(abus.occupant)
				var/mob/living/M = abus.occupant
				M.gui_icons.adminbus_hook.icon_state = "icon_singulo"
			abus.capture_singulo(S)
			return
	forceMove(get_step_towards(src,abus))
	max_distance++
	if(max_distance >= 7)
		if(abus.occupant)
			var/mob/living/M = abus.occupant
			M.gui_icons.adminbus_hook.icon_state = "icon_hook"
		abus.hook = 1
		qdel(src)
		return
	sleep(2)
	.()

/obj/structure/hookshot/ex_act(severity)
	return

/obj/structure/hookshot/cultify()
	return

/obj/structure/hookshot/singuloCanEat()
	return 0

/obj/structure/hookshot/singularity_act()
	return 0

/obj/structure/hookshot/singularity_pull()
	return 0

/////SINGULO CHAIN/////////

/obj/structure/singulo_chain
	name = "singularity chain"
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

/obj/structure/singulo_chain/singuloCanEat()
	return 0

/obj/structure/singulo_chain/singularity_act()
	return 0

/obj/structure/singulo_chain/singularity_pull()
	return 0

/////ROADLIGHTS/////////

/obj/structure/buslight//the things you have to do to pretend that your bus has directional lights...
	name = ""
	desc = ""
	anchored = 1
	density = 0
	opacity = 0
	mouse_opacity = 0

/obj/structure/buslight/ex_act(severity)
	return

/obj/structure/buslight/cultify()
	return

/obj/structure/buslight/singuloCanEat()
	return 0

/obj/structure/buslight/singularity_act()
	return 0

/obj/structure/buslight/singularity_pull()
	return 0


/////TELEPORT WARP/////////

/obj/structure/teleportwarp
	name = "teleportation warp"
	desc = "The bus is about to jump..."
	icon = 'icons/effects/160x160.dmi'
	icon_state = ""
	pixel_x = -64
	pixel_y = -64
	layer = MOB_LAYER-1
	anchored = 1
	density = 0
	mouse_opacity = 0

/obj/structure/teleportwarp/ex_act(severity)
	return

/obj/structure/teleportwarp/cultify()
	return

/obj/structure/teleportwarp/singuloCanEat()
	return 0

/obj/structure/teleportwarp/singularity_act()
	return 0

/obj/structure/teleportwarp/singularity_pull()
	return 0

#undef MAX_CAPACITY
