/* Alien Effects!
 * Contains:
 *		effect/alien
 *		Resin
 *		Weeds
 *		Acid
 *		Egg
 */

/*
 * effect/alien
 */
/obj/effect/alien
	name = "alien thing"
	desc = "theres something alien about this"
	icon = 'icons/mob/alien.dmi'
//	unacidable = 1 //Aliens won't ment their own.


/*
 * Resin
 */
/obj/effect/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "resin"

	density = 1
	opacity = 1
	anchored = 1
	var/health = 50
	//var/mob/living/affecting = null

	wall
		name = "resin wall"
		desc = "Purple slime solidified into a wall."
		icon_state = "resinwall" //same as resin, but consistency ho!

	membrane
		name = "resin membrane"
		desc = "Purple slime just thin enough to let light pass through."
		icon_state = "resinmembrane"
		opacity = 0
		health = 20

/obj/effect/alien/resin/proc/healthcheck()
	if(health <=0)
		density = 0
		del(src)
	return

/obj/effect/alien/resin/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/effect/alien/resin/ex_act(severity)
	switch(severity)
		if(1.0)
			health-=50
		if(2.0)
			health-=50
		if(3.0)
			if (prob(50))
				health-=50
			else
				health-=25
	healthcheck()
	return

/obj/effect/alien/resin/blob_act()
	health-=50
	healthcheck()
	return

/obj/effect/alien/resin/meteorhit()
	health-=50
	healthcheck()
	return

