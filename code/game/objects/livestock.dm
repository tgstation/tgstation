//Blatently copy/pasted from facehugger code + a few changes.

/obj/livestock
	name = "animal thing"
	desc = "This doesn't seem so bad..."
	icon = 'livestock.dmi'
	layer = 5.0
	density = 1
	anchored = 0
	unacidable = 1//While not technically mobs, these objects should not be affected by alien acid.

	var/state = 0		//0 = null, 1 = attack, 2 = idle

	var/list/path = new/list()

	var/frustration = 0						//How long it's gone without reaching it's target.
	var/patience = 35						//The maximum time it'll chase a target.
	var/mob/living/carbon/target			//Its combat target.
	var/list/mob/living/carbon/flee_from = new/list()
	var/list/path_target = new/list()		//The path to the combat target.

	var/turf/trg_idle					//It's idle target, the one it's following but not attacking.
	var/list/path_idle = new/list()		//The path to the idle target.

	var/alive = 1 //1 alive, 0 dead
	var/maxhealth = 25
	var/health = 25
	var/aggressive = 0
	var/cowardly = 0 //PLEASE do not mix with agressive, I have no idea what its behaviour will be then
	flags = 258.0
	var/strength = 10 //The damage done by the creature if it attacks something.
	var/cycle_pause = 5
	var/view_range = 7				//How far it can see.
	var/obj/item/weapon/card/id/anicard		//By default, animals can open doors but not any with access restrictions.
	var/intelligence = null					// the intelligence var allows for additional access (by job).

	var/species = "animal" //affects icon_state

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

	proc/gib()			//Will move this to a generic livestock proc once I get some gib animations for the others -- Darem.
		var/atom/movable/overlay/animation = null
		src.icon = null
		src.invisibility = 101
		animation = new(src.loc)
		animation.icon = 'livestock.dmi'
		animation.icon_state = "blank"
		animation.master = src
		if(istype(src, /obj/livestock/spesscarp)) flick("spesscarp_g", animation)
		sleep(11)
		src.death(1)
		del(animation)
		return


	attack_hand(user as mob)
		return

	attack_alien(var/mob/living/carbon/alien/user as mob) //So aliums can attack and potentially eat space carp.
		if(src.alive)
			if (user.a_intent == "help")
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\blue [user] caresses [src.name] with its scythe like arm."), 1)
			else
				src.health -= rand(15,30)
				if(src.aggressive)
					src.target = user
					src.state = 1
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has slashed [src.name]!</B>", user), 1)
				playsound(src.loc, 'slice.ogg', 25, 1, -1)
				if(prob(10)) new /obj/decal/cleanable/blood(src.loc)
				if (src.health <= 0)
					src.death()
		else
			if (user.a_intent == "grab")
				for(var/mob/N in viewers(user, null))
					if(N.client)
						N.show_message(text("\red <B>[user] is attempting to devour the carp!</B>"), 1)
				if(!do_after(user, 50))	return
				for(var/mob/N in viewers(user, null))
					if(N.client)
						N.show_message(text("\red <B>[user] hungrily devours the carp!</B>"), 1)
				user.health += rand(10,25)
				del(src)
			else
				user << "\green The creature is already dead."
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(src.alive)
			switch(W.damtype)
				if("fire")
					src.health -= W.force * 0.75
				if("brute")
					src.health -= W.force * 0.5
				else
			if (src.health <= 0)
				src.death()
			else if (W.force)
				if(src.aggressive && (ishuman(user) || ismonkey(user) || isrobot(user)))
					src.target = user
					src.state = 1
				if(prob(10)) new /obj/decal/cleanable/blood(src.loc)
		else if(istype(W, /obj/item/weapon/kitchenknife))
			user << "\red You slice open the [src.name]!"
			for (var/obj/item/I in src)
				I.loc = src.loc
			del(src)
			return
		..()

	bullet_act(flag, A as obj)
		switch(flag)
			if(PROJECTILE_BULLET)
				src.health -= 15
			if(PROJECTILE_TASER)
				src.health -= 5
			if(PROJECTILE_DART)
				src.health -= 10
			if(PROJECTILE_WEAKBULLET)
				src.health -= 8
			if(PROJECTILE_LASER)
				src.health -= 10
			if(PROJECTILE_PULSE)
				src.health -= 25
				if(prob(30))
					src.gib()
			if(PROJECTILE_BOLT)
				src.health -= 5
		if(prob(10)) new /obj/decal/cleanable/blood(src.loc)
		healthcheck()

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.death(1)
			if(2.0)
				src.health -= 15
				healthcheck()
		return

	meteorhit()
		src.gib()
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

	proc/special_extra()	//Placeholder for animal specific effects such as cow milk or spess carp breathing.

	proc/special_attack()	//Placeholder for extra effects from the attack such as the carp's stun.

	proc/special_target()	//Placeholder for extra targeting protocol

	proc/random_movement()						//Unlike pick(cardinal), it has a bias towards continuing on in it's
		var/temp_move = null					//	original direction.
		switch(roll(1,20))  //50% => Foreward, 20% turn left, 20% turn right, 10% don't move.
			if(1 to 10)
				temp_move = src.dir
			if(11 to 14)
				temp_move = turn(src.dir, -90)
			if(15 to 18)
				temp_move = turn(src.dir, 90)
		if(!isnull(temp_move))
			step(src,temp_move)

	proc/process()				//Master AI proc.
		set background = 1
		if (!alive)				//If it isn't alive, it shouldn't be doing anything.
			return
		if (cowardly) //cowardly = 1 stuff
			var/view = view_range-2							//Actual sight slightly lower then it's total sight.
			for (var/mob/living/carbon/C in range(view,src.loc)) //checking for threats
				if (((get_dir(src,C) & dir) || (C.m_intent=="run" && C.moved_recently)) && !(C in flee_from)) //if it can see or hear anyone nearby, start fleeing
					flee_from += C
			if (flee_from.len) //ohgodrun
				var/viable_dirs = 0
				for(var/mob/living/carbon/C in flee_from)
					if(!(C in view(src,view_range))) //first, see if someone who it has been fleeing from is still there. if not, delete that guy from the list
						flee_from -= C
					else
						viable_dirs |= get_dir(src,C)
				viable_dirs = 15 - viable_dirs //so it runs AWAY from those directions, not TOWARDS them
				if(viable_dirs) //if there is somewhere to run, DO IT DAMNIT
					var/list/turfs_to_move_to = new/list()
					for(var/turf/T in orange(src,1))
						if(((get_dir(src,T) & viable_dirs) == get_dir(src,T)) && !T.density)
							turfs_to_move_to += T
					src.Move(pick(turfs_to_move_to))
		if (aggressive) //aggressive = 1 stuff
			if (!target)
				if (path_target.len) path_target = new/list()	//No target but there's still path data? reset it.
				var/last_health = INFINITY						//Set as high as possible as an initial value.
				var/view = view_range-2							//Actual sight slightly lower then it's total sight.
				for (var/mob/living/carbon/C in range(view,src.loc))	//Checks all carbon creatures in range.
					if (!aggressive)									//Is this animal angry? If not, what the fuck are you doing?
						break
					if (C.stat == 2 || !can_see(src,C,view_range) || (!can_see(src,C,(view_range / 2)) && C.invisibility >= 1))
						continue
					if(C:stunned || C:paralysis || C:weakened)
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
							O.show_message("\red <B>[src.target] has been attacked by [src.name]!</B>", 1, "\red You hear someone fall.", 2)
						target.take_organ_damage(strength)
						special_attack()
						src.loc = target.loc
						set_null()
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
		special_extra()
		if(target || flee_from.len)
			spawn(cycle_pause / 3)
				src.process()
		else
			spawn(cycle_pause)
				src.process()

	proc/idle()					//Idle proc for when it isn't in combat mode. Called by itself and process()
		set background = 1
		if(state != 2 || !alive || target) return  //If you arne't idling, aren't alive, or have a target, you shouldn't be here.
		if(prob(5) && health < maxhealth)			//5% chance of healing every cycle.
			health++
		special_extra()
		if(isnull(trg_idle))						//No one to follow? Find one.
			for(var/mob/living/O in viewers(world.view,src))
				if(O.mutations == (0 || CLOWN))		//Hates mutants and fatties.
					trg_idle = O
					break
		if(isnull(trg_idle))						//Still no one to follow? Step in a random direction.
			random_movement()
		else if(!path_idle.len)						//Has a target but no path?
			if(can_see(src,trg_idle,view_range))	//Can see it? Then move towards it.
				step_towards(src,get_step_towards2(src , trg_idle))
			else
				path_idle(trg_idle)		//Can't see it? Find a path.
				if(!path_idle.len)		//Still no path? Stop trying to follow it.
					trg_idle = null
				random_movement()
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

	proc/death(var/messy = 0)
		if(!alive) return
		alive = 0
		density = 0
		icon_state = "[species]_d"
		set_null()
		if(!messy)
			for(var/mob/O in hearers(src, null))
				O.show_message("\red <B>[src]'s eyes glass over!</B>", 1)
		else
			for (var/obj/item/I in src)
				if(!istype(I, /obj/item/weapon/card)) I.loc = src.loc
			del(src)

	proc/healthcheck()
		if (src.health <= 0)
			src.death()


