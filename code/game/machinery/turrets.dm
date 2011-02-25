/area/turret_protected
	name = "Turret Protected Area"
	var/list/turretTargets = list()

/area/turret_protected/proc/subjectDied(target)
	if (istype(target, /mob))
		if (!istype(target, /mob/living/silicon))
			if (target:stat)
				if (target in turretTargets)
					src.Exited(target)


/area/turret_protected/Entered(O)
	..()
	if (istype(O, /mob))
		if (!istype(O, /mob/living/silicon))
			if (!(O in turretTargets))
				turretTargets += O
	else if (istype(O, /obj/mecha))
		var/obj/mecha/M = O
		if (M.occupant)
			if (!(M in turretTargets))
				turretTargets += M
	return 1

/area/turret_protected/Exited(O)
	if (istype(O, /mob))
		if (!istype(O, /mob/living/silicon))
			if (O in turretTargets)
				//O << "removing you from target list"
				turretTargets -= O
			//else
				//O << "You aren't in our target list!"

	else if (istype(O, /obj/mecha))
		if (O in turretTargets)
			turretTargets -= O

	if (turretTargets.len == 0)
		popDownTurrets()

	return 1

/area/turret_protected/proc/popDownTurrets()
	for (var/obj/machinery/turret/aTurret in src)
		if (!aTurret.isDown())
			aTurret.popDown()

/obj/machinery/turret
	name = "turret"
	icon = 'turrets.dmi'
	icon_state = "grey_target_prism"
	var/raised = 0
	var/enabled = 1
	anchored = 1
	layer = 3
	invisibility = 2
	density = 1
	var/lasers = 0
	var/health = 18
	var/obj/machinery/turretcover/cover = null
	var/popping = 0
	var/wasvalid = 0
	var/lastfired = 0
	var/shot_delay = 30 //3 seconds between shots
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300

/obj/machinery/turretcover
	name = "pop-up turret cover"
	icon = 'turrets.dmi'
	icon_state = "turretCover"
	anchored = 1
	layer = 3.5
	density = 0

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

/obj/machinery/turret/process()
	listcheck()
	if(stat & (NOPOWER|BROKEN))
		return
	if(lastfired && world.time - lastfired < shot_delay)
		return
	lastfired = world.time
	if (src.cover==null)
		src.cover = new /obj/machinery/turretcover(src.loc)
	var/loc = src.loc
	if (istype(loc, /turf))
		loc = loc:loc
	if (!istype(loc, /area))
		world << text("Badly positioned turret - loc.loc is [].", loc)
		return
	var/area/area = loc
	if (istype(area, /area))
		if (istype(loc, /area/turret_protected))
			src.wasvalid = 1
			var/area/turret_protected/tarea = loc


			if (tarea.turretTargets.len>0 && enabled)
				if (!isPopping())
					if (isDown())
						popUp()
						use_power = 2
					else
						targetting()
			else
				if (!isPopping())
					if (!isDown())
						popDown()
						use_power = 1
		else
			if (src.wasvalid)
				src.die()
			else
				world << text("ERROR: Turret at [x], [y], [z] is NOT in a turret-protected area!")

/obj/machinery/turret/proc/listcheck()
	for (var/mob/living/carbon/guy in loc.loc)
		if (guy in loc.loc:turretTargets)
			continue
		if (guy.lying && !lasers)
			continue
		if (!guy.stat)
			loc.loc:turretTargets += guy


/obj/machinery/turret/proc/targetting()
	var/mob/target
	var/notarget = 0
	do

		if (notarget >= 20)
			return
		if (target)
			if (!istype(target.loc.loc, loc.loc))
				loc.loc:Exited(target)
				target = null
		if (target)
			if ((target.lying && !lasers) || target.stat)
				loc.loc:Exited(target)
				target = null
		if (!target)
			listcheck()
			if (!lasers)
				for (var/mob/possible in loc.loc:turretTargets)
					if (!istype(possible.loc.loc, loc.loc))
						loc.loc:Exited(possible)
						continue
					if (possible.stat)
						loc.loc:Exited(possible)
						notarget++
						continue
					if (possible.lying)
						loc.loc:Exited(possible)
						notarget++
						continue
					if (!target)
						target = possible
						notarget = 0
						break
			else
				for (var/mob/possible in loc.loc:turretTargets)
					if (!istype(possible.loc.loc, loc.loc))
						loc.loc:Exited(possible)
						continue
					if (possible.stat)
						loc.loc:Exited(possible)
						notarget++
						continue
					if (!target)
						target = possible
						notarget = 0
						break
		if (target)
			src.dir = get_dir(src, target)
			if (src.enabled)
				if (istype(target, /mob/living))
					if (!target.stat)
						src.shootAt(target)
					else
						loc.loc:Exited(target)
						target = null
				else if (istype(target, /obj/mecha))
					var/obj/mecha/mecha = target
					if(!mecha.occupant)
						if (mecha in loc.loc:turretTargets)
							loc.loc:turretTargets -= mecha
							target = null
					else
						src.shootAt(target)
		else sleep(1)
	while(!target && loc.loc:turretTargets.len>0)


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
				invisibility = 2
				popping = 0

