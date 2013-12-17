/* Alien shit!
 * Contains:
 *		structure/alien
 *		Resin
 *		Weeds
 *		Egg
 *		effect/acid
 */


/obj/structure/alien
	icon = 'icons/mob/alien.dmi'

/*
 * Resin
 */
/obj/structure/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "resin"
	density = 1
	opacity = 1
	anchored = 1
	var/health = 200

/obj/structure/alien/resin/New(location)
	..()
	air_update_turf(1)
	return

/obj/structure/alien/resin/Del()
	density = 0
	air_update_turf(1)
	..()
	return

/obj/structure/alien/resin/Move()
	air_update_turf(1)
	..()
	air_update_turf(1)
	return

/obj/structure/alien/resin/CanAtmosPass()
	return !density

/obj/structure/alien/resin/wall
	name = "resin wall"
	desc = "Purple slime solidified into a wall."
	icon_state = "resinwall"	//same as resin, but consistency ho!

/obj/structure/alien/resin/membrane
	name = "resin membrane"
	desc = "Purple slime just thin enough to let light pass through."
	icon_state = "resinmembrane"
	opacity = 0
	health = 120


/obj/structure/alien/resin/proc/healthcheck()
	if(health <=0)
		del(src)


/obj/structure/alien/resin/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()


/obj/structure/alien/resin/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= 150
		if(2.0)
			health -= 100
		if(3.0)
			health -= 50
	healthcheck()


/obj/structure/alien/resin/blob_act()
	health -= 50
	healthcheck()


/obj/structure/alien/resin/hitby(atom/movable/AM)
	..()
	visible_message("<span class='danger'>[src] was hit by [AM].</span>")
	var/tforce = 0
	if(!isobj(AM))
		tforce = 10
	else
		var/obj/O = AM
		tforce = O.throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health -= tforce
	healthcheck()


/obj/structure/alien/resin/attack_hand(mob/user)
	if(HULK in user.mutations)
		user.visible_message("<span class='danger'>[user] destroys [src]!</span>")
		health = 0
		healthcheck()


/obj/structure/alien/resin/attack_paw(mob/user)
	return attack_hand(user)


/obj/structure/alien/resin/attack_alien(mob/user)
	if(islarva(user))
		return
	user.visible_message("<span class='danger'>[user] claws at the resin!</span>")
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health -= 50
	if(health <= 0)
		user.visible_message("<span class='danger'>[user] slices the [name] apart!</span>")
	healthcheck()


/obj/structure/alien/resin/attackby(obj/item/I, mob/user)
	health -= I.force
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	..()


/obj/structure/alien/resin/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density


/*
 * Weeds
 */

#define NODERANGE 3

/obj/structure/alien/weeds
	gender = PLURAL
	name = "weeds"
	desc = "Weird purple weeds."
	icon_state = "weeds"
	anchored = 1
	density = 0
	var/health = 15
	var/obj/structure/alien/weeds/node/linked_node = null


/obj/structure/alien/weeds/New(pos, node)
	..()
	linked_node = node
	if(istype(loc, /turf/space))
		del(src)
		return
	if(icon_state == "weeds")
		icon_state = pick("weeds", "weeds1", "weeds2")

	spawn(rand(150, 200))
		if(src)
			Life()


/obj/structure/alien/weeds/proc/Life()
	set background = 1
	var/turf/U = get_turf(src)

	if(istype(U, /turf/space))
		del(src)
		return

	direction_loop:
		for(var/dirn in cardinal)
			var/turf/T = get_step(src, dirn)

			if (!istype(T) || T.density || locate(/obj/structure/alien/weeds) in T || istype(T, /turf/space))
				continue

			if(!linked_node || get_dist(linked_node, src) > linked_node.node_range)
				return

			for(var/obj/O in T)
				if(O.density)
					continue direction_loop

			new /obj/structure/alien/weeds(T, linked_node)


/obj/structure/alien/weeds/ex_act(severity)
	del(src)


/obj/structure/alien/weeds/attackby(obj/item/I, mob/user)
	if(I.attack_verb.len)
		visible_message("<span class='danger'>[src] has been [pick(I.attack_verb)] with [I] by [user].</span>")
	else
		visible_message("<span class='danger'>[src] has been attacked with [I] by [user].</span>")

	var/damage = I.force / 4.0
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()


/obj/structure/alien/weeds/proc/healthcheck()
	if(health <= 0)
		del(src)


/obj/structure/alien/weeds/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()


//Weed nodes
/obj/structure/alien/weeds/node
	name = "purple sac"
	desc = "Weird purple octopus-like thing."
	icon_state = "weednode"
	luminosity = NODERANGE
	var/node_range = NODERANGE


/obj/structure/alien/weeds/node/New()
	..(loc, src)

#undef NODERANGE


/*
 * Egg
 */

