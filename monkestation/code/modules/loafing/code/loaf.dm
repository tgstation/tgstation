/obj/item/food/prison_loaf
	name = "prison loaf"
	desc = "A barely edible brick of nutrients, designed as a low-cost solution to malnourishment."
	icon = 'monkestation/code/modules/loafing/icons/obj.dmi'
	icon_state = "loaf"
	food_reagents = list(/datum/reagent/consumable/nutraslop = 10)
	var/loaf_density = 1 //base loaf density
	var/can_condense = TRUE //for special loaves, make false
	force_feed_on_aggression = TRUE
	//vars for high level loafs

	var/critical = FALSE
	var/atom/movable/warp_effect/warp


	var/lifespan = ANOMALY_COUNTDOWN_TIMER  //works similar to grav anomaly when hits critical
	var/death_time
	var/countdown_colour = COLOR_ASSEMBLY_LBLUE
	var/obj/effect/countdown/loaf/countdown
	var/boing = 0
	var/obj/singularity/singuloaf

/obj/item/food/prison_loaf/process(seconds_per_tick)
	anomalyEffect(seconds_per_tick)
	if(death_time < world.time)
		if(loc)
			detonate()
		qdel(src)

/obj/item/food/prison_loaf/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	vis_contents -= warp
	warp = null
	return ..()

/obj/item/food/prison_loaf/proc/anomalyEffect(seconds_per_tick)
	if(SPT_PROB(ANOMALY_MOVECHANCE, seconds_per_tick))
		step(src,pick(GLOB.alldirs))
		boing = 1
	for(var/obj/object in orange(4, src))
		if(!object.anchored)
			step_towards(object,src)
	for(var/mob/living/M in range(0, src))
		gravShock(M)
	for(var/mob/living/M in orange(4, src))
		if(!M.mob_negates_gravity())
			step_towards(M,src)
	for(var/obj/object in range(0,src))
		if(!object.anchored)
			if(isturf(object.loc))
				var/turf/T = object.loc
				if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(object, TRAIT_T_RAY_VISIBLE))
					continue
			var/mob/living/target = locate() in view(4,src)
			if(target && !target.stat)
				object.throw_at(target, 5, 10)
	animate(warp, time = seconds_per_tick*3, transform = matrix().Scale(0.5,0.5))
	animate(time = seconds_per_tick*7, transform = matrix())

/obj/item/food/prison_loaf/proc/detonate()
	var/turf/T = get_turf(src)
	log_game("\A [src] critical loaf has ended its lifespan, turning into a singularity at [AREACOORD(T)].")
	message_admins("A [src.name] critical loaf has ended its lifespan, turning into a singularity at [ADMIN_VERBOSEJMP(T)].")

	singuloaf = new /obj/singularity/(src)
	singuloaf.loc = src.loc
	return

/obj/item/food/prison_loaf/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	if(warp)
		SET_PLANE(warp, PLANE_TO_TRUE(warp.plane), new_turf)

/obj/item/food/prison_loaf/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	gravShock(AM)

/obj/item/food/prison_loaf/Bump(atom/A)
	if(critical)
		gravShock(A)
	else
		return 	..()

/obj/item/food/prison_loaf/Bumped(atom/movable/AM)
	if(critical)
		gravShock(AM)
	else
		return 	..()

/obj/item/food/prison_loaf/proc/gravShock(mob/living/A)
	if(boing && isliving(A) && !A.stat)
		A.Paralyze(40)
		var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
		A.throw_at(target, 5, 1)
		boing = 0

/obj/item/food/prison_loaf/proc/critical()
	src.critical = TRUE
	var/turf/T = get_turf(src)
	notify_ghosts(
		"A [src] has been condensed to the point of criticality!",
		source = src,
		action = NOTIFY_ORBIT,
		header = "Loaf Criticality!!"
	)
	log_game("\A [src] has been condensed to the point of criticality at [AREACOORD(T)].")
	message_admins("A [src.name] has been condensed to the point of criticality at [ADMIN_VERBOSEJMP(T)].")
	death_time = world.time + lifespan
	warp = new(src)
	vis_contents += warp
	countdown = new(src)
	if(countdown_colour)
		countdown.color = countdown_colour
	countdown.start()
	can_condense = FALSE
	START_PROCESSING(SSobj, src)

