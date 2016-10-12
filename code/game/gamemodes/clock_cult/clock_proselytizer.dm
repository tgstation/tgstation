
/obj/item/clockwork/clockwork_proselytizer //Clockwork proselytizer (yes, that's a real word): Converts applicable objects to Ratvarian variants.
	name = "clockwork proselytizer"
	desc = "An odd, L-shaped device that hums with energy."
	clockwork_desc = "A device that allows the replacing of mundane objects with Ratvarian variants. It requires liquified Replicant Alloy to function."
	icon_state = "clockwork_proselytizer"
	w_class = 3
	force = 5
	flags = NOBLUDGEON
	var/stored_alloy = 0 //Requires this to function; each chunk of replicant alloy provides REPLICANT_ALLOY_UNIT
	var/max_alloy = REPLICANT_ALLOY_UNIT * 10
	var/uses_alloy = TRUE
	var/metal_to_alloy = FALSE
	var/repairing = null //what we're currently repairing, if anything

/obj/item/clockwork/clockwork_proselytizer/preloaded
	stored_alloy = REPLICANT_WALL_MINUS_FLOOR+REPLICANT_WALL_TOTAL

/obj/item/clockwork/clockwork_proselytizer/scarab
	name = "scarab proselytizer"
	clockwork_desc = "A cogscarab's internal proselytizer. It can only be successfully used by a cogscarab and requires liquified Replicant Alloy to function."
	metal_to_alloy = TRUE
	item_state = "nothing"
	w_class = 1
	var/debug = FALSE

/obj/item/clockwork/clockwork_proselytizer/scarab/proselytize(atom/target, mob/living/user)
	if(!debug && !isdrone(user))
		return 0
	return ..()

/obj/item/clockwork/clockwork_proselytizer/scarab/debug
	clockwork_desc = "A cogscarab's internal proselytizer. It can convert nearly any object into a Ratvarian variant."
	uses_alloy = FALSE
	debug = TRUE

/obj/item/clockwork/clockwork_proselytizer/examine(mob/living/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='brass'>Can be used to convert walls, floors, windows, airlocks, windoors, and grilles to clockwork variants.</span>"
		user << "<span class='brass'>Can also form some objects into Replicant Alloy, as well as reform Clockwork Walls into Clockwork Floors, and vice versa.</span>"
		if(metal_to_alloy)
			user << "<span class='alloy'>It can convert rods, metal, and plasteel to liquified replicant alloy at a low rate.</span>"
		if(uses_alloy)
			user << "<span class='alloy'>It has <b>[stored_alloy]/[max_alloy]</b> units of liquified alloy stored.</span>"
			user << "<span class='alloy'>Use it on a Tinkerer's Cache, strike it with Replicant Alloy, or attack Replicant Alloy with it to add additional liquified alloy.</span>"
			user << "<span class='alloy'>Use it in-hand to remove stored liquified alloy.</span>"

/obj/item/clockwork/clockwork_proselytizer/attack_self(mob/living/user)
	if(is_servant_of_ratvar(user) && uses_alloy)
		if(!can_use_alloy(REPLICANT_ALLOY_UNIT))
			user << "<span class='warning'>[src] [stored_alloy ? "Lacks enough":"Contains no"] alloy to reform[stored_alloy ? "":" any"] into solidified alloy!</span>"
			return
		modify_stored_alloy(-REPLICANT_ALLOY_UNIT)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		new/obj/item/clockwork/component/replicant_alloy(user.loc)
		user << "<span class='brass'>You force [stored_alloy ? "some":"all"] of the alloy in [src]'s compartments to reform and solidify. \
		It now contains <b>[stored_alloy]/[max_alloy]</b> units of liquified alloy.</span>"

/obj/item/clockwork/clockwork_proselytizer/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/clockwork/component/replicant_alloy) && is_servant_of_ratvar(user) && uses_alloy)
		if(!can_use_alloy(-REPLICANT_ALLOY_UNIT))
			user << "<span class='warning'>[src]'s replicant alloy compartments are full!</span>"
			return 0
		modify_stored_alloy(REPLICANT_ALLOY_UNIT)
		playsound(user, 'sound/machines/click.ogg', 50, 1)
		user << "<span class='brass'>You force [I] to liquify and pour it into [src]'s compartments. It now contains <b>[stored_alloy]/[max_alloy]</b> units of liquified alloy.</span>"
		user.drop_item()
		qdel(I)
		return 1
	else
		return ..()

