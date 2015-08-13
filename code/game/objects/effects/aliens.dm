/* Alien shit!
 * Contains:
 *		structure/alien
 *		Resin
 *		Weeds
 *		Egg
 *		effect/acid
 */

#define WEED_NORTH_EDGING "north"
#define WEED_SOUTH_EDGING "south"
#define WEED_EAST_EDGING "east"
#define WEED_WEST_EDGING "west"

/obj/structure/alien
	icon = 'icons/mob/alien.dmi'

/*
 * Resin
 */
/obj/structure/alien/resin
	name = "resin"
	desc = "Looks like some kind of thick resin."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	icon_state = "resin"
	density = 1
	opacity = 1
	anchored = 1
	canSmoothWith = list(/obj/structure/alien/resin)
	var/health = 200
	var/resintype = null
	smooth = 1


/obj/structure/alien/resin/New(location)
	..()
	air_update_turf(1)
	return

/obj/structure/alien/resin/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/alien/resin/CanAtmosPass()
	return !density

/obj/structure/alien/resin/wall
	name = "resin wall"
	desc = "Thick resin solidified into a wall."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	icon_state = "wall0"	//same as resin, but consistency ho!
	resintype = "wall"
	canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/obj/structure/alien/resin/wall/BlockSuperconductivity()
	return 1

/obj/structure/alien/resin/wall/shadowling //For chrysalis
	name = "chrysalis wall"
	desc = "Some sort of purple substance in an egglike shape. It pulses and throbs from within and seems impenetrable."
	health = INFINITY

/obj/structure/alien/resin/membrane
	name = "resin membrane"
	desc = "Resin just thin enough to let light pass through."
	icon = 'icons/obj/smooth_structures/alien/resin_membrane.dmi'
	icon_state = "membrane0"
	opacity = 0
	health = 120
	resintype = "membrane"
	canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/obj/structure/alien/resin/proc/healthcheck()
	if(health <=0)
		qdel(src)


/obj/structure/alien/resin/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()


/obj/structure/alien/resin/ex_act(severity, target)
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
	var/tforce = 0
	if(!isobj(AM))
		tforce = 10
	else
		var/obj/O = AM
		tforce = O.throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health -= tforce
	healthcheck()

/obj/structure/alien/resin/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	user.do_attack_animation(src)
	user.visible_message("<span class='danger'>[user] destroys [src]!</span>")
	health = 0
	healthcheck()

/obj/structure/alien/resin/attack_paw(mob/user)
	return attack_hand(user)


