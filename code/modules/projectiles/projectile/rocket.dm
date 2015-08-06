/obj/item/projectile/rocket
	name = "rocket"
	icon_state = "rpground"
	damage = 50
	stun = 5
	weaken = 5
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"
	var/embed = 1
	var/picked_up_speed = 5

/obj/item/projectile/rocket/process_step()
	if(src.loc)
		if(picked_up_speed > 1)
			picked_up_speed--
		if(dist_x > dist_y)
			bresenham_step(dist_x,dist_y,dx,dy)
		else
			bresenham_step(dist_y,dist_x,dy,dx)
		if(linear_movement)
			update_pixel()
			pixel_x = PixelX
			pixel_y = PixelY
		sleep(picked_up_speed)

/obj/item/projectile/rocket/Bump(var/atom/rocket)
	explosion(rocket, -1, 1, 4, 8)
	qdel(src)
