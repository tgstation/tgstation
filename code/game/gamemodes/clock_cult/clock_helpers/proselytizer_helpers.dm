//For the clockwork proselytizer, this proc exists to make it easy to customize what the proselytizer does when hitting something.

//if a valid target, returns an associated list in this format;
//list("operation_time" = 15, "new_obj_type" = /obj/structure/window/reinforced/clockwork, "power_cost" = 5, "spawn_dir" = dir, "dir_in_new" = TRUE)
//otherwise, return literally any non-list thing but preferably FALSE
//returning TRUE won't produce the "cannot be proselytized" message and will still prevent proselytizing

/atom/proc/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Turf conversion
/turf/closed/wall/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer) //four sheets of metal
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_TOTAL - (POWER_METAL * 4), "spawn_dir" = SOUTH)

/turf/closed/wall/mineral/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer) //two sheets of metal
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_TOTAL - (POWER_METAL * 2), "spawn_dir" = SOUTH)

/turf/closed/wall/mineral/iron/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer) //two sheets of metal, five rods
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_TOTAL - (POWER_METAL * 2) - (POWER_ROD * 5), "spawn_dir" = SOUTH)

/turf/closed/wall/mineral/cult/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer) //no metal
	return list("operation_time" = 80, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_TOTAL, "spawn_dir" = SOUTH)

/turf/closed/wall/shuttle/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer) //two sheets of metal
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_TOTAL - (POWER_METAL * 2), "spawn_dir" = SOUTH)

/turf/closed/wall/r_wall/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/turf/closed/wall/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 50, "new_obj_type" = /turf/open/floor/clockwork, "power_cost" = -POWER_WALL_MINUS_FLOOR, "spawn_dir" = SOUTH)

/turf/open/floor/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(floor_tile == /obj/item/stack/tile/plasteel)
		PoolOrNew(floor_tile, src)
		make_plating()
		playsound(src, 'sound/items/Crowbar.ogg', 10, 1) //clink
	return list("operation_time" = 30, "new_obj_type" = /turf/open/floor/clockwork, "power_cost" = POWER_FLOOR, "spawn_dir" = SOUTH)

/turf/open/floor/plating/asteroid/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/turf/open/floor/plating/ashplanet/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/turf/open/floor/plating/lava/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/turf/open/floor/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(is_blocked_turf(src, TRUE))
		user << "<span class='warning'>Something is in the way, preventing you from proselytizing [src] into a clockwork wall.</span>"
		return TRUE
	return list("operation_time" = 100, "new_obj_type" = /turf/closed/wall/clockwork, "power_cost" = POWER_WALL_MINUS_FLOOR, "spawn_dir" = SOUTH)

//False wall conversion
/obj/structure/falsewall/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/cost = POWER_WALL_MINUS_FLOOR
	if(ispath(mineral, /obj/item/stack/sheet/metal))
		cost -= (POWER_METAL * (2 + mineral_amount)) //four sheets of metal, plus an assumption that the girder is also two
	else
		cost -= (POWER_METAL * 2) //anything that doesn't use metal just has the girder
	return list("operation_time" = 50, "new_obj_type" = /obj/structure/falsewall/brass, "power_cost" = cost, "spawn_dir" = SOUTH)

/obj/structure/falsewall/iron/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer) //two sheets of metal, two rods; special assumption
	return list("operation_time" = 50, "new_obj_type" = /obj/structure/falsewall/brass, "power_cost" = POWER_WALL_MINUS_FLOOR - (POWER_METAL * 2) - (POWER_ROD * 2), "spawn_dir" = SOUTH)

/obj/structure/falsewall/reinforced/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/obj/structure/falsewall/brass/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Metal conversion
/obj/item/stack/tile/plasteel/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(source)
		return FALSE
	var/amount_temp = get_amount()
	if(proselytizer.metal_to_power)
		var/no_delete = FALSE
		if(amount_temp < 2)
			user << "<span class='warning'>You need at least <b>2</b> floor tiles to convert into power.</span>"
			return TRUE
		if(IsOdd(amount_temp))
			amount_temp--
			no_delete = TRUE
			use(amount_temp)
		amount_temp *= 12.5 //each tile is 12.5 power so this is 2 tiles to 25 power
		return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -amount_temp, "spawn_dir" = SOUTH, "no_target_deletion" = no_delete)
	if(amount_temp >= 20)
		var/sheets_to_make = round(amount_temp * 0.05) //and 20 to 1 brass
		var/used = sheets_to_make * 20
		user.visible_message("<span class='warning'>[user]'s [proselytizer.name] rips into [src], converting it to brass!</span>", \
		"<span class='brass'>You convert [get_amount() - used > 0 ? "part of ":""][src] into brass...</span>")
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		new /obj/item/stack/tile/brass(get_turf(src), sheets_to_make)
		use(used)
	else
		user << "<span class='warning'>You need at least <b>20</b> floor tiles to convert into brass.</span>"
	return TRUE