//////////////////////////////////////////////////////////////////////////////
/////////////////////////Specific Creature Entries////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/*/obj/livestock/chick
	name = "Chick"
	desc = "A harmless little baby chicken, it's so cute!"
	icon_state = "chick"
	health = 10
	maxhealth = 10
	strength = 5
	cycle_pause = 15
	patience = 25
	var/obj/item/weapon/reagent_containers/food/snacks/egg_holder
	special_extra()
		if(prob(5))
			for(var/mob/O in hearers(src, null))
				O << "\green Chick: Cluck."
			src.egg_holder = new /obj/item/weapon/reagent_containers/food/snacks/egg(src)
			src.egg_holder.loc = src.loc
			src.egg_holder = null
		for(var/mob/living/carbon/human/V in viewers(world.view,src))
			if(V.mind.special_role == "wizard")
				for(var/mob/H in hearers(src, null))
					H << "\green Chick clucks in an angry manner at [V.name]."
*/

/obj/livestock/spesscarp
	name = "Spess Carp"
	desc = "Oh shit, you're really fucked now."
	icon_state = "spesscarp"
	species = "spesscarp"
	aggressive = 1
	health = 25
	maxhealth = 25
	strength = 10
	cycle_pause = 10
	patience = 25
	view_range = 8
	var/stun_chance = 5					// determines the prob of a stun
	New()
		..()
		new /obj/item/weapon/reagent_containers/food/snacks/carpmeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/carpmeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/carpmeat(src)
	special_attack()
		if (prob(stun_chance))
			target:stunned = max(target:stunned, (strength / 2))

