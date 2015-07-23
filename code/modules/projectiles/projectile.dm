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

	var/step_delay = 0 //how long it goes between moving. You should probably leave this as 0 for a lot of things

	var/inaccurate = 0

	var/turf/target = null
	var/dist_x = 0
	var/dist_y = 0
	var/dx = 0
	var/dy = 0
	var/error = 0
	var/target_angle = 0

	var/custom_impact = 0

	//update_pixel stuff
	var/PixelX = 0
	var/PixelY = 0

	animate_movement = 0
	var/linear_movement = 1

/obj/item/projectile/proc/on_hit(var/atom/atarget, var/blocked = 0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/projectile/proc/on_hit() called tick#: [world.time]")
	if(blocked >= 2)		return 0//Full block
	if(!isliving(atarget))	return 0
	// FUCK mice. - N3X
	if(ismouse(atarget) && (stun+weaken+paralyze+agony)>5)
		var/mob/living/simple_animal/mouse/M=atarget
		M << "<span class='warning'>What would probably not kill a human completely overwhelms your tiny body.</span>"
		M.splat()
		return 1
	if(isanimal(atarget))	return 0
	var/mob/living/L = atarget
	if(L.flags & INVULNERABLE)			return 0
	L.apply_effects(stun, weaken, paralyze, irradiate, stutter, eyeblur, drowsy, agony, blocked) // add in AGONY!
	return 1

/obj/item/projectile/proc/check_fire(var/mob/living/target as mob, var/mob/living/user as mob)  //Checks if you can hit them or not.
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/projectile/proc/check_fire() called tick#: [world.time]")
	if(!istype(target) || !istype(user))
		return 0
	var/obj/item/projectile/test/in_chamber = getFromPool(/obj/item/projectile/test, get_step_to(user, target)) //Making the test....
	in_chamber.target = target
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

/obj/item/projectile/Bump(atom/A as mob|obj|turf|area)
	if(A == firer)
		loc = A.loc
		return 0 //cannot shoot yourself

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
				M << "<span class='warning'>You've been shot in the [parse_zone(def_zone)] by the [src.name]!</span>"
			else
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

	if(A)
		if(firer && istype(A, /obj/structure/bed/chair/vehicle))//This is very sloppy but there's no way to get the firer after its passed to bullet_act, we'll just have to assume the admins will use their judgement
			var/obj/structure/bed/chair/vehicle/JC = A
			if(JC.occupant)
				var/mob/BM = JC.occupant
				if(istype(firer, /mob))
					BM.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot <b>[key_name(BM)]</b> with a <b>[type]</b>"
					firer.attack_log += "\[[time_stamp()]\] <b>[key_name(firer)]</b> shot <b>[key_name(BM)]</b> with a <b>[type]</b>"
					log_attack("<font color='red'>[key_name(firer)] shot [key_name(BM)] with a [type]</font>")
					msg_admin_attack("[key_name(firer)] shot [key_name(BM)] with a [type]") //BS12 EDIT ALG
					if(!iscarbon(firer))
						BM.LAssailant = null
					else
						BM.LAssailant = firer
				else
					BM.attack_log += "\[[time_stamp()]\] <b>UNKNOWN/(no longer exists)</b> shot <b>[key_name(BM)]</b> with a <b>[type]</b>"
					log_attack("<font color='red'>UNKNOWN/(no longer exists) shot [key_name(BM)] with a [type]</font>")
					msg_admin_attack("UNKNOWN/(no longer exists) shot [key_name(BM)] with a [type]") //BS12 EDIT ALG
		if (!forcedodge)
			forcedodge = A.bullet_act(src, def_zone) // searches for return value
		if(forcedodge == -1) // the bullet passes through a dense object!
			bumped = 0 // reset bumped variable!
			if(istype(A, /turf))
				loc = A
			else
				loc = A.loc
			if(istype(permutated,/list)) permutated.Add(A)
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
			T.overlays += impact

			spawn(3)
				T.overlays -= impact

			playsound(T, impact_sound, 30, 1)

		if(istype(A,/turf))
			for(var/obj/O in A)
				O.bullet_act(src)
			for(var/mob/M in A)
				M.bullet_act(src, def_zone)
		loc = null
		spawn()//if(!istype(src, /obj/item/projectile/beam/lightning))
			density = 0
			invisibility = 101
			//del(src)
			returnToPool(src)
			OnDeath()
	return 1


/obj/item/projectile/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0)) return 1

	if(istype(mover, /obj/item/projectile))
		return prob(95)
	else
		return 1

/obj/item/projectile/proc/OnDeath()	//if assigned, allows for code when the projectile disappears
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/projectile/proc/OnDeath() called tick#: [world.time]")
	return 1

/obj/item/projectile/proc/OnFired()	//if assigned, allows for code when the projectile gets fired
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/projectile/proc/OnFired() called tick#: [world.time]")
	target = get_turf(original)
	dist_x = abs(target.x - starting.x)
	dist_y = abs(target.y - starting.y)

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
		if( !("[icon_state][target_angle]" in bullet_master) )
			var/icon/I = new(icon,"[icon_state]_pixel") //Generate it.
			I.Turn(target_angle+45)
			bullet_master["[icon_state]_angle[target_angle]"] = I //And cache it!
		src.icon = bullet_master["[icon_state]_angle[target_angle]"]

	return 1

/obj/item/projectile/proc/process_step()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/projectile/proc/process_step() called tick#: [world.time]")
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
		var/AX = (starting.x - src.x)*32
		var/AY = (starting.y - src.y)*32
		var/BX = (target.x - src.x)*32
		var/BY = (target.y - src.y)*32
		var/XX = (((BX-AX)*(-BX))+((BY-AY)*(-BY)))/(((BX-AX)*(BX-AX))+((BY-AY)*(BY-AY)))

		PixelX = round(BX+((BX-AX)*XX))
		PixelY = round(BY+((BY-AY)*XX))

	return

/obj/item/projectile/proc/bullet_die()
	OnDeath()
	returnToPool(src)

/obj/item/projectile/proc/bump_original_check()
	if(!bumped && !isturf(original))
		if(loc == get_turf(original))
			if(!(original in permutated))
				Bump(original)

/obj/item/projectile/process()
	spawn while(loc)
		src.process_step()
	return

/obj/item/projectile/proc/dumbfire(var/dir) // for spacepods, go snowflake go
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/projectile/proc/dumbfire() called tick#: [world.time]")
	if(!dir)
		//del(src)
		OnDeath()
		returnToPool(src)
	if(kill_count < 1)
		//del(src)
		OnDeath()
		returnToPool(src)
	kill_count--
	spawn while(loc)
		var/turf/T = get_step(src, dir)
		step_towards(src, T)
		if(!bumped && !isturf(original))
			if(loc == get_turf(original))
				if(!(original in permutated))
					Bump(original)
					sleep(1)
		sleep(1)
	return

/obj/item/projectile/bullet_act(/obj/item/projectile/bullet)
	return -1

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
		if((!( ttarget ) || loc == ttarget))
			ttarget = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z) //Finding the target turf at map edge
		step_towards(src, ttarget)
		var/mob/living/M = locate() in get_turf(src)
		if(istype(M)) //If there is someting living...
			return 1 //Return 1
		else
			M = locate() in get_step(src,ttarget)
			if(istype(M))
				return 1