/obj/item/stack/rods/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(source)
		return FALSE
	if(proselytizer.metal_to_power)
		return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -(amount*POWER_ROD), "spawn_dir" = SOUTH)
	if(get_amount() >= 10)
		var/sheets_to_make = round(get_amount() * 0.1)
		var/used = sheets_to_make * 10
		user.visible_message("<span class='warning'>[user]'s [proselytizer.name] rips into [src], converting it to brass!</span>", \
		"<span class='brass'>You convert [get_amount() - used > 0 ? "part of ":""][src] into brass...</span>")
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		new /obj/item/stack/tile/brass(get_turf(src), sheets_to_make)
		use(used)
	else
		user << "<span class='warning'>You need at least <b>10</b> rods to convert into brass.</span>"
	return TRUE

/obj/item/stack/sheet/metal/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(source)
		return FALSE
	if(proselytizer.metal_to_power)
		return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -(amount*POWER_METAL), "spawn_dir" = SOUTH)
	if(get_amount() >= 5)
		var/sheets_to_make = round(get_amount() * 0.2)
		var/used = sheets_to_make * 5
		user.visible_message("<span class='warning'>[user]'s [proselytizer.name] rips into [src], converting it to brass!</span>", \
		"<span class='brass'>You convert [get_amount() - used > 0 ? "part of ":""][src] into brass...</span>")
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		new /obj/item/stack/tile/brass(get_turf(src), sheets_to_make)
		use(used)
	else
		user << "<span class='warning'>You need at least <b>5</b> sheets of metal to convert into brass.</span>"
	return TRUE

/obj/item/stack/sheet/plasteel/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(source)
		return FALSE
	if(proselytizer.metal_to_power)
		return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -(amount*POWER_PLASTEEL), "spawn_dir" = SOUTH)
	if(get_amount() >= 2)
		var/sheets_to_make = round(get_amount() * 0.5)
		var/used = sheets_to_make * 2
		user.visible_message("<span class='warning'>[user]'s [proselytizer.name] rips into [src], converting it to brass!</span>", \
		"<span class='brass'>You convert [get_amount() - used > 0 ? "part of ":""][src] into brass...</span>")
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		new /obj/item/stack/tile/brass(get_turf(src), sheets_to_make)
		use(used)
	else
		user << "<span class='warning'>You need at least <b>2</b> sheets of plasteel to convert into brass.</span>"
	return TRUE

//Brass directly to power
/obj/item/stack/tile/brass/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(source)
		return FALSE
	return list("operation_time" = amount, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -(amount*POWER_FLOOR), "spawn_dir" = SOUTH)

//Airlock conversion
/obj/machinery/door/airlock/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/doortype = /obj/machinery/door/airlock/clockwork
	if(glass)
		doortype = /obj/machinery/door/airlock/clockwork/brass
	return list("operation_time" = 60, "new_obj_type" = doortype, "power_cost" = POWER_WALL_TOTAL, "spawn_dir" = dir)

/obj/machinery/door/airlock/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Window conversion
/obj/structure/window/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/windowtype = /obj/structure/window/reinforced/clockwork
	var/new_dir = TRUE
	var/prosel_time = 15
	var/prosel_cost = POWER_FLOOR
	if(fulltile)
		windowtype = /obj/structure/window/reinforced/clockwork/fulltile
		new_dir = FALSE
		prosel_time = 30
		prosel_cost = POWER_STANDARD
		if(reinf)
			prosel_cost -= POWER_ROD
	if(reinf)
		prosel_cost -= POWER_ROD
	for(var/obj/structure/grille/G in get_turf(src))
		addtimer(CALLBACK(proselytizer, /obj/item/clockwork/clockwork_proselytizer.proc/proselytize, G, user), 0)
	return list("operation_time" = prosel_time, "new_obj_type" = windowtype, "power_cost" = prosel_cost, "spawn_dir" = dir, "dir_in_new" = new_dir)

/obj/structure/window/reinforced/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Windoor conversion
/obj/machinery/door/window/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 30, "new_obj_type" = /obj/machinery/door/window/clockwork, "power_cost" = POWER_STANDARD, "spawn_dir" = dir, "dir_in_new" = TRUE)

/obj/machinery/door/window/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Grille conversion
/obj/structure/grille/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/grilletype = /obj/structure/grille/ratvar
	var/prosel_time = 15
	if(broken)
		grilletype = /obj/structure/grille/ratvar/broken
		prosel_time = 5
	return list("operation_time" = prosel_time, "new_obj_type" = grilletype, "power_cost" = 0, "spawn_dir" = dir)

