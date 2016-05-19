
/*
 * Use: Caches beam state images and holds turfs that had these images overlaid.
 * Structure:
 * beam_master
 *     icon_states/dirs of beams
 *         image for that beam
 *     references for fired beams
 *         icon_states/dirs for each placed beam image
 *             turfs that have that icon_state/dir
 */
var/list/beam_master = list()

/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	invisibility = 101
	animate_movement = 2
	linear_movement = 1
	layer = 13

	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 30
	damage_type = BURN
	flag = "laser"
	eyeblur = 4
	fire_sound = 'sound/weapons/Laser.ogg'
	var/frequency = 1
	var/wait = 0

/obj/item/projectile/beam/OnFired()	//if assigned, allows for code when the projectile gets fired
	target = get_turf(original)
	dist_x = abs(target.x - starting.x)
	dist_y = abs(target.y - starting.y)

	override_starting_X = starting.x
	override_starting_Y = starting.y
	override_target_X = target.x
	override_target_Y = target.y

	if (target.x > starting.x)
		dx = EAST
	else
		dx = WEST

	if (target.y > starting.y)
		dy = NORTH
	else
		dy = SOUTH

	if(dist_x > dist_y)
		error = dist_x/2 - dist_y
	else
		error = dist_y/2 - dist_x

	target_angle = round(Get_Angle(starting,target))

	return 1

/obj/item/projectile/beam/process()
	var/lastposition = loc
	var/reference = "\ref[src]" //So we do not have to recalculate it a ton

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
	var/target_dir = SOUTH

	if(dist_x > dist_y)
		error = dist_x/2 - dist_y

		spawn
			reference = bresenham_step(dist_x,dist_y,dx,dy,lastposition,target_dir,reference)

	else
		error = dist_y/2 - dist_x
		spawn
			reference = bresenham_step(dist_y,dist_x,dy,dx,lastposition,target_dir,reference)

	cleanup(reference)
	return

/obj/item/projectile/beam/bresenham_step(var/distA, var/distB, var/dA, var/dB, var/lastposition, var/target_dir, var/reference)
	var/first = 1
	var/tS = 0
	while(src && src.loc)// only stop when we've hit something, or hit the end of the map
		if(first && timestopped)
			tS = 1
			timestopped = 0
		if(error < 0)
			var/atom/step = get_step(src, dB)
			if(!step)
				bullet_die()
			src.Move(step)
			error += distA
			target_dir = null
		else
			var/atom/step = get_step(src, dA)
			if(!step)
				bullet_die()
			src.Move(step)
			error -= distB
			target_dir = dA
			if(error < 0)
				target_dir = dA + dB

		if(isnull(loc))
			return reference
		if(lastposition == loc && (!tS && !timestopped && !loc.timestopped))
			kill_count = 0
		lastposition = loc
		if(kill_count < 1)
			returnToPool(src)
			return reference
		kill_count--
		if(bump_original_check())
			return reference

		if(linear_movement)
			update_pixel()

			//If the icon has not been added yet
			if( !("[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]" in beam_master) )
				var/image/I = image(icon,"[icon_state]_pixel",13,target_dir) //Generate it.
				I.transform = turn(I.transform, target_angle+45)
				I.pixel_x = PixelX
				I.pixel_y = PixelY
				beam_master["[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]"] = I //And cache it!

			//Finally add the overlay
			if(src.loc && target_dir)
				src.loc.overlays += beam_master["[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]"]

				//Add the turf to a list in the beam master so they can be cleaned up easily.
				if(reference in beam_master)
					var/list/turf_master = beam_master[reference]
					if("[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]" in turf_master)
						var/list/turfs = turf_master["[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]"]
						turfs += loc
					else
						turf_master["[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]"] = list(loc)
				else
					var/list/turfs = list()
					turfs["[icon_state]_angle[target_angle]_pX[PixelX]_pY[PixelY]"] = list(loc)
					beam_master[reference] = turfs
		else
			//If the icon has not been added yet
			if( !("[icon_state][target_dir]" in beam_master) )
				var/image/I = image(icon,icon_state,10,target_dir) //Generate it.
				beam_master["[icon_state][target_dir]"] = I //And cache it!

			//Finally add the overlay
			if(src.loc && target_dir)
				src.loc.overlays += beam_master["[icon_state][target_dir]"]

				//Add the turf to a list in the beam master so they can be cleaned up easily.
				if(reference in beam_master)
					var/list/turf_master = beam_master[reference]
					if("[icon_state][target_dir]" in turf_master)
						var/list/turfs = turf_master["[icon_state][target_dir]"]
						turfs += loc
					else
						turf_master["[icon_state][target_dir]"] = list(loc)
				else
					var/list/turfs = list()
					turfs["[icon_state][target_dir]"] = list(loc)
					beam_master[reference] = turfs
		if(tS)
			timestopped = loc.timestopped
			tS = 0
		if(wait)
			sleep(wait)
			wait = 0
		while((loc.timestopped || timestopped) && !first)
			sleep(3)
		first = 0


	return reference