/obj/effect/countdown/loaf
	name = "singuloaf countdown"

/obj/effect/countdown/loaf/get_value()
	var/obj/item/food/prison_loaf/loaf = attached_to
	if(!istype(loaf))
		return
	else
		var/time_left = max(0, (loaf.death_time - world.time) / 10)
		return round(time_left)

/obj/item/food/prison_loaf/rod
	name = "rod loaf"
	desc = "If you loaf something, set it free.  If it comes back, it's yours."
	icon_state = "rod_loaf"
	can_condense = FALSE

/obj/item/food/prison_loaf/rod/after_throw(datum/callback/callback)
	. = ..()
	var/startside = pick(GLOB.cardinals)
	var/turf/end_turf = get_edge_target_turf(get_random_station_turf(), turn(startside, 180))
	var/turf/start_turf = get_turf(usr)
	var/atom/rod = new /obj/effect/immovablerod/loaf(start_turf, end_turf)
	notify_ghosts(
		"[usr.name] has an object of interest: [rod]!",
		source = rod,
		action = NOTIFY_ORBIT,
		header = "Something's Interesting!"
	)
	qdel(src)

/obj/effect/immovablerod/loaf
	name = "immovable loaf"
	desc = "Oh no, the flavor is coming right for us!"
	icon = 'monkestation/code/modules/loafing/icons/obj.dmi'
	icon_state = "rod_loaf"

/obj/machinery/power/supermatter_crystal/loaf
	name = "suppermatter loaf" //you can't kill me for my bad puns.  they make me immortal.
	desc = "A prison loaf that has condensed and crystalized to the point where it can be used as a standard power source."
	icon = 'monkestation/code/modules/loafing/icons/obj.dmi'
	icon_state = "sm"



