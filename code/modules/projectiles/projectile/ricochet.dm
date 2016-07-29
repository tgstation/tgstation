// RICOCHET SHOT
//A projectile that mones only in diagonal, bounces off walls and opaque doors, goes through everything else.
/obj/item/projectile/ricochet
	name = "ricochet shot"
	damage_type = BURN
	flag = "laser"
	kill_count = 100
	layer = 13
	damage = 30
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "ricochet_head"
	animate_movement = 0
	linear_movement = 0
	custom_impact = 1
	var/pos_from = EAST	//which side of the turf is the shot coming from
	var/pos_to = SOUTH	//which side of the turf is the shot heading to
	var/bouncin = 0

	//list of objects that'll stop the shot, and apply bullet_act
	var/list/obj/ricochet_bump = list(
		/obj/effect/blob,
		/obj/machinery/turret,
		/obj/machinery/turretcover,
		/obj/mecha,
		/obj/structure/reagent_dispensers/fueltank,
		/obj/structure/bed/chair/vehicle,
		)

/obj/item/projectile/ricochet/OnFired()	//The direction and position of the projectile when it spawns depends heavily on where the player clicks.
	var/turf/T1 = get_turf(shot_from)	//From a single turf, a player can fire the ricochet rifle in 8 different directions.
	var/turf/T2 = get_turf(original)
	shot_from.update_icon()
	var/X = T2.x - T1.x
	var/Y = T2.y - T1.y
	var/X_spawn = 0
	var/Y_spawn = 0
	if(X>0)
		if(Y>0)
			if(X>Y)
				pos_from = WEST
				pos_to = NORTH
				X_spawn = 1
			else if(X<Y)
				pos_from = SOUTH
				pos_to = EAST
				Y_spawn = 1
			else
				if(prob(50))
					pos_from = WEST
					pos_to = NORTH
					X_spawn = 1
				else
					pos_from = SOUTH
					pos_to = EAST
					Y_spawn = 1
		else if(Y<0)
			if(X>(Y*-1))
				pos_from = WEST
				pos_to = SOUTH
				X_spawn = 1
			else if(X<(Y*-1))
				pos_from = NORTH
				pos_to = EAST
				Y_spawn = -1
			else
				if(prob(50))
					pos_from = WEST
					pos_to = SOUTH
					X_spawn = 1
				else
					pos_from = NORTH
					pos_to = EAST
					Y_spawn = -1
		else if(Y==0)
			pos_from = WEST
			X_spawn = 1
			if(prob(50))
				pos_to = NORTH
			else
				pos_to = SOUTH
	else if(X<0)
		if(Y>0)
			if((X*-1)>Y)
				pos_from = EAST
				pos_to = NORTH
				X_spawn = -1
			else if((X*-1)<Y)
				pos_from = SOUTH
				pos_to = WEST
				Y_spawn = 1
			else
				if(prob(50))
					pos_from = EAST
					pos_to = NORTH
					X_spawn = -1
				else
					pos_from = SOUTH
					pos_to = WEST
					Y_spawn = 1
		else if(Y<0)
			if((X*-1)>(Y*-1))
				pos_from = EAST
				pos_to = SOUTH
				X_spawn = -1
			else if((X*-1)<(Y*-1))
				pos_from = NORTH
				pos_to = WEST
				Y_spawn = -1
			else
				if(prob(50))
					pos_from = EAST
					pos_to = SOUTH
					X_spawn = -1
				else
					pos_from = NORTH
					pos_to = WEST
					Y_spawn = -1
		else if(Y==0)
			pos_from = EAST
			X_spawn = -1
			if(prob(50))
				pos_to = NORTH
			else
				pos_to = SOUTH
	else if(X==0)
		if(Y>0)
			Y_spawn = 1
			pos_from = SOUTH
			if(prob(50))
				pos_to = EAST
			else
				pos_to = WEST
		else if(Y<0)
			Y_spawn = -1
			pos_from = NORTH
			if(prob(50))
				pos_to = EAST
			else
				pos_to = WEST
	else
		OnDeath()
		loc = null
		returnToPool(src)
		return

	var/turf/newspawn = locate(T1.x + X_spawn, T1.y + Y_spawn, z)
	src.loc = newspawn

	update_icon()
	..()

/obj/item/projectile/ricochet/update_icon()//8 possible combinations
	switch(pos_to)
		if(NORTH)
			if(pos_from == WEST)
				dir = NORTHWEST
			else
				dir = EAST
		if(SOUTH)
			if(pos_from == WEST)
				dir = WEST
			else
				dir = SOUTHEAST
		if(EAST)
			if(pos_from == NORTH)
				dir = NORTHEAST
			else
				dir = SOUTH
		if(WEST)
			if(pos_from == NORTH)
				dir = NORTH
			else
				dir = SOUTHWEST

/obj/item/projectile/ricochet/proc/bounce()
	bouncin = 1
	var/obj/structure/ricochet_bump/bump = new(loc)
	bump.dir = pos_to
	playsound(get_turf(src), 'sound/items/metal_impact.ogg', 50, 1)
	switch(pos_to)
		if(NORTH)
			if(pos_from == WEST)
				pos_to = EAST
			else
				pos_to = WEST
			pos_from = NORTH
		if(SOUTH)
			if(pos_from == WEST)
				pos_to = EAST
			else
				pos_to = WEST
			pos_from = SOUTH
		if(EAST)
			if(pos_from == NORTH)
				pos_to = SOUTH
			else
				pos_to = NORTH
			pos_from = EAST
		if(WEST)
			if(pos_from == NORTH)
				pos_to = SOUTH
			else
				pos_to = NORTH
			pos_from = WEST

