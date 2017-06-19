//For the clockwork proselytizer, this proc exists to make it easy to customize what the proselytizer does when hitting something.

//if a valid target, returns an associated list in this format;
//list("operation_time" = 15, "new_obj_type" = /obj/structure/window/reinforced/clockwork, "spawn_dir" = dir, "dir_in_new" = TRUE)
//otherwise, return literally any non-list thing but preferably FALSE
//returning TRUE won't produce the "cannot be proselytized" message and will still prevent proselytizing

/atom/proc/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

//Turf conversion
/turf/closed/wall/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent) //four sheets of metal
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "spawn_dir" = SOUTH)

/turf/closed/wall/mineral/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent) //two sheets of metal
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "spawn_dir" = SOUTH)

/turf/closed/wall/mineral/iron/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent) //two sheets of metal, five rods
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "spawn_dir" = SOUTH)

/turf/closed/wall/mineral/cult/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent) //no metal
	return list("operation_time" = 80, "new_obj_type" = /turf/closed/wall/clockwork, "spawn_dir" = SOUTH)

/turf/closed/wall/shuttle/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent) //two sheets of metal
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "spawn_dir" = SOUTH)

/turf/closed/wall/r_wall/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

/turf/closed/wall/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return list("operation_time" = 50, "new_obj_type" = /turf/open/floor/clockwork, "spawn_dir" = SOUTH)

/turf/open/floor/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	if(floor_tile == /obj/item/stack/tile/plasteel)
		new floor_tile(src)
		make_plating()
		playsound(src, 'sound/items/Crowbar.ogg', 10, 1) //clink
	return list("operation_time" = 30, "new_obj_type" = /turf/open/floor/clockwork, "spawn_dir" = SOUTH)

/turf/open/floor/plating/asteroid/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

/turf/open/floor/plating/ashplanet/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

/turf/open/floor/plating/lava/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

/turf/open/floor/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	if(locate(/obj/structure/table) in src)
		return FALSE
	if(locate(/obj/structure/falsewall) in contents)
		to_chat(user, "<span class='warning'>There is a false wall in the way, preventing you from proselytizing [src] into a clockwork wall.</span>")
		return
	if(is_blocked_turf(src, TRUE))
		to_chat(user, "<span class='warning'>Something is in the way, preventing you from proselytizing [src] into a clockwork wall.</span>")
		return TRUE
	var/operation_time = 100
	if(!GLOB.ratvar_awakens && proselytizer.speed_multiplier > 0) //if ratvar isn't awake, this always takes 10 seconds
		operation_time /= proselytizer.speed_multiplier
	return list("operation_time" = operation_time, "new_obj_type" = /turf/closed/wall/clockwork, "spawn_dir" = SOUTH)

//False wall conversion
/obj/structure/falsewall/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return list("operation_time" = 50, "new_obj_type" = /obj/structure/falsewall/brass, "spawn_dir" = SOUTH)

/obj/structure/falsewall/iron/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent) //two sheets of metal, two rods; special assumption
	return list("operation_time" = 50, "new_obj_type" = /obj/structure/falsewall/brass, "spawn_dir" = SOUTH)

/obj/structure/falsewall/reinforced/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

/obj/structure/falsewall/brass/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

//Airlock conversion
/obj/machinery/door/airlock/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	var/doortype = /obj/machinery/door/airlock/clockwork
	if(glass)
		doortype = /obj/machinery/door/airlock/clockwork/brass
	return list("operation_time" = 60, "new_obj_type" = doortype, "spawn_dir" = dir)

/obj/machinery/door/airlock/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

//Table conversion
/obj/structure/table/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	var/prosel_cost = POWER_STANDARD
	if(framestack == /obj/item/stack/rods)
		prosel_cost -= POWER_ROD*framestackamount
	else if(framestack == /obj/item/stack/tile/brass)
		prosel_cost -= POWER_FLOOR*framestackamount
	if(buildstack == /obj/item/stack/sheet/metal)
		prosel_cost -= POWER_METAL*buildstackamount
	else if(buildstack == /obj/item/stack/sheet/plasteel)
		prosel_cost -= POWER_PLASTEEL*buildstackamount
	return list("operation_time" = 20, "new_obj_type" = /obj/structure/table/reinforced/brass, "spawn_dir" = SOUTH)

