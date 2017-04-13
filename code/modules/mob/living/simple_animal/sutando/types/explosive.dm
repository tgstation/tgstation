//killed queem u bad cat

/datum/sutando_abilities/bomb
	id = "bomb"
	name = "Remote Explosives"
	var/bomb_cooldown = 0
	value = 6

/datum/sutando_abilities/bomb/handle_stats()
	. = ..()
	stand.melee_damage_lower += 7
	stand.melee_damage_upper += 7
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.2
	stand.range += 6

/datum/sutando_abilities/bomb/ability_act()
	if(prob(40))
		if(isliving(stand.target))
			var/mob/living/M = stand.target
			if(!M.anchored && M != user && !stand.hasmatchingsummoner(M))
				new /obj/effect/overlay/temp/sutando/phase/out(get_turf(M))
				do_teleport(M, M, 10)
				for(var/mob/living/L in range(1, M))
					if(stand.hasmatchingsummoner(L)) //if the user matches don't hurt them
						continue
					if(L != stand && L != user)
						L.apply_damage(15, BRUTE)
						stand.say("[battlecry]!!")
				new /obj/effect/overlay/temp/explosion(get_turf(M))


/datum/sutando_abilities/bomb/alt_ability_act(atom/movable/A)
	if(!istype(A))
		return
	if(stand.loc == user)
		to_chat(stand,"<span class='danger'><B>You must be manifested to create bombs!</span></B>")
		return
	if(isobj(A))
		if(bomb_cooldown <= world.time && !stand.stat)
			var/obj/sutando_bomb/B = new/obj/sutando_bomb(get_turf(A))
			to_chat(stand,"<span class='danger'><B>Success! Bomb armed!</span></B>")
			stand.say("[battlecry]!!")
			bomb_cooldown = world.time + 200
			B.spawner = stand
			B.disguise(A)
		else
			to_chat(stand,"<span class='danger'><B>Your powers are on cooldown! You must wait 20 seconds between bombs.</span></B>")

/obj/sutando_bomb
	name = "bomb"
	desc = "You shouldn't be seeing this!"
	var/obj/stored_obj
	var/mob/living/simple_animal/hostile/sutando/spawner


/obj/sutando_bomb/proc/disguise(obj/A)
	A.loc = src
	stored_obj = A
	opacity = A.opacity
	anchored = A.anchored
	density = A.density
	appearance = A.appearance
	addtimer(CALLBACK(src, .proc/disable), 600)

/obj/sutando_bomb/proc/disable()
	stored_obj.forceMove(get_turf(src))
	spawner << "<span class='danger'><B>Failure! Your trap didn't catch anyone this time.</span></B>"
	qdel(src)

/obj/sutando_bomb/proc/detonate(mob/living/user)
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

/obj/sutando_bomb/Bump(atom/A)
	detonate(A)
	..()

/obj/sutando_bomb/attackby(mob/living/user)
	detonate(user)

/obj/sutando_bomb/attack_hand(mob/living/user)
	detonate(user)

/obj/sutando_bomb/examine(mob/user)
	stored_obj.examine(user)
	if(get_dist(user,src)<=2)
		user << "<span class='holoparasite'>It glows with a strange <font color=\"[spawner.namedatum.colour]\">light</font>!</span>"