/obj/item/projectile/beam/dumbfire(var/dir)
	var/reference = "\ref[src]" // So we do not have to recalculate it a ton.

	spawn(0)
		var/target_dir = dir ? dir : src.dir// TODO: remove dir arg. Or don't because the way this was set up without it broke spacepods.
		var/first = 1
		var/tS = 0
		while(loc) // Move until we hit something.
			if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
				returnToPool(src)
				break
			if(first && timestopped)
				tS = 1
				timestopped = 0
			step(src, target_dir) // Move.
			if(tS)
				tS = 0
				timestopped = loc.timestopped
			if(bumped)
				break

			if(kill_count-- < 1)
				returnToPool(src)
				break

			// Add the overlay as we pass over tiles.

			// If the icon has not been added yet.
			if(!beam_master.Find("[icon_state][target_dir]"))
				beam_master["[icon_state][target_dir]"] = image(icon, icon_state, 10, target_dir) // Generate, and cache it!

			// Finally add the overlay
			loc.overlays.Add(beam_master["[icon_state][target_dir]"])

			// Add the turf to a list in the beam master so they can be cleaned up easily.
			if(beam_master.Find(reference))
				var/list/turf_master = beam_master[reference]

				if(turf_master.Find("[icon_state][target_dir]"))
					turf_master["[icon_state][target_dir]"] += loc
				else
					turf_master["[icon_state][target_dir]"] = list(loc)
			else
				var/list/turfs = new
				turfs["[icon_state][target_dir]"] = list(loc)
				beam_master[reference] = turfs
			while((loc.timestopped || timestopped) && !first)
				sleep(3)
			first = 0


	cleanup(reference)

/obj/item/projectile/beam/proc/cleanup(const/reference)
	var/TS
	var/atom/lastloc
	var/starttime = world.time
	var/cleanedup = 0
	while(world.time - starttime < 3 || TS)
		if(loc)
			lastloc = loc
		TS = lastloc.timestopped
		if(TS)
			if(world.time - starttime > 3)
				if(!cleanedup)
					var/list/turf_master = beam_master[reference]

					for(var/laser_state in turf_master)
						var/list/turfs = turf_master[laser_state]
						for(var/turf/T in turfs)
							if(!T.timestopped)
								T.overlays.Remove(beam_master[laser_state])
					cleanedup = 1
			sleep(2)

		else sleep(1)

	if(cleanedup) sleep(2)
	var/list/turf_master = beam_master[reference]

	for(var/laser_state in turf_master)
		var/list/turfs = turf_master[laser_state]

		for(var/turf/T in turfs)
			T.overlays.Remove(beam_master[laser_state])

		turfs.len = 0

// Special laser the captains gun uses
/obj/item/projectile/beam/captain
	name = "captain laser"
	damage = 40
	linear_movement = 0

/obj/item/projectile/beam/retro
	linear_movement = 0

/obj/item/projectile/beam/lightning
	invisibility = 101
	name = "lightning"
	damage = 0
	icon = 'icons/obj/lightning.dmi'
	icon_state = "lightning"
	stun = 10
	weaken = 10
	stutter = 50
	eyeblur = 50
	var/tang = 0
	layer = 13
	var/turf/last = null
	kill_count = 12

/obj/item/projectile/beam/lightning/proc/adjustAngle(angle)
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

/obj/item/projectile/beam/lightning/process()
	icon_state = "lightning"
	var/first = 1 //So we don't make the overlay in the same tile as the firer
	var/broke = 0
	var/broken
	var/atom/curr = current
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
	var/turf/T = get_turf(src)
	var/list/ouroverlays = list()

	spawn() for(N,N<length,N+=32)
		if(count >= kill_count)
			break
		count++
		var/obj/effect/overlay/beam/persist/X=getFromPool(/obj/effect/overlay/beam/persist,T)
		X.BeamSource=src
		ouroverlays += X
		if((N+64>length) && (N+32<=length))
			X.icon=Iend
		else if(N==0)
			X.icon=Istart
		else if(N+32>length)
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
		while((TT.timestopped || timestopped || X.timestopped) && count)
			sleep(2)
		if(TT == firer.loc)
			continue
		if(TT.density)
			qdel(X)
			X = null
			break
		for(var/atom/movable/O in TT)
			if(!O.Cross(src))
				qdel(X)
				broke = 1
				break
		for(var/mob/living/O in TT.contents)
			if(istype(O, /mob/living))
				if(O.density)
					qdel(X)
					X = null
					broke = 1
					break
		if(broke)
			if(X)
				qdel(X)
				X = null
			break
	spawn(10)
		for(var/atom/thing in ouroverlays)
			if(!thing.timestopped && thing.loc && !thing.loc.timestopped)
				ouroverlays -= thing
				returnToPool(thing)
	spawn
		var/tS = 0
		while(loc) //Move until we hit something
			if(tS)
				tS = 0
				timestopped = loc.timestopped
			while((loc.timestopped || timestopped) && !first)
				tS = 1
				sleep(3)
			if(first)
				icon = midicon
				if(timestopped || loc.timestopped)
					tS = 1
					timestopped = 0
			if((!( current ) || loc == current)) //If we pass our target
				broken = 1
				icon = endicon
				tang = adjustAngle(get_angle(original,current))
				if(tang > 180)
					tang -= 180
				else
					tang += 180
				icon_state = "[tang]"
				var/turf/simulated/floor/f = current
				if(f && istype(f))
					f.break_tile()
					f.hotspot_expose(1000,CELL_VOLUME,surfaces=1)
			if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
