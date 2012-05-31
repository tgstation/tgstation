//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05

/obj/item/projectile/hivebotbullet
	damage = 5
	damage_type = BRUTE

/obj/effect/critter/hivebot
	name = "Hivebot"
	desc = "A small robot"
	icon = 'hivebot.dmi'
	icon_state = "basic"
	health = 10
	max_health = 10
	aggressive = 1
	wanderer = 1
	opensdoors = 1
	atkcarbon = 1
	atksilicon = 0
	atkcritter = 1
	atksame = 0
	atkmech = 1
	firevuln = 0.5
	brutevuln = 1
	seekrange = 8
	armor = 5
	melee_damage_lower = 2
	melee_damage_upper = 3
	angertext = "leaps at"
	attacktext = "claws"
	var/ranged = 0
	var/rapid = 0
	proc
		Shoot(var/target, var/start, var/user, var/bullet = 0)
		OpenFire(var/thing)//bluh ill rename this later or somethin


	Die()
		if (!src.alive) return
		src.alive = 0
		walk_to(src,0)
		src.visible_message("<b>[src]</b> blows apart!")
		var/turf/Ts = get_turf(src)
		new /obj/effect/decal/cleanable/robot_debris(Ts)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		del(src)

	seek_target()
		src.anchored = 0
		var/T = null
		for(var/mob/living/C in view(src.seekrange,src))//TODO: mess with this
			if (src.target)
				src.task = "chasing"
				break
			if((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if(istype(C, /mob/living/carbon/) && !src.atkcarbon) continue
			if(istype(C, /mob/living/silicon/) && !src.atksilicon) continue
			if(C.health < 0) continue
			if(istype(C, /mob/living/carbon/) && src.atkcarbon)
				if(C:mind)
					if(C:mind:special_role == "H.I.V.E")
						continue
				src.attack = 1
			if(istype(C, /mob/living/silicon/) && src.atksilicon)
				if(C:mind)
					if(C:mind:special_role == "H.I.V.E")
						continue
				src.attack = 1
			if(src.attack)
				T = C
				break

		if(!src.attack)
			for(var/obj/effect/critter/C in view(src.seekrange,src))
				if(istype(C, /obj/effect/critter) && !src.atkcritter) continue
				if(C.health <= 0) continue
				if(istype(C, /obj/effect/critter) && src.atkcritter)
					if((istype(C, /obj/effect/critter/hivebot) && !src.atksame) || (C == src))	continue
					T = C
					break

			for(var/obj/mecha/M in view(src.seekrange,src))
				if(istype(M, /obj/mecha) && !src.atkmech) continue
				if(M.health <= 0) continue
				if(istype(M, /obj/mecha) && src.atkmech) src.attack = 1
				if(src.attack)
					T = M
					break

		if(src.attack)
			src.target = T
			src.oldtarget_name = T:name
			if(src.ranged)
				OpenFire(T)
				return
			src.task = "chasing"
		return


	OpenFire(var/thing)
		src.target = thing
		src.oldtarget_name = thing:name
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
		return


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



/obj/effect/critter/hivebot/range
	name = "Hivebot"
	desc = "A smallish robot, this one is armed!"
	ranged = 1

/obj/effect/critter/hivebot/rapid
	ranged = 1
	rapid = 1

/obj/effect/critter/hivebot/strong
	name = "Strong Hivebot"
	desc = "A robot, this one is armed and looks tough!"
	health = 50
	armor = 10
	ranged = 1

/obj/effect/critter/hivebot/borg
	health = 20
	atksilicon = 1
	ranged = 1
	rapid = 1



/obj/effect/critter/hivebot/tele//this still needs work
	name = "Beacon"
	desc = "Some odd beacon thing"
	icon = 'Hivebot.dmi'
	icon_state = "def_radar-off"
	health = 100
	max_health = 100
	aggressive = 0
	wanderer = 0
	opensdoors = 0
	atkcarbon = 0
	atksilicon = 0
	atkcritter = 0
	atksame = 0
	atkmech = 0
	firevuln = 0.5
	brutevuln = 1
	seekrange = 2
	armor = 10

	var/bot_type = "norm"
	var/bot_amt = 10
	var/spawn_delay = 600
	var/turn_on = 0
	var/auto_spawn = 1
	proc
		warpbots()


	New()
		..()
		var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
		smoke.set_up(5, 0, src.loc)
		smoke.start()
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>The [src] warps in!</B>", 1)
		playsound(src.loc, 'EMPulse.ogg', 25, 1)
		if(auto_spawn)
			spawn(spawn_delay)
				turn_on = 1
				auto_spawn = 0


	warpbots()
		icon_state = "def_radar"
		for(var/mob/O in viewers(src, null))
			O.show_message("\red The [src] turns on!", 1)
		while(bot_amt > 0)
			bot_amt--
			switch(bot_type)
				if("norm")
					new /obj/effect/critter/hivebot(get_turf(src))
				if("range")
					new /obj/effect/critter/hivebot/range(get_turf(src))
				if("rapid")
					new /obj/effect/critter/hivebot/rapid(get_turf(src))
		spawn(100)
			del(src)
		return


	process()
		if((health < (max_health/2)) && (!turn_on))
			if(prob(2))//Might be a bit low, will mess with it likely
				turn_on = 1
		if(turn_on == 1)
			warpbots()
			turn_on = 2
		..()

/obj/effect/critter/hivebot/tele/massive
	bot_type = "norm"
	bot_amt = 30
	auto_spawn = 0

/obj/effect/critter/hivebot/tele/ranged
	bot_type = "range"

/obj/effect/critter/hivebot/tele/rapid
	bot_type = "rapid"
	spawn_delay = 800
