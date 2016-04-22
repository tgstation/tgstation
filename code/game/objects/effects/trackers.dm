
//object that moves constantly toward a target.

/obj/effect/tracker
	name = "tracker"
	unacidable = 1
	w_type=NOT_RECYCLABLE
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soul2"
	mouse_opacity = 0
	animate_movement = 0
	var/absolute_X = 0
	var/absolute_Y = 0
	var/atom/target = null
	var/speed = 2
	var/acceleration = 1
	var/maxdist = 320
	var/refresh = 1

/obj/effect/tracker/New()
	. = ..()
	absolute_X = (x * 32)
	absolute_Y = (y * 32)

	spawn(1)
		process_step()

/obj/effect/tracker/soul
	name = "soul"
	icon_state = "soul3"

/obj/effect/tracker/drain
	name = "blood"
	color = "red"

/obj/effect/tracker/proc/process_step()
	if(!target)
		target = pick(player_list)
		return
	if(target.z != z)
		returnToPool(src)
		return

	var/target_absolute_X = target.x * 32
	var/target_absolute_Y = target.y * 32

	var/dx = target_absolute_X - absolute_X
	var/dy = target_absolute_Y - absolute_Y

	var/dist = sqrt(abs(dx)**2 + abs(dy)**2)
	if(dist > maxdist)
		returnToPool(src)
		return
	else if(dist < 16)
		returnToPool(src)
		return

	if(abs(dx) > abs(dy))
		absolute_X += (dx/abs(dx)) * speed
		absolute_Y += round((speed * dy)/abs(dx))
	else if(abs(dx) < abs(dy))
		absolute_X += round((speed * dx)/abs(dy))
		absolute_Y += (dy/abs(dy)) * speed
	else
		absolute_X += (dx/abs(dx)) * speed
		absolute_Y += (dy/abs(dy)) * speed


	absolute_X += round((dx/100)*speed)
	absolute_Y += round((dy/100)*speed)

	speed += acceleration

	x = absolute_X/32
	y = absolute_Y/32
	update_icon()

	sleep(refresh)
	process_step()


/obj/effect/tracker/update_icon()
	pixel_x = absolute_X % 32
	pixel_y = absolute_Y % 32

/obj/effect/tracker/cultify()
	return

/obj/effect/tracker/singuloCanEat()
	return 0

/obj/effect/tracker/singularity_act()
	return

/obj/effect/tracker/singularity_pull()
	return
