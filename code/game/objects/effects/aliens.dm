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
	w_type=NOT_RECYCLABLE

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
	var/health = 200
	var/turf/linked_turf

/obj/effect/alien/resin/wall
	name = "resin wall"
	desc = "Purple slime solidified into a wall."
	icon_state = "resinwall" //same as resin, but consistency ho!

/obj/effect/alien/resin/membrane
	name = "resin membrane"
	desc = "Purple slime just thin enough to let light pass through."
	icon_state = "resinmembrane"
	opacity = 0
	health = 120

/obj/effect/alien/resin/New()
	..()
	linked_turf = get_turf(src)
	linked_turf.thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

/obj/effect/alien/resin/Destroy()
	if(linked_turf)
		linked_turf.thermal_conductivity = initial(linked_turf.thermal_conductivity)
	..()


/obj/effect/alien/resin/proc/healthcheck()
	if(health <=0)
		density = 0
		qdel(src)

/obj/effect/alien/resin/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()

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

/obj/effect/alien/resin/blob_act()
	health-=50
	healthcheck()

/obj/effect/alien/resin/hitby(AM as mob|obj)
	..()
	for(var/mob/O in viewers(src, null))
		O.show_message("<span class='danger'>[src] was hit by [AM].</span>", 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health = max(0, health - tforce)
	healthcheck()
	..()

/obj/effect/alien/resin/attack_hand()
	usr.delayNextAttack(10)
	if (M_HULK in usr.mutations)
		to_chat(usr, "<span class='notice'>You easily destroy the [name].</span>")
		for(var/mob/O in oviewers(src))
			O.show_message("<span class='warning'>[usr] destroys the [name]!</span>", 1)
		health = 0
	else
		to_chat(usr, "<span class='notice'>You claw at the [name].</span>")
		for(var/mob/O in oviewers(src))
			O.show_message("<span class='warning'>[usr] claws at the [name]!</span>", 1)
		health -= rand(5,10)
	healthcheck()

/obj/effect/alien/resin/attack_paw()
	return attack_hand()

/obj/effect/alien/resin/attack_alien()
	if (islarva(usr))//Safety check for larva. /N
		return
	to_chat(usr, "<span class='good'>You claw at the [name].</span>")
	for(var/mob/O in oviewers(src))
		O.show_message("<span class='warning'>[usr] claws at the resin!</span>", 1)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health -= rand(40, 60)
	if(health <= 0)
		to_chat(usr, "<span class='good'>You slice the [name] to pieces.</span>")
		for(var/mob/O in oviewers(src))
			O.show_message("<span class='warning'>[usr] slices the [name] apart!</span>", 1)
	healthcheck()

/obj/effect/alien/resin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	/*if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(isalien(user)&&(ishuman(G.affecting)||ismonkey(G.affecting)))
		//Only aliens can stick humans and monkeys into resin walls. Also, the wall must not have a person inside already.
			if(!affecting)
				if(G.state<2)
					to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
					return
				G.affecting.loc = src
				G.affecting.paralysis = 10
				for(var/mob/O in viewers(world.view, src))
					if (O.client)
						to_chat(O, text("<span class='good'>[] places [] in the resin wall!</span>", G.assailant, G.affecting))
				affecting=G.affecting
				del(W)
				spawn(0)
					process()
			else
				to_chat(user, "<span class='warning'>This wall is already occupied.</span>")
		return */
	user.delayNextAttack(10)
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	..()

/obj/effect/alien/resin/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density


/*
 * Weeds
 */
#define NODERANGE 3
#define HEARTBEAT_RATE 300

/obj/effect/alien/weeds
	name = "weeds"
	desc = "Weird purple weeds."
	icon_state = "weeds"

	anchored = 1
	density = 0
	layer = 2
	var/health = 14
	var/obj/effect/alien/weeds/node/linked_node = null
	var/obj/machinery/door/jammin = null

/obj/effect/alien/weeds/Destroy()
	if(linked_node)
		linked_node.connected_weeds.Remove(src)
		linked_node = null
	if(jammin)
		jammin.jammed = null
		jammin = null
	..()

/obj/effect/alien/weeds/node
	icon_state = "weednode"
	name = "purple sac"
	desc = "Weird purple octopus-like thing."
	layer = 3
	luminosity = NODERANGE
	var/node_range = NODERANGE
	var/list/obj/effect/alien/weeds/connected_weeds


/obj/effect/alien/weeds/node/New()
	connected_weeds = new()
	..(src.loc, src)

/obj/effect/alien/weeds/node/Destroy()
	for(var/obj/effect/alien/weeds/W in connected_weeds)
		W.health -= 2 * get_dist(W, src)//so the further ones are more likely to disappear first
		W.linked_node = null
		spawn()
			W.DieWeed()
	connected_weeds = null
	..()

/obj/effect/alien/weeds/New(pos, var/obj/effect/alien/weeds/node/N)
	..()

	if(istype(loc, /turf/space))
		qdel(src)
		return

	for(var/obj/machinery/door/D in loc)
		if(istype(D,/obj/machinery/door/mineral/resin))
			continue
		if(!D.density && !D.operating)
			D.jammed = src
			jammin = D

	linked_node = N
	if(linked_node)
		linked_node.connected_weeds.Add(src)

	if(icon_state == "weeds")icon_state = pick("weeds", "weeds1", "weeds2")
	spawn(rand(100, 250))
		if(src)
			Life()

/obj/effect/alien/weeds/node/New()
	..()
	spawn(HEARTBEAT_RATE)
		heartbeat()

/obj/effect/alien/weeds/node/proc/heartbeat()
	flick("weednode-heartbeat",src)

	for(var/obj/effect/alien/weeds/W in connected_weeds)
		if(W.health == 15)
			spawn()
				W.Life()
	spawn(HEARTBEAT_RATE)
		if(!gcDestroyed)
			heartbeat()

/obj/effect/alien/weeds/proc/Life()
	health = 15
	var/turf/U = get_turf(src)
	if (istype(U, /turf/space))
		qdel(src)
		return

	if(!linked_node || !linked_node.loc)
		return

	if((get_dist(linked_node, src) > linked_node.node_range))
		return

	direction_loop:
		for(var/dirn in cardinal)

			var/turf/T = get_step(src, dirn)

			if (!istype(T) || T.density || istype(T.loc, /area/arrival) || istype(T, /turf/space))
				continue

			var/obj/effect/alien/weeds/W = locate(/obj/effect/alien/weeds) in T
			if (W)
				if(!W.linked_node)
					W.linked_node = linked_node
					W.health = 15
				continue

	//		if (locate(/obj/movable, T)) // don't propogate into movables
	//			continue

			for(var/obj/O in T)
				if(O.density)
					continue direction_loop

			new /obj/effect/alien/weeds(T, linked_node)


/obj/effect/alien/weeds/proc/DieWeed()
	sleep(rand(100, 250))
	if(!linked_node || !linked_node.loc)
		if(prob(max(100-((health*6) + 20),0)))
			qdel(src)

		health--

		DieWeed()
	else
		Life()

/obj/effect/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(5))
				qdel(src)

