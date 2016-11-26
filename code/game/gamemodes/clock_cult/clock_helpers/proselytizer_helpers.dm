//For the clockwork proselytizer, this proc exists to make it easy to customize what the proselytizer does when hitting something.

//if a valid target, returns an associated list in this format;
//list("operation_time" = 15, "new_obj_type" = /obj/structure/window/reinforced/clockwork, "alloy_cost" = 5, "spawn_dir" = dir, "dir_in_new" = TRUE)
//otherwise, return literally any non-list thing but preferably FALSE
//returning TRUE won't produce the "cannot be proselytized" message and will still prevent proselytizing

/atom/proc/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Turf conversion
/turf/closed/wall/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "alloy_cost" = REPLICANT_WALL_TOTAL, "spawn_dir" = SOUTH)

/turf/closed/wall/r_wall/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/turf/closed/wall/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 50, "new_obj_type" = /turf/open/floor/clockwork, "alloy_cost" = -REPLICANT_WALL_MINUS_FLOOR, "spawn_dir" = SOUTH)

/turf/open/floor/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 30, "new_obj_type" = /turf/open/floor/clockwork, "alloy_cost" = REPLICANT_FLOOR, "spawn_dir" = SOUTH)

/turf/open/floor/plating/asteroid/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/turf/open/floor/plating/ashplanet/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/turf/open/floor/plating/lava/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/turf/open/floor/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	for(var/obj/O in src)
		if(O.density && !O.CanPass(user, src, 5))
			user << "<span class='warning'>Something is in the way, preventing you from proselytizing [src] into a clockwork wall.</span>"
			return FALSE
	return list("operation_time" = 100, "new_obj_type" = /turf/closed/wall/clockwork, "alloy_cost" = REPLICANT_WALL_MINUS_FLOOR, "spawn_dir" = SOUTH)

//Metal conversion
/obj/item/stack/rods/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(get_amount() >= 10)
		var/sheets_to_make = round(get_amount() * 0.1)
		var/used = sheets_to_make * 10
		user.visible_message("<span class='warning'>[user]'s [proselytizer.name] rips into [src], converting it to brass!</span>", \
		"<span class='brass'>You convert [get_amount() - used > 0 ? "part of ":""][src] into brass...</span>")
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		new /obj/item/stack/sheet/brass(get_turf(src), sheets_to_make)
		use(used)
	else
		user << "<span class='warning'>You need at least 10 rods to convert into brass.</span>"
	return TRUE

/obj/item/stack/sheet/metal/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(get_amount() >= 5)
		var/sheets_to_make = round(get_amount() * 0.2)
		var/used = sheets_to_make * 5
		user.visible_message("<span class='warning'>[user]'s [proselytizer.name] rips into [src], converting it to brass!</span>", \
		"<span class='brass'>You convert [get_amount() - used > 0 ? "part of ":""][src] into brass...</span>")
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		new /obj/item/stack/sheet/brass(get_turf(src), sheets_to_make)
		use(used)
	else
		user << "<span class='warning'>You need at least 5 sheets of metal to convert into brass.</span>"
	return TRUE

/obj/item/stack/sheet/plasteel/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(get_amount() >= 2)
		var/sheets_to_make = round(get_amount() * 0.5)
		var/used = sheets_to_make * 2
		user.visible_message("<span class='warning'>[user]'s [proselytizer.name] rips into [src], converting it to brass!</span>", \
		"<span class='brass'>You convert [get_amount() - used > 0 ? "part of ":""][src] into brass...</span>")
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		new /obj/item/stack/sheet/brass(get_turf(src), sheets_to_make)
		use(used)
	else
		user << "<span class='warning'>You need at least 2 sheets of plasteel to convert into brass.</span>"
	return TRUE

//Brass directly to alloy; scarab only
/obj/item/stack/sheet/brass/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(!proselytizer.metal_to_alloy)
		return FALSE
	var/prosel_cost = -amount*REPLICANT_FLOOR
	var/prosel_time = -amount
	return list("operation_time" = -prosel_time, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "alloy_cost" = prosel_cost, "spawn_dir" = SOUTH)

