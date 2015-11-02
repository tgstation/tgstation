//////////////
//Gun Turret//
//////////////

/obj/machinery/gun_turret //related to turrets but work way differentely because of being mounted on a moving ship.
	name = "machine gun turret"
	desc = "Syndicate defense turret. It really packs a punch."
	density = 1
	anchored = 1
	var/state = 0 //Like stat on mobs, 0 is alive, 1 is damaged, 2 is dead
	var/faction = "syndicate"
	var/atom/cur_target = null
	var/scan_range = 9 //You will never see them coming
	var/health = 200 //Because it lacks a cover, and is mostly to keep people from touching the syndie shuttle.
	var/base_icon_state = "syndieturret"
	var/projectile_type = /obj/item/projectile/bullet
	var/fire_sound = 'sound/weapons/Gunshot.ogg'
	var/atom/base = null //where do to range calculations, firing projectiles, etc. from. allows for turrets inside of things to work
	icon = 'icons/obj/turrets.dmi'
	icon_state = "syndieturret0"

/obj/machinery/gun_turret/New()
	..()
	if(!base)
		base = src
	take_damage(0) //check your health
	icon_state = "[base_icon_state]" + "0"


/obj/machinery/gun_turret/ex_act(severity, target)
	switch(severity)
		if(1)
			die()
		if(2)
			take_damage(100)
		if(3)
			take_damage(50)
	return

/obj/machinery/gun_turret/emp_act() //Can't emp an mechanical turret.
	return

/obj/machinery/gun_turret/update_icon()
	if(state > 2 || state < 0) //someone fucked up the vars so fix them
		take_damage(0)
	icon_state = "[base_icon_state]" + "[state]"
	return


/obj/machinery/gun_turret/proc/take_damage(damage)
	health -= damage
	switch(health)
		if(101 to INFINITY)
			state = 0
		if(1 to 100)
			state = 1
		if(-INFINITY to 0)
			if(state != 2)
				die()
				return
			state = 2

	update_icon()
	return


/obj/machinery/gun_turret/bullet_act(obj/item/projectile/Proj)
	take_damage(Proj.damage)
	return

/obj/machinery/gun_turret/proc/die()
	state = 2
	update_icon()

/obj/machinery/gun_turret/attack_hand(mob/user)
	return

/obj/machinery/gun_turret/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/gun_turret/attack_alien(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='danger'>[user] slashes at [src]!</span>", "<span class='danger'>You slash at [src]!</span>")
	take_damage(15)
	return

/obj/machinery/gun_turret/proc/validate_target(atom/target)
	if(get_dist(target, base)>scan_range)
		return 0
	if(istype(target, /mob))
		var/mob/M = target
		if(!M.stat)
			return 1
	else if(istype(target, /obj/mecha))
		var/obj/mecha/M = target
		if(M.occupant)
			return 1
	return 0


/obj/machinery/gun_turret/process()
	if(state == 2)
		return
	if(cur_target && !validate_target(cur_target))
		cur_target = null
	if(!cur_target)
		cur_target = get_target()
	if(cur_target)
		fire(cur_target)
	return


/obj/machinery/gun_turret/proc/get_target()
	var/list/pos_targets = list()
	var/target = null
	for(var/mob/living/M in view(scan_range,base))
		if(M.stat)
			continue
		if(faction in M.faction)
			continue
		pos_targets += M
	for(var/obj/mecha/M in oview(scan_range, base))
		if(M.occupant)
			if(faction in M.occupant.faction)
				continue
		if(!M.occupant)
			continue //Don't shoot at empty mechs.
		pos_targets += M
	if(pos_targets.len)
		target = pick(pos_targets)
	return target


/obj/machinery/gun_turret/proc/fire(atom/target)
	if(!target)
		cur_target = null
		return
	src.dir = get_dir(base,target)
	var/turf/targloc = get_turf(target)
	if(!src)
		return
	var/turf/curloc = get_turf(base)
	if (!targloc || !curloc)
		return
	if (targloc == curloc)
		return
	playsound(src, fire_sound, 50, 1)
	var/obj/item/projectile/A = new projectile_type(curloc)
	A.current = curloc
	A.yo = targloc.y - curloc.y
	A.xo = targloc.x - curloc.x
	A.fire()
	return