//				to_chat(world, "deleting")
				//del(src) //Delete if it passes the world edge
				broken = 1
				return
			if(kill_count < 1)
//				to_chat(world, "deleting")
				//del(src)
				broken = 1
			kill_count--
//			to_chat(world, "[x] [y]")
			if(!bumped && !isturf(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						icon = endicon
					if(!broken)
						tang = adjustAngle(get_angle(original,current))
						if(tang > 180)
							tang -= 180
						else
							tang += 180
						icon_state = "[tang]"
					Bump(original)
			first = 0
			if(broken)
//				to_chat(world, "breaking")
				break
			else
				last = get_turf(src.loc)
				step_towards(src, current) //Move~
				if(src.loc != current)
					tang = adjustAngle(get_angle(src.loc,current))
				icon_state = "[tang]"
		if(ouroverlays.len)
			sleep(10)
			for(var/atom/thing in ouroverlays)
				ouroverlays -= thing
				returnToPool(thing)

		//del(src)
		returnToPool(src)
	return
/*cleanup(reference) //Waits .3 seconds then removes the overlay.
//	to_chat(world, "setting invisibility")
	sleep(50)
	src.invisibility = 101
	return*/

/obj/item/projectile/beam/lightning/on_hit(atom/target, blocked = 0)
	if(istype(target, /mob/living))
		var/mob/living/M = target
		M.playsound_local(src, "explosion", 50, 1)
	..()

/obj/item/projectile/beam/lightning/spell
	var/spell/lightning/our_spell
	weaken = 0
	stun = 0
/obj/item/projectile/beam/lightning/spell/Bump(atom/A as mob|obj|turf|area)
	. = ..()
	if(.)
		our_spell.lastbumped = A
	return .

/obj/item/projectile/beam/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"
	eyeblur = 2

/obj/item/projectile/beam/practice/stormtrooper
	fire_sound = "sound/weapons/blaster-storm.ogg"

/obj/item/projectile/beam/practice/stormtrooper/on_hit(var/atom/target, var/blocked = 0)
	if(..(target, blocked))
		var/mob/living/L = target
		var/message = pick("\the [src] narrowly whizzes past [L]!","\the [src] almost hits [L]!","\the [src] straight up misses its target.","[L]'s hair is singed off by \the [src]!","\the [src] misses [L] by a millimetre!","\the [src] doesn't hit","\the [src] misses its intended target.","[L] has a lucky escape from \the [src]!")
		target.loc.visible_message("<span class='danger'>[message]</span>")

/obj/item/projectile/beam/lightlaser
	name = "light laser"
	icon_state = "light laser"
	damage = 25


/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 30
	fire_sound = 'sound/weapons/laser3.ogg'

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	destroy = 1
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/projectile/beam/deathlaser
	name = "death laser"
	icon_state = "heavylaser"
	damage = 60

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30

/obj/item/projectile/beam/emitter/singularity_pull()
	return

/obj/item/projectile/beam/lastertag/blue
	name = "lasertag beam"
	icon_state = "bluelaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
				M.Weaken(5)
		return 1

/obj/item/projectile/beam/lastertag/red
	name = "lasertag beam"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
				M.Weaken(5)
		return 1

/obj/item/projectile/beam/lastertag/omni//A laser tag bolt that stuns EVERYONE
	name = "lasertag beam"
	icon_state = "omnilaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if((istype(M.wear_suit, /obj/item/clothing/suit/bluetag))||(istype(M.wear_suit, /obj/item/clothing/suit/redtag)))
				M.Weaken(5)
		return 1

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
	linear_movement = 0
	pass_flags = PASSTABLE
	var/drawn = 0
	var/tang = 0
	var/turf/last = null
	fire_sound = 'sound/weapons/bison_fire.ogg'

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
				if(loc == target)
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

/obj/item/projectile/beam/bison/bullet_die()
	draw_ray(loc)
	..()

/obj/item/projectile/beam/bison/proc/draw_ray(var/turf/lastloc)
	if(drawn) return
	drawn = 1
	var/atom/curr = lastloc
	if(!firer)
		firer = starting
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
	var/increment = timer_total/max(1,round(length/32))
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
