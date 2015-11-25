/*
#define BRUTE "brute"
#define BURN "burn"
#define TOX "tox"
#define OXY "oxy"
#define CLONE "clone"

#define ADD "add"
#define SET "set"
*/
var/list/bullet_master = list()
var/list/impact_master = list()

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 1
	unacidable = 1
	anchored = 1 //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	flags = FPRINT
	pass_flags = PASSTABLE
	mouse_opacity = 0
	var/bumped = 0		//Prevents it from hitting more than one guy at once
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/silenced = 0	//Attack message
	var/yo = null
	var/xo = null
	var/turf/current = null
	var/obj/shot_from = null // the object which shot us
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid
	var/projectile_type = "/obj/item/projectile"
	var/kill_count = 50 //This will de-increment every process(). When 0, it will delete the projectile.
	var/total_steps = 0
		//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/agony = 0
	var/jittery = 0

	var/destroy = 0	//if set to 1, will destroy wall, tables and racks on impact (or at least, has a chance to)

	var/reflected = 0

	var/bounce_sound = 'sound/items/metal_impact.ogg'
	var/bounce_type = null//BOUNCEOFF_WALLS, BOUNCEOFF_WINDOWS, BOUNCEOFF_OBJS, BOUNCEOFF_MOBS
	var/bounces = 0	//if set to -1, will always bounce off obstacles

	var/phase_type = null//PHASEHTROUGH_WALLS, PHASEHTROUGH_WINDOWS, PHASEHTROUGH_OBJS, PHASEHTROUGH_MOBS
	var/penetration = 0	//if set to -1, will always phase through obstacles
	var/mark_type = "trace"	//what marks will the bullet leave on a wall that it penetrates? from 'icons/effects/96x96.dmi'

	var/step_delay = 0 //how long it goes between moving. You should probably leave this as 0 for a lot of things

	var/inaccurate = 0

	var/turf/target = null
	var/dist_x = 0
	var/dist_y = 0
	var/dx = 0
	var/dy = 0
	var/error = 0
	var/target_angle = 0

	var/override_starting_X = 0
	var/override_starting_Y = 0
	var/override_target_X = 0
	var/override_target_Y = 0
	var/last_bump = null

	var/custom_impact = 0

	//update_pixel stuff
	var/PixelX = 0
	var/PixelY = 0

	animate_movement = 0
	var/linear_movement = 1

/obj/item/projectile/proc/on_hit(var/atom/atarget, var/blocked = 0)
	if(blocked >= 2)		return 0//Full block
	if(!isliving(atarget))	return 0
	// FUCK mice. - N3X
	if(ismouse(atarget) && (stun+weaken+paralyze+agony)>5)
		var/mob/living/simple_animal/mouse/M=atarget
		to_chat(M, "<span class='warning'>What would probably not kill a human completely overwhelms your tiny body.</span>")
		M.splat()
		return 1
	if(isanimal(atarget))	return 0
	var/mob/living/L = atarget
	if(L.flags & INVULNERABLE)			return 0
	L.apply_effects(stun, weaken, paralyze, irradiate, stutter, eyeblur, drowsy, agony, blocked) // add in AGONY!
	if(jittery)
		L.Jitter(jittery)
	return 1

/obj/item/projectile/proc/check_fire(var/mob/living/target as mob, var/mob/living/user as mob)  //Checks if you can hit them or not.
	if(!istype(target) || !istype(user))
		return 0
	var/obj/item/projectile/test/in_chamber = getFromPool(/obj/item/projectile/test, get_step_to(user, target)) //Making the test....
	in_chamber.target = target
	in_chamber.ttarget = target //what the fuck
	in_chamber.flags = flags //Set the flags...
	in_chamber.pass_flags = pass_flags //And the pass flags to that of the real projectile...
	in_chamber.firer = user
	var/output = in_chamber.process() //Test it!
	//del(in_chamber) //No need for it anymore
	returnToPool(in_chamber)
	return output //Send it back to the gun!

/obj/item/projectile/resetVariables()
	if(!istype(permutated,/list))
		permutated = list()
	else
		permutated.len = 0
	..("permutated")

/obj/item/projectile/proc/admin_warn(mob/living/M)
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
		msg_admin_attack("UNKNOWN/(no longer exists) shot UNKNOWN/(no longer exists) with a [type]. Wait what the fuck?")
		log_attack("<font color='red'>UNKNOWN/(no longer exists) shot UNKNOWN/(no longer exists) with a [type]</font>")

