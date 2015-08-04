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
		/obj/structure/stool/bed/chair/vehicle,
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

/obj/item/projectile/ricochet/proc/admin_warn(mob/living/M)
	if(istype(firer, /mob))
		if(firer == M)
			log_attack("<font color='red'>[key_name(firer)] shot himself with a [type].</font>")
			M.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot himself with a <b>[type]</b>"
			firer.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot himself with a <b>[type]</b>"
			msg_admin_attack("[key_name(firer)] shot himself with a [type], [pick("top kek!","for shame.","he definitely meant to do that","probably not the last time either.")] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)")
			if(!iscarbon(firer))
				M.LAssailant = null
			else
				M.LAssailant = firer
		else
			log_attack("<font color='red'>[key_name(firer)] shot [key_name(M)] with a [type]</font>")
			M.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot <b>[key_name(M)]</b> with a <b>[type]</b>"
			firer.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot <b>[key_name(M)]</b> with a <b>[type]</b>"
			msg_admin_attack("[key_name(firer)] shot [key_name(M)] with a [type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)")
			if(!iscarbon(firer))
				M.LAssailant = null
			else
				M.LAssailant = firer
	else
		M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN/(no longer exists)</b> shot <b>UNKNOWN/(no longer exists)</b> with a <b>[type]</b>"
		msg_admin_attack("UNKNOWN/(no longer exists) shot UNKNOWN/(no longer exists) with a [type]. Wait what the fuck? (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)")
		log_attack("<font color='red'>UNKNOWN/(no longer exists) shot UNKNOWN/(no longer exists) with a [type]</font>")

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


/obj/item/projectile/beam/bison
	name = "heat ray"
	damage_type = BURN
	flag = "laser"
	kill_count = 100
	layer = 13
	damage = 15
	icon = 'icons/obj/lightning.dmi'
	icon_state = "heatray"
	animate_movement = 0
	pass_flags = PASSTABLE

	var/tang = 0
	var/turf/last = null
/obj/item/projectile/beam/bison/proc/adjustAngle(angle)
	angle = round(angle) + 45
	if(angle > 180)
		angle -= 180
	else
		angle += 180
	if(!angle)
		angle = 1
	/*if(angle < 0)
		//angle = (round(abs(get_angle(A, user))) + 45) - 90
		angle = round(angle) + 45 + 180
	else
		angle = round(angle) + 45*/
	return angle