//for the status var
#define BURST 0
#define BURSTING 1
#define GROWING 2
#define GROWN 3
#define MIN_GROWTH_TIME 1800	//time it takes to grow a hugger
#define MAX_GROWTH_TIME 3000

/obj/structure/alien/egg
	name = "egg"
	desc = "A large mottled egg."
	icon_state = "egg_growing"
	density = 0
	anchored = 1
	var/health = 100
	var/status = GROWING	//can be GROWING, GROWN or BURST; all mutually exclusive


/obj/structure/alien/egg/New()
	new /obj/item/clothing/mask/facehugger(src)
	..()
	spawn(rand(MIN_GROWTH_TIME, MAX_GROWTH_TIME))
		Grow()


/obj/structure/alien/egg/attack_paw(mob/user)
	if(isalien(user))
		switch(status)
			if(BURST)
				user << "<span class='notice'>You clear the hatched egg.</span>"
				playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
				del(src)
				return
			if(GROWING)
				user << "<span class='notice'>The child is not developed yet.</span>"
				return
			if(GROWN)
				user << "<span class='notice'>You retrieve the child.</span>"
				Burst(0)
				return
	else
		return attack_hand(user)


/obj/structure/alien/egg/attack_hand(mob/user)
	user << "<span class='notice'>It feels slimy.</span>"


/obj/structure/alien/egg/proc/GetFacehugger()
	return locate(/obj/item/clothing/mask/facehugger) in contents


/obj/structure/alien/egg/proc/Grow()
	icon_state = "egg"
	status = GROWN


/obj/structure/alien/egg/proc/Burst(var/kill = 1)	//drops and kills the hugger if any is remaining
	if(status == GROWN || status == GROWING)
		icon_state = "egg_hatched"
		flick("egg_opening", src)
		status = BURSTING
		spawn(15)
			status = BURST
			var/obj/item/clothing/mask/facehugger/child = GetFacehugger()
			if(child)
				child.loc = get_turf(src)
				if(kill && istype(child))
					child.Die()
				else
					for(var/mob/M in range(1,src))
						if(CanHug(M))
							child.Attach(M)
							break


/obj/structure/alien/egg/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()


/obj/structure/alien/egg/attackby(obj/item/I, mob/user)
	if(I.attack_verb.len)
		visible_message("<span class='danger'>[src] has been [pick(I.attack_verb)] with [I] by [user].</span>")
	else
		visible_message("<span class='danger'>[src] has been attacked with [I] by [user].</span>")

	var/damage = I.force / 4
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()


/obj/structure/alien/egg/proc/healthcheck()
	if(health <= 0)
		if(status != BURST && status != BURSTING)
			Burst()
		else if(status == BURST && prob(50))
			del(src)	//Remove the egg after it has been hit after bursting.


/obj/structure/alien/egg/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		health -= 5
		healthcheck()


/obj/structure/alien/egg/HasProximity(atom/movable/AM)
	if(status == GROWN)
		if(!CanHug(AM))
			return

		var/mob/living/carbon/C = AM
		if(C.stat == CONSCIOUS && C.status_flags & XENO_HOST)
			return

		Burst(0)

#undef BURST
#undef BURSTING
#undef GROWING
#undef GROWN
#undef MIN_GROWTH_TIME
#undef MAX_GROWTH_TIME


/*
 * Acid
 */
/obj/effect/acid
	gender = PLURAL
	name = "acid"
	desc = "Burbling corrossive stuff."
	icon = 'icons/effects/effects.dmi'
	icon_state = "acid"
	density = 0
	opacity = 0
	anchored = 1
	unacidable = 1
	var/atom/target
	var/ticks = 0
	var/target_strength = 0


/obj/effect/acid/New(loc, targ)
	..(loc)
	target = targ

	//handle APCs and newscasters and stuff nicely
	pixel_x = target.pixel_x
	pixel_y = target.pixel_y

	if(isturf(target))	//Turfs take twice as long to take down.
		target_strength = 8
	else
		target_strength = 4
	tick()


/obj/effect/acid/proc/tick()
	if(!target)
		del(src)

	ticks++

	if(ticks >= target_strength)
		target.visible_message("<span class='warning'>[target] collapses under its own weight into a puddle of goop and undigested debris!</span>")

		if(istype(target, /turf/simulated/wall))
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else
			del(target)

		del(src)
		return

	loc = target.loc

	switch(target_strength - ticks)
		if(6)
			visible_message("<span class='warning'>[target] is holding up against the acid!</span>")
		if(4)
			visible_message("<span class='warning'>[target] is being melted by the acid!</span>")
		if(2)
			visible_message("<span class='warning'>[target] is struggling to withstand the acid!</span>")
		if(0 to 1)
			visible_message("<span class='warning'>[target] begins to crumble under the acid!</span>")

	spawn(rand(150, 200))
		if(src)
			tick()
