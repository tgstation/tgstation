
/obj/item/clockwork/clockwork_proselytizer //Clockwork proselytizer (yes, that's a real word): Converts applicable objects to Ratvarian variants.
	name = "clockwork proselytizer"
	desc = "An odd, L-shaped device that hums with energy."
	clockwork_desc = "A device that allows the replacing of mundane objects with Ratvarian variants. It requires liquified replicant alloy to function."
	icon_state = "clockwork_proselytizer"
	item_state = "resonator_u"
	w_class = 3
	force = 5
	flags = NOBLUDGEON
	var/stored_alloy = 0 //Requires this to function; each chunk of replicant alloy provides 10 charge
	var/max_alloy = 100
	var/uses_alloy = TRUE

/obj/item/clockwork/clockwork_proselytizer/preloaded
	stored_alloy = 25

/obj/item/clockwork/clockwork_proselytizer/examine(mob/living/user)
	..()
	if((is_servant_of_ratvar(user) || isobserver(user)) && uses_alloy)
		user << "<span class='alloy'>It has [stored_alloy]/[max_alloy] units of liquified replicant alloy stored.</span>"
		user << "<span class='alloy'>Strike it with replicant alloy or attack replicant alloy with it to add additional alloy.</span>"

/obj/item/clockwork/clockwork_proselytizer/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/clockwork/component/replicant_alloy) && is_servant_of_ratvar(user) && uses_alloy)
		if(stored_alloy >= max_alloy)
			user << "<span class='warning'>[src]'s replicant alloy compartments are full!</span>"
			return 0
		modify_stored_alloy(10)
		user << "<span class='brass'>You force [I] to liquify and pour it into [src]'s compartments. It now contains [stored_alloy]/[max_alloy] units of liquified alloy.</span>"
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
	if(ratvar_awakens) //Ratvar makes it free
		amount = 0
	stored_alloy = Clamp(stored_alloy + amount, 0, max_alloy)
	return 1

/obj/item/clockwork/clockwork_proselytizer/proc/proselytize(atom/target, mob/living/user)
	if(!target || !user)
		return 0
	var/target_type = target.type
	var/list/proselytize_values = target.proselytize_vals(user) //relevant values for proselytizing stuff, given as an associated list
	if(!islist(proselytize_values))
		user << "<span class='warning'>[target] cannot be proselytized!</span>"
		return 0

	if(!uses_alloy)
		proselytize_values["alloy_cost"] = 0

	if(stored_alloy - proselytize_values["alloy_cost"] < 0)
		user << "<span class='warning'>You need [proselytize_values["alloy_cost"]] replicant alloy to proselytize [target]!</span>"
		return 0
	if(stored_alloy - proselytize_values["alloy_cost"] > 100)
		user << "<span class='warning'>You have too much replicant alloy stored to proselytize [target]!</span>"
		return 0

	if(ratvar_awakens) //Ratvar makes it faster
		proselytize_values["operation_time"] *= 0.5

	user.visible_message("<span class='warning'>[user]'s [name] begins tearing apart [target]!</span>", "<span class='brass'>You begin proselytizing [target]...</span>")
	playsound(target, 'sound/machines/click.ogg', 50, 1)
	if(proselytize_values["operation_time"] && !do_after(user, proselytize_values["operation_time"], target = target))
		return 0
	if(stored_alloy - proselytize_values["alloy_cost"] < 0) //Check again to prevent bypassing via spamclick
		return 0
	if(stored_alloy - proselytize_values["alloy_cost"] > 100)
		return 0
	if(!target || target.type != target_type)
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

/atom/proc/proselytize_vals(mob/living/proselytizer)
	return FALSE

/turf/closed/wall/proselytize_vals(mob/living/proselytizer)
	return list("operation_time" = 50, "new_obj_type" = /turf/closed/wall/clockwork, "alloy_cost" = 5, "spawn_dir" = SOUTH)

