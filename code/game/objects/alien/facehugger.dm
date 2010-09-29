#define cycle_pause 5 //min 1
#define viewrange 7 //min 2




// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
// Includes spacetiles
/turf/proc/CardinalTurfsWithAccessSpace(var/obj/item/weapon/card/id/ID)
	var/L[] = new()
	for(var/d in cardinal)
		var/turf/simulated/T = get_step(src, d)
		if((istype(T) || istype(T,/turf/space))&& !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L



/obj/alien/facehugger
	name = "alien"
	desc = "An alien, looks pretty scary!"
	icon_state = "facehugger"
	layer = 5.0
	density = 1
	anchored = 0

	var/state = 0

	var/list/path = new/list()

	var/frustration = 0
	var/mob/living/carbon/target
	var/list/path_target = new/list()

	var/turf/trg_idle
	var/list/path_idle = new/list()

	var/alive = 1 //1 alive, 0 dead
	var/health = 25
	var/maxhealth = 25
	var/lamarr = 0
	flags = 258.0





	New()
		..()
		if(aliens_allowed)
			health = maxhealth
			src.process()
		else
			del(src)

	examine()
		set src in view()
		..()
		if(!alive)
			usr << text("\red <B>the alien is not moving</B>")
		else if (src.health > 15)
			usr << text("\red <B>the alien looks fresh, just out of the egg</B>")
		else
			usr << text("\red <B>the alien looks pretty beat up</B>")
		if (lamarr)
			usr << text("\red <B>it looks like the proboscis has been removed</B>")
		return


	attack_hand(user as mob)
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		switch(W.damtype)
			if("fire")
				src.health -= W.force * 0.75
			if("brute")
				src.health -= W.force * 0.5
			else
		if (src.health <= 0)
			src.death()
		else if (W.force)
			if(ishuman(user) || ismonkey(user))
				src.target = user
				src.state = 1
		..()

	bullet_act(flag, A as obj)
		if (flag == PROJECTILE_BULLET)
			src.health -= 20
		else if (flag == PROJECTILE_WEAKBULLET)
			src.health -= 4
		else if (flag == PROJECTILE_LASER)
			src.health -= 10
		healthcheck()

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.death()
			if(2.0)
				src.health -= 15
				healthcheck()
		return

	meteorhit()
		src.death()
		return

	blob_act()
		if(prob(25))
			src.death()
		return

	Bumped(AM as mob|obj)
		if(ismob(AM) && (ishuman(AM) || ismonkey(AM)) )
			src.target = AM
			set_attack()
		else if(ismob(AM))
			spawn(0)
				var/turf/T = get_turf(src)
				AM:loc = T

	Bump(atom/A)
		if(ismob(A) && (ishuman(A) || ismonkey(A)))
			src.target = A
			set_attack()
		else if(ismob(A))
			src.loc = A:loc

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if(exposed_temperature > 300)
			health -= 5
			healthcheck()




	verb/follow()
		set src in view()
		set name = "Follow Me"
		if(!alive) return
		if(!isalien(usr))
			usr << text("\red <B>The alien ignores you.</B>")
			return
		if(state != 2 || health < maxhealth)
			usr << text("\red <B>The alien is too busy to follow you.</B>")
			return
		usr << text("\green <B>The alien will now try to follow you.</B>")
		trg_idle = usr
		path_idle = new/list()
		return

	verb/stop()
		set src in view()
		set name = "Stop Following"
		if(!alive) return
		if(!isalien(usr))
			usr << text("\red <B>The alien ignores you.</B>")
			return
		if(state != 2)
			usr << text("\red <B>The alien is too busy to follow you.</B>")
			return
		usr << text("\green <B>The alien stops following you.</B>")
		set_null()
		return




	proc/call_to(var/mob/user)
		if(!alive || !isalien(user) || state != 2) return
		trg_idle = user
		path_idle = new/list()
		return

	proc/set_attack()
		state = 1
		if(path_idle.len) path_idle = new/list()
		trg_idle = null

	proc/set_idle()
		state = 2
		if (path_target.len) path_target = new/list()
		target = null
		frustration = 0

	proc/set_null()
		state = 0
		if (path_target.len) path_target = new/list()
		if (path_idle.len) path_idle = new/list()
		target = null
		trg_idle = null
		frustration = 0

	proc/process()
		set background = 1
		var/quick_move = 0

		if (!alive)
			return

		if (!target)
			if (path_target.len) path_target = new/list()

			var/last_health = INFINITY
			var/view
			if (lamarr)
				view = 1
			else
				view = viewrange-2
			for (var/mob/living/carbon/C in range(view,src.loc))
				if (C.stat == 2 || isalien(C) || C.alien_egg_flag || !can_see(src,C,viewrange))
					continue
				if(C:stunned || C:paralysis || C:weakened)
					target = C
					break
				if(C:health < last_health)
					last_health = C:health
					target = C

			if(target)
				if (!lamarr || prob(10))
					set_attack()
			else if(state != 2)
				set_idle()
				idle()

		else if(target)
			var/turf/distance = get_dist(src, target)
			if (!lamarr || prob(10))
				set_attack()

			if(can_see(src,target,viewrange))
				if(distance <= 1 && (!lamarr || prob(20)))
					for(var/mob/O in viewers(world.view,src))
						O.show_message("\red <B>[src.target] has been leapt on by [lamarr ? src.name : "the alien"]!</B>", 1, "\red You hear someone fall", 2)
					if (!lamarr)
						target:bruteloss += 10
						target:paralysis = max(target:paralysis, 10)
					src.loc = target.loc

					if(!target.alien_egg_flag && ( ishuman(target) || ismonkey(target) ) )
						if (!lamarr)
							target.alien_egg_flag = 1
							var/mob/trg = target
							src.death()
							trg.contract_disease(new /datum/disease/alien_embryo, 1)
							return
						else
							sleep(50)
					else
						set_null()
						spawn(cycle_pause) src.process()
						return

				step_towards(src,get_step_towards2(src , target))
			else
				if( !path_target.len )

					path_attack(target)
					if(!path_target.len)
						set_null()
						spawn(cycle_pause) src.process()
						return
				else
					var/turf/next = path_target[1]

					if(next in range(1,src))
						path_attack(target)

					if(!path_target.len)
						src.frustration += 5
					else
						next = path_target[1]
						path_target -= next
						step_towards(src,next)
						quick_move = 1

			if (get_dist(src, src.target) >= distance) src.frustration++
			else src.frustration--
			if(frustration >= 35 || lamarr) set_null()

		if(quick_move)
			spawn(cycle_pause/2)
				src.process()
		else
			spawn(cycle_pause)
				src.process()

	proc/idle()
		set background = 1
		var/quick_move = 0

		if(state != 2 || !alive || target) return

		if(locate(/obj/alien/weeds) in src.loc && health < maxhealth)
			health++
			spawn(cycle_pause) idle()
			return

		if(!path_idle.len)

			if(isalien(trg_idle))
				if(can_see(src,trg_idle,viewrange))
					step_towards(src,get_step_towards2(src , trg_idle))
				else
					path_idle(trg_idle)
					if(!path_idle.len)
						trg_idle = null
						set_idle()
						spawn(cycle_pause) src.idle()
						return
			else
				var/obj/alien/weeds/W = null
				if(health < maxhealth)
					var/list/the_weeds = new/list()

					find_weeds:
						for(var/obj/alien/weeds/weed in range(viewrange,src.loc))
							if(!can_see(src,weed,viewrange)) continue
							for(var/atom/A in get_turf(weed))
								if(A.density) continue find_weeds
							the_weeds += weed
					if(the_weeds.len)
						W = pick(the_weeds)

				if(W)
					path_idle(W)
					if(!path_idle.len)
						trg_idle = null
						spawn(cycle_pause) src.idle()
						return
				else
					for(var/mob/living/carbon/alien/humanoid/H in range(1,src))
						spawn(cycle_pause) src.idle()
						return
					step(src,pick(cardinal))

		else

			if(can_see(src,trg_idle,viewrange))
				switch(get_dist(src, trg_idle))
					if(1)
						if(istype(trg_idle,/obj/alien/weeds))
							step_towards(src,get_step_towards2(src , trg_idle))
					if(2 to INFINITY)
						step_towards(src,get_step_towards2(src , trg_idle))
						if(path_idle.len) path_idle = new/list()
					/*
					if(viewrange+1 to INFINITY)
						step_towards(src,get_step_towards2(src , trg_idle))
						if(path_idle.len) path_idle = new/list()
						quick_move = 1
					*/
			else
				var/turf/next = path_idle[1]
				if(!next in range(1,src))
					path_idle(trg_idle)

				if(!path_idle.len)
					spawn(cycle_pause) src.idle()
					return
				else
					next = path_idle[1]
					path_idle -= next
					step_towards(src,next)
					quick_move = 1

		if(quick_move)
			spawn(cycle_pause/2)
				idle()
		else
			spawn(cycle_pause)
				idle()

	proc/path_idle(var/atom/trg)
		path_idle = AStar(src.loc, get_turf(trg), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, null, null)
		path_idle = reverselist(path_idle)

	proc/path_attack(var/atom/trg)
		target = trg
		path_target = AStar(src.loc, target.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, null, null)
		path_target = reverselist(path_target)


	proc/death()
		if(!alive) return
		src.alive = 0
		density = 0
		icon_state = "facehugger_l"
		set_null()
		for(var/mob/O in hearers(src, null))
			O.show_message("\red <B>[src] curls up into a ball!</B>", 1)

	proc/healthcheck()
		if (src.health <= 0)
			src.death()

