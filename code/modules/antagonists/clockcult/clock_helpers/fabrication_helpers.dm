//For the clockwork fabricator, this proc exists to make it easy to customize what the fabricator does when hitting something.

//if a valid target, returns an associated list in this format;
//list("operation_time" = 15, "new_obj_type" = /obj/structure/window/reinforced/clockwork, "power_cost" = 5, "spawn_dir" = dir, "dir_in_new" = TRUE)
//otherwise, return literally any non-list thing but preferably FALSE
//returning TRUE won't produce the "cannot be fabricated" message and will still prevent fabrication

/atom/proc/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

/atom/proc/consume_visual(obj/item/clockwork/replica_fabricator/fabricator, power_amount)
	if(get_clockwork_power(power_amount))
		var/obj/effect/temp_visual/ratvar/beam/itemconsume/B = new /obj/effect/temp_visual/ratvar/beam/itemconsume(get_turf(src))
		B.pixel_x = pixel_x
		B.pixel_y = pixel_y

//Turf conversion
/turf/closed/wall/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent) //four sheets of metal
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_TOTAL - (POWER_METAL * 4), "spawn_dir" = SOUTH)

/turf/closed/wall/mineral/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent) //two sheets of metal
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_TOTAL - (POWER_METAL * 2), "spawn_dir" = SOUTH)

/turf/closed/wall/mineral/iron/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent) //two sheets of metal, five rods
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_TOTAL - (POWER_METAL * 2) - (POWER_ROD * 5), "spawn_dir" = SOUTH)

/turf/closed/wall/mineral/cult/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent) //no metal
	return list("operation_time" = 80, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_TOTAL, "spawn_dir" = SOUTH)

/turf/closed/wall/r_wall/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

/turf/closed/wall/clockwork/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return list("operation_time" = 50, "new_obj_type" = /turf/open/floor/clockwork, "power_cost" = -POWER_WALL_MINUS_FLOOR, "spawn_dir" = SOUTH)

/turf/open/floor/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	if(floor_tile == /obj/item/stack/tile/plasteel)
		new floor_tile(src)
		make_plating()
		playsound(src, 'sound/items/crowbar.ogg', 10, 1) //clink
	return list("operation_time" = 30, "new_obj_type" = /turf/open/floor/clockwork, "power_cost" = POWER_FLOOR, "spawn_dir" = SOUTH)

/turf/open/floor/plating/asteroid/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

/turf/open/floor/plating/ashplanet/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

/turf/open/lava/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

/turf/open/floor/clockwork/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	if(locate(/obj/structure/table) in src)
		return FALSE
	if(locate(/obj/structure/falsewall) in contents)
		to_chat(user, "<span class='warning'>There is a false wall in the way, preventing you from fabricating a clockwork wall on [src].</span>")
		return
	if(is_blocked_turf(src, TRUE))
		to_chat(user, "<span class='warning'>Something is in the way, preventing you from fabricating a clockwork wall on [src].</span>")
		return TRUE
	var/operation_time = 100
	if(!GLOB.ratvar_awakens && fabricator.speed_multiplier > 0) //if ratvar isn't awake, this always takes 10 seconds
		operation_time /= fabricator.speed_multiplier
	return list("operation_time" = operation_time, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_MINUS_FLOOR, "spawn_dir" = SOUTH)

//False wall conversion
/obj/structure/falsewall/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	var/cost = POWER_WALL_MINUS_FLOOR
	if(ispath(mineral, /obj/item/stack/sheet/metal))
		cost -= (POWER_METAL * (2 + mineral_amount)) //four sheets of metal, plus an assumption that the girder is also two
	else
		cost -= (POWER_METAL * 2) //anything that doesn't use metal just has the girder
	return list("operation_time" = 50, "new_obj_type" = /obj/structure/falsewall/brass, "power_cost" = cost, "spawn_dir" = SOUTH)

/obj/structure/falsewall/iron/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent) //two sheets of metal, two rods; special assumption
	return list("operation_time" = 50, "new_obj_type" = /obj/structure/falsewall/brass, "power_cost" = POWER_WALL_MINUS_FLOOR - (POWER_METAL * 2) - (POWER_ROD * 2), "spawn_dir" = SOUTH)

/obj/structure/falsewall/reinforced/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

/obj/structure/falsewall/brass/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