/obj/structure/alien/resin/attack_alien(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(islarva(user))
		return
	user.visible_message("<span class='danger'>[user] claws at the resin!</span>")
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health -= 50
	if(health <= 0)
		user.visible_message("<span class='danger'>[user] slices the [name] apart!</span>")
	healthcheck()


/obj/structure/alien/resin/attackby(obj/item/I, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	health -= I.force
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	..()


/obj/structure/alien/resin/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density


/*
 * Weeds
 */

#define NODERANGE 3

/obj/structure/alien/weeds
	gender = PLURAL
	name = "resin floor"
	desc = "A thick resin surface covers the floor."
	icon_state = "weeds"
	anchored = 1
	density = 0
	layer = 2
	var/health = 15
	var/obj/structure/alien/weeds/node/linked_node = null
	var/static/list/weedImageCache


/obj/structure/alien/weeds/New(pos, node)
	..()
	linked_node = node
	if(istype(loc, /turf/space))
		qdel(src)
		return
	if(icon_state == "weeds")
		icon_state = pick("weeds", "weeds1", "weeds2")
	fullUpdateWeedOverlays()
	spawn(rand(150, 200))
		if(src)
			Life()

/obj/structure/alien/weeds/Destroy()
	var/turf/T = loc
	loc = null
	for (var/obj/structure/alien/weeds/W in range(1,T))
		W.updateWeedOverlays()
	linked_node = null
	..()

/obj/structure/alien/weeds/proc/Life()
	set background = BACKGROUND_ENABLED
	var/turf/U = get_turf(src)

	if(istype(U, /turf/space))
		qdel(src)
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


/obj/structure/alien/weeds/ex_act(severity, target)
	qdel(src)


/obj/structure/alien/weeds/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(I.attack_verb.len)
		visible_message("<span class='danger'>[user] has [pick(I.attack_verb)] [src] with [I]!</span>")
	else
		visible_message("<span class='danger'>[user] has attacked [src] with [I]!</span>")

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
		qdel(src)


/obj/structure/alien/weeds/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()


/obj/structure/alien/weeds/proc/updateWeedOverlays()

	overlays.Cut()

	if(!weedImageCache || !weedImageCache.len)
		weedImageCache = list()
		weedImageCache.len = 4
		weedImageCache[WEED_NORTH_EDGING] = image('icons/mob/alien.dmi', "weeds_side_n", layer=2.11, pixel_y = -32)
		weedImageCache[WEED_SOUTH_EDGING] = image('icons/mob/alien.dmi', "weeds_side_s", layer=2.11, pixel_y = 32)
		weedImageCache[WEED_EAST_EDGING] = image('icons/mob/alien.dmi', "weeds_side_e", layer=2.11, pixel_x = -32)
		weedImageCache[WEED_WEST_EDGING] = image('icons/mob/alien.dmi', "weeds_side_w", layer=2.11, pixel_x = 32)

	var/turf/N = get_step(src, NORTH)
	var/turf/S = get_step(src, SOUTH)
	var/turf/E = get_step(src, EAST)
	var/turf/W = get_step(src, WEST)
	if(!locate(/obj/structure/alien) in N.contents)
		if(istype(N, /turf/simulated/floor))
			overlays += weedImageCache[WEED_SOUTH_EDGING]
	if(!locate(/obj/structure/alien) in S.contents)
		if(istype(S, /turf/simulated/floor))
			overlays += weedImageCache[WEED_NORTH_EDGING]
	if(!locate(/obj/structure/alien) in E.contents)
		if(istype(E, /turf/simulated/floor))
			overlays += weedImageCache[WEED_WEST_EDGING]
	if(!locate(/obj/structure/alien) in W.contents)
		if(istype(W, /turf/simulated/floor))
			overlays += weedImageCache[WEED_EAST_EDGING]


/obj/structure/alien/weeds/proc/fullUpdateWeedOverlays()
	for (var/obj/structure/alien/weeds/W in range(1,src))
		W.updateWeedOverlays()

//Weed nodes
/obj/structure/alien/weeds/node
	name = "glowing resin"
	desc = "Blue bioluminescence shines from beneath the surface."
	icon_state = "weednode"
	luminosity = 1
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
				qdel(src)
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
	user.changeNext_move(CLICK_CD_MELEE)


/obj/structure/alien/egg/proc/GetFacehugger()
	return locate(/obj/item/clothing/mask/facehugger) in contents


/obj/structure/alien/egg/proc/Grow()
	icon_state = "egg"
	status = GROWN


/obj/structure/alien/egg/proc/Burst(kill = 1)	//drops and kills the hugger if any is remaining
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


/obj/structure/alien/egg/attackby(obj/item/I, mob/user, params)
	if(I.attack_verb.len)
		visible_message("<span class='danger'>[user] has [pick(I.attack_verb)] [src] with [I]!</span>")
	else
		visible_message("<span class='danger'>[user] has attacked [src] with [I]!</span>")

	var/damage = I.force / 4
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	user.changeNext_move(CLICK_CD_MELEE)
	healthcheck()


/obj/structure/alien/egg/proc/healthcheck()
	if(health <= 0)
		if(status != BURST && status != BURSTING)
			Burst()
		else if(status == BURST && prob(50))
			qdel(src)	//Remove the egg after it has been hit after bursting.


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
		target_strength = 640
	else
		target_strength = 320
	tick()


/obj/effect/acid/proc/tick()
	if(!target)
		qdel(src)

	ticks++

	if(ticks >= target_strength)
		target.visible_message("<span class='warning'>[target] collapses under its own weight into a puddle of goop and undigested debris!</span>")

		if(istype(target, /turf/simulated/wall))
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else
			qdel(target)

		qdel(src)
		return

	x = target.x
	y = target.y
	z = target.z

	switch(target_strength - ticks)
		if(480)
			visible_message("<span class='warning'>[target] is holding up against the acid!</span>")
		if(320)
			visible_message("<span class='warning'>[target] is being melted by the acid!</span>")
		if(160)
			visible_message("<span class='warning'>[target] is struggling to withstand the acid!</span>")
		if(80)
			visible_message("<span class='warning'>[target] begins to crumble under the acid!</span>")

	spawn(1)
		if(src)
			tick()

#undef WEED_NORTH_EDGING
#undef WEED_SOUTH_EDGING
#undef WEED_EAST_EDGING
#undef WEED_WEST_EDGING