/obj/machinery/turret/proc/shootAt(var/mob/target)
	var/turf/T = loc
	var/atom/U = (istype(target, /atom/movable) ? target.loc : target)
	if ((!( U ) || !( T )))
		return
	while(!( istype(U, /turf) ))
		U = U.loc
	if (!( istype(T, /turf) ))
		return

	var/obj/beam/a_laser/A
	if (src.lasers)
		A = new /obj/beam/a_laser( loc )
		use_power(500)
	else
		A = new /obj/bullet/electrode( loc )
		use_power(200)

	if (!( istype(U, /turf) ))
		//A = null
		del(A)
		return
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn( 0 )
		A.process()
		return
	return

/obj/machinery/turret/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		src.health -= 4
	else if (flag == PROJECTILE_TASER) //taser
		src.health -= 1
	else if(flag == PROJECTILE_PULSE)
		src.health -= 10
	else
		src.health -= 2

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

/obj/machinery/turret/ex_act(severity)
	if(severity < 3)
		src.die()

/obj/machinery/turret/proc/die()
	src.health = 0
	src.density = 0
	src.stat |= BROKEN
	src.icon_state = "destroyed_target_prism"
	if (cover!=null)
		del(cover)
	sleep(3)
	flick("explosion", src)
	spawn(13)
		del(src)

/obj/machinery/turretid
	name = "Turret deactivation control"
	icon = 'device.dmi'
	icon_state = "motion3"
	anchored = 1
	density = 0
	var/enabled = 1
	var/lethal = 0
	var/locked = 1
	req_access = list(access_ai_upload)

/obj/machinery/turretid/attackby(obj/item/weapon/W, mob/user)
	if(stat & BROKEN) return
	if (istype(user, /mob/living/silicon))
		return src.attack_hand(user)
	else // trying to unlock the interface
		if (src.allowed(usr))
			locked = !locked
			user << "You [ locked ? "lock" : "unlock"] the panel."
			if (locked)
				if (user.machine==src)
					user.machine = null
					user << browse(null, "window=turretid")
			else
				if (user.machine==src)
					src.attack_hand(usr)
		else
			user << "\red Access denied."

/obj/machinery/turretid/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/turretid/attack_hand(mob/user as mob)
	if ( (get_dist(src, user) > 1 ))
		if (!istype(user, /mob/living/silicon))
			user << text("Too far away.")
			user.machine = null
			user << browse(null, "window=turretid")
			return

	user.machine = src
	var/loc = src.loc
	if (istype(loc, /turf))
		loc = loc:loc
	if (!istype(loc, /area))
		user << text("Turret badly positioned - loc.loc is [].", loc)
		return
	var/area/area = loc
	var/t = "<TT><B>Turret Control Panel</B> ([area.name])<HR>"

	if(src.locked && (!istype(user, /mob/living/silicon)))
		t += "<I>(Swipe ID card to unlock control panel.)</I><BR>"
	else
		t += text("Turrets [] - <A href='?src=\ref[];toggleOn=1'>[]?</a><br>\n", src.enabled?"activated":"deactivated", src, src.enabled?"Disable":"Enable")
		t += text("Currently set for [] - <A href='?src=\ref[];toggleLethal=1'>Change to []?</a><br>\n", src.lethal?"lethal":"stun repeatedly", src,  src.lethal?"Stun repeatedly":"Lethal")

	user << browse(t, "window=turretid")
	onclose(user, "turretid")


/obj/machinery/turret/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(!(stat & BROKEN))
		playsound(src.loc, 'slash.ogg', 25, 1, -1)
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
		src.health -= 4
		if (src.health <= 0)
			src.die()
	else
		M << "\green That object is useless to you."
	return

/obj/machinery/turretid/Topic(href, href_list)
	..()
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

/obj/machinery/turretid/proc/updateTurrets()
	if (src.enabled)
		if (src.lethal)
			icon_state = "motion1"
		else
			icon_state = "motion3"
	else
		icon_state = "motion0"

	var/loc = src.loc
	if (istype(loc, /turf))
		loc = loc:loc
	if (!istype(loc, /area))
		world << text("Turret badly positioned - loc.loc is [loc].")
		return
	var/area/area = loc

	for (var/obj/machinery/turret/aTurret in get_area_all_atoms(area))
		aTurret.setState(enabled, lethal)



