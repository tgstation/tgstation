/area/turret_protected
	name = "Turret Protected Area"
	var/list/turretTargets = list()

/area/turret_protected/proc/subjectDied(target)
	if( isliving(target) )
		if( !issilicon(target) )
			var/mob/living/L = target
			if( L.stat )
				if( L in turretTargets )
					src.Exited(L)


/area/turret_protected/Entered(O)
	..()
	if( master && master != src )
		return master.Entered(O)

	if( iscarbon(O) )
		turretTargets |= O
	else if( istype(O, /obj/mecha) )
		var/obj/mecha/Mech = O
		if( Mech.occupant )
			turretTargets |= Mech
	else if(istype(O,/mob/living/simple_animal))
		turretTargets |= O
	return 1

/area/turret_protected/Exited(O)
	if( master && master != src )
		return master.Exited(O)

	if( ismob(O) && !issilicon(O) )
		turretTargets -= O
	else if( istype(O, /obj/mecha) )
		turretTargets -= O
	..()
	return 1


/obj/machinery/turret
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "grey_target_prism"
	var/raised = 0
	var/enabled = 1
	anchored = 1
	layer = 3
	invisibility = INVISIBILITY_LEVEL_TWO
	density = 1
	var/lasers = 0
	var/lasertype = 1
		// 1 = lasers
		// 2 = cannons
		// 3 = pulse
		// 4 = change (HONK)
		// 5 = bluetag
		// 6 = redtag
	var/health = 80
	var/obj/machinery/turretcover/cover = null
	var/popping = 0
	var/wasvalid = 0
	var/lastfired = 0
	var/shot_delay = 30 //3 seconds between shots
	var/datum/effect/effect/system/spark_spread/spark_system
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300
//	var/list/targets
	var/atom/movable/cur_target
	var/targeting_active = 0
	var/area/turret_protected/protected_area


/obj/machinery/turret/New()
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
//	targets = new
	..()
	src.cover = new /obj/machinery/turretcover(src.loc)
	src.cover.host = src
	return

/obj/machinery/turretcover
	name = "pop-up turret cover"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = 1
	layer = 3.5
	density = 0
	var/obj/machinery/turret/host = null

/obj/machinery/turret/proc/isPopping()
	return (popping!=0)

/obj/machinery/turret/power_change()
	if(stat & BROKEN)
		icon_state = "grey_target_prism"
	else
		if( powered() )
			if (src.enabled)
				if (src.lasers)
					icon_state = "orange_target_prism"
				else
					icon_state = "target_prism"
			else
				icon_state = "grey_target_prism"
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "grey_target_prism"
				stat |= NOPOWER

/obj/machinery/turret/proc/setState(var/enabled, var/lethal)
	src.enabled = enabled
	src.lasers = lethal
	src.power_change()


/obj/machinery/turret/proc/get_protected_area()
	var/area/turret_protected/TP = get_area(src)
	if(istype(TP))
		if(TP.master && TP.master != TP)
			TP = TP.master
		return TP
	return

/obj/machinery/turret/proc/check_target(var/atom/movable/T as mob|obj)
	if( T && T in protected_area.turretTargets )
		var/area/area_T = get_area(T)
		if( !area_T || (area_T.type != protected_area.type) )
			protected_area.Exited(T)
			return 0 //If the guy is somehow not in the turret's area (teleportation), get them out the damn list. --NEO
		if( iscarbon(T) )
			var/mob/living/carbon/MC = T
			if( !MC.stat )
				if( !MC.lying || lasers )
					return 1
		else if( istype(T, /obj/mecha) )
			var/obj/mecha/ME = T
			if( ME.occupant )
				return 1
		else if(istype(T,/mob/living/simple_animal))
			var/mob/living/simple_animal/A = T
			if( !A.stat )
				if(lasers)
					return 1
	return 0

/obj/machinery/turret/proc/get_new_target()
	var/list/new_targets = new
	var/new_target
	for(var/mob/living/carbon/M in protected_area.turretTargets)
		if(!M.stat)
			if(!M.lying || lasers)
				new_targets += M
	for(var/obj/mecha/M in protected_area.turretTargets)
		if(M.occupant)
			new_targets += M
	for(var/mob/living/simple_animal/M in protected_area.turretTargets)
		if(!M.stat)
			new_targets += M
	if(new_targets.len)
		new_target = pick(new_targets)
	return new_target


/obj/machinery/turret/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(src.cover==null)
		src.loc = null
		qdel(src)
		return ..()
	protected_area = get_protected_area()
	if(!enabled || !protected_area || protected_area.turretTargets.len<=0)
		if(!isDown() && !isPopping())
			popDown()
		return
	if(!check_target(cur_target)) //if current target fails target check
		cur_target = get_new_target() //get new target

	if(cur_target) //if it's found, proceed