/obj/effect/alien/resin/hitby(AM as mob|obj)
	..()
	for(var/mob/O in viewers(src, null))
		O.show_message("\red <B>[src] was hit by [AM].</B>", 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health = max(0, health - tforce)
	healthcheck()
	..()
	return

/obj/effect/alien/resin/attack_hand()
	if ((HULK in usr.mutations) || (SUPRSTR in usr.augmentations))
		usr << "\blue You easily destroy the [name]."
		for(var/mob/O in oviewers(src))
			O.show_message("\red [usr] destroys the [name]!", 1)
		health = 0
	healthcheck()
	return

/obj/effect/alien/resin/attack_paw()
	return attack_hand()

/obj/effect/alien/resin/attack_alien()
	if (islarva(usr))//Safety check for larva. /N
		return
	usr << "\green You claw at the [name]."
	for(var/mob/O in oviewers(src))
		O.show_message("\red [usr] claws at the resin!", 1)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health -= rand(10, 20)
	if(health <= 0)
		usr << "\green You slice the [name] to pieces."
		for(var/mob/O in oviewers(src))
			O.show_message("\red [usr] slices the [name] apart!", 1)
	healthcheck()
	return

/obj/effect/alien/resin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	/*if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(isalien(user)&&(ishuman(G.affecting)||ismonkey(G.affecting)))
		//Only aliens can stick humans and monkeys into resin walls. Also, the wall must not have a person inside already.
			if(!affecting)
				if(G.state<2)
					user << "\red You need a better grip to do that!"
					return
				G.affecting.loc = src
				G.affecting.paralysis = 10
				for(var/mob/O in viewers(world.view, src))
					if (O.client)
						O << text("\green [] places [] in the resin wall!", G.assailant, G.affecting)
				affecting=G.affecting
				del(W)
				spawn(0)
					process()
			else
				user << "\red This wall is already occupied."
		return */

	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	..()
	return

/obj/effect/alien/resin/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density


/*
 * Weeds
 */
#define NODERANGE 3

/obj/effect/alien/weeds
	name = "weeds"
	desc = "Weird purple weeds."
	icon_state = "weeds"

	anchored = 1
	density = 0
	var/health = 15
	var/obj/effect/alien/weeds/node/linked_node = null

/obj/effect/alien/weeds/node
	icon_state = "weednode"
	name = "purple sac"
	desc = "Weird purple octopus-like thing."
	luminosity = NODERANGE
	var/node_range = NODERANGE

/obj/effect/alien/weeds/node/New()
	..(src.loc, src)


/obj/effect/alien/weeds/New(pos, node)
	..()
	linked_node = node
	if(istype(loc, /turf/space))
		del(src)
		return
	if(icon_state == "weeds")icon_state = pick("weeds", "weeds1", "weeds2")
	spawn(rand(150, 200))
		if(src)
			Life()
	return

/obj/effect/alien/weeds/proc/Life()
	set background = 1
	var/turf/U = get_turf(src)
/*
	if (locate(/obj/movable, U))
		U = locate(/obj/movable, U)
		if(U.density == 1)
			del(src)
			return

Alien plants should do something if theres a lot of poison
	if(U.poison> 200000)
		health -= round(U.poison/200000)
		update()
		return
*/
	if (istype(U, /turf/space))
		del(src)
		return

	direction_loop:
		for(var/dirn in cardinal)
			var/turf/T = get_step(src, dirn)

			if (!istype(T) || T.density || locate(/obj/effect/alien/weeds) in T || istype(T.loc, /area/arrival) || istype(T, /turf/space))
				continue

			if(!linked_node || get_dist(linked_node, src) > linked_node.node_range)
				return

	//		if (locate(/obj/movable, T)) // don't propogate into movables
	//			continue

			for(var/obj/O in T)
				if(O.density)
					continue direction_loop

			new /obj/effect/alien/weeds(T, linked_node)


/obj/effect/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				del(src)
		if(3.0)
			if (prob(5))
				del(src)
	return

/obj/effect/alien/weeds/attackby(var/obj/item/weapon/W, var/mob/user)
	if(W.attack_verb.len)
		visible_message("\red <B>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]")
	else
		visible_message("\red <B>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]")

	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()

/obj/effect/alien/weeds/proc/healthcheck()
	if(health <= 0)
		del(src)


/obj/effect/alien/weeds/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()

/*/obj/effect/alien/weeds/burn(fi_amount)
	if (fi_amount > 18000)
		spawn( 0 )
			del(src)
			return
		return 0
	return 1
*/

#undef NODERANGE


/*
 * Acid
 */
/obj/effect/alien/acid
	name = "acid"
	desc = "Burbling corrossive stuff. I wouldn't want to touch it."
	icon_state = "acid"

	density = 0
	opacity = 0
	anchored = 1

	var/atom/target
	var/ticks = 0

/obj/effect/alien/acid/proc/tick()
	if(!target)
		del(src)

	ticks += 1

	for(var/mob/O in hearers(src, null))
		O.show_message("\green <B>[src.target] sizzles and begins to melt under the bubbling mess of acid!</B>", 1)

	if(ticks >= 3)

		for(var/mob/O in hearers(src, null))
			O.show_message("\green <B>[src.target] collapses under its own weight into a puddle of goop and undigested debris!</B>", 1)

		if(istype(target, /turf/simulated/wall)) // I hate turf code.
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else
			del(target)
		del(src)
		return
	spawn(rand(100, 150)) tick()

/*
 * Egg
 */
/var/const //for the status var
	BURST = 0
	GROWING = 1
	GROWN = 2

	MIN_GROWTH_TIME = 1800 //time it takes to grow a hugger
	MAX_GROWTH_TIME = 3000

/obj/effect/alien/egg
	desc = "It looks like a weird egg"
	name = "egg"
	icon_state = "egg_growing"
	density = 0
	anchored = 1

	var/health = 100
	var/status = GROWING //can be GROWING, GROWN or BURST; all mutually exclusive

	New()
		if(aliens_allowed)
			..()
			spawn(rand(MIN_GROWTH_TIME,MAX_GROWTH_TIME))
				Grow()
		else
			del(src)

	attack_paw(user as mob)
		if(isalien(user))
			switch(status)
				if(BURST)
					user << "\red The child is already gone."
					return
				if(GROWING)
					user << "\red The child is not developed yet."
					return
				if(GROWN)
					user << "\red You retrieve the child."
					loc.contents += GetFacehugger()//need to write the code for giving it to the alien later
					Burst()
					return
		else
			return attack_hand(user)

	attack_hand(user as mob)
		user << "It feels slimy."
		return

	proc/GetFacehugger()
		return locate(/obj/item/clothing/mask/facehugger) in contents

	proc/Grow()
		icon_state = "egg"
		status = GROWN
		new /obj/item/clothing/mask/facehugger(src)
		return

	proc/Burst(var/kill = 1) //drops and kills the hugger if any is remaining
		var/obj/item/clothing/mask/facehugger/child = GetFacehugger()

		if(kill && istype(child))
			loc.contents += child
			child.Die()

		icon_state = "egg_hatched"
		status = BURST
		return


/obj/effect/alien/egg/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return


/obj/effect/alien/egg/attackby(var/obj/item/weapon/W, var/mob/user)
	if(health <= 0)
		return
	if(W.attack_verb.len)
		src.visible_message("\red <B>\The [src] has been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]")
	else
		src.visible_message("\red <B>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]")
	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

	src.health -= damage
	src.healthcheck()


/obj/effect/alien/egg/proc/healthcheck()
	if(health <= 0)
		Burst()

/obj/effect/alien/egg/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		health -= 5
		healthcheck()

/obj/effect/alien/egg/HasProximity(atom/movable/AM as mob|obj)
	if(!CanHug(AM))
		return
	if(status == GROWN && iscarbon(AM) && !isalien(AM))

		var/mob/living/carbon/C = AM
		if(C.stat == CONSCIOUS && C.has_disease(/datum/disease/alien_embryo))
			return

		status = BURST
		flick("egg_opening", src) //Play animation
		var/turf/pos = get_turf(src)
		spawn(18) // Wait until the animation finishes
			Burst(0)
			var/obj/item/clothing/mask/facehugger/child = GetFacehugger()
			child.loc = pos
			if(!CanHug(AM))
				return
			if(AM && in_range(AM, pos))
				child.Attach(AM)

