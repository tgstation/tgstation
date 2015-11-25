/obj/structure/grille
	name = "grille"
	desc = "A matrice of metal rods, usually used as a support for window bays, with screws to secure it to the floor."
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = 1
	anchored = 1
	flags = FPRINT
	siemens_coefficient = 1
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = 2.9
	explosion_resistance = 5
	var/health = 20 //Relatively "strong" since it's hard to dismantle via brute force
	var/broken = 0

/obj/structure/grille/examine(mob/user)

	..()
	if(!anchored)
		to_chat(user, "Its screws are loose.")
	if(broken) //We're not going to bother with the damage
		to_chat(user, "It has been completely smashed apart, only a few rods are still holding together")

/obj/structure/grille/cultify()
	new /obj/structure/grille/cult(get_turf(src))
	returnToPool(src)
	..()

/obj/structure/grille/proc/healthcheck(var/hitsound = 0) //Note : Doubles as the destruction proc()
	if(hitsound)
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	if(health <= (0.25*initial(health)) && !broken) //Modular, 1/4th of original health. Do make sure the grille isn't broken !
		broken = 1
		icon_state = "[initial(icon_state)]-b"
		density = 0 //Not blocking anything anymore
		getFromPool(/obj/item/stack/rods, get_turf(src)) //One rod set
	if(health <= 0) //Dead
		getFromPool(/obj/item/stack/rods, get_turf(src)) //Drop the second set of rods
		returnToPool(src)

/obj/structure/grille/ex_act(severity)
	switch(severity)
		if(1)
			health -= rand(30, 50)
		if(2)
			health -= rand(15, 30)
		if(3)
			health -= rand(5, 15)
	healthcheck(hitsound = 1)
	return

/obj/structure/grille/blob_act()
	health -= rand(initial(health)*0.8, initial(health)*3) //Grille will always be blasted, but chances of leaving things over
	healthcheck(hitsound = 1)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user))
		shock(user, 60) //Give the user the benifit of the doubt

/obj/structure/grille/attack_paw(mob/user as mob)
	attack_hand(user)

/obj/structure/grille/attack_hand(mob/user as mob)
	var/humanverb = pick(list("kick", "slam", "elbow")) //Only verbs with a third person "s", thank you
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] [humanverb]s \the [src].</span>", \
	"<span class='warning'>You [humanverb] \the [src].</span>", \
	"<span class='warning'>You hear twisting metal.</span>")
	if(M_HULK in user.mutations)
		health -= 5 //Fair hit
	else
		health -= 3 //Do decent damage, still not as good as using a real tool
	healthcheck(hitsound = 1)
	shock(user, 100) //If there's power running in the grille, allow the attack but grill the user

/obj/structure/grille/attack_alien(mob/user as mob)
	if(istype(user, /mob/living/carbon/alien/larva))
		return
	var/alienverb = pick(list("slam", "rip", "claw")) //See above
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] [alienverb]s \the [src].</span>", \
						 "<span class='warning'>You [alienverb] \the [src].</span>", \
						 "You hear twisting metal.")
	health -= 5
	healthcheck(hitsound = 1)
	shock(user, 75) //Ditto above

/obj/structure/grille/attack_slime(mob/user as mob)
	if(!istype(user, /mob/living/carbon/slime/adult))
		return
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] smashes against \the [src].</span>", \
						 "<span class='warning'>You smash against \the [src].</span>", \
						 "You hear twisting metal.")
	health -= 3
	healthcheck(hitsound = 1)
	shock(user, 100)
	return

/obj/structure/grille/attack_animal(var/mob/living/simple_animal/M as mob)
	M.delayNextAttack(8)
	if(M.melee_damage_upper == 0)
		return
	M.visible_message("<span class='warning'>[M] smashes against \the [src].</span>", \
					  "<span class='warning'>You smash against \the [src].</span>", \
					  "You hear twisting metal.")
	health -= rand(M.melee_damage_lower, M.melee_damage_upper)
	healthcheck(hitsound = 1)
	shock(M, 100)
	return


/obj/structure/grille/CanPass(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || (height == 0))
		return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			return prob(66) //Fairly hit chance
		else
			return !density

/obj/structure/grille/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	health -= Proj.damage //Just use the projectile damage, it already has high odds of "missing"
	healthcheck(hitsound = 1)
	return 0