/obj/effect/alien/weeds/attackby(var/obj/item/weapon/W, var/mob/user)
	user.delayNextAttack(10)
	if(W.attack_verb && W.attack_verb.len)
		visible_message("<span class='warning'><B>[user] [pick(W.attack_verb)] \the [src] with \the [W]!</span>")
	else
		visible_message("<span class='warning'><B>[user] attacks \the [src] with \the [W]!</span>")

	var/damage = W.force

	if(!W.is_hot())
		damage = damage / 4.0

	src.health -= damage
	src.healthcheck()


/obj/effect/alien/weeds/proc/healthcheck()
	if(health <= 0)
		qdel(src)


/obj/effect/alien/weeds/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
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
	var/target_strength = 0

/obj/effect/alien/acid/hyper
	name = "hyper acid"
	desc = "Burbling corrossive stuff. The radical kind."
	icon_state = "acid-hyper"

/obj/effect/alien/acid/New(loc, target)
	..(loc)
	src.target = target

	if(isturf(target)) // Turf take twice as long to take down.
		target_strength = 8
	else
		target_strength = 4
	tick()

/obj/effect/alien/acid/proc/tick()
	if(!target)
		qdel(src)

	ticks += 1

	if(ticks >= target_strength)

		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='good'><B>[src.target] collapses under its own weight into a puddle of goop and undigested debris!</B></span>", 1)

		if(istype(target, /turf/simulated/wall)) // I hate turf code.
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else
			qdel(target)
		qdel(src)
		return

	switch(target_strength - ticks)
		if(6)
			visible_message("<span class='good'><B>[src.target] is holding up against the acid!</B></span>")
		if(4)
			visible_message("<span class='good'><B>[src.target]\s structure is being melted by the acid!</B></span>")
		if(2)
			visible_message("<span class='good'><B>[src.target] is struggling to withstand the acid!</B></span>")
		if(0 to 1)
			visible_message("<span class='good'><B>[src.target] begins to crumble under the acid!</B></span>")
	spawn(rand(150, 200)) tick()

