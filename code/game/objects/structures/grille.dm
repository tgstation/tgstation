/obj/structure/grille
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = 1
	anchored = 1
	flags = CONDUCT
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = 2.9
	explosion_resistance = 5
	var/health = 10
	var/destroyed = 0
	var/obj/item/stack/rods/stored

/obj/structure/grille/New()
	stored = new/obj/item/stack/rods(src)
	stored.amount = 2

/obj/structure/grille/ex_act(severity)
	qdel(src)

/obj/structure/grille/blob_act()
	qdel(src)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user)) shock(user, 70)


/obj/structure/grille/attack_paw(mob/user as mob)
	attack_hand(user)

/obj/structure/grille/attack_hand(mob/living/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] hits [src].</span>", \
						 "<span class='warning'>You hit [src].</span>", \
						 "You hear twisting metal.")

	if(shock(user, 70))
		return
	if(HULK in user.mutations)
		health -= 5
	else
		health -= rand(1,2)
	healthcheck()

/obj/structure/grille/attack_alien(mob/living/user as mob)
	user.do_attack_animation(src)
	if(istype(user, /mob/living/carbon/alien/larva))	return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>", \
						 "<span class='warning'>You mangle [src].</span>", \
						 "You hear twisting metal.")

	if(!shock(user, 70))
		health -= 5
		healthcheck()
		return

/obj/structure/grille/attack_slime(mob/living/carbon/slime/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(!user.is_adult)	return

	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] smashes against [src].</span>", \
						 "<span class='warning'>You smash against [src].</span>", \
						 "You hear twisting metal.")

	health -= rand(1,2)
	healthcheck()
	return

/obj/structure/grille/attack_animal(var/mob/living/simple_animal/M as mob)
	M.changeNext_move(CLICK_CD_MELEE)
	if(M.melee_damage_upper == 0)	return
	M.do_attack_animation(src)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	M.visible_message("<span class='warning'>[M] smashes against [src].</span>", \
					  "<span class='warning'>You smash against [src].</span>", \
					  "You hear twisting metal.")

	health -= M.melee_damage_upper
	healthcheck()
	return


/obj/structure/grille/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile) && density)
			return prob(30)
		else
			return !density

/obj/structure/grille/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	..()
	if((Proj.damage_type != STAMINA)) //Grilles can't be exhausted to death
		src.health -= Proj.damage*0.3
		healthcheck()
	return

/obj/structure/grille/Deconstruct()
	transfer_fingerprints_to(stored)
	var/turf/T = loc
	stored.loc = T
	..()

/obj/structure/grille/proc/Break()
	icon_state = "brokengrille"
	density = 0
	destroyed = 1
	stored.amount = 1
	var/obj/item/stack/rods/newrods = new(loc)
	transfer_fingerprints_to(newrods)

/obj/structure/grille/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(istype(W, /obj/item/weapon/wirecutters))
		if(!shock(user, 100))
			playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
			Deconstruct()
	else if((istype(W, /obj/item/weapon/screwdriver)) && (istype(loc, /turf/simulated) || anchored))
		if(!shock(user, 90))
			playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
			anchored = !anchored
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] the [src].</span>", \
								 "<span class='notice'>You have [anchored ? "fastened the [src] to" : "unfastened the [src] from"] the floor.</span>")
			return
	else if(istype(W, /obj/item/stack/rods) && destroyed)
		var/obj/item/stack/rods/R = W
		if(!shock(user, 90))
			user.visible_message("<span class='notice'>[user] rebuilds the broken grille.</span>", \
								 "<span class='notice'>You rebuild the broken grille.</span>")
			health = 10
			density = 1
			destroyed = 0
			icon_state = "grille"
			R.use(1)
			return

//window placing begin
	else if(istype(W, /obj/item/stack/sheet/rglass) || istype(W, /obj/item/stack/sheet/glass))
		if (!destroyed)
			var/obj/item/stack/ST = W
			if (ST.get_amount() < 2)
				user << "<span class='warning'>You need at least two sheets of glass for that.</span>"
				return
			var/dir_to_set = SOUTHWEST
			for(var/obj/structure/window/WINDOW in loc)
				if(WINDOW.dir == dir_to_set)
					user << "<span class='notice'>There is already a window there.</span>"
					return
			user << "<span class='notice'>You start placing the window.</span>"
			if(do_after(user,20))
				if(!src) return //Grille destroyed while waiting
				var/obj/structure/window/WD
				if(istype(W, /obj/item/stack/sheet/rglass))
					WD = new/obj/structure/window(loc,1) //reinforced window
				else
					WD = new/obj/structure/window(loc,0) //normal window
				WD.dir = dir_to_set
				WD.ini_dir = dir_to_set
				WD.anchored = 0
				WD.state = 0
				ST.use(2)
				user << "<span class='notice'>You place the [WD] on [src].</span>"
			return
//window placing end

	else if(istype(W, /obj/item/weapon/shard))
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
		health -= W.force * 0.1
	else if(!shock(user, 70))
		switch(W.damtype)
			if(BURN)
				playsound(loc, 'sound/items/welder.ogg', 80, 1)
			else
				playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
		health -= W.force * 0.3

	healthcheck()
	..()
	return


/obj/structure/grille/proc/healthcheck()
	if(health <= 0)
		if(!destroyed)
			Break()
		else
			if(health <= -6)
				Deconstruct()
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
			s.set_up(3, 1, src)
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

/obj/structure/grille/hitby(AM as mob|obj)
	..()
	visible_message("<span class='danger'>[src] was hit by [AM].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 5
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce - 5
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	health = max(0, health - tforce)
	healthcheck()