/obj/structure/table/reinforced/brass/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

/obj/structure/table_frame/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	var/prosel_cost = POWER_FLOOR
	if(framestack == /obj/item/stack/rods)
		prosel_cost -= POWER_ROD*framestackamount
	else if(framestack == /obj/item/stack/tile/brass)
		prosel_cost -= POWER_FLOOR*framestackamount
	return list("operation_time" = 10, "new_obj_type" = /obj/structure/table_frame/brass, "spawn_dir" = SOUTH)

/obj/structure/table_frame/brass/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

//Window conversion
/obj/structure/window/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	var/windowtype = /obj/structure/window/reinforced/clockwork
	var/new_dir = TRUE
	var/prosel_time = 15
	if(fulltile)
		windowtype = /obj/structure/window/reinforced/clockwork/fulltile
		new_dir = FALSE
		prosel_time = 30
	for(var/obj/structure/grille/G in get_turf(src))
		INVOKE_ASYNC(proselytizer, /obj/item/clockwork/clockwork_proselytizer.proc/proselytize, G, user)
	return list("operation_time" = prosel_time, "new_obj_type" = windowtype, "spawn_dir" = dir, "dir_in_new" = new_dir)

/obj/structure/window/reinforced/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

//Windoor conversion
/obj/machinery/door/window/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return list("operation_time" = 30, "new_obj_type" = /obj/machinery/door/window/clockwork, "spawn_dir" = dir, "dir_in_new" = TRUE)

/obj/machinery/door/window/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

//Grille conversion
/obj/structure/grille/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	var/grilletype = /obj/structure/grille/ratvar
	var/prosel_time = 15
	if(broken)
		grilletype = /obj/structure/grille/ratvar/broken
		prosel_time = 5
	return list("operation_time" = prosel_time, "new_obj_type" = grilletype, "spawn_dir" = dir)

/obj/structure/grille/ratvar/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

//Lattice conversion
/obj/structure/lattice/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return list("operation_time" = 0, "new_obj_type" = /obj/structure/lattice/clockwork, "spawn_dir" = SOUTH, "no_target_deletion" = TRUE)

/obj/structure/lattice/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	ratvar_act() //just in case we're the wrong type for some reason??
	return FALSE

/obj/structure/lattice/catwalk/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return list("operation_time" = 0, "new_obj_type" = /obj/structure/lattice/catwalk/clockwork, "spawn_dir" = SOUTH, "no_target_deletion" = TRUE)

/obj/structure/lattice/catwalk/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return FALSE

//Girder conversion
/obj/structure/girder/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	return list("operation_time" = 20, "new_obj_type" = /obj/structure/destructible/clockwork/wall_gear,, "spawn_dir" = SOUTH)

//Hitting a clockwork structure will try to repair it.
/obj/structure/destructible/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	. = TRUE
	var/list/repair_values = list()
	if(!proselytizer.proselytizer_repair_checks(repair_values, src, user))
		return
	user.visible_message("<span class='notice'>[user]'s [proselytizer.name] starts covering [src] in glowing orange energy...</span>", \
	"<span class='alloy'>You start repairing [src]...</span>")
	proselytizer.repairing = src
	while(proselytizer && user && src)
		if(!do_after(user, PROSELYTIZER_REPAIR_RATE * proselytizer.speed_multiplier, target = src, \
			extra_checks = CALLBACK(proselytizer, /obj/item/clockwork/clockwork_proselytizer.proc/proselytizer_repair_checks, repair_values, src, user, TRUE)))
			break
		if(proselytizer.requires_resources)
			ADJUST_CLOCKWORK_WISDOM(-1)
		obj_integrity = Clamp(obj_integrity + repair_values["healing_for_cycle"], 0, max_integrity)
		playsound(src, 'sound/machines/click.ogg', 50, 1)

	if(proselytizer)
		proselytizer.repairing = null
		if(user)
			user.visible_message("<span class='notice'>[user]'s [proselytizer.name] stops covering [src] with glowing orange energy.</span>", \
			"<span class='alloy'>You finish repairing [src]. It is now at <b>[obj_integrity]/[max_integrity]</b> integrity.</span>")

