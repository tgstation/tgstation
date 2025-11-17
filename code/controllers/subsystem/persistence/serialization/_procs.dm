/atom
	// These vars help insert objects inside containers by matching and linking the parent containers id to the children
	// example:
	// backpack with var/save_container_parent_id = "foo123"
	// pen with var/save_container_child_id = "foo123"
	// This will cause the pen to be inserted into the backpack during initialization

	/// This is the parent id linked to the child object
	/// Used to determine which parent container to insert the object into during map loading
	var/save_container_child_id
	/// This is the generated id of the parent object that holds children inside
	/// Used to link children and parent objects together during map loading
	var/save_container_parent_id

/// A list of all parent containers storing objects inside (used via map save/load)
GLOBAL_LIST_EMPTY(save_containers_parents)
/// A list of all children that are stored inside parent containers (used via map save/load)
GLOBAL_LIST_EMPTY(save_containers_children)

/**
 * List of variables to include when it is serialized.
 *
 * Always use NAMEOF(src, varname) for the keys to ensure compile-time checking.
 * Do NOT return variable values or custom data in this proc.
 * To save calculated values or custom data, use either get_custom_save_vars() or on_object_saved()
 *
 * Returns: Array list of variable names to be serialized
 */
/atom/proc/get_save_vars(save_flags=ALL)
	. = list()
	. += NAMEOF(src, color)
	. += NAMEOF(src, dir)
	. += NAMEOF(src, pixel_x)
	. += NAMEOF(src, pixel_y)
	. += NAMEOF(src, density)
	. += NAMEOF(src, opacity)
	. += NAMEOF(src, save_container_child_id)
	. += NAMEOF(src, save_container_parent_id)

	if(uses_integrity)
		. += NAMEOF(src, resistance_flags)

	GLOB.map_export_save_vars_cache[type] = .
	return .

/atom/movable/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, anchored)
	return .

/obj/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, req_access)
	. += NAMEOF(src, id_tag)
	. += NAMEOF(src, obj_flags)
	return .

/**
 * Overrides the variables of an object with a custom value when it is serialized.
 *
 * Always use NAMEOF(src, varname) for the keys to ensure compile-time checking.
 * Examples:
 * - Saving a object reference as a savable id_tag
 * - Saving a calculated value
 *
 * Returns: Assoicated list of variables with custom values to be serialized
 */
/atom/proc/get_custom_save_vars(save_flags=ALL)
	. = list()
	if(uses_integrity && (atom_integrity != max_integrity))
		.[NAMEOF(src, atom_integrity)] = atom_integrity
	return .

/**
 * A procedure for saving non-standard properties of an object.
 * Examples:
 * - Saving material stacks (ie. ore in a silo)
 * - Saving variables that can be shown as mapping helpers (ie. welded airlock mapping helper)
 * - Saving objects inside of another object (ie. paper inside a noticeboard)
 *
 * Returns: Null or array list of additional object data to be included on turf
 */
/atom/proc/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	return

/// Helper proc to save children objects that are stored inside the contents of the source object
/// ignore ids is for objects that automatically handle inserting objects inside the parent like closets, lockers, notice boards, etc.
/obj/proc/save_stored_contents(map_string, turf/current_loc, list/obj_blacklist, include_ids=TRUE)
	var/parent_container_id_tag
	for(var/obj/target_obj in contents)
		if(!target_obj.is_saveable(current_loc, obj_blacklist))
			continue

		if(include_ids)
			if(!parent_container_id_tag)
				parent_container_id_tag = assign_random_name()
				GLOB.save_containers_parents[src] = parent_container_id_tag

			// link the stored child object to the id of the parent container
			GLOB.save_containers_children[target_obj] = parent_container_id_tag

		target_obj.on_object_saved(map_string, current_loc, obj_blacklist)
		var/metadata = generate_tgm_metadata(target_obj)
		TGM_MAP_BLOCK(map_string, target_obj.type, metadata)

/obj/get_custom_save_vars(save_flags=ALL)
	. = list()

	// this might cause hard deletes tied to the object as references ? but these lists get deleted at the end of map saving
	if(GLOB.save_containers_parents[src])
		.[NAMEOF(src, save_container_parent_id)] = GLOB.save_containers_parents[src]
	if(GLOB.save_containers_children[src])
		.[NAMEOF(src, save_container_child_id)] = GLOB.save_containers_children[src]
	return .

/obj/PersistentInitialize()
	if(save_container_parent_id)
		GLOB.save_containers_parents[save_container_parent_id] = src

	if(save_container_child_id)
		GLOB.save_containers_children += src
	. = ..()

/**
 * Check if an atom is savable for serilization during map export.
 *
 * For atoms that will always be blacklisted do NOT use this proc. Use the blacklist in map_writer.dm
 * Examples:
 * - [/obj/machinery/atmospherics/components/unary] spawns beneath cryo tubes that causes duplication
 * - [/obj/machinery/power/terminal] spawns beneath APC's that causes duplication
 * - [/obj/structure/transport/linear/tram] needs to skip multi-tile object checks
 *
 * Returns: Boolean
 */
/atom/proc/is_saveable(turf/current_loc, list/obj_blacklist)
	if(obj_blacklist[type])
		return FALSE
	if(flags_1 & HOLOGRAM_1)
		return FALSE

	return TRUE

/atom/movable/is_saveable(turf/current_loc, list/obj_blacklist)
	if(is_multi_tile_object(src) && (src.loc != current_loc))
		return FALSE

	return ..()

/obj/item/is_saveable(turf/current_loc, list/obj_blacklist)
	if(item_flags & ABSTRACT)
		return FALSE

	return ..()

/**
 * Check if an atom type has a substitute type for map export serialization.
 *
 * Substitution compacts map data by replacing the object with a typepath, which can improve
 * serialization speed. Any variables or data on the old object will not transfer over to the substitution.
 *
 * Examples:
 * - ORIGINAL /obj/machinery/atmospherics/pipe/smart/simple {color="#FF0000", hide=TRUE, pipe_layer=4}
 * - SUBSTITUTE /obj/machinery/atmospherics/pipe/smart/manifold4w/scrubber/hidden/layer4
 * - ORIGINAL /obj/machinery/light/built {icon_state="tube", status=LIGHT_OK}
 * - SUBSTITUTE /obj/machinery/light
 * - ORIGINAL /obj/machinery/atmospherics/components/unary/vent_scrubber {on=TRUE, layer=2}
 * - SUBSTITUTE /obj/machinery/atmospherics/components/unary/vent_scrubber/on/layer2
 *
 * Returns: The typepath for the substitution if possible or FALSE
 */
/atom/proc/substitute_with_typepath(map_string)
	return FALSE