/obj/item/projectile/beam/bison/process()
	//calculating the turfs that we go through
	var/lastposition = loc

	target = get_turf(original)
	dist_x = abs(target.x - src.x)
	dist_y = abs(target.y - src.y)

	if (target.x > src.x)
		dx = EAST
	else
		dx = WEST

	if (target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH

	if(dist_x > dist_y)
		error = dist_x/2 - dist_y

		spawn while(src && src.loc)
			// only stop when we've hit something, or hit the end of the map
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				error += dist_x
			else
				var/atom/step = get_step(src, dx)
				if(!step)
					break
				src.Move(step)
				error -= dist_y

			if(isnull(loc))
				draw_ray(lastposition)
				return
			if(lastposition == loc)
				kill_count = 0
			lastposition = loc
			if(kill_count < 1)
				//del(src)
				draw_ray(lastposition)
				returnToPool(src)
				return
			kill_count--

			if(!bumped && !isturf(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						draw_ray(target)
						Bump(original)

	else
		error = dist_y/2 - dist_x
		spawn while(src && src.loc)
			// only stop when we've hit something, or hit the end of the map
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step)
					break
				src.Move(step)
				error += dist_y
			else
				var/atom/step = get_step(src, dy)
				if(!step)
					break
				src.Move(step)
				error -= dist_x

			if(isnull(loc))
				draw_ray(lastposition)
				return
			if(lastposition == loc)
				kill_count = 0
			lastposition = loc
			if(kill_count < 1)
				//del(src)
				draw_ray(lastposition)
				returnToPool(src)
				return
			kill_count--

			if(!bumped && !isturf(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						draw_ray(target)
						Bump(original)

	return


/obj/item/projectile/beam/bison/proc/draw_ray(var/turf/lastloc)
	var/atom/curr = lastloc
	var/Angle=round(Get_Angle(firer,curr))
	var/icon/I=new('icons/obj/lightning.dmi',icon_state)
	var/icon/Istart=new('icons/obj/lightning.dmi',"[icon_state]start")
	var/icon/Iend=new('icons/obj/lightning.dmi',"[icon_state]end")
	I.Turn(Angle+45)
	Istart.Turn(Angle+45)
	Iend.Turn(Angle+45)
	var/DX=(32*curr.x+curr.pixel_x)-(32*firer.x+firer.pixel_x)
	var/DY=(32*curr.y+curr.pixel_y)-(32*firer.y+firer.pixel_y)
	var/N=0
	var/length=round(sqrt((DX)**2+(DY)**2))
	var/count = 0
	var/turf/T = get_turf(firer)
	var/timer_total = 16
	var/increment = timer_total/round(length/32)
	var/current_timer = 5

	for(N,N<(length+16),N+=32)
		if(count >= kill_count)
			break
		count++
		var/obj/effect/overlay/beam/X=getFromPool(/obj/effect/overlay/beam,T,current_timer,1)
		X.BeamSource=src
		current_timer += increment
		if((N+64>(length+16)) && (N+32<=(length+16)))
			X.icon=Iend
		else if(N==0)
			X.icon=Istart
		else if(N+32>(length+16))
			X.icon=null
		else
			X.icon=I


		var/Pixel_x=round(sin(Angle)+32*sin(Angle)*(N+16)/32)
		var/Pixel_y=round(cos(Angle)+32*cos(Angle)*(N+16)/32)
		if(DX==0) Pixel_x=0
		if(DY==0) Pixel_y=0
		if(Pixel_x>32)
			for(var/a=0, a<=Pixel_x,a+=32)
				X.x++
				Pixel_x-=32
		if(Pixel_x<-32)
			for(var/a=0, a>=Pixel_x,a-=32)
				X.x--
				Pixel_x+=32
		if(Pixel_y>32)
			for(var/a=0, a<=Pixel_y,a+=32)
				X.y++
				Pixel_y-=32
		if(Pixel_y<-32)
			for(var/a=0, a>=Pixel_y,a-=32)
				X.y--
				Pixel_y+=32

		//Now that we've calculated the total offset in pixels, we move each beam parts to their closest corresponding turfs
		var/x_increm = 0
		var/y_increm = 0

		while(Pixel_x >= 32 || Pixel_x <= -32)
			if(Pixel_x > 0)
				Pixel_x -= 32
				x_increm++
			else
				Pixel_x += 32
				x_increm--

		while(Pixel_y >= 32 || Pixel_y <= -32)
			if(Pixel_y > 0)
				Pixel_y -= 32
				y_increm++
			else
				Pixel_y += 32
				y_increm--

		X.x += x_increm
		X.y += y_increm
		X.pixel_x=Pixel_x
		X.pixel_y=Pixel_y
		var/turf/TT = get_turf(X.loc)
		if(TT == firer.loc)
			continue

	return

/obj/item/projectile/beam/bison/Bump(atom/A as mob|obj|turf|area)
	//Heat Rays go through mobs
	if(A == firer)
		loc = A.loc
		return 0 //cannot shoot yourself

	if(firer && istype(A, /mob/living))
		var/mob/living/M = A
		A.bullet_act(src, def_zone)
		loc = A.loc
		permutated.Add(A)
		visible_message("<span class='warning'>[A.name] is hit by the [src.name] in the [parse_zone(def_zone)]!</span>")//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
		if(istype(firer, /mob))
			log_attack("<font color='red'>[key_name(firer)] shot [key_name(M)] with a [type]</font>")
			M.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot <b>[key_name(M)]</b> with a <b>[type]</b>"
			firer.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot <b>[key_name(M)]</b> with a <b>[type]</b>"
			msg_admin_attack("[key_name(firer)] shot [key_name(M)] with a [type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)") //BS12 EDIT ALG
			if(!iscarbon(firer))
				M.LAssailant = null
			else
				M.LAssailant = firer
		else
			M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN/(no longer exists)</b> shot <b>[key_name(M)]</b> with a <b>[type]</b>"
			msg_admin_attack("UNKNOWN/(no longer exists) shot [key_name(M)] with a [type] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)") //BS12 EDIT ALG
			log_attack("<font color='red'>UNKNOWN/(no longer exists) shot [key_name(M)] with a [type]</font>")
		return 1
	else
		return ..()

#define SPUR_FULL_POWER 4
#define SPUR_HIGH_POWER 3
#define SPUR_MEDIUM_POWER 2
#define SPUR_LOW_POWER 1
#define SPUR_NO_POWER 0

/obj/item/projectile/spur
	name = "spur bullet"
	damage_type = BRUTE
	flag = "bullet"
	kill_count = 100
	layer = 13
	damage = 30
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "spur_medium"
	animate_movement = 2
	custom_impact = 1
	linear_movement = 0

/obj/item/projectile/spur/OnFired()
	var/obj/item/weapon/gun/energy/polarstar/quote = shot_from
	switch(quote.firelevel)
		if(SPUR_FULL_POWER,SPUR_HIGH_POWER)
			icon_state = "spur_high"
			damage = 40
			kill_count = 20
		if(SPUR_MEDIUM_POWER)
			icon_state = "spur_medium"
			damage = 30
			kill_count = 13
		if(SPUR_LOW_POWER,SPUR_NO_POWER)
			icon_state = "spur_low"
			damage = 20
			kill_count = 7
	..()

/obj/item/projectile/spur/Bump(atom/A as mob|obj|turf|area)

	if(loc)
		var/turf/T = loc
		var/impact_icon = null
		var/impact_sound = null
		var/PixelX = 0
		var/PixelY = 0

		switch(get_dir(src,A))
			if(NORTH)
				PixelY = 16
			if(SOUTH)
				PixelY = -16
			if(EAST)
				PixelX = 16
			if(WEST)
				PixelX = -16
		if(ismob(A))
			impact_icon = "spur_3"
			impact_sound = 'sound/weapons/spur_hitmob.ogg'
		else
			impact_icon = "spur_1"
			impact_sound = 'sound/weapons/spur_hitwall.ogg'

		var/image/impact = image('icons/obj/projectiles_impacts.dmi',loc,impact_icon)
		impact.pixel_x = PixelX
		impact.pixel_y = PixelY
		impact.layer = 13
		T.overlays += impact
		spawn(3)
			T.overlays -= impact
		playsound(impact, impact_sound, 30, 1)


	if(istype(A, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = A
		M.GetDrilled()
	if(istype(A, /obj/structure/boulder))
		returnToPool(A)

	return ..()

/obj/item/projectile/spur/process_step()
	if(kill_count <= 0)
		if(loc)
			var/turf/T = loc
			var/image/impact = image('icons/obj/projectiles_impacts.dmi',loc,"spur_2")
			impact.layer = 13
			T.overlays += impact
			spawn(3)
				T.overlays -= impact
	..()

#undef SPUR_FULL_POWER
#undef SPUR_HIGH_POWER
#undef SPUR_MEDIUM_POWER
#undef SPUR_LOW_POWER
#undef SPUR_NO_POWER


/obj/item/projectile/bullet/gatling
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "minigun"
	damage = 30

/obj/item/projectile/stickybomb
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "stickybomb"
	damage = 0
	var/obj/item/stickybomb/sticky = null


/obj/item/projectile/stickybomb/Bump(atom/A as mob|obj|turf|area)
	if(bumped)	return 0
	bumped = 1

	if(A)
		density = 0
		invisibility = 101
		kill_count = 0
		if(isliving(A))
			sticky.stick_to(A)
		else if(loc)
			var/turf/T = get_turf(src)
			sticky.stick_to(T,get_dir(src,A))
		bulletdies()

/obj/item/projectile/stickybomb/proc/bulletdies()
	returnToPool(src)
	OnDeath()

/obj/item/projectile/stickybomb/bump_original_check()//so players can aim at floors
	if(!bumped)
		if(loc == get_turf(original))
			if(!(original in permutated))
				Bump(original)

/obj/item/projectile/nikita
	name = "\improper Nikita missile"
	desc = "One does not simply dodge a nikita missile."
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "nikita"
	damage = 50
	stun = 5
	weaken = 5
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"
	animate_movement = 2
	linear_movement = 0
	kill_count = 100
	layer = 13
	var/mob/living/carbon/mob = null
	var/obj/item/weapon/gun/projectile/rocketlauncher/nikita/nikita = null
	var/steps_since_last_turn = 0
	var/last_dir = null
	var/emagged = 0//the value is set by the Nikita when it fires it

/obj/item/projectile/nikita/OnFired()
	nikita = shot_from
	emagged = nikita.emagged

	if(nikita && istype(nikita.loc,/mob/living/carbon))
		var/mob/living/carbon/C = nikita.loc
		if(C.get_active_hand() == nikita)
			mob = C
			mob.client.perspective = EYE_PERSPECTIVE
			mob.client.eye = src
			mob.orient_object = src
			mob.canmove = 0

	dir = get_dir_cardinal(starting,original)
	last_dir = dir

	if(mob && emagged)
		for(var/obj/item/W in mob.get_all_slots())
			mob.drop_from_inventory(W)//were you're going you won't need those!

/obj/item/projectile/nikita/emp_act(severity)
	new/obj/item/ammo_casing/rocket_rpg/nikita(get_turf(src))
	if(nikita)
		nikita.fired = null
	qdel(src)

/obj/item/projectile/nikita/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(!istype(Proj ,/obj/item/projectile/beam/lastertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			detonate()

/obj/item/projectile/nikita/Destroy()
	reset_view()
	if(nikita)
		nikita.fired = null
	..()

/obj/item/projectile/nikita/Bump(var/atom/A)
	if(bumped)
		return
	if(emagged && (A == mob))
		return
	bumped = 1
	detonate(get_turf(A))

/obj/item/projectile/nikita/Bumped(var/atom/A)
	if(emagged && (A == mob))
		return
	detonate()

/obj/item/projectile/nikita/process_step()
	if(!emagged && !check_user())//if the original user dropped the Nikita and the missile is still in the air, we check if someone picked it up.
		if(nikita && istype(nikita.loc,/mob/living/carbon))
			var/mob/living/carbon/C = nikita.loc
			if(C.get_active_hand() == nikita)
				mob = C
				mob.client.perspective = EYE_PERSPECTIVE
				mob.client.eye = src
				mob.orient_object = src
				mob.canmove = 0

	if(src.loc)
		var/atom/step = get_step(src, dir)
		if(!step)
			qdel(src)
		src.Move(step)

	if(mob)
		if(emagged)
			mob.loc = loc
			mob.dir = dir
		else
			mob.dir = get_dir(mob,src)

	if(!emagged)
		kill_count--
	if(!kill_count)
		detonate()

	if(kill_count == (initial(kill_count)/5))
		mob.playsound_local(mob, 'sound/machines/twobeep.ogg', 30, 1)
		mob << "<span class='warning'>WARNING: 20% fuel left on missile before self-detonation.<span>"
	if(dir != last_dir)
		last_dir = dir
		steps_since_last_turn = 0

	var/sleeptime = max(1,(steps_since_last_turn * -1) + 5)//5, 4, 3, 2, 1, 1, 1, 1, 1,...

	steps_since_last_turn++

	sleep(sleeptime)

/obj/item/projectile/nikita/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return (!density || !height || air_group)

/obj/item/projectile/nikita/proc/check_user()
	if(!mob || !mob.client)
		return 0
	if(mob.stat || (mob.get_active_hand() != src))
		reset_view()
		return 0
	return 1

/obj/item/projectile/nikita/proc/detonate(var/explosion = loc)
	explosion(explosion, -1, 1, 4, 8)
	if(src)
		qdel(src)

/obj/item/projectile/nikita/proc/reset_view()
	if(mob && mob.client)
		mob.client.eye = mob.client.mob
		mob.client.perspective = MOB_PERSPECTIVE
		mob.orient_object = null
		mob.canmove = 1
		mob = null
