/datum/gizmo_effect/dispense
	/// Weighted list of objects we could spawn
	var/list/possible_objects = list(
		/obj/item/crowbar = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/item/multitool = 1,
		/obj/item/wirecutters = 1,
		/obj/item/weldingtool = 1,
	)
	/// Typepath of object to spawn
	var/object_to_spawn

	/// List of softrefs of the objects we spawned. Exists only to prevent game-crashing object spam
	var/list/spawned_objects_weakrefs = list()
	/// Max objects that can exist at once
	var/max_objects = 50
	/// The position of the next object to spawn in spawned_objects_weakrefs
	var/next_object_position = 0

/datum/gizmo_effect/dispense/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	if(!object_to_spawn)
		object_to_spawn = pick_weight(possible_objects)

	// We don't technically track to make sure we dont make more than [max_objects] objects, we just delete whatever was made [max_objects] ago
	if(spawned_objects_weakrefs.len > (next_object_position % max_objects))
		qdel(spawned_objects_weakrefs["[(next_object_position % max_objects) + 1]"])

	var/new_object = new object_to_spawn (get_turf(holder))
	modify(new_object)
	spawned_objects_weakrefs["[(next_object_position % max_objects) + 1]"] = WEAKREF(new_object)
	next_object_position++

/datum/gizmo_effect/dispense/proc/modify(atom/movable/new_object)
	return

/// Food made with goop
/datum/gizmo_effect/dispense/food
	possible_objects = list(
		/obj/item/food/donut/plain = 1,
		/obj/item/food/burger/cheese = 1,
	)

/datum/gizmo_effect/dispense/food/modify(atom/movable/new_object)
	new_object.reagents.clear_reagents()
	// its goop all the way down
	new_object.reagents.add_reagent(/datum/reagent/consumable/gizmo_goop, 5)