/obj/structure/grille/ratvar/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

//Girder conversion
/obj/structure/girder/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/prosel_cost = POWER_GEAR - (POWER_METAL * 2)
	if(state == GIRDER_REINF_STRUTS || state == GIRDER_REINF)
		prosel_cost -= POWER_PLASTEEL
	return list("operation_time" = 20, "new_obj_type" = /obj/structure/destructible/clockwork/wall_gear, "power_cost" = prosel_cost, "spawn_dir" = SOUTH)

//Hitting a clockwork structure will try to repair it.
/obj/structure/destructible/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	. = TRUE
	if(!can_be_repaired)
		user << "<span class='warning'>[src] cannot be repaired!</span>"
		return
	if(obj_integrity >= max_integrity)
		user << "<span class='warning'>[src] is at maximum integrity!</span>"
		return
	var/amount_to_heal = max_integrity - obj_integrity
	var/healing_for_cycle = min(amount_to_heal, repair_amount)
	var/power_required = round(healing_for_cycle*MIN_CLOCKCULT_POWER, MIN_CLOCKCULT_POWER)
	if(!healing_for_cycle || (!proselytizer.can_use_power(RATVAR_POWER_CHECK) && !proselytizer.can_use_power(power_required)))
		user << "<span class='warning'>You need at least <b>[power_required]W</b> power to start repairing [src], and at least \
		<b>[round(amount_to_heal*MIN_CLOCKCULT_POWER, MIN_CLOCKCULT_POWER)]W</b> to fully repair it!</span>"
		return
	user.visible_message("<span class='notice'>[user]'s [proselytizer.name] starts covering [src] in glowing orange energy...</span>", \
	"<span class='alloy'>You start repairing [src]...</span>")
	//hugeass while because we need to re-check after the do_after
	proselytizer.repairing = src
	while(proselytizer && user && src && obj_integrity < max_integrity)
		amount_to_heal = max_integrity - obj_integrity
		if(amount_to_heal <= 0)
			break
		healing_for_cycle = min(amount_to_heal, repair_amount)
		power_required = round(healing_for_cycle*MIN_CLOCKCULT_POWER, MIN_CLOCKCULT_POWER)
		if(!healing_for_cycle || (!proselytizer.can_use_power(RATVAR_POWER_CHECK) && !proselytizer.can_use_power(power_required)) || \
		!do_after(user, healing_for_cycle * proselytizer.speed_multiplier, target = src) || \
		!proselytizer || (!proselytizer.can_use_power(RATVAR_POWER_CHECK) && !proselytizer.can_use_power(power_required)))
			break
		amount_to_heal = max_integrity - obj_integrity
		if(amount_to_heal <= 0)
			break
		healing_for_cycle = min(amount_to_heal, repair_amount)
		power_required = round(healing_for_cycle*MIN_CLOCKCULT_POWER, MIN_CLOCKCULT_POWER)
		if(!healing_for_cycle || (!proselytizer.can_use_power(RATVAR_POWER_CHECK) && !proselytizer.can_use_power(power_required)))
			break
		obj_integrity = Clamp(obj_integrity + healing_for_cycle, 0, max_integrity)
		proselytizer.modify_stored_power(-power_required)
		playsound(src, 'sound/machines/click.ogg', 50, 1)

	if(proselytizer)
		proselytizer.repairing = null
		if(user)
			user.visible_message("<span class='notice'>[user]'s [proselytizer.name] stops covering [src] with glowing orange energy.</span>", \
			"<span class='alloy'>You finish repairing [src]. It is now at <b>[obj_integrity]/[max_integrity]</b> integrity.</span>")

//Convert shards and replicant alloy directly to liquid alloy
/obj/item/clockwork/alloy_shards/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -POWER_STANDARD, "spawn_dir" = SOUTH)

/obj/item/clockwork/alloy_shards/medium/gear_bit/large/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -(CLOCKCULT_POWER_UNIT*0.08), "spawn_dir" = SOUTH)

/obj/item/clockwork/alloy_shards/large/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -(CLOCKCULT_POWER_UNIT*0.06), "spawn_dir" = SOUTH)

/obj/item/clockwork/alloy_shards/medium/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -(CLOCKCULT_POWER_UNIT*0.04), "spawn_dir" = SOUTH)

/obj/item/clockwork/alloy_shards/small/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -(CLOCKCULT_POWER_UNIT*0.02), "spawn_dir" = SOUTH)

/obj/item/clockwork/component/replicant_alloy/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "power_cost" = -CLOCKCULT_POWER_UNIT, "spawn_dir" = SOUTH)