/obj/structure/grille/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if(iswirecutter(W))
		if(!shock(user, 100)) //Prevent user from doing it if he gets shocked
			playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
			getFromPool(/obj/item/stack/rods, get_turf(src), broken ? 1 : 2) //Drop the rods, taking account on whenever the grille is broken or not !
			returnToPool(src)
			return
		return //Return in case the user starts cutting and gets shocked, so that it doesn't continue downwards !
	else if((isscrewdriver(W)) && (istype(loc, /turf/simulated) || anchored))
		if(!shock(user, 90))
			playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
			anchored = !anchored
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] the grille [anchored ? "to" : "from"] the floor.</span>", \
			"<span class='notice'>You [anchored ? "fasten" : "unfasten"] the grille [anchored ? "to" : "from"] the floor.</span>")
			return

//Window placement
	else if(istype(W, /obj/item/stack/sheet/glass))
		var/dir_to_set
		if(loc == user.loc)
			dir_to_set = user.dir //Whatever the user is doing, return the "normal" window placement output
		else
			if((x == user.x) || (y == user.y)) //Only supposed to work for cardinal directions, aka can't lay windows in diagonal directions
				if(x == user.x) //User is on the same vertical plane
					if(y > user.y)
						dir_to_set = 2 //User is laying from the bottom
					else
						dir_to_set = 1 //User is laying from the top
				else if(y == user.y) //User is on the same horizontal plane
					if (x > user.x)
						dir_to_set = 8 //User is laying from the left
					else
						dir_to_set = 4 //User is laying from the right
			else
				to_chat(user, "<span class='warning'>You can't reach far enough.</span>")
				return
		for(var/obj/structure/window/P in loc)
			if(P.dir == dir_to_set)
				to_chat(user, "<span class='warning'>There's already a window here.</span>")//You idiot

				return
		user.visible_message("<span class='notice'>[user] starts placing a window on \the [src].</span>", \
		"<span class='notice'>You start placing a window on \the [src].</span>")
		if(do_after(user, src, 20))
			for(var/obj/structure/window/P in loc)
				if(P.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
					to_chat(user, "<span class='warning'>There's already a window here.</span>")
					return
			var/obj/item/stack/sheet/glass/glass/G = W //This fucking stacks code holy shit
			var/obj/structure/window/WD = new G.created_window(loc, 0)
			WD.dir = dir_to_set
			WD.ini_dir = dir_to_set
			WD.anchored = 0
			WD.d_state = 0
			var/obj/item/stack/ST = W //HOLY FUCKING SHIT !
			ST.use(1)
			user.visible_message("<span class='notice'>[user] places \a [WD] on \the [src].</span>", \
			"<span class='notice'>You place \a [WD] on \the [src].</span>")
		return

	switch(W.damtype)
		if("fire")
			health -= W.force //Fire-based tools like welding tools are ideal to work through small metal rods !
		if("brute")
			health -= W.force * 0.5 //Rod matrices have an innate resistance to brute damage
	shock(user, 100 * W.siemens_coefficient) //Chance of getting shocked is proportional to conductivity
	healthcheck(hitsound = 1)
	..()
	return

//Shock user with probability prb (if all connections & power are working)
//Returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user as mob, prb)
	if(!anchored || broken)	//De-anchored and destroyed grilles are never connected to the powernet !
		return 0
	if(!prob(prb)) //If the probability roll failed, don't go further
		return 0
	if(!in_range(src, user)) //To prevent TK and mech users from getting shocked
		return 0
	//Process the shocking via powernet, our job is done here
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			return 1
		else
			return 0
	return 0

/obj/structure/grille/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 1500)
		health -= 1
		healthcheck() //Note : This healthcheck is silent, and it's going to stay that way
	..()

//Mapping entities and alternatives !

/obj/structure/grille/broken //THIS IS ONLY TO BE USED FOR MAPPING, THANK YOU FOR YOUR UNDERSTANDING

	//We need to set all variables for broken grilles manually, notably to have those show up nicely in mapmaker
	broken = 1
	icon_state = "grille-b"
	density = 0 //Not blocking anything anymore
	New()
		health -= rand(initial(health)*0.8, initial(health)*0.9) //Largely under broken threshold, this is used to adjust the health, NOT to break it
		healthcheck() //Send this to healthcheck just in case we want to do something else with it

/obj/structure/grille/cult //Used to get rid of those ugly fucking walls everywhere while still blocking air

	name = "cult grille"
	desc = "A matrice built out of an unknown material, with some sort of force field blocking air around it"
	icon_state = "grillecult"
	health = 40 //Make it strong enough to avoid people breaking in too easily

/obj/structure/grille/cult/CanPass(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || !broken)
		return 0 //Make sure air doesn't drain
	..()
