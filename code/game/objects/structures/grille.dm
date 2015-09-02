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
	var/health = 10
	var/destroyed = 0
	var/obj/item/stack/rods/stored

/obj/structure/grille/New()
	stored = new/obj/item/stack/rods(src)
	stored.amount = 2

/obj/structure/grille/ex_act(severity, target)
	qdel(src)

/obj/structure/grille/blob_act()
	qdel(src)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user)) shock(user, 70)


/obj/structure/grille/attack_paw(mob/user)
	attack_hand(user)

/obj/structure/grille/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	shock(user, 70)
	health -= 5
	healthcheck()

/obj/structure/grille/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] hits [src].</span>", \
						 "<span class='danger'>You hit [src].</span>", \
						 "<span class='italics'>You hear twisting metal.</span>")

	if(shock(user, 70))
		return
	else
		health -= rand(1,2)
	healthcheck()

/obj/structure/grille/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	if(istype(user, /mob/living/carbon/alien/larva))	return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>", \
						 "<span class='danger'>You mangle [src].</span>", \
						 "<span class='italics'>You hear twisting metal.</span>")

	if(!shock(user, 70))
		health -= 5
		healthcheck()
		return

/obj/structure/grille/attack_slime(mob/living/simple_animal/slime/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(!user.is_adult)	return

	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] smashes against [src].</span>", \
						 "<span class='danger'>You smash against [src].</span>", \
						 "<span class='italics'>You hear twisting metal.</span>")

	health -= rand(1,2)
	healthcheck()
	return

/obj/structure/grille/attack_animal(var/mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	if(M.melee_damage_upper == 0 || (M.melee_damage_type != BRUTE && M.melee_damage_type != BURN))
		return
	M.do_attack_animation(src)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	M.visible_message("<span class='warning'>[M] smashes against [src].</span>", \
					  "<span class='danger'>You smash against [src].</span>", \
					  "<span class='italics'>You hear twisting metal.</span>")

	health -= M.melee_damage_upper
	healthcheck()
	return


/obj/structure/grille/mech_melee_attack(obj/mecha/M)
	if(..())
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
		health -= M.force * 0.5
		healthcheck()


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
	if(!loc) //if already qdel'd somehow, we do nothing
		return
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

/obj/structure/grille/attackby(obj/item/weapon/W, mob/user, params)
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
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] [src].</span>", \
								 "<span class='notice'>You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor.</span>")
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
	else if(istype(W, /obj/item/weapon/rcd) && istype(loc, /turf/simulated)) //Do not attack the grille if the user is holding an RCD
		return

//window placing begin
	else if(istype(W, /obj/item/stack/sheet/rglass) || istype(W, /obj/item/stack/sheet/glass))
		if (!destroyed)
			var/obj/item/stack/ST = W
			if (ST.get_amount() < 2)
				user << "<span class='warning'>You need at least two sheets of glass for that!</span>"
				return
			var/dir_to_set = SOUTHWEST
			if(!anchored)
				user << "<span class='warning'>[src] needs to be fastened to the floor first!</span>"
				return
			for(var/obj/structure/window/WINDOW in loc)
				user << "<span class='warning'>There is already a window there!</span>"
				return
			user << "<span class='notice'>You start placing the window...</span>"
			if(do_after(user,20, target = src))
				if(!src.loc || !anchored) //Grille destroyed or unanchored while waiting
					return
				for(var/obj/structure/window/WINDOW in loc) //Another window already installed on grille
					return
				var/obj/structure/window/WD
				if(istype(W, /obj/item/stack/sheet/rglass))
					WD = new/obj/structure/window/reinforced/fulltile(loc) //reinforced window
				else
					WD = new/obj/structure/window/fulltile(loc) //normal window
				WD.dir = dir_to_set
				WD.ini_dir = dir_to_set
				WD.anchored = 0
				WD.state = 0
				ST.use(2)
				user << "<span class='notice'>You place [WD] on [src].</span>"
			return
//window placing end

	else if(istype(W, /obj/item/weapon/shard))
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
		health -= W.force * 0.1
	else if(!shock(user, 70))
		switch(W.damtype)
			if(STAMINA)
				return
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

/obj/structure/grille/proc/shock(mob/user, prb)
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
	var/tforce = 0
	if(ismob(AM))
		tforce = 5
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = max(0, I.throwforce * 0.5)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	health = max(0, health - tforce)
	healthcheck()

/obj/structure/grille/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	return 0