//		world << "[cur_target]"
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


/obj/machinery/turret/proc/target()
	while(src && enabled && !stat && check_target(cur_target))
		src.dir = get_dir(src, cur_target)
		shootAt(cur_target)
		sleep(shot_delay)
	return

/obj/machinery/turret/proc/shootAt(var/atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if (!T || !U)
		return
	var/obj/item/projectile/A
	if (src.lasers)
		switch(lasertype)
			if(1)
				A = new /obj/item/projectile/beam( loc )
			if(2)
				A = new /obj/item/projectile/beam/heavylaser( loc )
			if(3)
				A = new /obj/item/projectile/beam/pulse( loc )
			if(4)
				A = new /obj/item/projectile/magic/change( loc )
			if(5)
				A = new /obj/item/projectile/lasertag/bluetag( loc )
			if(6)
				A = new /obj/item/projectile/lasertag/redtag( loc )
		A.original = target
		use_power(500)
	else
		A = new /obj/item/projectile/energy/electrode( loc )
		use_power(200)
	A.current = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.fire()
	return


/obj/machinery/turret/proc/isDown()
	return (invisibility!=0)

/obj/machinery/turret/proc/popUp()
	if ((!isPopping()) || src.popping==-1)
		invisibility = 0
		popping = 1
		if (src.cover!=null)
			flick("popup", src.cover)
			src.cover.icon_state = "openTurretCover"
		spawn(10)
			if (popping==1) popping = 0

/obj/machinery/turret/proc/popDown()
	if ((!isPopping()) || src.popping==1)
		popping = -1
		if (src.cover!=null)
			flick("popdown", src.cover)
			src.cover.icon_state = "turretCover"
		spawn(10)
			if (popping==-1)
				invisibility = INVISIBILITY_LEVEL_TWO
				popping = 0

/obj/machinery/turret/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		src.health -= Proj.damage
		..()
		if(prob(45) && Proj.damage > 0) src.spark_system.start()
		qdel(Proj)
		if (src.health <= 0)
			src.die()
	return

/obj/machinery/turret/attackby(obj/item/weapon/W, mob/user, params)//I can't believe no one added this before/N
	..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src.loc, 'sound/weapons/smash.ogg', 60, 1)
	src.spark_system.start()
	src.health -= W.force * 0.5
	if (src.health <= 0)
		src.die()
	return

/obj/machinery/turret/emp_act(severity)
	switch(severity)
		if(1)
			enabled = 0
			lasers = 0
			power_change()
	..()

/obj/machinery/turret/ex_act(severity, target)
	if(severity < 3)
		src.die()

/obj/machinery/turret/proc/die()
	src.health = 0
	src.density = 0
	src.stat |= BROKEN
	src.icon_state = "destroyed_target_prism"
	if (cover!=null)
		qdel(cover)
	sleep(3)
	flick("explosion", src)
	spawn(13)
		qdel(src)


/obj/machinery/turret/attack_animal(mob/living/simple_animal/M as mob)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0)	return
	if(!(stat & BROKEN))
		visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>")
		add_logs(M, src, "attacked", admin=0)
		//src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		src.health -= M.melee_damage_upper
		if (src.health <= 0)
			src.die()
	else
		M << "<span class='danger'>That object is useless to you.</span>"
	return




/obj/machinery/turret/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(!(stat & BROKEN))
		playsound(src.loc, 'sound/weapons/slash.ogg', 25, 1, -1)
		visible_message("<span class='danger'>[M] has slashed at [src]!</span>")
		src.health -= 15
		if (src.health <= 0)
			src.die()
	else
		M << "\green That object is useless to you."
	return


//////////////
//Gun Turret//
//////////////

/obj/machinery/gun_turret //related to turrets but work way differentely because of being mounted on a moving ship.
	name = "machine gun turret"
	desc = "Syndicate defense turret. It really packs a bunch."
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
	icon = 'icons/obj/turrets.dmi'
	icon_state = "syndieturret0"

/obj/machinery/gun_turret/New()
	..()
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


/obj/machinery/gun_turret/bullet_act(var/obj/item/projectile/Proj)
	take_damage(Proj.damage)
	return

/obj/machinery/gun_turret/proc/die()
	state = 2
	update_icon()

/obj/machinery/gun_turret/attack_hand(mob/user)
	return