//Proselytizer mob heal proc, to avoid as much copypaste as possible.
/mob/living/proc/proselytizer_heal(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/list/repair_values = list()
	if(!proselytizer.proselytizer_repair_checks(repair_values, src, user))
		return
	user.visible_message("<span class='notice'>[user]'s [proselytizer.name] starts coverin[src == user ? "g [user.p_them()]" : "g [src]"] in glowing orange energy...</span>", \
	"<span class='alloy'>You start repairin[src == user ? "g yourself" : "g [src]"]...</span>")
	proselytizer.repairing = src
	while(proselytizer && user && src)
		if(!do_after(user, repair_values["healing_for_cycle"] * proselytizer.speed_multiplier, target = src, \
			extra_checks = CALLBACK(proselytizer, /obj/item/clockwork/clockwork_proselytizer.proc/proselytizer_repair_checks, repair_values, src, user, TRUE)))
			break
		proselytizer_heal_tick(repair_values["healing_for_cycle"])
		playsound(src, 'sound/machines/click.ogg', 50, 1)

	if(proselytizer)
		proselytizer.repairing = null

	return TRUE

/mob/living/proc/proselytizer_heal_tick(amount)
	var/static/list/damage_heal_order = list(BRUTE, BURN, TOX, OXY)
	heal_ordered_damage(amount, damage_heal_order)

/mob/living/simple_animal/proselytizer_heal_tick(amount)
	adjustHealth(-amount)

//Hitting a ratvar'd silicon will also try to repair it.
/mob/living/silicon/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	. = TRUE
	if(health == maxHealth) //if we're at maximum health, prosel the turf under us
		return FALSE
	else if(proselytizer_heal(user, proselytizer) && user)
		user.visible_message("<span class='notice'>[user]'s [proselytizer.name] stops coverin[src == user ? "g [user.p_them()]" : "g [src]"] with glowing orange energy.</span>", \
		"<span class='alloy'>You finish repairin[src == user ? "g yourself. You are":"g [src]. [p_they(TRUE)] [p_are()]"] now at <b>[abs(HEALTH_THRESHOLD_DEAD - health)]/[abs(HEALTH_THRESHOLD_DEAD - maxHealth)]</b> health.</span>")

//Same with clockwork mobs.
/mob/living/simple_animal/hostile/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	. = TRUE
	if(health == maxHealth) //if we're at maximum health, prosel the turf under us
		return FALSE
	else if(proselytizer_heal(user, proselytizer) && user)
		user.visible_message("<span class='notice'>[user]'s [proselytizer.name] stops coverin[src == user ? "g [user.p_them()]" : "g [src]"] with glowing orange energy.</span>", \
		"<span class='alloy'>You finish repairin[src == user ? "g yourself. You are":"g [src]. [p_they(TRUE)] [p_are()]"] now at <b>[health]/[maxHealth]</b> health.</span>")

//Cogscarabs get special interaction because they're drones and have innate self-heals/revives.
/mob/living/simple_animal/drone/cogscarab/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer, silent)
	. = TRUE
	if(stat == DEAD)
		try_reactivate(user) //if we're at maximum health, prosel the turf under us
		return
	if(health == maxHealth)
		return FALSE
	else if(!(flags & GODMODE))
		user.visible_message("<span class='notice'>[user]'s [proselytizer.name] starts coverin[src == user ? "g [user.p_them()]" : "g [src]"] in glowing orange energy...</span>", \
		"<span class='alloy'>You start repairin[src == user ? "g yourself" : "g [src]"]...</span>")
		proselytizer.repairing = src
		if(do_after(user, (maxHealth - health)*2, target=src))
			adjustHealth(-maxHealth)
			user.visible_message("<span class='notice'>[user]'s [proselytizer.name] stops coverin[src == user ? "g [user.p_them()]" : "g [src]"] with glowing orange energy.</span>", \
			"<span class='alloy'>You finish repairin[src == user ? "g yourself" : "g [src]"].</span>")
		if(proselytizer)
			proselytizer.repairing = null