/obj/item/projectile/Bump(atom/A as mob|obj|turf|area)
	if (!A)	//This was runtiming if by chance A was null.
		return 0
	if((A == firer) && !reflected)
		loc = A.loc
		return 0 //cannot shoot yourself, unless an ablative armor sent back the projectile

	if(bumped)	return 0
	var/forcedodge = 0 // force the projectile to pass

	bumped = 1
	if(firer && istype(A, /mob))
		var/mob/M = A
		if(!istype(A, /mob/living))
			loc = A.loc
			return 0// nope.avi

		//Lower accurancy/longer range tradeoff. Distance matters a lot here, so at
		// close distance, actually RAISE the chance to hit.
		var/distance = get_dist(starting,loc)
		var/miss_modifier = -30
		if (istype(shot_from,/obj/item/weapon/gun))	//If you aim at someone beforehead, it'll hit more often.
			var/obj/item/weapon/gun/daddy = shot_from //Kinda balanced by fact you need like 2 seconds to aim
			if (daddy.target && original in daddy.target) //As opposed to no-delay pew pew
				miss_modifier += -30
		if(istype(src, /obj/item/projectile/beam/lightning)) //Lightning is quite accurate
			miss_modifier += -200
			if(inaccurate)
				miss_modifier += (abs(miss_modifier))
			def_zone = get_zone_with_miss_chance(def_zone, M, miss_modifier)
			var/turf/simulated/floor/f = get_turf(A.loc)
			if(f && istype(f))
				f.break_tile()
				f.hotspot_expose(1000,CELL_VOLUME,surfaces=1)
		else
			if(inaccurate)
				miss_modifier += 8*distance
				miss_modifier += (abs(miss_modifier))

			def_zone = get_zone_with_miss_chance(def_zone, M, miss_modifier)

		if(!def_zone)
			visible_message("<span class='notice'>\The [src] misses [M] narrowly!</span>")
			forcedodge = -1
		else
			if(silenced)
				to_chat(M, "<span class='warning'>You've been shot in the [parse_zone(def_zone)] by the [src.name]!</span>")
			else
				visible_message("<span class='warning'>[A.name] is hit by the [src.name] in the [parse_zone(def_zone)]!</span>")//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
			admin_warn(M)
			if(istype(firer, /mob))
				if(!iscarbon(firer))
					M.LAssailant = null
				else
					M.LAssailant = firer

	if(!A)
		return 1

	if(A)
		if(firer && istype(A, /obj/structure/bed/chair/vehicle))//This is very sloppy but there's no way to get the firer after its passed to bullet_act, we'll just have to assume the admins will use their judgement
			var/obj/structure/bed/chair/vehicle/JC = A
			if(JC.occupant)
				var/mob/BM = JC.occupant
				if(istype(firer, /mob))
					admin_warn(BM)
					if(!iscarbon(firer))
						BM.LAssailant = null
				else
					BM.LAssailant = firer
	if (!forcedodge)
		forcedodge = A.bullet_act(src, def_zone) // searches for return value
	if(forcedodge == -1) // the bullet passes through a dense object!
		bumped = 0 // reset bumped variable!

		if(istype(A, /turf))
			loc = A
		else
			loc = A.loc

		if(permutated)
			permutated.Add(A)

		return 0
	else if(!custom_impact)
		var/impact_icon = null
		var/impact_sound = null
		if(ismob(A))
			if(issilicon(A))
				impact_icon = "default_solid"
				impact_sound = 'sound/items/metal_impact.ogg'
			else
				impact_icon = "default_mob"//todo: blood_colors
				impact_sound = 'sound/weapons/pierce.ogg'
		else
			impact_icon = "default_solid"
			impact_sound = 'sound/items/metal_impact.ogg'
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

		var/image/impact = image('icons/obj/projectiles_impacts.dmi',loc,impact_icon)
		impact.pixel_x = PixelX
		impact.pixel_y = PixelY

		var/turf/T = src.loc
		if(T) //Trying to fix a runtime that happens when a flare hits a window, T somehow becomes null.
			T.overlays += impact

			spawn(3)
				T.overlays -= impact

			playsound(T, impact_sound, 30, 1)

	if(istype(A,/turf))
		for(var/obj/O in A)
			O.bullet_act(src)
		for(var/mob/M in A)
			M.bullet_act(src, def_zone)

	if(!A)
		return 1

	//the bullets first checks if it can bounce off the obstacle, and if it cannot it then checks if it can phase through it, if it cannot either then it dies.
	var/reaction_type = A.projectile_check()
	if(bounces && (bounce_type & reaction_type))
		rebound(A)
		bounces--
		return 1
	else if(penetration && (phase_type & reaction_type))
		if((penetration > 0) && (penetration < A.penetration_dampening))	//if the obstacle is too resistant, we don't go through it.
			penetration = 0
			bullet_die()
			return 1
		A.visible_message("<span class='warning'>\The [src] goes right through \the [A]!</span>")
		src.forceMove(get_step(src.loc,dir))
		if(linear_movement)
			update_pixel()
			pixel_x = PixelX
			pixel_y = PixelY
		if(penetration > 0)//a negative penetration value means that the projectile can keep moving through obstacles
			penetration = max(0, penetration - A.penetration_dampening)
		if(isturf(A))				//if the bullet goes through a wall, we leave a nice mark on it
			damage -= (damage/4)	//and diminish the bullet's damage a bit
			if(!destroy)//destroying projectiles don't leave marks, as they would then appear on the resulting plating.
				var/turf/T = A
				T.bullet_marks++
				var/icon/I = icon(T.icon, T.icon_state)
				var/icon/trace = icon('icons/effects/96x96.dmi',mark_type)	//first we take the 96x96 icon with the overlay we want to blend on the wall
				trace.Turn(target_angle+45)									//then we rotate it so it matches the bullet's angle
				trace.Crop(33-pixel_x,33-pixel_y,64-pixel_x,64-pixel_y)		//lastly we crop a 32x32 square in the icon whose offset matches the projectile's pixel offset *-1
				I.Blend(trace,ICON_MULTIPLY ,1 ,1)							//we can now blend our resulting icon on the wall
				T.icon = I
		return 1

	bullet_die()
	return 1