/obj/item/projectile/ricochet/proc/bulletdies(var/atom/A = null)
	var/obj/effect/overlay/beam/impact = getFromPool(/obj/effect/overlay/beam,get_turf(src),10,0,'icons/obj/projectiles_impacts.dmi')
	if(A)
		switch(get_dir(src,A))
			if(NORTH)
				impact.pixel_y = 16
			if(SOUTH)
				impact.pixel_y = -16
			if(EAST)
				impact.pixel_x = 16
			if(WEST)
				impact.pixel_x = -16
	impact.icon_state = "ricochet_hit"
	playsound(impact, 'sound/weapons/pierce.ogg', 30, 1)

	spawn()
		density = 0
		invisibility = 101
		returnToPool(src)
		OnDeath()

/obj/item/projectile/ricochet/Bump(atom/A as mob|obj|turf|area)
	if(bumped)	return 0
	bumped = 1

	if(A)
		if(istype(A,/turf/) || (istype(A,/obj/machinery/door/) && A.opacity))
			bounce()

		else if(istype(A,/mob/living))//ricochet shots "never miss"
			if(istype(A,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = A
				if(istype(H.wear_suit,/obj/item/clothing/suit/armor/laserproof))// bwoing!!
					visible_message("<span class='warning'>\the [src.name] bounces off \the [A.name]'s [H.wear_suit]!</span>")
					bounce()
				else
					visible_message("<span class='warning'>\the [A.name] is hit by \the [src.name] in the [parse_zone(def_zone)]!</span>")
					A.bullet_act(src, def_zone)
					admin_warn(A)
					bulletdies(A)
			else
				visible_message("<span class='warning'>\the [A.name] is hit by \the [src.name] in the [parse_zone(def_zone)]!</span>")
				A.bullet_act(src, def_zone)
				admin_warn(A)
				bulletdies(A)

		else if(is_type_in_list(A,ricochet_bump))//beware fuel tanks!
			visible_message("<span class='warning'>\the [A.name] is hit by \the [src.name]!</span>")
			A.bullet_act(src)
			bulletdies(A)

		else if((istype(A,/obj/structure/window) || istype(A,/obj/machinery/door/window) || istype(A,/obj/machinery/door/firedoor/border_only)) && (A.loc == src.loc))
							//all this part is to prevent a bug that causes the shot to go through walls
							//if they are one the same tile as a one-directional window/windoor and try to cross them
			var/turf/T = get_step(src, pos_to)
			if(T.density)
				bounce()

			else
				ricochet_jump()

		else
			ricochet_jump()

/obj/item/projectile/ricochet/process_step()//unlike laser guns the projectile isn't instantaneous, but it still travels twice as fast as kinetic bullets since it moves twices per ticks
	if(src.loc)
		if(kill_count < 1)
			bulletdies()
		kill_count--
		for(var/i=1;i<=2;i++)
			ricochet_movement()
		update_icon()
		sleep(1)

/obj/item/projectile/ricochet/proc/ricochet_step(var/phase=1)
	var/obj/structure/ricochet_trail/trail = new(loc)
	switch(pos_to)
		if(NORTH)
			if(pos_from == WEST)
				trail.dir = NORTH
			else
				trail.dir = EAST
		if(SOUTH)
			if(pos_from == WEST)
				trail.dir = WEST
			else
				trail.dir = SOUTH
		if(EAST)
			if(pos_from == NORTH)
				trail.dir = EAST
			else
				trail.dir = SOUTH
		if(WEST)
			if(pos_from == NORTH)
				trail.dir = NORTH
			else
				trail.dir = WEST
	if(phase)
		current = get_step(src, pos_to)
		step_towards(src, current)
	else
		var/turf/T = get_step(src, pos_to)
		loc = T

	if((bumped && !phase) || bouncin)
		return

	switch(pos_to)
		if(NORTH)
			if(pos_from == WEST)
				pos_to = EAST
			else
				pos_to = WEST
			pos_from = SOUTH
		if(SOUTH)
			if(pos_from == WEST)
				pos_to = EAST
			else
				pos_to = WEST
			pos_from = NORTH
		if(EAST)
			if(pos_from == NORTH)
				pos_to = SOUTH
			else
				pos_to = NORTH
			pos_from = WEST
		if(WEST)
			if(pos_from == NORTH)
				pos_to = SOUTH
			else
				pos_to = NORTH
			pos_from = EAST

/obj/item/projectile/ricochet/proc/ricochet_movement()//movement through empty space
	if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
		bulletdies()
		return
	ricochet_step()
	bumped = 0
	bouncin = 0

/obj/item/projectile/ricochet/proc/ricochet_jump()//movement through dense objects
	if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
		bulletdies()
		return
	ricochet_step(0)

/obj/structure/ricochet_trail	//so pretty
	name = "ricochet shot"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "ricochet"
	opacity = 0
	density = 0
	unacidable = 1
	anchored = 1
	layer = 12

/obj/structure/ricochet_trail/New()
	. = ..()
	spawn(30)
		qdel(src)

/obj/structure/ricochet_bump	//oh so pretty
	name = "ricochet shot"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "ricochet_bounce"
	opacity = 0
	density = 0
	unacidable = 1
	anchored = 1
	layer = 14

/obj/structure/ricochet_bump/New()
	. = ..()
	spawn(30)
		qdel(src)

