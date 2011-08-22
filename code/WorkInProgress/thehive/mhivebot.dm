/obj/item/projectile/hivebotbullet
		damage = 5
		mobdamage = list(BRUTE = 5, BURN = 0, TOX = 0, OXY = 0, CLONE = 0)

/obj/hivebot
	name = "Hivebot"
	desc = "A small robot"
	icon = 'Hivebot.dmi'
	icon_state = "basic"
	layer = 5.0
	density = 1
	anchored = 0
	var
		alive = 1
		health = 10
		task = "thinking"
		aggressive = 1
		wanderer = 1
		opensdoors = 1
		frustration = 0
		last_found = null
		target = null
		oldtarget_name = null
		target_lastloc = null
		atkcarbon = 1
		atksilicon = 0
		attack = 0
		attacking = 0
		steps = 0
		firevuln = 0.5
		brutevuln = 1
		seekrange = 8
		basic_damage = 2
		armor = 5
	proc
		patrol_step()
		process()
		seek_target()
		Die()
		ChaseAttack(mob/M)
		RunAttack(mob/M)
		Shoot(var/target, var/start, var/user, var/bullet = 0)
		TakeDamage(var/damage = 0)


	attackby(obj/item/weapon/W as obj, mob/living/user as mob)
		..()
		if (!src.alive) return
		var/damage = 0
		switch(W.damtype)
			if("fire") damage = W.force * firevuln
			if("brute") damage = W.force * brutevuln
		TakeDamage(damage)


	attack_hand(var/mob/user as mob)
		if (!src.alive) return
		if (user.a_intent == "hurt")
			TakeDamage(2 * brutevuln)
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <b>[user]</b> punches [src]!", 1)
			playsound(src.loc, pick('punch1.ogg','punch2.ogg','punch3.ogg','punch4.ogg'), 100, 1)


	patrol_step()
		var/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)
		if (istype(moveto, /turf/simulated/floor) || istype(moveto, /turf/simulated/shuttle/floor) || istype(moveto, /turf/unsimulated/floor)) step_towards(src, moveto)
		if(src.aggressive) seek_target()
		steps += 1
		if (steps == rand(5,20)) src.task = "thinking"


	Bump(M as mob|obj)
		spawn(0)
			if ((istype(M, /obj/machinery/door)))
				var/obj/machinery/door/D = M
				if (src.opensdoors)
					D.open()
					src.frustration = 0
				else src.frustration ++
			else if ((istype(M, /mob/living/)) && (!src.anchored))
				src.loc = M:loc
				src.frustration = 0
			return
		return


	Bumped(M as mob|obj)
		spawn(0)
			var/turf/T = get_turf(src)
			M:loc = T


	bullet_act(var/obj/item/projectile/Proj)
		TakeDamage(Proj.damage)

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.Die()
				return
			if(2.0)
				TakeDamage(20)
				return
		return


	emp_act(serverity)
		src.Die()//Currently why not
		return


	meteorhit()
		src.Die()
		return


	blob_act()
		if(prob(25))
			src.Die()
		return


	process()
		set background = 1
		if (!src.alive) return
		switch(task)
			if("thinking")
				src.attack = 0
				src.target = null
				sleep(15)
				walk_to(src,0)
				if (src.aggressive) seek_target()
				if (src.wanderer && !src.target) src.task = "wandering"
			if("chasing")
				if (src.frustration >= 8)
					src.target = null
					src.last_found = world.time
					src.frustration = 0
					src.task = "thinking"
					walk_to(src,0)
				if (target)
					if (get_dist(src, src.target) <= 1)
						var/mob/living/carbon/M = src.target
						ChaseAttack(M)
						src.task = "attacking"
						src.anchored = 1
						src.target_lastloc = M.loc
					else
						var/turf/olddist = get_dist(src, src.target)
						walk_to(src, src.target,1,4)
						if ((get_dist(src, src.target)) >= (olddist))
							src.frustration++
						else
							src.frustration = 0
						sleep(5)
				else src.task = "thinking"
			if("attacking")
				// see if he got away
				if ((get_dist(src, src.target) > 1) || ((src.target:loc != src.target_lastloc)))
					src.anchored = 0
					src.task = "chasing"
				else
					if (get_dist(src, src.target) <= 1)
						var/mob/living/carbon/M = src.target
						if (!src.attacking) RunAttack(src.target)
						if (!src.aggressive)
							src.task = "thinking"
							src.target = null
							src.anchored = 0
							src.last_found = world.time
							src.frustration = 0
							src.attacking = 0
						else
							if(M!=null)
								if (M.health < 0)
									src.task = "thinking"
									src.target = null
									src.anchored = 0
									src.last_found = world.time
									src.frustration = 0
									src.attacking = 0
					else
						src.anchored = 0
						src.attacking = 0
						src.task = "chasing"
			if("wandering")
				patrol_step()
				sleep(10)
		spawn(8)
			process()
		return


	New()
		spawn(0) process()
		..()


	seek_target()
		src.anchored = 0
		for (var/mob/living/C in view(src.seekrange,src))
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (istype(C, /mob/living/carbon/) && !src.atkcarbon) continue
			if (istype(C, /mob/living/silicon/) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (istype(C, /mob/living/carbon/) && src.atkcarbon) src.attack = 1
			if (istype(C, /mob/living/silicon/) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.task = "chasing"
				break
			else
				continue


	Die()
		if (!src.alive) return
		src.alive = 0
		walk_to(src,0)
		src.visible_message("<b>[src]</b> blows apart!")
		var/turf/Ts = get_turf(src)
		new /obj/decal/cleanable/robot_debris(Ts)
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		del(src)


	TakeDamage(var/damage = 0)
		var/tempdamage = (damage-armor)
		if(tempdamage > 0)
			src.health -= tempdamage
		else
			src.health--
		if(src.health <= 0)
			src.Die()


	ChaseAttack(mob/M)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> leaps at [src.target]!", 1)


	RunAttack(mob/M)
		src.attacking = 1
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> claws at [src.target]!", 1)
		src.target:bruteloss += basic_damage
		spawn(25)
			src.attacking = 0


	Shoot(var/target, var/start, var/user, var/bullet = 0)
		if(target == start)
			return

		var/obj/item/projectile/hivebotbullet/A = new /obj/item/projectile/hivebotbullet(user:loc)
		playsound(user, 'Gunshot.ogg', 100, 1)

		if(!A)	return

		if (!istype(target, /turf))
			del(A)
			return
		A.current = target
		A.yo = target:y - start:y
		A.xo = target:x - start:x
		spawn( 0 )
			A.process()
		return


/obj/hivebot/range
	name = "Hivebot"
	desc = "A smallish robot, this one is armed!"
	var/rapid = 0

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in view(src.seekrange,src))
			if (!src.alive) break
			if (C.health < 0) continue
			if (istype(C, /mob/living/carbon/) && src.atkcarbon) src.attack = 1
			if (istype(C, /mob/living/silicon/) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <b>[src]</b> fires at [src.target]!", 1)

				var/tturf = get_turf(target)
				if(rapid)
					spawn(1)
						Shoot(tturf, src.loc, src)
					spawn(4)
						Shoot(tturf, src.loc, src)
					spawn(6)
						Shoot(tturf, src.loc, src)
				else
					Shoot(tturf, src.loc, src)

				src.attack = 0
				sleep(12)
				seek_target()
				src.task = "thinking"
				break
			else continue

/obj/hivebot/range/rapid
	rapid = 1

/obj/hivebot/range/strong
	name = "Strong Hivebot"
	desc = "A robot, this one is armed and looks tough!"
	health = 50
	armor = 10

/obj/hivebot/range/borgkill
	health = 20
	atksilicon = 1