//Metal conversion
/obj/item/stack/tile/plasteel/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	if(source)
		return FALSE
	var/amount_temp = get_amount()
	var/no_delete = FALSE
	if(amount_temp < 2)
		to_chat(user, "<span class='warning'>You need at least <b>2</b> floor tiles to convert into power.</span>")
		return TRUE
	if(ISODD(amount_temp))
		amount_temp--
		no_delete = TRUE
		use(amount_temp)
	amount_temp *= 12.5 //each tile is 12.5 power so this is 2 tiles to 25 power
	consume_visual(fabricator, amount_temp)
	return list("operation_time" = 0, "new_obj_type" = null, "power_cost" = -amount_temp, "spawn_dir" = SOUTH, "no_target_deletion" = no_delete)

/obj/item/stack/rods/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	if(source)
		return FALSE
	var/power_amount = -(amount*POWER_ROD)
	consume_visual(fabricator, power_amount)
	return list("operation_time" = 0, "new_obj_type" = null, "power_cost" = power_amount, "spawn_dir" = SOUTH)

/obj/item/stack/sheet/metal/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	if(source)
		return FALSE
	var/power_amount = -(amount*POWER_METAL)
	consume_visual(fabricator, power_amount)
	return list("operation_time" = 0, "new_obj_type" = null, "power_cost" = power_amount, "spawn_dir" = SOUTH)

/obj/item/stack/sheet/plasteel/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	if(source)
		return FALSE
	var/power_amount = -(amount*POWER_PLASTEEL)
	consume_visual(fabricator, power_amount)
	return list("operation_time" = 0, "new_obj_type" = null, "power_cost" = power_amount, "spawn_dir" = SOUTH)

//Brass directly to power
/obj/item/stack/tile/brass/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	if(source)
		return FALSE
	var/power_amount = -(amount*POWER_FLOOR)
	consume_visual(fabricator, power_amount)
	return list("operation_time" = 0, "new_obj_type" = null, "power_cost" = power_amount, "spawn_dir" = SOUTH)

//Airlock conversion
/obj/machinery/door/airlock/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	var/doortype = /obj/machinery/door/airlock/clockwork
	if(glass)
		doortype = /obj/machinery/door/airlock/clockwork/brass
	return list("operation_time" = 60, "new_obj_type" = doortype, "power_cost" = POWER_WALL_TOTAL, "spawn_dir" = dir, "transfer_name" = TRUE)

/obj/machinery/door/airlock/clockwork/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

//Table conversion
/obj/structure/table/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	var/fabrication_cost = POWER_STANDARD
	if(framestack == /obj/item/stack/rods)
		fabrication_cost -= POWER_ROD*framestackamount
	else if(framestack == /obj/item/stack/tile/brass)
		fabrication_cost -= POWER_FLOOR*framestackamount
	if(buildstack == /obj/item/stack/sheet/metal)
		fabrication_cost -= POWER_METAL*buildstackamount
	else if(buildstack == /obj/item/stack/sheet/plasteel)
		fabrication_cost -= POWER_PLASTEEL*buildstackamount
	return list("operation_time" = 20, "new_obj_type" = /obj/structure/table/reinforced/brass, "power_cost" = fabrication_cost, "spawn_dir" = SOUTH)

/obj/structure/table/reinforced/brass/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

/obj/structure/table_frame/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	var/fabrication_cost = POWER_FLOOR
	if(framestack == /obj/item/stack/rods)
		fabrication_cost -= POWER_ROD*framestackamount
	else if(framestack == /obj/item/stack/tile/brass)
		fabrication_cost -= POWER_FLOOR*framestackamount
	return list("operation_time" = 10, "new_obj_type" = /obj/structure/table_frame/brass, "power_cost" = fabrication_cost, "spawn_dir" = SOUTH)

/obj/structure/table_frame/brass/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

//Window conversion
/obj/structure/window/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	var/windowtype = /obj/structure/window/reinforced/clockwork
	var/new_dir = TRUE
	var/fabrication_time = 15
	var/fabrication_cost = POWER_FLOOR
	if(fulltile)
		windowtype = /obj/structure/window/reinforced/clockwork/fulltile
		new_dir = FALSE
		fabrication_time = 30
		fabrication_cost = POWER_STANDARD
		if(reinf)
			fabrication_cost -= POWER_ROD
	if(reinf)
		fabrication_cost -= POWER_ROD
	for(var/obj/structure/grille/G in get_turf(src))
		INVOKE_ASYNC(fabricator, /obj/item/clockwork/replica_fabricator.proc/fabricate, G, user)
	return list("operation_time" = fabrication_time, "new_obj_type" = windowtype, "power_cost" = fabrication_cost, "spawn_dir" = dir, "dir_in_new" = new_dir)

