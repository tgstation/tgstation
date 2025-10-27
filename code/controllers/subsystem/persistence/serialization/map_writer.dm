/**
 * Enhanced write_map procedure with proper progress tracking and metrics
 */
/proc/write_map(
	minx,
	miny,
	minz,
	maxx,
	maxy,
	maxz,
	save_flag = ALL,
	shuttle_area_flag = SAVE_SHUTTLEAREA_DONTCARE,
	list/obj_blacklist,
)
	var/width = maxx - minx
	var/height = maxy - miny
	var/depth = maxz - minz

	var/max_object_limit = CONFIG_GET(number/persistent_max_object_limit_per_turf)
	var/max_mob_limit = CONFIG_GET(number/persistent_max_mob_limit_per_turf)

	if(obj_blacklist && !islist(obj_blacklist))
		CRASH("Non-list being used as object blacklist for map writing")

	// we want to keep decals from crayon writings, blood splatters, cobwebs, etc.
	// most landmarks get deleted except for latejoin arrivals shuttle
	var/static/list/default_blacklist = typecacheof(list(/obj/effect, /obj/projectile, /obj/machinery/gravity_generator/part, /obj/structure/fluff/airlock_filler, /mob/living/carbon)) - typecacheof(list(/obj/effect/decal, /obj/effect/turf_decal, /obj/effect/landmark))

	if(!obj_blacklist)
		obj_blacklist = default_blacklist

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
			// Update progress tracking for the UI
			if(SSpersistence.save_in_progress)
				SSpersistence.current_save_x = x
				SSpersistence.current_save_y = 0

			contents += "\n([x + 1],1,[z + 1]) = {\"\n"
			for(var/y in height to 0 step -1)
				CHECK_TICK

				// Update progress tracking for the UI
				if(SSpersistence.save_in_progress)
					SSpersistence.current_save_y = y

				//====Get turfs Data====
				var/turf/saved_turf
				var/area/saved_area
				var/turf/pull_from = locate((minx + x), (miny + y), (minz + z))

				// Reset per-turf counters
				GLOB.TGM_objs = 0
				GLOB.TGM_mobs = 0

				//If there is nothing there, save as a noop (For odd shapes)
				if(isnull(pull_from))
					saved_turf = /turf/template_noop
					saved_area = /area/template_noop
				//Ignore things in space, must be a space turf
				else if(istype(pull_from, /turf/open/space) && !(save_flag & SAVE_TURFS_SPACE))
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
				if(!(save_flag & SAVE_AREAS))
					saved_area = /area/template_noop
				if(!(save_flag & SAVE_TURFS))
					saved_turf = /turf/template_noop
				//====Generate Header Character====
				// Info that describes this turf and all its contents
				// Unique, will be checked for existing later
				var/list/current_header = list()
				current_header += "(\n"
				//Add objects to the header file
				var/empty = TRUE

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
					skip_shuttle_area = !(save_flag & SAVE_AREAS_CUSTOM_SHUTTLES)
				else if(is_shuttle_area)
					skip_shuttle_area = !(save_flag & SAVE_AREAS_DEFAULT_SHUTTLES)

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
							var/metadata = generate_tgm_metadata(shuttle_port)
							current_header += "[empty ? "" : ",\n"][shuttle_port.type][metadata]"
							empty = FALSE

					pull_from = null

				// always replace [/turf/open/space] with [/turf/open/space/basic] since it speeds up the maploader
				// [/turf/open/space] is created naturally when shuttles are moving or turf gets destroyed leading to space
				if(ispath(saved_turf, /turf/open/space))
					// figure out why arrivals shuttle is bypassing this lol
					saved_turf = /turf/open/space/basic
				else if(!istype(saved_turf, /turf/template_noop))
					// exclude all space and template_noop from our count
					INCREMENT_TURF_COUNT

				// Count unique areas
				if(saved_area != /area/template_noop && !(saved_area in SSpersistence.counted_areas))
					SSpersistence.counted_areas += saved_area
					INCREMENT_AREA_COUNT

				for(var/atom/movable/target_atom as anything in pull_from)
					if(target_atom.flags_1 & HOLOGRAM_1)
						continue
					if(!target_atom.is_saveable(pull_from))
						continue
					if(obj_blacklist[target_atom.type])
						continue

					var/typepath = target_atom.get_save_substitute_type() || target_atom.type

					//====SAVING OBJECTS====
					if((save_flag & SAVE_OBJECTS) && isobj(target_atom))
						var/obj/target_obj = target_atom
						CHECK_TICK

						if(OBJECT_LIMIT_EXCEEDED)
							continue
						INCREMENT_OBJ_COUNT()

						var/metadata
						if(save_flag & SAVE_OBJECTS_VARIABLES)
							metadata = generate_tgm_metadata(target_obj)

						current_header += "[empty ? "" : ",\n"][typepath][metadata]"
						empty = FALSE
						//====SAVING SPECIAL DATA====
						//This is what causes lockers and machines to save stuff inside of them
						if(save_flag & SAVE_OBJECTS_PROPERTIES)
							var/custom_data = target_obj.on_object_saved(pull_from)
							current_header += "[custom_data ? ",\n[custom_data]" : ""]"

					//====SAVING MOBS====
					if((save_flag & SAVE_MOBS) && isliving(target_atom))
						var/mob/living/target_mob = target_atom
						CHECK_TICK

						if(MOB_LIMIT_EXCEEDED)
							continue
						INCREMENT_MOB_COUNT()
						//GLOB.TGM_mobs++

						var/metadata = generate_tgm_metadata(target_mob)
						current_header += "[empty ? "" : ",\n"][target_mob.type][metadata]"
						empty = FALSE

				current_header += "[empty ? "" : ",\n"][saved_turf]"
				//====SAVING ATMOS====
				if((save_flag & SAVE_TURFS) && (save_flag & SAVE_TURFS_ATMOS))
					var/turf/open/atmos_turf = pull_from
					// Optimiziations that skip saving atmospheric data for turfs that don't need it
					// - Walls: Atmos values should not realistically change
					// - Space: Gas is constantly purged and temperature is immutable
					// - Planetary: Atmos slowly reverts to its default gas mix
					if(isopenturf(atmos_turf) && !isspaceturf(atmos_turf) && !atmos_turf.planetary_atmos)
						var/metadata = generate_tgm_metadata(atmos_turf)
						current_header += "[metadata]"

				current_header += ",\n[saved_area])\n"
				//====Fill the contents file====
				var/textiftied_header = current_header.Join()
				// If we already know this header just use its key, otherwise we gotta make a new one
				var/key = header_data[textiftied_header]
				if(!key)
					key = calculate_tgm_header_index(key_index, layers)
					key_index++
					header += "\"[key]\" = [textiftied_header]"
					header_data[textiftied_header] = key
				contents += "[key]\n"
			contents += "\"}"
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