//Airlock conversion
/obj/machinery/door/airlock/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/doortype = /obj/machinery/door/airlock/clockwork
	if(glass)
		doortype = /obj/machinery/door/airlock/clockwork/brass
	return list("operation_time" = 60, "new_obj_type" = doortype, "alloy_cost" = REPLICANT_WALL_TOTAL, "spawn_dir" = dir)

/obj/machinery/door/airlock/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Window conversion
/obj/structure/window/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/windowtype = /obj/structure/window/reinforced/clockwork
	var/new_dir = TRUE
	var/prosel_time = 15
	var/prosel_cost = REPLICANT_FLOOR
	if(fulltile)
		windowtype = /obj/structure/window/reinforced/clockwork/fulltile
		new_dir = FALSE
		prosel_time = 30
		prosel_cost = REPLICANT_STANDARD
	return list("operation_time" = prosel_time, "new_obj_type" = windowtype, "alloy_cost" = prosel_cost, "spawn_dir" = dir, "dir_in_new" = new_dir)

/obj/structure/window/reinforced/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Windoor conversion
/obj/machinery/door/window/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 30, "new_obj_type" = /obj/machinery/door/window/clockwork, "alloy_cost" = REPLICANT_STANDARD, "spawn_dir" = dir, "dir_in_new" = TRUE)

/obj/machinery/door/window/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Grille conversion
/obj/structure/grille/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/grilletype = /obj/structure/grille/ratvar
	var/prosel_time = 15
	if(broken)
		grilletype = /obj/structure/grille/ratvar/broken
		prosel_time = 5
	return list("operation_time" = prosel_time, "new_obj_type" = grilletype, "alloy_cost" = 0, "spawn_dir" = dir)

/obj/structure/grille/ratvar/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Girder conversion
/obj/structure/girder/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 20, "new_obj_type" = /obj/structure/destructible/clockwork/wall_gear, "alloy_cost" = REPLICANT_GEAR, "spawn_dir" = SOUTH)

//Hitting a clockwork structure will try to repair it.
/obj/structure/destructible/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	. = TRUE
	if(!can_be_repaired)
		user << "<span class='warning'>[src] cannot be repaired with a proselytizer!</span>"
		return
	if(obj_integrity >= max_integrity)
		user << "<span class='warning'>[src] is at maximum integrity!</span>"
		return
	var/amount_to_heal = max_integrity - obj_integrity
	var/healing_for_cycle = min(amount_to_heal, repair_amount)
	var/proselytizer_cost = 0
	if(!proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK))
		healing_for_cycle = min(healing_for_cycle, proselytizer.stored_alloy * 0.5)
		proselytizer_cost = healing_for_cycle * 2
	if(!proselytizer.can_use_alloy(proselytizer_cost))
		user << "<span class='warning'>You need more liquified alloy to repair [src]!</span>"
		return
	user.visible_message("<span class='notice'>[user]'s [proselytizer.name] starts covering [src] in black liquid metal...</span>", \
	"<span class='alloy'>You start repairing [src]...</span>")
	//hugeass while because we need to re-check after the do_after
	proselytizer.repairing = src
	while(proselytizer && user && src && obj_integrity != max_integrity)
		amount_to_heal = max_integrity - obj_integrity
		if(amount_to_heal <= 0)
			break
		healing_for_cycle = min(amount_to_heal, repair_amount)
		if(!proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK))
			healing_for_cycle = min(healing_for_cycle, proselytizer.stored_alloy * 0.5)
			proselytizer_cost = healing_for_cycle * 2
			if(!proselytizer.can_use_alloy(proselytizer_cost))
				break
		else
			proselytizer_cost = 0
		if(!proselytizer.can_use_alloy(proselytizer_cost) || !do_after(user, proselytizer_cost, target = src) || !proselytizer || !proselytizer.can_use_alloy(proselytizer_cost))
			break
		amount_to_heal = max_integrity - obj_integrity
		if(amount_to_heal <= 0)
			break
		healing_for_cycle = min(amount_to_heal, repair_amount)
		if(!proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK))
			healing_for_cycle = min(healing_for_cycle, proselytizer.stored_alloy * 0.5)
			proselytizer_cost = healing_for_cycle * 2
			if(!proselytizer.can_use_alloy(proselytizer_cost))
				break
		else
			proselytizer_cost = 0
		obj_integrity = Clamp(obj_integrity + healing_for_cycle, 0, max_integrity)
		proselytizer.modify_stored_alloy(-proselytizer_cost)
		playsound(src, 'sound/machines/click.ogg', 50, 1)

	if(proselytizer)
		proselytizer.repairing = null
		if(user)
			user.visible_message("<span class='notice'>[user]'s [proselytizer.name] stops covering [src] with black liquid metal.</span>", \
		"<span class='alloy'>You finish repairing [src]. It is now at <b>[obj_integrity]/[max_integrity]</b> integrity.</span>")
	return

