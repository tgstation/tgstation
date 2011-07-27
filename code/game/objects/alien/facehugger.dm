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
	var/health = 10
	var/maxhealth = 10
	var/lamarr = 0
	flags = 258.0





	New()
		..()
		if(aliens_allowed)
			health = maxhealth
			process()
		else
			del(src)

	examine()
		set src in view()
		..()
		if(!alive)
			usr << text("\red <B>The alien is not moving.</B>")
		else if (health > 5)
			usr << text("\red <B>The alien looks fresh, just out of the egg.</B>")
		else
			usr << text("\red <B>The alien looks injured.</B>")
		if (lamarr)
			usr << text("\red <B>It looks like the proboscis has been removed.</B>")
		return


	attack_hand(user as mob)
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		switch(W.damtype)
			if("fire")
				health -= W.force * 0.75
			if("brute")
				health -= W.force * 0.5
			else
		if (health <= 0)
			death()
		else if (W.force)
			if(ishuman(user) || ismonkey(user))
				target = user
				state = 1
		..()

	bullet_act(var/obj/item/projectile/Proj)
		health -= round(Proj.damage / 2)
		healthcheck()

	ex_act(severity)
		switch(severity)
			if(1.0)
				death()
			if(2.0)
				health -= 15
				healthcheck()
		return

	meteorhit()
		death()
		return

	blob_act()
		if(prob(50))
			death()
		return

	Bumped(AM as mob|obj)
		if(ismob(AM) && (ishuman(AM) || ismonkey(AM)) )
			target = AM
			set_attack()
		else if(ismob(AM))
			spawn(0)
				var/turf/T = get_turf(src)
				AM:loc = T

	Bump(atom/A)
		if(ismob(A) && (ishuman(A) || ismonkey(A)))
			target = A
			set_attack()
		else if(ismob(A))
			loc = A:loc

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if(exposed_temperature > 300)
			health -= 5
			healthcheck()




	verb/follow()
		set src in view() //set src in get_aliens(view()) - does not work, damn shitty byond :( -- rastaf0
		set name = "Follow Me"
		set category = "Object" //"Alien" does not work perfect - humans get "Alien" tab too, that's annoying
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
		set category = "Object"
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
			for (var/mob/living/carbon/C in range(view,loc))
				if (C.stat == 2 || isalien(C) || C.alien_egg_flag || !can_see(src,C,viewrange) || istype(C, /mob/living/carbon/metroid))
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
						O.show_message("\red <B>[target] has been leapt on by [lamarr ? name : "the alien"]!</B>", 1, "\red You hear someone fall", 2)
					if (!lamarr)
						target:take_overall_damage(5)
						if(prob(70))
							target:paralysis = max(target:paralysis, 5)
					loc = target.loc

					if(!target.alien_egg_flag && ( ishuman(target) || ismonkey(target) ) )
						if (!lamarr && target)
							var/mob/trg = target
							death()
							//if(trg.virus)//Viruses are stored in a global database.
								//trg.virus.cure(0)//You need to either cure() or del() them to stop their processing.
							trg.contract_disease(new /datum/disease/alien_embryo(0))//So after that you need to infect the target anew.
							for(var/datum/disease/alien_embryo/A in trg.viruses)
								trg.alien_egg_flag = 1//We finally set their flag to 1.
							return
						else
							sleep(50)
					else
						set_null()
						spawn(cycle_pause) process()
						return

				step_towards(src,get_step_towards2(src , target))
			else
				if( !path_target.len )

					path_attack(target)
					if(!path_target.len)
						set_null()
						spawn(cycle_pause) process()
						return
				else
					var/turf/next = path_target[1]

					if(next in range(1,src))
						path_attack(target)

					if(!path_target.len)
						frustration += 5
					else
						next = path_target[1]
						path_target -= next
						step_towards(src,next)
						quick_move = 1

			if (get_dist(src, target) >= distance) frustration++
			else frustration--
			if(frustration >= 35 || lamarr) set_null()

		if(quick_move)
			spawn(cycle_pause/2)
				process()
		else
			spawn(cycle_pause)
				process()

	proc/idle()
		set background = 1
		var/quick_move = 0

		if(state != 2 || !alive || target) return

		if(locate(/obj/alien/weeds) in loc && health < maxhealth)
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
						spawn(cycle_pause) idle()
						return
			else
				var/obj/alien/weeds/W = null
				if(health < maxhealth)
					var/list/the_weeds = new/list()

					find_weeds:
						for(var/obj/alien/weeds/weed in range(viewrange,loc))
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
						spawn(cycle_pause) idle()
						return
				else
					for(var/mob/living/carbon/alien/humanoid/H in range(1,src))
						spawn(cycle_pause) idle()
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
					spawn(cycle_pause) idle()
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
		path_idle = AStar(loc, get_turf(trg), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, null, null)
		path_idle = reverselist(path_idle)

	proc/path_attack(var/atom/trg)
		target = trg
		path_target = AStar(loc, target.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, null, null)
		path_target = reverselist(path_target)


	proc/death()
		if(!alive) return
		alive = 0
		density = 0
		icon_state = "facehugger_l"
		set_null()
		for(var/mob/O in hearers(src, null))
			O.show_message("\red <B>[src] curls up into a ball!</B>", 1)

	proc/healthcheck()
		if (health <= 0)
			death()

