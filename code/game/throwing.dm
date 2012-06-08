/mob/living/carbon/proc/toggle_throw_mode()
	if(!equipped())//Not holding anything
		if(TK in mutations)
			if (hand)
				l_hand = new/obj/item/tk_grab(src)
				l_hand:host = src
			else
				r_hand = new/obj/item/tk_grab(src)
				r_hand:host = src
		return

	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/carbon/proc/throw_mode_off()
	src.in_throw_mode = 0
	src.throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/proc/throw_mode_on()
	src.in_throw_mode = 1
	src.throw_icon.icon_state = "act_throw_on"

/mob/living/carbon/proc/throw_item(atom/target)
	src.throw_mode_off()

	if(usr.stat || !target)
		return
	if(target.type == /obj/screen) return

	var/atom/movable/item = src.equipped()

	if(!item) return



	u_equip(item)
	if(src.client)
		src.client.screen -= item
	item.loc = src.loc

	if (istype(item, /obj/item/weapon/grab))
		item = item:throw() //throw the person instead of the grab

	if(istype(item, /obj/item))
		item:dropped(src) // let it know it's been dropped

	//actually throw it!
	if (item)
		item.layer = initial(item.layer)
		src.visible_message("\red [src] has thrown [item].")

		if(istype(item,/mob/living))
			var/mob/living/M = item
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been thrown by [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='red'>Threw [M.name] ([M.ckey])</font>")
			log_attack("<font color='red'>[src.name] ([src.ckey]) threw [M.name] ([M.ckey])</font>")
			log_admin("ATTACK: [src.name] ([src.ckey]) threw [M.name] ([M.ckey])")

		if(!src.lastarea)
			src.lastarea = get_area(src.loc)
		if((istype(src.loc, /turf/space)) || (src.lastarea.has_gravity == 0))
			src.inertia_dir = get_dir(target, src)
			step(src, inertia_dir)


/*
		if(istype(src.loc, /turf/space) || (src.flags & NOGRAV)) //they're in space, move em one space in the opposite direction
			src.inertia_dir = get_dir(target, src)
			step(src, inertia_dir)
*/



		item.throw_at(target, item.throw_range, item.throw_speed)



/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/atom/movable/proc/hit_check(var/turf/target)
	if(src.throwing)
		for(var/atom/A in get_turf(src))
			if(A == src) continue
			if(istype(A,/mob/living))
				if(A:lying) continue
				src.throw_impact(A)
				if(src.throwing == 1)
					src.throwing = 0
			if(isobj(A))
				if(A.density && !A.CanPass(src,target))
					src.throw_impact(A)
					src.throwing = 0

/atom/proc/throw_impact(atom/hit_atom)
	if(istype(hit_atom,/mob/living))
		var/mob/living/M = hit_atom
		M.visible_message("\red [hit_atom] has been hit by [src].")

		if(!istype(src, /obj/item)) // this is a big item that's being thrown at them~

			if(istype(M, /mob/living/carbon/human))
				var/armor_block = M:run_armor_check("chest", "melee")
				M:apply_damage(rand(20,45), BRUTE, "chest", armor_block)

				visible_message("\red <B>[M] has been knocked down by the force of [src]!</B>")
				M:apply_effect(rand(4,12), WEAKEN, armor_block)

				M:UpdateDamageIcon()
			else
				M.take_organ_damage(rand(20,45))


		else if(src.vars.Find("throwforce"))
			M.take_organ_damage(src:throwforce)

			log_attack("<font color='red'>[hit_atom] ([M.ckey]) was hit by [src] thrown by ([src.fingerprintslast])</font>")
			log_admin("ATTACK: [hit_atom] ([M.ckey]) was hit by [src] thrown by ([src.fingerprintslast])")
			message_admins("ATTACK: [hit_atom] ([M.ckey]) was hit by [src] thrown by ([src.fingerprintslast])")

	else if(isobj(hit_atom))
		var/obj/O = hit_atom
		if(!O.anchored)
			step(O, src.dir)
		O.hitby(src)

	else if(isturf(hit_atom))
		var/turf/T = hit_atom
		if(T.density)
			spawn(2)
				step(src, turn(src.dir, 180))
			if(istype(src,/mob/living))
				var/mob/living/M = src
				M.take_organ_damage(20)

/atom/movable/Bump(atom/O)
	if(src.throwing)
		src.throw_impact(O)
		src.throwing = 0
		airflow_speed = 0
	..()

/atom/movable/proc/throw_at(atom/target, range, speed)
	if(!target || !src)	return 0
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

	src.throwing = 1

	if(usr)
		if((HULK in usr.mutations) || (SUPRSTR in usr.augmentations))
			src.throwing = 2 // really strong throw!

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)

	var/dx
	if (target.x > src.x)
		dx = EAST
	else
		dx = WEST

	var/dy
	if (target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH
	var/dist_travelled = 0
	var/dist_since_sleep = 0
	var/area/a = get_area(src.loc)
	var/turf/target_turf = get_turf(target)
	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y



		while(src && target &&((((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || (a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(target_turf)
				error += dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(target_turf)
				error -= dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			a = get_area(src.loc)
	else
		var/error = dist_y/2 - dist_x
		while(src && target &&((((src.y < target.y && dy == NORTH) || (src.y > target.y && dy == SOUTH)) && dist_travelled < range) || (a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(target_turf)
				error += dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(target_turf)
				error -= dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)

			a = get_area(src.loc)

	//done throwing, either because it hit something or it finished moving
	src.throwing = 0
	if(isobj(src)) src:throw_impact(get_turf(src))