//Hitting a tinkerer's cache will try to fill the proselytizer with alloy after trying to repair.
/obj/structure/destructible/clockwork/cache/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	. = ..()
	if(proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK) || proselytizer.stored_alloy + REPLICANT_ALLOY_UNIT > proselytizer.max_alloy)
		user << "<span class='warning'>[proselytizer]'s containers of liquified alloy are full!</span>"
		return
	if(!clockwork_component_cache["replicant_alloy"])
		user << "<span class='warning'>There is no Replicant Alloy in the global component cache!</span>"
		return
	proselytizer.refueling = TRUE
	user.visible_message("<span class='notice'>[user] places the end of [proselytizer] in the hole in [src]...</span>", \
	"<span class='notice'>You start filling [proselytizer] with liquified alloy...</span>")
	//hugeass check because we need to re-check after the do_after
	while(proselytizer && !proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK) && proselytizer.stored_alloy + REPLICANT_ALLOY_UNIT <= proselytizer.max_alloy && clockwork_component_cache["replicant_alloy"] \
	&& do_after(user, 10, target = src) \
	&& proselytizer && !proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK) &&  proselytizer.stored_alloy + REPLICANT_ALLOY_UNIT <= proselytizer.max_alloy && clockwork_component_cache["replicant_alloy"])
		proselytizer.modify_stored_alloy(REPLICANT_ALLOY_UNIT)
		clockwork_component_cache["replicant_alloy"]--
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
	if(proselytizer)
		proselytizer.refueling = FALSE
		if(user)
			user.visible_message("<span class='notice'>[user] removes [proselytizer] from the hole in [src], apparently satisfied.</span>", \
		"<span class='brass'>You finish filling [proselytizer] with liquified alloy. It now contains <b>[proselytizer.stored_alloy]/[proselytizer.max_alloy]</b> units of liquified alloy.</span>")
	return

//convert wall gears back to brass sheets
/obj/structure/destructible/clockwork/wall_gear/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 10, "new_obj_type" = /obj/item/stack/sheet/brass, "alloy_cost" = 0, "spawn_dir" = 3, "dir_in_new" = TRUE)

//Convert shards and replicant alloy directly to liquid alloy
/obj/item/clockwork/alloy_shards/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 5, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "alloy_cost" = -REPLICANT_STANDARD, "spawn_dir" = SOUTH)

/obj/item/clockwork/alloy_shards/large/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 2, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "alloy_cost" = -(REPLICANT_ALLOY_UNIT*0.06), "spawn_dir" = SOUTH)

/obj/item/clockwork/alloy_shards/medium/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 1, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "alloy_cost" = -(REPLICANT_ALLOY_UNIT*0.04), "spawn_dir" = SOUTH)

/obj/item/clockwork/alloy_shards/small/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "alloy_cost" = -(REPLICANT_ALLOY_UNIT*0.02), "spawn_dir" = SOUTH)

/obj/item/clockwork/component/replicant_alloy/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "alloy_cost" = -REPLICANT_ALLOY_UNIT, "spawn_dir" = SOUTH)