/obj/effect/alien/acid/hyper/tick()
	visible_message("<span class='good'><B>[src.target] begins to crumble under the acid!</B></span>")
	spawn(rand(50,100))
		visible_message("<span class='good'><B>[src.target] collapses under its own weight into a puddle of goop and undigested debris!</B></span>")
		if(istype(target, /turf/simulated/wall))
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else
			qdel(target)
		qdel(src)
/*
 * Egg
 */
/var/const //for the status var
	BURST = 0
	BURSTING = 1
	GROWING = 2
	GROWN = 3

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

	flags = PROXMOVE

/obj/effect/alien/egg/New()
	if(aliens_allowed)
		..()
		spawn(rand(MIN_GROWTH_TIME,MAX_GROWTH_TIME))
			Grow()
	else
		qdel(src)

/obj/effect/alien/egg/attack_paw(user as mob)
	if(isalien(user))
		switch(status)
			if(BURST)
				to_chat(user, "<span class='warning'>You clear the hatched egg.</span>")
				qdel(src)
				return
			if(GROWING)
				to_chat(user, "<span class='warning'>The child is not developed yet.</span>")
				return
			if(GROWN)
				to_chat(user, "<span class='warning'>You retrieve the child.</span>")
				Burst(0)
				return
	else
		return attack_hand(user)

/obj/effect/alien/egg/attack_hand(user as mob)
	to_chat(user, "<span class='warning'>It feels slimy.</span>")

/obj/effect/alien/egg/proc/GetFacehugger()
	return locate(/obj/item/clothing/mask/facehugger) in contents

/obj/effect/alien/egg/proc/Grow()
	icon_state = "egg"
	status = GROWN
	new /obj/item/clothing/mask/facehugger(src)

	for(var/mob/M in range(2,src))
		if(CanHug(M))
			Burst(0)
			break

/obj/effect/alien/egg/proc/Burst(var/kill = 1) //drops and kills the hugger if any is remaining
	if(status == GROWN || status == GROWING)
		var/obj/item/clothing/mask/facehugger/child = GetFacehugger()
		icon_state = "egg_hatched"
		flick("egg_opening", src)
		status = BURSTING
		spawn(15)
			status = BURST
			if(!child)
				src.visible_message("<span class='warning'>The egg bursts apart, revealing nothing!</span>")
				status = "GROWN"
				getFromPool(/obj/effect/decal/cleanable/blood/xeno, src)
				health = min(health,0)
				return
			child.forceMove(loc)
			if(kill && istype(child))
				child.Die()
			else
				for(var/mob/M in range(1,src))
					if(CanHug(M))
						child.Attach(M)
						break
				if(!ismob(child.loc))
					child.findtarget()
	health = min(health,0)

/obj/effect/alien/egg/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()


/obj/effect/alien/egg/attackby(var/obj/item/weapon/W, var/mob/user)
	user.delayNextAttack(10)
	if(W.attack_verb && W.attack_verb.len)
		src.visible_message("<span class='warning'><B>[user] [pick(W.attack_verb)] \the [src] with \the [W]!</span>")
	else
		src.visible_message("<span class='warning'><B>[user] attacks \the [src] with \the [W]!</span>")

	var/damage = W.force

	if(!W.is_hot())
		damage = damage / 4.0

	src.health -= damage
	src.healthcheck()


/obj/effect/alien/egg/proc/healthcheck()
	if(health <= 0)
		Burst()
	if(health <= -20)
		qdel(src)

/obj/effect/alien/egg/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		health -= 5
		healthcheck()

/obj/effect/alien/egg/HasProximity(atom/movable/AM as mob|obj)
	if(status == GROWN)
		if(!CanHug(AM))
			return

		var/mob/living/carbon/C = AM
		if(C.stat == CONSCIOUS && C.status_flags & XENO_HOST)
			return

		Burst(0)