/obj/structure/window/reinforced/clockwork/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

//Windoor conversion
/obj/machinery/door/window/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return list("operation_time" = 30, "new_obj_type" = /obj/machinery/door/window/clockwork, "power_cost" = POWER_STANDARD, "spawn_dir" = dir, "dir_in_new" = TRUE, "transfer_name" = TRUE)

/obj/machinery/door/window/clockwork/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

//Grille conversion
/obj/structure/grille/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	var/grilletype = /obj/structure/grille/ratvar
	var/fabrication_time = 15
	if(broken)
		grilletype = /obj/structure/grille/ratvar/broken
		fabrication_time = 5
	return list("operation_time" = fabrication_time, "new_obj_type" = grilletype, "power_cost" = 0, "spawn_dir" = dir)

/obj/structure/grille/ratvar/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

//Lattice conversion
/obj/structure/lattice/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return list("operation_time" = 0, "new_obj_type" = /obj/structure/lattice/clockwork, "power_cost" = 0, "spawn_dir" = SOUTH, "no_target_deletion" = TRUE)

/obj/structure/lattice/clockwork/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	ratvar_act() //just in case we're the wrong type for some reason??
	return FALSE

/obj/structure/lattice/catwalk/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return list("operation_time" = 0, "new_obj_type" = /obj/structure/lattice/catwalk/clockwork, "power_cost" = 0, "spawn_dir" = SOUTH, "no_target_deletion" = TRUE)

/obj/structure/lattice/catwalk/clockwork/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	return FALSE

//Girder conversion
/obj/structure/girder/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	var/fabrication_cost = POWER_GEAR - (POWER_METAL * 2)
	if(state == GIRDER_REINF_STRUTS || state == GIRDER_REINF)
		fabrication_cost -= POWER_PLASTEEL
	return list("operation_time" = 20, "new_obj_type" = /obj/structure/destructible/clockwork/wall_gear, "power_cost" = fabrication_cost, "spawn_dir" = SOUTH)

//Hitting a clockwork structure will try to repair it.
/obj/structure/destructible/clockwork/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	. = TRUE
	var/list/repair_values = list()
	if(!fabricator.fabricator_repair_checks(repair_values, src, user))
		return
	user.visible_message("<span class='notice'>[user]'s [fabricator.name] starts covering [src] in glowing orange energy...</span>", \
	"<span class='alloy'>You start repairing [src]...</span>")
	fabricator.repairing = src
	while(fabricator && user && src)
		if(!do_after(user, repair_values["healing_for_cycle"] * fabricator.speed_multiplier, target = src, \
			extra_checks = CALLBACK(fabricator, /obj/item/clockwork/replica_fabricator.proc/fabricator_repair_checks, repair_values, src, user, TRUE)))
			break
		obj_integrity = CLAMP(obj_integrity + repair_values["healing_for_cycle"], 0, max_integrity)
		adjust_clockwork_power(-repair_values["power_required"])
		playsound(src, 'sound/machines/click.ogg', 50, 1)

	if(fabricator)
		fabricator.repairing = null
		if(user)
			user.visible_message("<span class='notice'>[user]'s [fabricator.name] stops covering [src] with glowing orange energy.</span>", \
			"<span class='alloy'>You finish repairing [src]. It is now at <b>[obj_integrity]/[max_integrity]</b> integrity.</span>")

//Fabricator mob heal proc, to avoid as much copypaste as possible.
/mob/living/proc/fabricator_heal(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator)
	var/list/repair_values = list()
	if(!fabricator.fabricator_repair_checks(repair_values, src, user))
		return
	user.visible_message("<span class='notice'>[user]'s [fabricator.name] starts covering [src == user ? "[user.p_them()]" : "[src]"] in glowing orange energy...</span>", \
	"<span class='alloy'>You start repairing [src == user ? "yourself" : "[src]"]...</span>")
	fabricator.repairing = src
	while(fabricator && user && src)
		if(!do_after(user, repair_values["healing_for_cycle"] * fabricator.speed_multiplier, target = src, \
			extra_checks = CALLBACK(fabricator, /obj/item/clockwork/replica_fabricator.proc/fabricator_repair_checks, repair_values, src, user, TRUE)))
			break
		fabricator_heal_tick(repair_values["healing_for_cycle"])
		adjust_clockwork_power(-repair_values["power_required"])
		playsound(src, 'sound/machines/click.ogg', 50, 1)

	if(fabricator)
		fabricator.repairing = null

	return TRUE

