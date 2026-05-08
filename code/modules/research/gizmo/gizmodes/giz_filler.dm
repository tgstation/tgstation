/// Shake around some, make some oil or just fly away
/datum/gizmodes/sputter
	possible_active_modes = list(
		/datum/gizpulse/sputter = 1,
		/datum/gizpulse/throw_self = 1,
	)

	min_modes = 2
	cooldown_time = 5 SECONDS

/// Shake around some and spill oil
/datum/gizpulse/sputter
	/// Range in which we can oilerize
	var/oil_range = 3
	/// Chance for a tile to get oiled
	var/oil_chance = 8

/datum/gizpulse/sputter/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	playsound(holder, 'sound/effects/splat.ogg', 30)
	for(var/turf/open/tile in oview(oil_range, holder))
		if(prob(oil_chance))
			new /obj/effect/decal/cleanable/blood/oil(tile)

	holder.Shake()

/datum/gizpulse/throw_self/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.throw_at(get_edge_target_turf(holder, pick(GLOB.alldirs)), 50, 1)

/// Spawn some item
/datum/gizmodes/dispenser
	possible_active_modes = list(
		/datum/gizpulse/dispense = 1,
		/datum/gizpulse/dispense = 1,
		/datum/gizpulse/dispense = 1,
		/datum/gizpulse/dispense = 1,
		/datum/gizpulse/dispense = 1,
		/datum/gizpulse/dispense = 1,
	)
	min_modes = 4
	max_modes = 6

/datum/gizpulse/dispense
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

/datum/gizpulse/dispense/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!object_to_spawn)
		object_to_spawn = pick_weight(possible_objects)

	// We don't technically track to make sure we dont make more than [max_objects] objects, we just delete whatever was made [max_objects] ago
	if(spawned_objects_weakrefs.len > (next_object_position % max_objects))
		qdel(spawned_objects_weakrefs["[(next_object_position % max_objects) + 1]"])

	var/new_object = new object_to_spawn (get_turf(holder))
	modify(new_object)
	spawned_objects_weakrefs["[(next_object_position % max_objects) + 1]"] = WEAKREF(new_object)
	next_object_position++

/datum/gizpulse/dispense/proc/modify(atom/movable/new_object)
	return

/// Spawn fake goop food
/datum/gizmodes/dispenser/food
	possible_active_modes = list(
		/datum/gizpulse/dispense/food = 1,
	)

	mode_pulses = list(
		/datum/gizpulse/mode_controle/direct_activate,
	)

	min_modes = 1
	max_modes = 1

/// Food made with goop
/datum/gizpulse/dispense/food
	possible_objects = list(
		/obj/item/food/donut/plain = 1,
		/obj/item/food/burger = 1,
	)

/datum/gizpulse/dispense/food/modify(atom/movable/new_object)
	new_object.reagents.clear_reagents()
	// its goop all the way down
	new_object.reagents.add_reagent(/datum/reagent/consumable/gizmo_goop, 5)