/obj/turret/gun_turret
	name = "Gun Turret"
	density = 1
	anchored = 1
	var/cooldown = 20
	var/projectiles = 100
	var/projectiles_per_shot = 2
	var/deviation = 0.3
	var/list/snapshot = list()
	var/atom/cur_target
	var/scan_range = 7
	var/health = 40
	var/list/scan_for = list("human"=0,"cyborg"=0,"mecha"=0,"alien"=1)
	var/on = 0
	icon = 'turrets.dmi'
	icon_state = "gun_turret"


	ex_act()
		del src
		return

	emp_act()
		del src
		return

	meteorhit()
		del src
		return

	proc/update_health()
		if(src.health<=0)
			del src
		return

	proc/take_damage(damage)
		src.health -= damage
		if(src.health<=0)
			del src
		return

	bullet_act(flag)
		var/damage = 0
		switch(flag)
			if(PROJECTILE_PULSE)
				damage = 40
			if(PROJECTILE_LASER)
				damage = 20
			if(PROJECTILE_TASER)
				damage = 8
			if(PROJECTILE_WEAKBULLET)
				damage = 8
			if(PROJECTILE_BULLET)
				damage = 10
			if(PROJECTILE_BOLT)
				damage = 5
			if(PROJECTILE_DART)
				damage = 5
		src.take_damage(damage)
		return

	attack_hand(mob/user as mob)
		user.machine = src
		var/dat = {"<html>
						<head><title>[src] Control</title></head>
						<body>
						<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"on":"off"]</a><br>
						<b>Scan Range: </b><a href='?src=\ref[src];scan_range=-1'>-</a> [scan_range] <a href='?src=\ref[src];scan_range=1'>+</a><br>
						<b>Scan for: </b>"}
		for(var/scan in scan_for)
			dat += "<div style=\"margin-left: 15px;\">[scan] (<a href='?src=\ref[src];scan_for=[scan]'>[scan_for[scan]?"Yes":"No"]</a>)</div>"

		dat += {"<b>Ammo: </b>[max(0, projectiles)]<br>
					</body>
					</html>"}
		user << browse(dat, "window=turret")
		onclose(user, "turret")
		return

	attack_ai(mob/user as mob)
		return attack_hand(user)


	attack_alien(mob/user as mob)
		user.visible_message("[user] slashes at [src]", "You slash at [src]")
		src.take_damage(15)
		return

	Topic(href, href_list)
		if(href_list["power"])
			src.on = !src.on
			if(src.on)
				spawn(50)
					src.process()
		if(href_list["scan_range"])
			src.scan_range = between(1,src.scan_range+text2num(href_list["scan_range"]),8)
		if(href_list["scan_for"])
			if(href_list["scan_for"] in scan_for)
				scan_for[href_list["scan_for"]] = !scan_for[href_list["scan_for"]]
		src.updateUsrDialog()
		return


	proc/validate_target(atom/target)
		if(get_dist(target, src)>scan_range)
			return 0
		if(istype(target, /mob))
			var/mob/M = target
			if(!M.stat && !M.lying)//ninjas can't catch you if you're lying
				return 1
		else if(istype(target, /obj/mecha))
			return 1
		return 0


	proc/process()
		spawn while(on)
			if(projectiles<=0)
				on = 0
				return
			if(cur_target && !validate_target(cur_target))
				cur_target = null
			if(!cur_target)
				cur_target = get_target()
			fire(cur_target)
			sleep(cooldown)
		return

	proc/get_target()
		var/list/pos_targets = list()
		var/target = null
		if(scan_for["human"])
			for(var/mob/living/carbon/human/M in oview(scan_range,src))
				if(!M.stat && !M.lying)
					pos_targets += M
		if(scan_for["cyborg"])
			for(var/mob/living/silicon/M in oview(scan_range,src))
				if(!M.stat && !M.lying)
					pos_targets += M
		if(scan_for["mecha"])
			for(var/obj/mecha/M in oview(scan_range, src))
				pos_targets += M
		if(scan_for["alien"])
			for(var/mob/living/carbon/alien/M in oview(scan_range,src))
				if(!M.stat && !M.lying)
					pos_targets += M
		if(pos_targets.len)
			target = pick(pos_targets)
		return target


	proc/fire(atom/target)
		if(!target)
			cur_target = null
			return
		src.dir = get_dir(src,target)
		var/turf/targloc = get_turf(target)
		var/target_x = targloc.x
		var/target_y = targloc.y
		var/target_z = targloc.z
		targloc = null
		spawn	for(var/i=1 to min(projectiles, projectiles_per_shot))
			if(!src) break
			var/turf/curloc = get_turf(src)
			targloc = locate(target_x+GaussRandRound(deviation,1),target_y+GaussRandRound(deviation,1),target_z)
			if (!targloc || !curloc)
				continue
			if (targloc == curloc)
				continue
			playsound(src, 'Gunshot.ogg', 50, 1)
			var/obj/bullet/A = new /obj/bullet(curloc)
			src.projectiles--
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			A.process()
			sleep(2)
		return