/obj/item/projectile/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0)) return 1

	if(istype(mover, /obj/item/projectile))
		return prob(95)
	else
		return 1

/obj/item/projectile/proc/OnDeath()	//if assigned, allows for code when the projectile disappears
	return 1

/obj/item/projectile/proc/OnFired()	//if assigned, allows for code when the projectile gets fired
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

	if(linear_movement)
		//If the icon has not been added yet
		if( !("[icon_state]_angle[target_angle]" in bullet_master) )
			var/icon/I = new(icon,"[icon_state]_pixel") //Generate it.
			I.Turn(target_angle+45)
			bullet_master["[icon_state]_angle[target_angle]"] = I //And cache it!
		src.icon = bullet_master["[icon_state]_angle[target_angle]"]

	return 1

/obj/item/projectile/proc/process_step()
	var/sleeptime = 1
	if(src.loc)
		if(dist_x > dist_y)
			sleeptime = bresenham_step(dist_x,dist_y,dx,dy)
		else
			sleeptime = bresenham_step(dist_y,dist_x,dy,dx)
		if(linear_movement)
			update_pixel()
			pixel_x = PixelX
			pixel_y = PixelY

		bumped = 0

		sleep(sleeptime)


/obj/item/projectile/proc/bresenham_step(var/distA, var/distB, var/dA, var/dB)
	if(step_delay)
		sleep(step_delay)
	if(kill_count < 1)
		bullet_die()
		return 1
	kill_count--
	total_steps++
	if(error < 0)
		var/atom/step = get_step(src, dB)
		if(!step)
			bullet_die()
		src.Move(step)
		error += distA
		bump_original_check()
		return 0//so that bullets going in diagonals don't move twice slower
	else
		var/atom/step = get_step(src, dA)
		if(!step)
			bullet_die()
		src.Move(step)
		error -= distB
		dir = dA
		if(error < 0)
			dir = dA + dB
		bump_original_check()
		return 1

/obj/item/projectile/proc/update_pixel()
	if(src && starting && target)
		var/AX = (override_starting_X - src.x)*32
		var/AY = (override_starting_Y - src.y)*32
		var/BX = (override_target_X - src.x)*32
		var/BY = (override_target_Y - src.y)*32
		var/XX = (((BX-AX)*(-BX))+((BY-AY)*(-BY)))/(((BX-AX)*(BX-AX))+((BY-AY)*(BY-AY)))

		PixelX = round(BX+((BX-AX)*XX))
		PixelY = round(BY+((BY-AY)*XX))
		switch(last_bump)
			if(NORTH)
				PixelY -= 16
			if(SOUTH)
				PixelY += 16
			if(EAST)
				PixelX -= 16
			if(WEST)
				PixelX += 16
	return

/obj/item/projectile/proc/bullet_die()
	spawn()
		OnDeath()
		returnToPool(src)

/obj/item/projectile/proc/bump_original_check()
	if(!bumped && !isturf(original))
		if(loc == get_turf(original))
			if(!(original in permutated))
				Bump(original)
				return 1//so laser beams visually stop when they hit their target
	return 0

