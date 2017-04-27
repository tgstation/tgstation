//killed queem u bad cat

/datum/guardian_abilities/bomb
	id = "bomb"
	name = "Remote Explosives"
	var/bomb_cooldown = 0
	value = 6

/datum/guardian_abilities/bomb/handle_stats()
	. = ..()
	guardian.melee_damage_lower += 7
	guardian.melee_damage_upper += 7
	for(var/i in guardian.damage_coeff)
		guardian.damage_coeff[i] -= 0.2
	guardian.range += 6

/datum/guardian_abilities/bomb/ability_act()
	if(prob(40))
		if(isliving(guardian.target))
			var/mob/living/M = guardian.target
			if(!M.anchored && M != user && !guardian.hasmatchingsummoner(M))
				new /obj/effect/overlay/temp/guardian/phase/out(get_turf(M))
				do_teleport(M, M, 10)
				for(var/mob/living/L in range(1, M))
					if(guardian.hasmatchingsummoner(L)) //if the user matches don't hurt them
						continue
					if(L != guardian && L != user)
						L.apply_damage(15, BRUTE)
						guardian.say("[battlecry]!!")
				new /obj/effect/overlay/temp/explosion(get_turf(M))


/datum/guardian_abilities/bomb/alt_ability_act(atom/movable/A)
	if(!istype(A))
		return
	if(guardian.loc == user)
		to_chat(guardian,"<span class='danger'><B>You must be manifested to create bombs!</span></B>")
		return
	if(isobj(A))
		if(bomb_cooldown <= world.time && !guardian.stat)
			var/obj/guardian_bomb/B = new/obj/guardian_bomb(get_turf(A))
			to_chat(guardian,"<span class='danger'><B>Success! Bomb armed!</span></B>")
			guardian.say("[battlecry]!!")
			bomb_cooldown = world.time + 200
			B.spawner = guardian
			B.disguise(A)
		else
			to_chat(guardian,"<span class='danger'><B>Your powers are on cooldown! You must wait 20 seconds between bombs.</span></B>")

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
	to_chat(spawner,"<span class='danger'><B>Failure! Your trap didn't catch anyone this time.</span></B>")
	qdel(src)

/obj/guardian_bomb/proc/detonate(mob/living/user)
	if(isliving(user))
		if(user != spawner && user != spawner.summoner && !spawner.hasmatchingsummoner(user))
			to_chat(user,"<span class='danger'><B>The [src] was boobytrapped!</span></B>")
			to_chat(spawner,"<span class='danger'><B>Success! Your trap caught [user]</span></B>")
			var/turf/T = get_turf(src)
			stored_obj.forceMove(T)
			playsound(T,'sound/effects/Explosion2.ogg', 200, 1)
			new /obj/effect/overlay/temp/explosion(T)
			user.ex_act(2)
			qdel(src)
		else
			to_chat(user,"<span class='holoparasite'>[src] glows with a strange <font color=\"[spawner.namedatum.colour]\">light</font>, and you don't touch it.</span>")

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
		to_chat(user,"<span class='holoparasite'>It glows with a strange <font color=\"[spawner.namedatum.colour]\">light</font>!</span>")
