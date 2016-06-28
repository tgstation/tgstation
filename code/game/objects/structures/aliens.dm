/* Alien shit!
 * Contains:
 *		structure/alien
 *		Resin
 *		Weeds
 *		Egg
 */


/obj/structure/alien
	icon = 'icons/mob/alien.dmi'
	var/health = 100

/obj/structure/alien/attacked_by(obj/item/I, mob/user)
	..()
	var/damage = I.force
	switch(I.damtype)
		if(BRUTE)
			damage *= 0.25
		if(BURN)
			damage *= 2
		else
			damage = 0 //stamina damage does no damage
	take_damage(damage, I.damtype)

/obj/structure/alien/proc/take_damage(amount, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
		if(BURN)
			if(sound_effect)
				playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		else
			return
	health = max(health - amount, 0)
	if(!health)
		Break()

/obj/structure/alien/proc/Break()
	qdel(src)

/obj/structure/alien/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type)

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
	health = 200
	smooth = SMOOTH_TRUE
	var/resintype = null



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

/obj/structure/alien/resin/membrane
	name = "resin membrane"
	desc = "Resin just thin enough to let light pass through."
	icon = 'icons/obj/smooth_structures/alien/resin_membrane.dmi'
	icon_state = "membrane0"
	opacity = 0
	health = 160
	resintype = "membrane"
	canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/obj/structure/alien/resin/ex_act(severity, target)
	switch(severity)
		if(1)
			take_damage(150, BRUTE, 0)
		if(2)
			take_damage(100, BRUTE, 0)
		if(3)
			take_damage(50, BRUTE, 0)

/obj/structure/alien/blob_act(obj/effect/blob/B)
	take_damage(50, BRUTE, 0)

/obj/structure/alien/resin/hitby(atom/movable/AM)
	..()
	var/tforce = 0
	if(!isobj(AM))
		tforce = 10
	else
		var/obj/O = AM
		tforce = O.throwforce
	take_damage(tforce)

/obj/structure/alien/resin/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	user.visible_message("<span class='danger'>[user] destroys [src]!</span>")
	take_damage(200)

/obj/structure/alien/resin/attack_paw(mob/user)
	return attack_hand(user)


/obj/structure/alien/resin/attack_alien(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='danger'>[user] claws at the resin!</span>")
	take_damage(50)

/obj/structure/alien/resin/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(!M.melee_damage_upper)
		return
	visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>")
	take_damage(M.melee_damage_upper, M.melee_damage_type)

/obj/structure/alien/resin/CanPass(atom/movable/mover, turf/target, height=0)
	return !density


/*
 * Weeds
 */

#define NODERANGE 3

/obj/structure/alien/weeds
	gender = PLURAL
	name = "resin floor"
	desc = "A thick resin surface covers the floor."
	anchored = 1
	density = 0
	layer = TURF_LAYER
	icon_state = "weeds"
	health = 15
	var/obj/structure/alien/weeds/node/linked_node = null
	canSmoothWith = list(/obj/structure/alien/weeds, /turf/closed/wall)
	smooth = SMOOTH_MORE


/obj/structure/alien/weeds/New(pos, node)
	pixel_x = -4
	pixel_y = -4 //so the sprites line up right in the map editor
	..()
	if(!luminosity) //weed nodes have luminosity, but normal weeds don't!
		switch(rand(1,3))
			if(1)
				icon = 'icons/obj/smooth_structures/alien/weeds1.dmi'
			if(2)
				icon = 'icons/obj/smooth_structures/alien/weeds2.dmi'
			if(3)
				icon = 'icons/obj/smooth_structures/alien/weeds3.dmi'
	linked_node = node
	if(istype(loc, /turf/open/space))
		qdel(src)
		return
	addtimer(src, "Life", rand(150, 200))

/obj/structure/alien/weeds/Destroy()
	linked_node = null
	return ..()

/obj/structure/alien/weeds/proc/Life()
	set background = BACKGROUND_ENABLED
	var/turf/U = get_turf(src)

	if(istype(U, /turf/open/space))
		qdel(src)
		return

	if(!linked_node || get_dist(linked_node, src) > linked_node.node_range)
		return

	for(var/turf/T in U.GetAtmosAdjacentTurfs())

		if (locate(/obj/structure/alien/weeds) in T || istype(T, /turf/open/space))
			continue

		new /obj/structure/alien/weeds(T, linked_node)


/obj/structure/alien/weeds/ex_act(severity, target)
	qdel(src)


/obj/structure/alien/weeds/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0)


//Weed nodes
/obj/structure/alien/weeds/node
	name = "glowing resin"
	desc = "Blue bioluminescence shines from beneath the surface."
	icon_state = "weednode"
	luminosity = 1
	var/node_range = NODERANGE


/obj/structure/alien/weeds/node/New()
	icon = 'icons/obj/smooth_structures/alien/weednode.dmi'
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
#define MIN_GROWTH_TIME 900	//time it takes to grow a hugger
#define MAX_GROWTH_TIME 1500

/obj/structure/alien/egg
	name = "egg"
	desc = "A large mottled egg."
	icon_state = "egg_growing"
	density = 0
	anchored = 1
	health = 100
	var/status = GROWING	//can be GROWING, GROWN or BURST; all mutually exclusive
	layer = MOB_LAYER


/obj/structure/alien/egg/New()
	new /obj/item/clothing/mask/facehugger(src)
	..()
	addtimer(src, "Grow", rand(MIN_GROWTH_TIME, MAX_GROWTH_TIME))

/obj/structure/alien/egg/Destroy()
	remove_from_proximity_list(src, 1)
	..()

/obj/structure/alien/egg/attack_paw(mob/living/user)
	return attack_hand(user)

/obj/structure/alien/egg/attack_hand(mob/living/user)
	if(user.getorgan(/obj/item/organ/alien/plasmavessel))
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
		user << "<span class='notice'>It feels slimy.</span>"
		user.changeNext_move(CLICK_CD_MELEE)


/obj/structure/alien/egg/proc/GetFacehugger()
	return locate(/obj/item/clothing/mask/facehugger) in contents

/obj/structure/alien/egg/proc/Grow()
	icon_state = "egg"
	status = GROWN
	add_to_proximity_list(src, 1)

/obj/structure/alien/egg/proc/Burst(kill = 1)	//drops and kills the hugger if any is remaining
	if(status == GROWN || status == GROWING)
		remove_from_proximity_list(src, 1)
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

/obj/structure/alien/egg/Move()
	remove_from_proximity_list(src, 1)
	..()

/obj/structure/alien/egg/Break()
	if(status != BURST && status != BURSTING)
		Burst()
	else if(status == BURST)
		qdel(src)	//Remove the egg after it has been hit after bursting.


/obj/structure/alien/egg/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		take_damage(5, BURN, 0)


/obj/structure/alien/egg/HasProximity(atom/movable/AM)
	if(status == GROWN)
		if(!CanHug(AM))
			return

		var/mob/living/carbon/C = AM
		if(C.stat == CONSCIOUS && C.getorgan(/obj/item/organ/body_egg/alien_embryo))
			return

		Burst(0)

#undef BURST
#undef BURSTING
#undef GROWING
#undef GROWN
#undef MIN_GROWTH_TIME
#undef MAX_GROWTH_TIME