/mob/living/proc/fabricator_heal_tick(amount)
	var/static/list/damage_heal_order = list(BRUTE, BURN, TOX, OXY)
	heal_ordered_damage(amount, damage_heal_order)

/mob/living/simple_animal/fabricator_heal_tick(amount)
	adjustHealth(-amount)

//Hitting a ratvar'd silicon will also try to repair it.
/mob/living/silicon/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	. = TRUE
	if(health == maxHealth) //if we're at maximum health, replace the turf under us
		return FALSE
	else if(fabricator_heal(user, fabricator) && user)
		user.visible_message("<span class='notice'>[user]'s [fabricator.name] stops covering [src == user ? "[user.p_them()]" : "[src]"] with glowing orange energy.</span>", \
		"<span class='alloy'>You finish repairin[src == user ? "g yourself. You are":"g [src]. [p_theyre(TRUE)]"] now at <b>[abs(HEALTH_THRESHOLD_DEAD - health)]/[abs(HEALTH_THRESHOLD_DEAD - maxHealth)]</b> health.</span>")

//Same with clockwork mobs.
/mob/living/simple_animal/hostile/clockwork/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	. = TRUE
	if(health == maxHealth) //if we're at maximum health, replace the turf under us
		return FALSE
	else if(fabricator_heal(user, fabricator) && user)
		user.visible_message("<span class='notice'>[user]'s [fabricator.name] stops covering [src == user ? "[user.p_them()]" : "[src]"] with glowing orange energy.</span>", \
		"<span class='alloy'>You finish repairin[src == user ? "g yourself. You are":"g [src]. [p_theyre(TRUE)]"] now at <b>[health]/[maxHealth]</b> health.</span>")

//Cogscarabs get special interaction because they're drones and have innate self-heals/revives.
/mob/living/simple_animal/drone/cogscarab/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent)
	. = TRUE
	if(stat == DEAD)
		try_reactivate(user) //if we're dead, try to repair us
		return
	if(health == maxHealth)
		return FALSE
	else if(!(flags_1 & GODMODE))
		user.visible_message("<span class='notice'>[user]'s [fabricator.name] starts covering [src == user ? "[user.p_them()]" : "[src]"] in glowing orange energy...</span>", \
		"<span class='alloy'>You start repairing [src == user ? "yourself" : "[src]"]...</span>")
		fabricator.repairing = src
		if(do_after(user, (maxHealth - health)*2, target=src))
			adjustHealth(-maxHealth)
			user.visible_message("<span class='notice'>[user]'s [fabricator.name] stops covering [src == user ? "[user.p_them()]" : "[src]"] with glowing orange energy.</span>", \
			"<span class='alloy'>You finish repairing [src == user ? "yourself" : "[src]"].</span>")
		if(fabricator)
			fabricator.repairing = null

//Convert shards and gear bits directly to power
/obj/item/clockwork/alloy_shards/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent, power_amount)
	if(!power_amount)
		power_amount = -POWER_STANDARD
	consume_visual(fabricator, power_amount)
	if(!silent) //looper no looping
		for(var/obj/item/clockwork/alloy_shards/S in get_turf(src)) //convert all other shards in the turf if we can
			if(S == src)
				continue //we want the shards to be fabricated after the main shard, thus this delay
			addtimer(CALLBACK(fabricator, /obj/item/clockwork/replica_fabricator.proc/fabricate, S, user, TRUE), 0)
	return list("operation_time" = 0, "new_obj_type" = null, "power_cost" = power_amount, "spawn_dir" = SOUTH)

/obj/item/clockwork/alloy_shards/medium/gear_bit/large/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent, power_amount)
	if(!power_amount)
		power_amount = -(CLOCKCULT_POWER_UNIT*0.08)
	return ..()

/obj/item/clockwork/alloy_shards/large/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent, power_amount)
	if(!power_amount)
		power_amount = -(CLOCKCULT_POWER_UNIT*0.06)
	return ..()

/obj/item/clockwork/alloy_shards/medium/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent, power_amount)
	if(!power_amount)
		power_amount = -(CLOCKCULT_POWER_UNIT*0.04)
	return ..()

/obj/item/clockwork/alloy_shards/small/fabrication_vals(mob/living/user, obj/item/clockwork/replica_fabricator/fabricator, silent, power_amount)
	if(!power_amount)
		power_amount = -(CLOCKCULT_POWER_UNIT*0.02)
	return ..()
