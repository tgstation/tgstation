//Blatently copy/pasted from facehugger code + a few changes.

/obj/livestock
	name = "animal thing"
	desc = "This doesn't seem so bad..."
	icon = 'livestock.dmi'
	layer = 5.0
	density = 1
	anchored = 0

	var/state = 0		//0 = null, 1 = attack, 2 = idle

	var/list/path = new/list()

	var/frustration = 0						//How long it's gone without reaching it's target.
	var/patience = 35						//The maximum time it'll chase a target.
	var/mob/living/carbon/target			//It's combat target.
	var/list/path_target = new/list()		//The path to the combat target.

	var/turf/trg_idle					//It's idle target, the one it's following but not attacking.
	var/list/path_idle = new/list()		//The path to the idle target.

	var/alive = 1 //1 alive, 0 dead
	var/maxhealth = 25
	var/health = 25
	var/aggressive = 0
	flags = 258.0
	var/strength = 10 //The damage done by the creature if it attacks something.
	var/cycle_pause = 5
	var/view_range = 7				//How far it can see.
	var/obj/item/weapon/card/id/anicard		//By default, animals can open doors but not any with access restrictions.
	var/intelligence = null					// the intelligence var allows for additional access (by job).

	New()			//Initializes the livestock's AI and access
		..()
		anicard = new(src)
		if(!isnull(src.intelligence))
			anicard.access = get_access(intelligence)
		else
			anicard.access = null
		src.process()

	examine()
		set src in view()
		..()
		if(!alive)
			usr << text("\red <B>The animal is not moving</B>")
		else if (src.health == src.health)
			usr << text("\red <B>The animal looks healthy.</B>")
		else
			usr << text("\red <B>The animal looks beat up</B>")
		if (aggressive && alive)
			usr << text("\red <B>Looks fierce!</B>")
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
			if(src.aggressive && (ishuman(user) || ismonkey(user)))
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
		if(prob(50))
			src.death()
		return

	Bumped(AM as mob|obj)
		if(ismob(AM) && src.aggressive && (ishuman(AM) || ismonkey(AM)) )
			src.target = AM
			set_attack()
		else if(ismob(AM))
			spawn(0)
				var/turf/T = get_turf(src)
				AM:loc = T

	Bump(atom/A)
		if(ismob(A) && src.aggressive && (ishuman(A) || ismonkey(A)))
			src.target = A
			set_attack()
		else if(ismob(A))
			src.loc = A:loc
		..()

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if(exposed_temperature > 300)
			health -= 5
			healthcheck()

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

	proc/process()				//Master AI proc.
		set background = 1
		if (!alive)				//If it isn't alive, it shouldn't be doing anything.
			return
		if (!target)
			if (path_target.len) path_target = new/list()	//No target but there's still path data? reset it.
			var/last_health = INFINITY						//Set as high as possible as an initial value.
			var/view = view_range-2							//Actual sight slightly lower then it's total sight.
			for (var/mob/living/carbon/C in range(view,src.loc))	//Checks all carbon creatures in range.
				if (!aggressive)									//Is this animal angry? If not, what the fuck are you doing?
					break
				if (C.stat == 2 || !can_see(src,C,view_range))		//Can it see it at all or is the target a ghost?
					continue
				if(C:stunned || C:paralysis || C:weakened)			//An easy target, bwahaha!
					target = C
					break
				if(C:health < last_health)				//Selects the target but does NOT break the FOR loop.
					last_health = C:health				//	As such, it'll keep going until it finds the one with the
					target = C							//	lowest health.
			if(target)			//Does it have a target NOW?
				if (aggressive)	//Double checking if it is aggressive or not.
					set_attack()
			else if(state != 2)	//If it doesn't have a target and it isn't idling already, idle.
				set_idle()
				idle()
		else if(target)		//It already has a target? YAY!
			var/turf/distance = get_dist(src, target)
			if (src.aggressive)  //I probably don't need this check, but just in case.
				set_attack()
			else
				set_idle()
				idle()
			if(can_see(src,target,view_range ))	//Can I see it?
				if(distance <= 1)  				//Am I close enough to attack it?
					for(var/mob/O in viewers(world.view,src))
						O.show_message("\red <B>[src.target] has been leapt on by [src.name]!</B>", 1, "\red You hear someone fall", 2)
					target:bruteloss += strength
					target:stunned = max(target:stunned, (strength / 2))
					src.loc = target.loc
					set_null()  //Break off the attack for a sec.
				step_towards(src,get_step_towards2(src , target)) // Move towards the target.
			else
				if( !path_target.len )		//Don't have a path yet but do have a target?
					path_attack(target)			//Find a path!
					if(!path_target.len)		//Still no path?
						set_null()				//Fuck this shit.
				if( path_target.len )						 //Ok, I DO have a path
					var/turf/next = path_target[1] //Select the next square to move to.
					if(next in range(1,src))		//Is it next to it?
						path_attack(target)			//Re-find path.
					if(!path_target.len)			//If can't path to the target, it gets really angry.
						src.frustration += 5
					else
						next = path_target[1]		//If it CAN path to the target, select the next move point
						path_target -= next
						step_towards(src,next)		//And move in that direction.
			if (get_dist(src, src.target) >= distance) src.frustration++ //If it hasn't reached the target yet, get a little angry.
			else src.frustration--			//It reached the target! Get less angry.
			if(frustration >= patience) set_null()		//If too angry? Fuck this shit.
		if(target)
			spawn(3)
				src.process()
		else
			spawn(cycle_pause)
				src.process()

	proc/idle()					//Idle proc for when it isn't in combat mode. Called by itself and process()
		set background = 1
		if(state != 2 || !alive || target) return  //If you arne't idling, aren't alive, or have a target, you shouldn't be here.
		if(prob(5) && health < maxhealth)			//5% chance of healing every cycle.
			health++
		if(isnull(trg_idle))						//No one to follow? Find one.
			for(var/mob/living/O in viewers(world.view,src))
				if(O.mutations == (0 || 16))		//Hates mutants and fatties.
					trg_idle = O
					break
		if(isnull(trg_idle))						//Still no one to follow? Step in a random direction.
			step(src,pick(cardinal))
		else if(!path_idle.len)						//Has a target but no path?
			if(can_see(src,trg_idle,view_range))	//Can see it? Then move towards it.
				step_towards(src,get_step_towards2(src , trg_idle))
			else
				path_idle(trg_idle)		//Can't see it? Find a path.
				if(!path_idle.len)		//Still no path? Stop trying to follow it.
					trg_idle = null
				step(src,pick(cardinal))
		else
			if(can_see(src,trg_idle,view_range))	//Has a path and can see the target?
				if(get_dist(src, trg_idle) >= 2)		//If 2 or more squares away, re-find path and move towards it.
					step_towards(src,get_step_towards2(src , trg_idle))
					if(path_idle.len) path_idle = new/list()
			else
				var/turf/next = path_idle[1]		//Has a target and a path but can't see it?
				if(!next in range(1,src))			//If end of path and not next to target, find new path.
					path_idle(trg_idle)

				if(path_idle.len)					//If still some path left, move along path.
					next = path_idle[1]
					path_idle -= next
					step_towards(src,next)
		spawn(cycle_pause)
			idle()

	proc/path_idle(var/atom/trg)
		path_idle = AStar(src.loc, get_turf(trg), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, anicard, null)
		path_idle = reverselist(path_idle)

	proc/path_attack(var/atom/trg)
		path_target = AStar(src.loc, trg.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, anicard, null)
		path_target = reverselist(path_target)

	proc/death()
		if(!alive) return
		src.alive = 0
		density = 0
		icon_state = "[initial(icon_state)]_d"
		set_null()
		for(var/mob/O in hearers(src, null))
			O.show_message("\red <B>[src] curls up into a ball!</B>", 1)

	proc/healthcheck()
		if (src.health <= 0)
			src.death()

/obj/livestock/chick
	name = "Chick"
	desc = "A harmless little baby chicken, it's so cute!"
	icon_state = "chick"
	health = 10
	maxhealth = 10
	strength = 5
	cycle_pause = 15
	patience = 25

/obj/livestock/spesscarp
	name = "Spess Carp"
	desc = "Oh shit, you're really fucked now."
	icon_state = "spesscarp"
	aggressive = 1
	health = 40
	maxhealth = 40
	strength = 15
	cycle_pause = 10
	patience = 50
	view_range = 10

/obj/livestock/spesscarp/elite
	desc = "Oh shit, you're really fucked now. It has an evil gleam in it's eye."
	health = 50
	maxhealth = 50
	view_range = 14
	intelligence = "Assistant"