/obj/item/projectile/process()
	var/first = 1
	var/tS = 0
	spawn while(loc)
		if(first && timestopped)
			tS = 1
			timestopped = 0
		while((loc.timestopped || timestopped) && !first)
			sleep(3)
		first = 0
		src.process_step()
		if(tS)
			timestopped = loc.timestopped
			tS = 0
	return

/obj/item/projectile/proc/dumbfire(var/dir) // for spacepods, go snowflake go
	if(!dir)
		//del(src)
		OnDeath()
		returnToPool(src)
	if(kill_count < 1)
		//del(src)
		OnDeath()
		returnToPool(src)
	kill_count--
	var/first = 1
	var/tS = 0
	spawn while(loc)
		if(first && timestopped)
			tS = 1
			timestopped = 0
		var/turf/T = get_step(src, dir)
		step_towards(src, T)
		if(!bumped && !isturf(original))
			if(loc == get_turf(original))
				if(!(original in permutated))
					Bump(original)
					sleep(1)
		while((loc.timestopped || timestopped) && !first)
			sleep(3)
		first = 0
		if(tS)
			timestopped = loc.timestopped
			tS = 0
		sleep(1)
	return

/obj/item/projectile/bullet_act(/obj/item/projectile/bullet)
	return -1

/obj/item/projectile/proc/rebound(var/atom/A)//Projectiles bouncing off walls and obstacles
	var/turf/T = get_turf(src)
	var/turf/W = get_turf(A)
	playsound(T, bounce_sound, 30, 1)
	var/orientation = SOUTH
	if(T == W)
		orientation = dir
	else
		orientation = get_dir(T,W)
	last_bump = orientation
	switch(orientation)
		if(NORTH)
			dy = SOUTH
			override_starting_Y = (W.y * 2) - override_starting_Y
			override_target_Y = (W.y * 2) - override_target_Y
		if(SOUTH)
			dy = NORTH
			override_starting_Y = (W.y * 2) - override_starting_Y
			override_target_Y = (W.y * 2) - override_target_Y
		if(EAST)
			dx = WEST
			override_starting_X = (W.x * 2) - override_starting_X
			override_target_X = (W.x * 2) - override_target_X
		if(WEST)
			dx = EAST
			override_starting_X = (W.x * 2) - override_starting_X
			override_target_X = (W.x * 2) - override_target_X
	var/newdiffX = override_target_X - override_starting_X
	var/newdiffY = override_target_Y - override_starting_Y

	if(!W)
		W = T
	override_starting_X = W.x
	override_starting_Y = W.y
	override_target_X = W.x + newdiffX
	override_target_Y = W.y + newdiffY

	var/disty
	var/distx
	var/newangle
	disty = (32 * override_target_Y)-(32 * override_starting_Y)
	distx = (32 * override_target_X)-(32 * override_starting_X)
	if(!disty)
		if(distx >= 0)
			newangle = 90
		else
			newangle = 270
	else
		newangle = arctan(distx/disty)
		if(disty < 0)
			newangle += 180
		else if(distx < 0)
			newangle += 360

	target_angle = round(newangle)

	if(linear_movement)
		if( !("[icon_state][target_angle]" in bullet_master) )
			var/icon/I = new(initial(icon),"[icon_state]_pixel")
			I.Turn(target_angle+45)
			bullet_master["[icon_state]_angle[target_angle]"] = I
		src.icon = bullet_master["[icon_state]_angle[target_angle]"]

/obj/item/projectile/test //Used to see if you can hit them.
	invisibility = 101 //Nope!  Can't see me!
	yo = null
	xo = null
	var/ttarget = null
	var/result = 0 //To pass the message back to the gun.

/obj/item/projectile/test/Bump(atom/A as mob|obj|turf|area)
	if(A == firer)
		loc = A.loc
		return //cannot shoot yourself
	if(istype(A, /obj/item/projectile))
		return
	if(istype(A, /mob/living))
		result = 2 //We hit someone, return 1!
		return
	result = 1
	return

/obj/item/projectile/test/process()
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(ttarget)
	if(!curloc || !targloc)
		return 0
	yo = targloc.y - curloc.y
	xo = targloc.x - curloc.x
	target = targloc
	while(loc) //Loop on through!
		if(result)
			return (result - 1)

		var/mob/living/M = locate() in get_turf(src)
		if(istype(M)) //If there is someting living...
			return 1 //Return 1
		else
			M = locate() in get_step(src,ttarget)
			if(istype(M))
				return 1

		if((!( ttarget ) || loc == ttarget))
			ttarget = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z) //Finding the target turf at map edge
		step_towards(src, ttarget)