/obj/item/clockwork/clockwork_proselytizer/afterattack(atom/target, mob/living/user, proximity_flag, params)
	if(!target || !user || !proximity_flag)
		return 0
	if(!is_servant_of_ratvar(user))
		return ..()
	proselytize(target, user)

/obj/item/clockwork/clockwork_proselytizer/proc/modify_stored_alloy(amount)
	if(can_use_alloy(RATVAR_ALLOY_CHECK)) //Ratvar makes it free
		amount = 0
	stored_alloy = Clamp(stored_alloy + amount, 0, max_alloy)
	return 1

/obj/item/clockwork/clockwork_proselytizer/proc/can_use_alloy(amount)
	if(amount == RATVAR_ALLOY_CHECK)
		if(ratvar_awakens || !uses_alloy)
			return TRUE
		else
			return FALSE
	if(stored_alloy - amount < 0)
		return FALSE
	if(stored_alloy - amount > max_alloy)
		return FALSE
	return TRUE

/obj/item/clockwork/clockwork_proselytizer/proc/proselytize(atom/target, mob/living/user)
	if(!target || !user)
		return 0
	var/target_type = target.type
	var/list/proselytize_values = target.proselytize_vals(user, src) //relevant values for proselytizing stuff, given as an associated list
	if(!islist(proselytize_values))
		if(proselytize_values != TRUE) //if we get true, fail, but don't send a message for whatever reason
			user << "<span class='warning'>[target] cannot be proselytized!</span>"
		return 0
	if(repairing)
		user << "<span class='warning'>You are currently repairing [repairing] with [src]!</span>"
		return 0
	if(!uses_alloy)
		proselytize_values["alloy_cost"] = 0

	if(!can_use_alloy(proselytize_values["alloy_cost"]))
		if(stored_alloy - proselytize_values["alloy_cost"] < 0)
			user << "<span class='warning'>You need <b>[proselytize_values["alloy_cost"]]</b> liquified alloy to proselytize [target]!</span>"
		else if(stored_alloy - proselytize_values["alloy_cost"] > max_alloy)
			user << "<span class='warning'>You have too much liquified alloy stored to proselytize [target]!</span>"
		return 0

	if(can_use_alloy(RATVAR_ALLOY_CHECK)) //Ratvar makes it faster
		proselytize_values["operation_time"] *= 0.5

	user.visible_message("<span class='warning'>[user]'s [name] begins tearing apart [target]!</span>", "<span class='brass'>You begin proselytizing [target]...</span>")
	playsound(target, 'sound/machines/click.ogg', 50, 1)
	if(proselytize_values["operation_time"] && !do_after(user, proselytize_values["operation_time"], target = target))
		return 0
	if(!can_use_alloy(proselytize_values["alloy_cost"])) //Check again to prevent bypassing via spamclick
		return 0
	if(!target || target.type != target_type)
		return 0
	if(repairing)
		return 0
	user.visible_message("<span class='warning'>[user]'s [name] disgorges a chunk of metal and shapes it over what's left of [target]!</span>", \
	"<span class='brass'>You proselytize [target].</span>")
	playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
	var/new_thing_type = proselytize_values["new_obj_type"]
	if(isturf(target))
		var/turf/T = target
		T.ChangeTurf(new_thing_type)
	else
		if(proselytize_values["dir_in_new"])
			new new_thing_type(get_turf(target), proselytize_values["spawn_dir"])
		else
			var/atom/A = new new_thing_type(get_turf(target))
			A.setDir(proselytize_values["spawn_dir"])
		qdel(target)
	modify_stored_alloy(-proselytize_values["alloy_cost"])
	return 1