/obj/machinery/gun_turret/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/gun_turret/attack_alien(mob/living/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='danger'>[user] slashes at [src]!</span>", "<span class='danger'>You slash at [src]!</span>")
	take_damage(15)
	return

/obj/machinery/gun_turret/proc/validate_target(atom/target)
	if(get_dist(target, src)>scan_range)
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
	for(var/mob/living/M in view(scan_range,src))
		if(M.stat)
			continue
		if(faction in M.faction)
			continue
		pos_targets += M
	for(var/obj/mecha/M in oview(scan_range, src))
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
	src.dir = get_dir(src,target)
	var/turf/targloc = get_turf(target)
	if(!src)
		return
	var/turf/curloc = get_turf(src)
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


////////////////////////
//Turret Control Panel//
////////////////////////

/obj/machinery/areaturretid
	name = "turret control panel"
	desc = "Used to control a room's automated defenses."
	icon = 'icons/obj/machines/turret_control.dmi'
	icon_state = "control_standby"
	anchored = 1
	density = 0
	var/enabled = 1
	var/lethal = 0
	var/locked = 1
	var/control_area //can be area name, path or nothing.
	var/ailock = 0 // AI cannot use this
	req_access = list(access_ai_upload)

/obj/machinery/areaturretid/New()
	..()
	if(!control_area)
		var/area/CA = get_area(src)
		if(CA.master && CA.master != CA)
			control_area = CA.master
		else
			control_area = CA
	else if(istext(control_area))
		for(var/area/A in world)
			if(A.name && A.name==control_area)
				control_area = A
				break
	power_change() //Checks power and initial settings
	//don't have to check if control_area is path, since get_area_all_atoms can take path.
	return

/obj/machinery/areaturretid/attackby(obj/item/weapon/W, mob/user, params)
	if(stat & BROKEN) return
	if (istype(user, /mob/living/silicon))
		return src.attack_hand(user)

	else if( get_dist(src, user) == 0 )		// trying to unlock the interface
		if (src.allowed(usr))
			if(emagged)
				user << "<span class='notice'>The turret control is unresponsive.</span>"
				return

			locked = !locked
			user << "<span class='notice'>You [ locked ? "lock" : "unlock"] the panel.</span>"
			if (locked)
				if (user.machine==src)
					user.unset_machine()
					user << browse(null, "window=turretid")
			else
				if (user.machine==src)
					src.attack_hand(user)
		else
			user << "<span class='warning'>Access denied.</span>"

/obj/machinery/areaturretid/emag_act(mob/user as mob)
	if(!emagged)
		user << "<span class='danger'>You short out the turret controls' access analysis module.</span>"
		emagged = 1
		locked = 0
		if(user.machine==src)
			src.attack_hand(user)

/obj/machinery/areaturretid/attack_ai(mob/user as mob)
	if(!ailock)
		return attack_hand(user)
	else
		user << "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>"

/obj/machinery/areaturretid/attack_hand(mob/user as mob)
	if ( get_dist(src, user) > 0 )
		if ( !issilicon(user) )
			user << "<span class='notice'>You are too far away.</span>"
			user.unset_machine()
			user << browse(null, "window=turretid")
			return

	user.set_machine(src)
	var/loc = src.loc
	if (istype(loc, /turf))
		loc = loc:loc
	if (!istype(loc, /area))
		user << text("Turret badly positioned - loc.loc is [].", loc)
		return
	var/area/area = loc
	var/t = ""

	if(src.locked && (!istype(user, /mob/living/silicon)))
		t += "<div class='notice icon'>Swipe ID card to unlock interface</div>"
	else
		if (!istype(user, /mob/living/silicon))
			t += "<div class='notice icon'>Swipe ID card to lock interface</div>"
		t += text("Turrets [] - <A href='?src=\ref[];toggleOn=1'>[]?</a><br>\n", src.enabled?"activated":"deactivated", src, src.enabled?"Disable":"Enable")
		t += text("Currently set for [] - <A href='?src=\ref[];toggleLethal=1'>Change to []?</a><br>\n", src.lethal?"lethal":"stun repeatedly", src,  src.lethal?"Stun repeatedly":"Lethal")

	//user << browse(t, "window=turretid")
	//onclose(user, "turretid")
	var/datum/browser/popup = new(user, "turretid", "Turret Control Panel ([area.name])")
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/areaturretid/Topic(href, href_list)
	if(..())
		return
	if (src.locked)
		if (!istype(usr, /mob/living/silicon))
			usr << "Control panel is locked!"
			return
	if (href_list["toggleOn"])
		src.enabled = !src.enabled
		src.updateTurrets()
	else if (href_list["toggleLethal"])
		src.lethal = !src.lethal
		src.updateTurrets()
	src.attack_hand(usr)

/obj/machinery/areaturretid/proc/updateTurrets()
	if(control_area)
		for (var/obj/machinery/turret/aTurret in get_area_all_atoms(control_area))
			aTurret.setState(enabled, lethal)
	src.update_icon()

/obj/machinery/areaturretid/power_change()
	..()
	update_icon()

/obj/machinery/areaturretid/update_icon()
	..()
	if(stat & NOPOWER)
		icon_state = "control_off"
	else if (enabled)
		if (lethal)
			icon_state = "control_kill"
		else
			icon_state = "control_stun"
	else
		icon_state = "control_standby"