/turf/closed/wall/r_wall/proselytize_vals(mob/living/proselytizer)
	return FALSE

/turf/closed/wall/clockwork/proselytize_vals(mob/living/proselytizer)
	return list("operation_time" = 80, "new_obj_type" = /turf/open/floor/clockwork, "alloy_cost" = -4, "spawn_dir" = SOUTH)

/turf/open/floor/proselytize_vals(mob/living/proselytizer)
	return list("operation_time" = 30, "new_obj_type" = /turf/open/floor/clockwork, "alloy_cost" = 1, "spawn_dir" = SOUTH)

/turf/open/floor/clockwork/proselytize_vals(mob/living/proselytizer)
	for(var/obj/O in src)
		if(O.density && !O.CanPass(proselytizer, src, 5))
			proselytizer << "<span class='warning'>Something is in the way, preventing you from proselytizing [src] into a clockwork wall.</span>"
			return 0
	return list("operation_time" = 100, "new_obj_type" = /turf/closed/wall/clockwork, "alloy_cost" = 4, "spawn_dir" = SOUTH)

/obj/machinery/door/airlock/proselytize_vals(mob/living/proselytizer)
	var/doortype = /obj/machinery/door/airlock/clockwork
	if(glass)
		doortype = /obj/machinery/door/airlock/clockwork/brass
	return list("operation_time" = 40, "new_obj_type" = doortype, "alloy_cost" = 5, "spawn_dir" = dir)

/obj/machinery/door/airlock/clockwork/proselytize_vals(mob/living/proselytizer)
	return FALSE

/obj/structure/window/proselytize_vals(mob/living/proselytizer)
	var/windowtype = /obj/structure/window/reinforced/clockwork
	var/new_dir = TRUE
	var/prosel_time = 15
	if(fulltile)
		windowtype = /obj/structure/window/reinforced/clockwork/fulltile
		new_dir = FALSE
		prosel_time = 30
	return list("operation_time" = prosel_time, "new_obj_type" = windowtype, "alloy_cost" = 5, "spawn_dir" = dir, "dir_in_new" = new_dir)

/obj/structure/window/reinforced/clockwork/proselytize_vals(mob/living/proselytizer)
	return FALSE

/obj/machinery/door/window/proselytize_vals(mob/living/proselytizer)
	return list("operation_time" = 30, "new_obj_type" = /obj/machinery/door/window/clockwork, "alloy_cost" = 5, "spawn_dir" = dir, "dir_in_new" = TRUE)

/obj/machinery/door/window/clockwork/proselytize_vals(mob/living/proselytizer)
	return FALSE

/obj/structure/grille/proselytize_vals(mob/living/proselytizer)
	var/grilletype = /obj/structure/grille/ratvar
	var/prosel_time = 15
	if(destroyed)
		grilletype = /obj/structure/grille/ratvar/broken
		prosel_time = 5
	return list("operation_time" = prosel_time, "new_obj_type" = grilletype, "alloy_cost" = 0, "spawn_dir" = dir)

/obj/structure/grille/ratvar/proselytize_vals(mob/living/proselytizer)
	return FALSE

/obj/structure/clockwork/wall_gear/proselytize_vals(mob/living/proselytizer)
	return list("operation_time" = 20, "new_obj_type" = /obj/item/clockwork/component/replicant_alloy, "alloy_cost" = 6, "spawn_dir" = SOUTH)

/obj/item/clockwork/alloy_shards/proselytize_vals(mob/living/proselytizer)
	return list("operation_time" = 10, "new_obj_type" = /obj/item/clockwork/component/replicant_alloy, "alloy_cost" = 7, "spawn_dir" = SOUTH)

/obj/item/clockwork/component/replicant_alloy/proselytize_vals(mob/living/proselytizer)
	return list("operation_time" = 0, "new_obj_type" = /obj/effect/overlay/temp/ratvar/beam/itemconsume, "alloy_cost" = -10, "spawn_dir" = SOUTH)