//if a valid target, returns an associated list in this format;
//list("operation_time" = 15, "new_obj_type" = /obj/structure/window/reinforced/clockwork, "alloy_cost" = 5, "spawn_dir" = dir, "dir_in_new" = TRUE)
//otherwise, return literally any non-list thing but preferably FALSE
//returning TRUE won't produce the "cannot be proselytized" message and will still prevent proselytizing

/atom/proc/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

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

/obj/item/stack/rods/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(get_amount() >= 10)
		var/sheets_to_make = round(get_amount() * 0.1)
		var/remainder = get_amount() - (sheets_to_make * 10)
		if(remainder)
			new type(loc, remainder)
		return list("operation_time" = 0, "new_obj_type" = /obj/item/stack/sheet/brass, "alloy_cost" = 0, "spawn_dir" = sheets_to_make, "dir_in_new" = TRUE)
	else
		user << "<span class='warning'>You need at least 10 rods to convert into brass.</span>"
		return TRUE

/obj/item/stack/sheet/metal/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(src.get_amount() >= 5)
		var/sheets_to_make = round(src.get_amount() * 0.2)
		var/remainder = src.get_amount() - (sheets_to_make * 5)
		if(remainder)
			new type(loc, remainder)
		return list("operation_time" = 0, "new_obj_type" = /obj/item/stack/sheet/brass, "alloy_cost" = 0, "spawn_dir" = sheets_to_make, "dir_in_new" = TRUE)
	else
		user << "<span class='warning'>You need at least 5 sheets of metal to convert into brass.</span>"
		return TRUE

/obj/item/stack/sheet/plasteel/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(get_amount() >= 10)
		var/sheets_to_make = round(get_amount() * 0.4)
		var/remainder = get_amount() - (sheets_to_make * 2.5)
		if(remainder)
			new type(loc, remainder)
		return list("operation_time" = 0, "new_obj_type" = /obj/item/stack/sheet/brass, "alloy_cost" = 0, "spawn_dir" = sheets_to_make, "dir_in_new" = TRUE)
	else
		user << "<span class='warning'>You need at least 10 sheets of plasteel to convert into brass.</span>"
		return TRUE

/obj/item/stack/sheet/brass/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	if(!proselytizer.metal_to_alloy)
		return FALSE
	var/prosel_cost = -amount*10
	var/prosel_time = -amount*1
	return list("operation_time" = -prosel_time, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "alloy_cost" = prosel_cost, "spawn_dir" = SOUTH)

/obj/machinery/door/airlock/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/doortype = /obj/machinery/door/airlock/clockwork
	if(glass)
		doortype = /obj/machinery/door/airlock/clockwork/brass
	return list("operation_time" = 40, "new_obj_type" = doortype, "alloy_cost" = REPLICANT_WALL_TOTAL, "spawn_dir" = dir)

/obj/machinery/door/airlock/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

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

/obj/machinery/door/window/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 30, "new_obj_type" = /obj/machinery/door/window/clockwork, "alloy_cost" = REPLICANT_STANDARD, "spawn_dir" = dir, "dir_in_new" = TRUE)

/obj/machinery/door/window/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/obj/structure/grille/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	var/grilletype = /obj/structure/grille/ratvar
	var/prosel_time = 15
	if(broken)
		grilletype = /obj/structure/grille/ratvar/broken
		prosel_time = 5
	return list("operation_time" = prosel_time, "new_obj_type" = grilletype, "alloy_cost" = 0, "spawn_dir" = dir)

/obj/structure/grille/ratvar/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return FALSE