/obj/item/food/prison_loaf/proc/condense()
	if(!src.can_condense)
		return
	switch(src.loaf_density)
		if(0 to 10)
			src.name = initial(src.name)
			src.desc = "A barely edible brick of nutrients, designed as a low-cost solution to malnourishment."
			src.icon_state = initial(src.icon_state) + "0"
			src.force = 0
			src.throwforce = 0
			src.reagents.add_reagent(/datum/reagent/consumable/salt, 1)
			src.reagents.add_reagent(/datum/reagent/consumable/nutraslop, 1)
		if(11 to 100)
			src.name = "dense " + initial(src.name)
			src.desc = initial(src.desc) + "\n This loaf is noticeably heavier than usual."
			src.icon_state = initial(src.icon_state) + "0"
			src.force = 2
			src.throwforce = 2
			src.reagents.add_reagent(/datum/reagent/consumable/salt, 3)
			src.reagents.add_reagent(/datum/reagent/consumable/nutraslop, 3)
		if(101 to 250)
			src.name = "compacted " + initial(src.name)
			src.desc = initial(src.desc) + "\n Hooh, this thing packs a punch. What are they putting into these?"
			src.icon_state = initial(src.icon_state) + "0"
			src.force = 4
			src.throwforce = 4
			src.throw_range = 6
			src.reagents.add_reagent(/datum/reagent/consumable/salt, 5)
			src.reagents.add_reagent(/datum/reagent/consumable/nutraslop, 5)
		if(251 to 500)
			src.name = "super-compressed " + initial(src.name)
			src.desc = initial(src.desc) + "\n Hard enough to scratch a diamond, yet still somehow edible,\n this loaf seems to be emitting decay heat. Dear god."
			src.icon_state = initial(src.icon_state) + "1"
			src.force = 5
			src.throwforce = 5
			src.throw_range = 6
			src.reagents.add_reagent(/datum/reagent/consumable/salt, 8)
			src.reagents.add_reagent(/datum/reagent/consumable/nutraslop, 8)
		if(501 to 2500)
			src.name = "molecular " + initial(src.name)
			src.desc = initial(src.desc) + "\n The loaf has become so dense that no food particulates are visible to the naked eye."
			src.icon_state = initial(src.icon_state) + "2"
			src.force = 10
			src.throwforce = 10
			src.throw_range = 5
			src.reagents.add_reagent(/datum/reagent/consumable/salt, 10)
			src.reagents.add_reagent(/datum/reagent/consumable/nutraslop, 10)
			src.reagents.add_reagent(/datum/reagent/consumable/corn_syrup, 5)
		if(2501 to 10000)
			src.name = "atomic " + initial(src.name)
			src.desc = initial(src.desc) + "\n Forget food particulates, the loaf is now comprised of flavor atoms."
			src.icon_state = initial(src.icon_state) + "3"
			src.force = 20
			src.throwforce = 20
			src.throw_range = 4
			src.reagents.add_reagent(/datum/reagent/consumable/salt, 10)
			src.reagents.add_reagent(/datum/reagent/consumable/nutraslop, 10)
			src.reagents.add_reagent(/datum/reagent/growthserum, 5)
		if(10001 to 25000)
			src.name = "sub atomic " + initial(src.name)
			src.desc = initial(src.desc) + "\n Oh good, the flavor atoms in this prison loaf have collapsed down to a a solid lump of neutrons. Eating this could prove dangerous."
			src.icon_state = initial(src.icon_state) + "4"
			src.force = 30
			src.throwforce = 30
			src.throw_range = 3
			src.reagents.add_reagent(/datum/reagent/consumable/salt, 10)
			src.reagents.add_reagent(/datum/reagent/consumable/nutraslop, 10)
			src.reagents.add_reagent(/datum/reagent/consumable/vitfro, 25)
		if(25001 to 50000)
			src.name = "quark " + initial(src.name)
			src.desc = initial(src.desc) + "\n This nutritional loaf is collapsing into subatomic flavor particles. Consuption could convert your DNA into synthetic sludge."
			src.icon_state = initial(src.icon_state) + "5"
			src.force = 50
			src.throwforce = 50
			src.throw_range = 2
			src.reagents.add_reagent(/datum/reagent/consumable/salt, 10)
			src.reagents.add_reagent(/datum/reagent/consumable/nutraslop, 10)
			src.reagents.add_reagent(/datum/reagent/mulligan, 25)
		if(50001 to 100000)
			src.name = "strangelet " + initial(src.name)
			src.desc = initial(src.desc) + "\n At this point you may be considering: has man gone too far? Are we meant to have food this powerful?"
			src.icon_state = initial(src.icon_state) + "6"
			src.force = 75
			src.throwforce = 75
			src.throw_range = 1
			src.reagents.add_reagent(/datum/reagent/consumable/salt, 10)
			src.reagents.add_reagent(/datum/reagent/consumable/nutraslop, 10)
			src.reagents.add_reagent(/datum/reagent/cyborg_mutation_nanomachines, 50)
		if(100001 to 1000000)
			src.name = "quantum " + initial(src.name)
			src.desc = initial(src.desc) + "\n The mere existence of this nutritional masterpiece is causing reality to distort!"
			src.icon_state = initial(src.icon_state) + "7"
			src.force = 100
			src.throwforce = 100
			src.throw_range = 0
			src.reagents.add_reagent(/datum/reagent/consumable/salt, 10)
			src.reagents.add_reagent(/datum/reagent/consumable/nutraslop, 10)
			src.reagents.add_reagent(/datum/reagent/gravitum, 100)
			critical()


/datum/export/food/loaf
	cost = 10
	unit_name = "loaf"
	message = "of Nutraloaf"
	export_types = list(/obj/item/food/prison_loaf)

/datum/export/food/loaf/get_cost(obj/O)
	var/obj/item/food/prison_loaf/loaf = O
	cost = max(10, loaf.loaf_density / 5)
	return ..()
