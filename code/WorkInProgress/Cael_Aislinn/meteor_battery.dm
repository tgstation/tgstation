#define MISSILE_SPEED 5

//automated turret that shoots missiles at meteors

/obj/item/projectile/missile
	name = "missile"
	icon = 'meteor_turret.dmi'
	icon_state = "missile"
	var/turf/target
	var/tracking = 0
	density = 1
	desc = "It's sparking and shaking slightly."

/obj/item/projectile/missile/process(var/turf/newtarget)
	target = newtarget
	dir = get_dir(src.loc, target)
	walk_towards(src, target, MISSILE_SPEED)

/obj/item/projectile/missile/Bump(atom/A)
	spawn(0)
		if(istype(A,/obj/effect/meteor))
			del(A)
		explode()
	return

/obj/item/projectile/missile/proc/explode()
	explosion(src.loc, 1, 1, 2, 7, 0)
	playsound(src.loc, "explosion", 50, 1)
	del(src)

/obj/item/projectile/missile/attack_hand(mob/user)
	..()
	return attackby(null, user)

/obj/item/projectile/missile/attackby(obj/item/weapon/W, mob/user)
	//can't touch this
	..()
	explode()

/obj/machinery/meteor_battery
	name = "meteor battery"
	icon = 'meteor_turret.dmi'
	icon_state = "turret0"
	var/raised = 0
	var/enabled = 1
	anchored = 1
	layer = 3
	invisibility = 2
	density = 1
	var/health = 18
	var/id = ""
	var/obj/machinery/turretcover/cover = null
	var/popping = 0
	var/wasvalid = 0
	var/lastfired = 0
	var/shot_delay = 50
	var/datum/effect/effect/system/spark_spread/spark_system
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300
	var/atom/movable/cur_target
	var/targeting_active = 0
	var/protect_range = 30
	var/tracking_missiles = 0
	var/list/fired_missiles

/obj/machinery/meteor_battery/New()
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	fired_missiles = new/list()
//	targets = new
	..()
	return

/obj/machinery/meteor_battery/proc/isPopping()
	return (popping!=0)

/obj/machinery/meteor_battery/power_change()
	if(stat & BROKEN)
		icon_state = "broke"
	else
		if( powered() )
			if (src.enabled)
				icon_state = "turret1"
			else
				icon_state = "turret0"
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "turret0"
				stat |= NOPOWER

/obj/machinery/meteor_battery/proc/setState(var/enabled)
	src.enabled = enabled
	src.power_change()

/obj/machinery/meteor_battery/proc/get_new_target()
	var/list/new_targets = new
	var/new_target
	for(var/obj/effect/meteor/M in view(protect_range, get_turf(src)))
		new_targets += M
	if(new_targets.len)
		new_target = pick(new_targets)
	return new_target

/obj/machinery/meteor_battery/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(src.cover==null)
		src.cover = new /obj/machinery/turretcover(src.loc)
		src.cover.host = src
	if(!enabled)
		if(!isDown() && !isPopping())
			popDown()
		return

	//update our missiles
	for(var/obj/item/projectile/missile/M in fired_missiles)
		if(!M)
			fired_missiles.Remove(M)
			continue
		if(tracking_missiles && cur_target)
			//update homing missile target
			M.target = get_turf(cur_target)
			walk_towards(M, M.target, MISSILE_SPEED)

		if(get_turf(M) == M.target && M)
			//missile has arrived at destination
			fired_missiles.Remove(M)
			if( istype(get_turf(M), /turf/space) )
				//send the missile shooting off into the distance
				walk(M, get_dir(src,M), MISSILE_SPEED)
				spawn(rand(3,10) * 10)
					if(M)
						M.explode()
			else if(rand(3) == 3)
				//chance to blow up later (between 4 seconds and 2 minutes), or just sit there being ominous
				spawn(rand(4,120) * 10)
					M.explode()
				for(var/mob/P in view(7))
					P.visible_message("\red The missile skids to a halt, vibrating and sparking ominously!")

	if(!cur_target)
		cur_target = get_new_target() //get new target

	if(cur_target) //if it's found, proceed
		if(!isPopping())
			if(isDown())
				popUp()
				use_power = 2
			else
				spawn()
					if(!targeting_active)
						targeting_active = 1
						target()
						targeting_active = 0
	else if(!isPopping())//else, pop down
		if(!isDown())
			popDown()
			use_power = 1

	return

/obj/machinery/meteor_battery/proc/target()
	while(src && enabled && !stat)
		src.dir = get_dir(src, cur_target)
		shootAt(cur_target)
		sleep(shot_delay)
	return

/obj/machinery/meteor_battery/proc/shootAt(var/atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if (!T || !U)
		return
	use_power(500)
	var/obj/item/projectile/missile/A = new(T)
	A.tracking = tracking_missiles
	fired_missiles.Add(A)
	spawn(0)
		A.process(U)
	return


/obj/machinery/meteor_battery/proc/isDown()
	return (invisibility!=0)

/obj/machinery/meteor_battery/proc/popUp()
	if ((!isPopping()) || src.popping==-1)
		invisibility = 0
		popping = 1
		if (src.cover!=null)
			flick("popup", src.cover)
			src.cover.icon_state = "openTurretCover"
		spawn(10)
			if (popping==1) popping = 0

/obj/machinery/meteor_battery/proc/popDown()
	if ((!isPopping()) || src.popping==1)
		popping = -1
		if (src.cover!=null)
			flick("popdown", src.cover)
			src.cover.icon_state = "turretCover"
		spawn(10)
			if (popping==-1)
				invisibility = 2
				popping = 0

/obj/machinery/meteor_battery/bullet_act(var/obj/item/projectile/Proj)
	src.health -= Proj.damage
	..()
	if(prob(45) && Proj.damage > 0) src.spark_system.start()
	if (src.health <= 0)
		src.die()
	return

/obj/machinery/meteor_battery/attackby(obj/item/weapon/W, mob/user)//I can't believe no one added this before/N
	..()
	playsound(src.loc, 'smash.ogg', 60, 1)
	src.spark_system.start()
	src.health -= W.force * 0.5
	if (src.health <= 0)
		src.die()
	return

/obj/machinery/meteor_battery/emp_act(severity)
	switch(severity)
		if(1)
			enabled = 0
			power_change()
	..()

/obj/machinery/meteor_battery/ex_act(severity)
	if(severity < 3)
		src.die()

/obj/machinery/meteor_battery/proc/die()
	src.health = 0
	src.density = 0
	src.stat |= BROKEN
	src.icon_state = "broke"
	if (cover!=null)
		del(cover)
	sleep(3)
	flick("explosion", src)
	spawn(13)
		del(src)

/obj/machinery/meteor_battery/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(!(stat & BROKEN))
		playsound(src.loc, 'slash.ogg', 25, 1, -1)
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
		src.health -= 15
		if (src.health <= 0)
			src.die()
	else
		M << "\green That object is useless to you."
	return
