/**Map exporter
* Inputting a list of turfs into convert_map_to_tgm() will output a string
* with the turfs and their objects / areas on said turf into the TGM mapping format
* for .dmm files. This file can then be opened in the map editor or imported
* back into the game.
* ============================
* This has been made semi-modular so you should be able to use these functions
* elsewhere in code if you ever need to get a file in the .dmm format
**/

GLOBAL_LIST_EMPTY(save_object_blacklist)

/**
 *Procedure for converting a coordinate-selected part of the map into text for the .dmi format
 */
/proc/write_map(
	minx,
	miny,
	minz,
	maxx,
	maxy,
	maxz,
	save_flags = ALL,
	shuttle_area_flag = SAVE_SHUTTLEAREA_DONTCARE,
	list/obj_blacklist,
)
	var/width = maxx - minx
	var/height = maxy - miny
	var/depth = maxz - minz

	if(obj_blacklist && !islist(obj_blacklist))
		CRASH("Non-list being used as object blacklist for map writing")

	if(!length(GLOB.save_object_blacklist))
		GLOB.save_object_blacklist += typecacheof(list(
			/obj/effect,
			/obj/projectile,
			/atom/movable/mirage_holder,
			/obj/machinery/gravity_generator/part,
			/obj/structure/fluff/airlock_filler,
			/mob/living/carbon,
		))

		GLOB.save_object_blacklist -= typecacheof(list(
			/obj/effect/decal, // keep decals from crayon writings, blood splatters, cobwebs, etc.
			/obj/effect/turf_decal,
			/obj/effect/landmark, // most landmarks get deleted except for latejoin arrivals shuttle
		))

	if(!obj_blacklist)
		obj_blacklist = GLOB.save_object_blacklist

	//Step 0: Calculate the amount of letters we need (26 ^ n > turf count)
	var/turfs_needed = width * height
	var/layers = FLOOR(log(GLOB.save_file_chars.len, turfs_needed) + 0.999,1)

	//Step 1: Run through the area and generate file data
	var/list/header_data = list() //holds the data of a header -> to its key
	var/list/header = list() //The actual header in text
	var/list/contents = list() //The contents in text (bit at the end)
	var/key_index = 1 // How many keys we've generated so far

	for(var/z in 0 to depth)
		for(var/x in 0 to width)
			SSpersistence.current_save_x = x
			contents += "\n([x + 1],1,[z + 1]) = {\"\n"

			for(var/y in height to 0 step -1)
				CHECK_TICK

				SSpersistence.current_save_y = y
				// Reset the per turf obj/mob limits
				GLOB.TGM_objs = 0
				GLOB.TGM_mobs = 0

				//====Get turfs Data====
				var/turf/saved_turf
				var/area/saved_area
				var/turf/pull_from = locate((minx + x), (miny + y), (minz + z))
				//If there is nothing there, save as a noop (For odd shapes)
				if(isnull(pull_from))
					saved_turf = /turf/template_noop
					saved_area = /area/template_noop
				//Ignore things in space, must be a space turf
				else if(istype(pull_from, /turf/open/space) && !(save_flags & SAVE_TURFS_SPACE))
					saved_turf = /turf/template_noop
					saved_area = /area/template_noop
					pull_from = null
				//Stuff to add
				else
					var/area/place_area = get_area(pull_from)
					saved_area = place_area.type
					saved_turf = pull_from.type

				//====Saving holodeck areas====
				// All hologram objects get skipped and floor tiles get replaced with empty plating
				if(ispath(saved_area, /area/station/holodeck) && istype(saved_turf, /turf/open/floor/holofloor))
					saved_turf = /turf/open/floor/holofloor/plating
				//====For toggling not saving areas and turfs====
				if(!(save_flags & SAVE_AREAS))
					saved_area = /area/template_noop
				if(!(save_flags & SAVE_TURFS))
					saved_turf = /turf/template_noop
				//====Generate Header Character====
				// Info that describes this turf and all its contents
				// Unique, will be checked for existing later
				var/list/current_header = list()

				//====Saving Shuttles==========
				var/is_shuttle_area = ispath(saved_area, /area/shuttle)
				var/is_custom_shuttle_area = ispath(saved_area, /area/shuttle/custom)
				var/skip_nonshuttle_area = (shuttle_area_flag == SAVE_SHUTTLES_ONLY) && !is_shuttle_area
				if(skip_nonshuttle_area)
					saved_turf = /turf/template_noop
					saved_area = /area/template_noop
					pull_from = null

				var/skip_shuttle_area
				if(is_custom_shuttle_area)
					skip_shuttle_area = !(save_flags & SAVE_AREAS_CUSTOM_SHUTTLES)
				else if(is_shuttle_area)
					skip_shuttle_area = !(save_flags & SAVE_AREAS_DEFAULT_SHUTTLES)

				if(skip_shuttle_area)
					var/shuttle_depth = pull_from.depth_to_find_baseturf(/turf/baseturf_skipover/shuttle)
					var/obj/docking_port/mobile/shuttle = SSshuttle.get_containing_shuttle(pull_from)

					// save turf underneath shuttle
					saved_turf = shuttle_depth ? pull_from.baseturf_at_depth(shuttle_depth + 1) : /turf/template_noop

					// save area underneath shuttle
					if(shuttle)
						var/area/area_underneath_shuttle = shuttle.underlying_areas_by_turf[pull_from]
						saved_area = area_underneath_shuttle.type || SHUTTLE_DEFAULT_UNDERLYING_AREA
					else // shouldn't be possible but just in case
						saved_area = /area/template_noop

					if(!is_custom_shuttle_area) // only save the docking ports for default shuttles (arrivals/cargo/mining/etc.)
						var/obj/docking_port/stationary/shuttle_port = locate(/obj/docking_port/stationary) in pull_from
						if(shuttle_port)
							var/shuttle_metadata = generate_tgm_metadata(shuttle_port)
							TGM_MAP_BLOCK(current_header, shuttle_port.type, shuttle_metadata)


					pull_from = null

				// always replace [/turf/open/space] with [/turf/open/space/basic] since it speeds up the maploader
				// [/turf/open/space] is created naturally when shuttles are moving or turf gets destroyed leading to space
				if(ispath(saved_turf, /turf/open/space))
					saved_turf = /turf/open/space/basic
					// space turfs without catwalks/lattice should always be saved as [/area/space]
					if((saved_area.type != /area/space) && !(locate(/obj/structure/lattice, pull_from)))
						saved_area = /area/space

				else if(!istype(saved_turf, /turf/template_noop))
					// exclude all space and template_noop from our count
					INCREMENT_TURF_COUNT

				// Count unique areas
				if(saved_area != /area/template_noop && !(SSpersistence.counted_areas[saved_area]))
					SSpersistence.counted_areas[saved_area] = TRUE
					INCREMENT_AREA_COUNT

				for(var/atom/movable/target_atom as anything in pull_from)
					if(!target_atom.is_saveable(pull_from, obj_blacklist))
						continue

					//====SAVING OBJECTS====
					if((save_flags & SAVE_OBJECTS) && isobj(target_atom))
						CHECK_TICK

						if(OBJECT_LIMIT_EXCEEDED)
							continue
						INCREMENT_OBJ_COUNT()

					//====SAVING MOBS====
					else if((save_flags & SAVE_MOBS) && isliving(target_atom))
						CHECK_TICK

						if(MOB_LIMIT_EXCEEDED)
							continue
						INCREMENT_MOB_COUNT()

					// if a typepath substitute was performed we don't need to save original object data
					if(target_atom.substitute_with_typepath(current_header))
						continue

					//====SAVING SPECIAL DATA====
					//This is what causes lockers and machines to save stuff inside of them
					if((save_flags & SAVE_OBJECTS_PROPERTIES))
						target_atom.on_object_saved(current_header, pull_from, obj_blacklist)

					var/metadata = generate_tgm_metadata(target_atom, save_flags)
					TGM_MAP_BLOCK(current_header, target_atom.type, metadata)

				var/turf_metadata
				//====SAVING ATMOS====
				if((save_flags & SAVE_TURFS))
					var/turf/open/atmos_turf = pull_from
					// Optimiziations that skip saving atmospheric data for turfs that don't need it
					// - Walls: Atmos values should not realistically change
					// - Space: Gas is constantly purged and temperature is immutable
					// - Planetary: Atmos slowly reverts to its default gas mix
					if(isopenturf(atmos_turf) && !isspaceturf(atmos_turf) && !atmos_turf.planetary_atmos)
						turf_metadata = generate_tgm_metadata(atmos_turf, save_flags)

				TGM_MAP_BLOCK(current_header, saved_turf.type, turf_metadata)

				TGM_MAP_BLOCK(current_header, saved_area.type, null) // no metadata for now

				//====Fill the contents file====
				var/textiftied_header = "(\n[current_header.Join()])\n"

				// If we already know this header just use its key, otherwise we gotta make a new one
				var/key = header_data[textiftied_header]
				if(!key)
					key = calculate_tgm_header_index(key_index, layers)
					key_index++
					header += "\"[key]\" = [textiftied_header]"
					header_data[textiftied_header] = key
				contents += "[key]\n"
			contents += "\"}"

	// These always need to be reset between saves so old child/parents storages dont get mixed up
	GLOB.save_containers_parents.Cut()
	GLOB.save_containers_children.Cut()

	return "//[DMM2TGM_MESSAGE]\n[header.Join()][contents.Join()]"

// Could be inlined, not a massive cost tho so it's fine
/// Generates a key matching our index
/proc/calculate_tgm_header_index(index, key_length)
	var/list/output = list()
	// We want to stick the first one last, so we walk backwards
	var/list/pull_from = GLOB.save_file_chars
	var/length = length(pull_from)
	for(var/i in key_length to 1 step -1)
		var/calculated = FLOOR((index-1) / (length ** (i - 1)), 1)
		calculated = (calculated % length) + 1
		output += pull_from[calculated]
	return output.Join()

