//Bomb
/mob/living/simple_animal/hostile/guardian/bomb
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 0.6, CLONE = 0.6, STAMINA = 0, OXY = 0.6)
	range = 13
	playstyle_string = "<span class='holoparasite'>As an <b>explosive</b> type, you have moderate close combat abilities, may explosively teleport targets on attack, and are capable of converting nearby items and objects into disguised bombs via alt click.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Scientist, master of explosive death.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Explosive modules active. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! Caught one! It's an explosive carp! Boom goes the fishy.</span>"
	var/bomb_cooldown = 0

/mob/living/simple_animal/hostile/guardian/bomb/Stat()
	..()
	if(statpanel("Status"))
		if(bomb_cooldown >= world.time)
			stat(null, "Bomb Cooldown Remaining: [max(round((bomb_cooldown - world.time)*0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/bomb/AttackingTarget()
	if(..())
		if(prob(40))
			if(isliving(target))
				var/mob/living/M = target
				if(!M.anchored && M != summoner && !hasmatchingsummoner(M))
					new /obj/effect/overlay/temp/guardian/phase/out(get_turf(M))
					do_teleport(M, M, 10)
					for(var/mob/living/L in range(1, M))
						if(hasmatchingsummoner(L)) //if the summoner matches don't hurt them
							continue
						if(L != src && L != summoner)
							L.apply_damage(15, BRUTE)
					new /obj/effect/overlay/temp/explosion(get_turf(M))

/mob/living/simple_animal/hostile/guardian/bomb/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(src.loc == summoner)
		src << "<span class='danger'><B>You must be manifested to create bombs!</span></B>"
		return
	if(isobj(A))
		if(bomb_cooldown <= world.time && !stat)
			var/obj/guardian_bomb/B = new /obj/guardian_bomb(get_turf(A))
			src << "<span class='danger'><B>Success! Bomb armed!</span></B>"
			bomb_cooldown = world.time + 200
			B.spawner = src
			B.disguise(A)
		else
			src << "<span class='danger'><B>Your powers are on cooldown! You must wait 20 seconds between bombs.</span></B>"

/obj/guardian_bomb
	name = "bomb"
	desc = "You shouldn't be seeing this!"
	var/obj/stored_obj
	var/mob/living/simple_animal/hostile/guardian/spawner


/obj/guardian_bomb/proc/disguise(obj/A)
	A.loc = src
	stored_obj = A
	opacity = A.opacity
	anchored = A.anchored
	density = A.density
	appearance = A.appearance
	addtimer(CALLBACK(src, .proc/disable), 600)

/obj/guardian_bomb/proc/disable()
	stored_obj.forceMove(get_turf(src))
	spawner << "<span class='danger'><B>Failure! Your trap didn't catch anyone this time.</span></B>"
	qdel(src)

/obj/guardian_bomb/proc/detonate(mob/living/user)
	if(isliving(user))
		if(user != spawner && user != spawner.summoner && !spawner.hasmatchingsummoner(user))
			user << "<span class='danger'><B>The [src] was boobytrapped!</span></B>"
			spawner << "<span class='danger'><B>Success! Your trap caught [user]</span></B>"
			var/turf/T = get_turf(src)
			stored_obj.forceMove(T)
			playsound(T,'sound/effects/Explosion2.ogg', 200, 1)
			new /obj/effect/overlay/temp/explosion(T)
			user.ex_act(2)
			qdel(src)
		else
			user << "<span class='holoparasite'>[src] glows with a strange <font color=\"[spawner.namedatum.colour]\">light</font>, and you don't touch it.</span>"

/obj/guardian_bomb/Bump(atom/A)
	detonate(A)
	..()

/obj/guardian_bomb/attackby(mob/living/user)
	detonate(user)

/obj/guardian_bomb/attack_hand(mob/living/user)
	detonate(user)

/obj/guardian_bomb/examine(mob/user)
	stored_obj.examine(user)
	if(get_dist(user,src)<=2)
		user << "<span class='holoparasite'>It glows with a strange <font color=\"[spawner.namedatum.colour]\">light</font>!</span>"