/obj/structure/destructible/clockwork/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	. = TRUE
	if(proselytizer.repairing) //no spamclicking for fast repairs, bucko
		user << "<span class='warning'>You are already repairing [proselytizer.repairing] with [proselytizer]!</span>"
		return
	if(!can_be_repaired)
		user << "<span class='warning'>[src] cannot be repaired with a proselytizer!</span>"
		return
	if(obj_integrity == max_integrity)
		user << "<span class='warning'>[src] is at maximum integrity!</span>"
		return
	var/amount_to_heal = max_integrity - obj_integrity
	var/healing_for_cycle = min(amount_to_heal, repair_amount)
	if(!proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK))
		healing_for_cycle = min(healing_for_cycle, proselytizer.stored_alloy)
	var/proselytizer_cost = healing_for_cycle*2
	if(!proselytizer.can_use_alloy(proselytizer_cost))
		user << "<span class='warning'>You need more liquified alloy to repair [src]!</span>"
		return
	user.visible_message("<span class='notice'>[user]'s [proselytizer.name] starts covering [src] in black liquid metal...</span>", \
	"<span class='alloy'>You start repairing [src]...</span>")
	//hugeass while because we need to re-check after the do_after
	proselytizer.repairing = src
	while(proselytizer && user && src && obj_integrity != max_integrity)
		amount_to_heal = max_integrity - obj_integrity
		if(!amount_to_heal)
			break
		healing_for_cycle = min(amount_to_heal, repair_amount)
		if(!proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK))
			healing_for_cycle = min(healing_for_cycle, proselytizer.stored_alloy)
		proselytizer_cost = healing_for_cycle*2
		if(!proselytizer.can_use_alloy(proselytizer_cost) || !do_after(user, proselytizer_cost, target = src) || !proselytizer || !proselytizer.can_use_alloy(proselytizer_cost))
			break
		amount_to_heal = max_integrity - obj_integrity
		if(!amount_to_heal)
			break
		healing_for_cycle = min(amount_to_heal, repair_amount)
		if(!proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK))
			healing_for_cycle = min(healing_for_cycle, proselytizer.stored_alloy)
		proselytizer_cost = healing_for_cycle*2
		if(!proselytizer.can_use_alloy(proselytizer_cost))
			break
		obj_integrity += healing_for_cycle
		proselytizer.modify_stored_alloy(-proselytizer_cost)
		playsound(src, 'sound/machines/click.ogg', 50, 1)

	if(proselytizer)
		proselytizer.repairing = null
		if(user)
			user.visible_message("<span class='notice'>[user]'s [proselytizer.name] stops covering [src] with black liquid metal.</span>", \
		"<span class='alloy'>You finish repairing [src]. It is now at <b>[obj_integrity]/[max_integrity]</b> integrity.</span>")
	return

/obj/structure/destructible/clockwork/cache/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	. = ..()
	if(proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK) || proselytizer.stored_alloy + REPLICANT_ALLOY_UNIT > proselytizer.max_alloy)
		user << "<span class='warning'>[proselytizer]'s containers of liquified alloy are full!</span>"
		return
	if(!clockwork_component_cache["replicant_alloy"])
		user << "<span class='warning'>There is no Replicant Alloy in the global component cache!</span>"
		return
	user.visible_message("<span class='notice'>[user] places the end of [proselytizer] in the hole in [src]...</span>", \
	"<span class='notice'>You start filling [proselytizer] with liquified alloy...</span>")
	//hugeass check because we need to re-check after the do_after
	while(proselytizer && !proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK) && proselytizer.stored_alloy + REPLICANT_ALLOY_UNIT <= proselytizer.max_alloy && clockwork_component_cache["replicant_alloy"] \
	&& do_after(user, 10, target = src) \
	&& proselytizer && !proselytizer.can_use_alloy(RATVAR_ALLOY_CHECK) &&  proselytizer.stored_alloy + REPLICANT_ALLOY_UNIT <= proselytizer.max_alloy && clockwork_component_cache["replicant_alloy"])
		proselytizer.modify_stored_alloy(REPLICANT_ALLOY_UNIT)
		clockwork_component_cache["replicant_alloy"]--
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
	if(proselytizer && user)
		user.visible_message("<span class='notice'>[user] removes [proselytizer] from the hole in [src], apparently satisfied.</span>", \
		"<span class='brass'>You finish filling [proselytizer] with liquified alloy. It now contains <b>[proselytizer.stored_alloy]/[proselytizer.max_alloy]</b> units of liquified alloy.</span>")
	return

/obj/structure/destructible/clockwork/wall_gear/proselytize_vals(mob/living/user, obj/item/clockwork/clockwork_proselytizer/proselytizer)
	return list("operation_time" = 10, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "alloy_cost" = -REPLICANT_GEAR, "spawn_dir" = SOUTH)

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