/obj/livestock/spesscarp/elite
	desc = "Oh shit, you're really fucked now. It has an evil gleam in it's eye."
	health = 50
	maxhealth = 50
	view_range = 14
	stun_chance = 40
	intelligence = "Assistant"

/obj/livestock/killertomato
	name = "Killer Tomato"
	desc = "Oh shit, you're really fucked now."
	icon_state = "killertomato"
	species = "killertomato"
	aggressive = 1
	health = 75
	maxhealth = 75
	strength = 19
	cycle_pause = 10
	patience = 10
	view_range = 14
	intelligence = "Captain"
	var/stun_chance = 10					// determines the prob of a stun
	New()
		..()
		new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
	special_attack()
		if (prob(stun_chance))
			target:stunned = max(target:stunned, (strength / 1))

/obj/livestock/walkingmushroom
	name = "Walking Mushroom"
	desc = "A...huge...mushroom...with legs!?"
	icon_state = "walkingmushroom"
	species = "walkingmushroom"
	cowardly = 1
	health = 50
	maxhealth = 50
	strength = 0
	cycle_pause = 10
	patience = 25
	view_range = 8
	intelligence = "Captain"
	var/stun_chance = 0
	New()
		..()
		new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src)
		new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src)
		new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src)

/obj/livestock/lizard
	name = "Lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	species = "lizard"
	cowardly = 1
	health = 10
	maxhealth = 10
	strength = 2
	cycle_pause = 10
	patience = 50
	view_range = 7

/obj/livestock/roach
	name = "Roach"
	desc = "A cute large roach."
	icon_state = "roach"
	species = "roach"
	aggressive = 1
	health = 15
	maxhealth = 15
	strength = 2
	cycle_pause = 10
	patience = 50
	view_range = 7

/obj/livestock/bear
	name = "ninja space bear"
	desc = "Its sight is unbearable to your eye."
	icon_state = "bear"
	species = "bear"
	aggressive = 1
	health = 100
	maxhealth = 100
	cycle_pause = 15
	patience = 75
	strength = 30
	intelligence = "Captain"

	var/adaptationChance = 10 //the chance per tick the bear will change its camouflage
	var/camouflage = "space" //"", "space" or "floor"

	New()
		..()
		//new /obj/item/clothing/suit/bearpelt(src)
		new /obj/item/weapon/reagent_containers/food/snacks/bearmeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/bearmeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/bearmeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/bearmeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/bearmeat(src)
		//new /obj/item/weapon/reagent_containers/food/snacks/bearinnards(src)

	special_extra() //camouflage check
		if(prob(adaptationChance))
			if(istype(loc,/turf/simulated/floor))
				if(camouflage != "floor")
					camouflage = "floor"
			else if(istype(loc,/turf/space))
				if(camouflage != "space")
					camouflage = "space"
			else if(camouflage != "")
				camouflage = ""
		update_icon()

	update_icon()
		icon_state = "[species][camouflage][alive?"":"_d"]"

/* 		Commented out because of Filthy Xeno-lovers.
/obj/livestock/cow
	name = "Pigmy Cow"
	desc = "That's not my cow!"
	icon_state = "cow"
	health = 100
	maxhealth = 100
	strength = 20
	cycle_pause = 20
	patience = 50
	view_range = 10
	New()
		..()
		new /obj/item/weapon/reagent_containers/food/snacks/monkeymeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeymeat(src)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeymeat(src)
	special_extra()
		if(prob(20))
			for(var/mob/O in hearers(src, null))
				O << "\green Cow: Moo."
			src.reagents.add_reagent("milk", 1)
		if(src.reagents.get_reagent_amount("milk") >= 100)
			gib()

	examine()
		..()
		switch(src.reagents.get_reagent_amount("milk"))
			if(0 to 10)
				usr << text("\red The cow looks content.")
			if(11 to 80)
				usr << text("\red The cow looks uncomfortable.")
			if(81 to INFINITY)
				usr << text("\red The cow looks as if it could burst at any minute!")
			*/