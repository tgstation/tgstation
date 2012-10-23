/obj/structure/grille
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = 1
	anchored = 1
	flags = FPRINT | CONDUCT
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = 2.9
	explosion_resistance = 5
	var/health = 10
	var/destroyed = 0


/obj/structure/grille/ex_act(severity)
	del(src)

/obj/structure/grille/blob_act()
	del(src)

/obj/structure/grille/meteorhit(var/obj/M)
	del(src)


/obj/structure/grille/Bumped(atom/user)
	if(ismob(user)) shock(user, 70)


/obj/structure/grille/attack_paw(mob/user as mob)
	attack_hand(user)

/obj/structure/grille/attack_hand(mob/user as mob)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] kicks [src].</span>", \
						 "<span class='warning'>You kick [src].</span>", \
						 "You hear twisting metal.")

	if(shock(user, 70))
		return
	if((HULK in user.mutations) || (SUPRSTR in user.augmentations))
		health -= 5
	else
		health -= 3
	healthcheck()

/obj/structure/grille/attack_alien(mob/user as mob)
	if(istype(user, /mob/living/carbon/alien/larva))	return

	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>", \
						 "<span class='warning'>You mangle [src].</span>", \
						 "You hear twisting metal.")

	if(!shock(user, 70))
		health -= 5
		healthcheck()
		return

/obj/structure/grille/attack_metroid(mob/user as mob)
	if(!istype(user, /mob/living/carbon/metroid/adult))	return

	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] smashes against [src].</span>", \
						 "<span class='warning'>You smash against [src].</span>", \
						 "You hear twisting metal.")

	health -= rand(2,3)
	healthcheck()
	return

/obj/structure/grille/attack_animal(var/mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)	return

	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	M.visible_message("<span class='warning'>[M] smashes against [src].</span>", \
					  "<span class='warning'>You smash against [src].</span>", \
					  "You hear twisting metal.")

	health -= M.melee_damage_upper
	healthcheck()
	return


/obj/structure/grille/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			return prob(30)
		else
			return !density


/obj/structure/grille/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswirecutter(W))
		if(!shock(user, 100))
			playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
			new /obj/item/stack/rods(loc)
			del(src)
	else if((isscrewdriver(W)) && (istype(loc, /turf/simulated) || anchored))
		if(!shock(user, 90))
			playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
			anchored = !anchored
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] the grille.</span>", \
								 "<span class='notice'>You have [anchored ? "fastened the grille to" : "unfastened the grill from"] the floor.</span>")
			return

//window placing begin
	else if( istype(W,/obj/item/stack/sheet/rglass) || istype(W,/obj/item/stack/sheet/glass) )
		var/dir_to_set = 1
		if(loc == user.loc)
			dir_to_set = user.dir
		else
			if( ( x == user.x ) || (y == user.y) ) //Only supposed to work for cardinal directions.
				if( x == user.x )
					if( y > user.y )
						dir_to_set = 2
					else
						dir_to_set = 1
				else if( y == user.y )
					if( x > user.x )
						dir_to_set = 8
					else
						dir_to_set = 4
			else
				user << "<span class='notice'>You can't reach.</span>"
				return //Only works for cardinal direcitons, diagonals aren't supposed to work like this.
		for(var/obj/structure/window/WINDOW in loc)
			if(WINDOW.dir == dir_to_set)
				user << "<span class='notice'>There is already a window facing this way there.</span>"
				return
		user << "<span class='notice'>You start placing the window.</span>"
		if(do_after(user,20))
			if(!src) return //Grille destroyed while waiting
			for(var/obj/structure/window/WINDOW in loc)
				if(WINDOW.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
					user << "<span class='notice'>There is already a window facing this way there.</span>"
					return
			var/obj/structure/window/WD
			if(istype(W,/obj/item/stack/sheet/rglass))
				WD = new/obj/structure/window(loc,1) //reinforced window
			else
				WD = new/obj/structure/window(loc,0) //normal window
			WD.dir = dir_to_set
			WD.ini_dir = dir_to_set
			WD.anchored = 0
			WD.state = 0
			var/obj/item/stack/ST = W
			ST.use(1)
			user << "<span class='notice'>You place the [WD] on [src].</span>"
		return
//window placing end

	else if(istype(W, /obj/item/weapon/shard))
		health -= W.force * 0.1
	else if(!shock(user, 70))
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
		switch(W.damtype)
			if("fire")
				health -= W.force
			if("brute")
				health -= W.force * 0.1
	healthcheck()
	..()
	return


/obj/structure/grille/proc/healthcheck()
	if(health <= 0)
		if(!destroyed)
			icon_state = "brokengrille"
			density = 0
			destroyed = 1
			new /obj/item/stack/rods(loc)

		else
			if(health <= -6)
				new /obj/item/stack/rods(loc)
				del(src)
				return
	return

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user as mob, prb)
	if(!anchored || destroyed)		// anchored/destroyed grilles are never connected
		return 0
	if(!prob(prb))
		return 0
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return 0
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()
			return 1
		else
			return 0
	return 0

/obj/structure/grille/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!destroyed)
		if(exposed_temperature > T0C + 1500)
			health -= 1
			healthcheck()
	..()