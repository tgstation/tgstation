/**Map exporter
* Inputting a list of turfs into convert_map_to_tgm() will output a string
* with the turfs and their objects / areas on said turf into the TGM mapping format
* for .dmm files. This file can then be opened in the map editor or imported
* back into the game.
* ============================
* This has been made semi-modular so you should be able to use these functions
* elsewhere in code if you ever need to get a file in the .dmm format
**/


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
	save_flag = ALL,
	shuttle_area_flag = SAVE_SHUTTLEAREA_DONTCARE,
	list/obj_blacklist,
)
	var/width = maxx - minx
	var/height = maxy - miny
	var/depth = maxz - minz

	var/max_object_limit = CONFIG_GET(number/persistent_max_object_limit_per_turf)
	var/max_mob_limit = CONFIG_GET(number/persistent_max_mob_limit_per_turf)
	var/total_mobs_saved = 0
	var/total_objs_saved = 0
	var/total_turfs_saved = 0
	//var/total_areas_saved = 0  this might be useful later but not right now

	if(obj_blacklist && !islist(obj_blacklist))
		CRASH("Non-list being used as object blacklist for map writing")

	// we want to keep decals from crayon writings, blood splatters, cobwebs, etc.
	// most landmarks get deleted except for latejoin arrivals shuttle
	var/static/list/default_blacklist = typecacheof(list(/obj/effect, /obj/projectile)) - typecacheof(list(/obj/effect/decal, /obj/effect/turf_decal, /obj/effect/landmark))
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
			contents += "\n([x + 1],1,[z + 1]) = {\"\n"
			for(var/y in height to 0 step -1)
				CHECK_TICK
				//====Get turfs Data====
				var/turf/saved_turf
				var/area/saved_area
				var/turf/pull_from = locate((minx + x), (miny + y), (minz + z))
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
				if(isspaceturf(saved_turf))
					// figure out why arrivals shuttle is bypassing this lol
					saved_turf = /turf/open/space/basic
				else if(!istype(saved_turf, /turf/template_noop))
					// exclude all space and template_noop from our count
					total_turfs_saved++

				// always reset these to 0 as we iterate to a new turf
				GLOB.serialization_turf_obj_count = 0
				GLOB.serialization_turf_mob_count = 0

				for(var/atom/movable/target_atom as anything in pull_from)
					if(target_atom.flags_1 & HOLOGRAM_1)
						continue
					if(is_multi_tile_object(target_atom) && (target_atom.loc != pull_from))
						continue

					//====SAVING OBJECTS====
					if((save_flag & SAVE_OBJECTS) && isobj(target_atom))
						var/obj/target_obj = target_atom
						CHECK_TICK
						if(obj_blacklist[target_obj.type])
							continue
						if(GLOB.serialization_turf_obj_count >= max_object_limit)
							continue

						var/metadata
						if(save_flag & SAVE_OBJECTS_VARIABLES)
							metadata = generate_tgm_metadata(target_obj)

						GLOB.serialization_turf_obj_count++
						current_header += "[empty ? "" : ",\n"][target_obj.type][metadata]"
						empty = FALSE
						//====SAVING SPECIAL DATA====
						//This is what causes lockers and machines to save stuff inside of them
						if(save_flag & SAVE_OBJECTS_PROPERTIES)
							var/custom_data = target_obj.on_object_saved(serialization_turf_obj_count)
							current_header += "[custom_data ? ",\n[custom_data]" : ""]"

					//====SAVING MOBS====
					if((save_flag & SAVE_MOBS) && isliving(target_atom))
						var/mob/living/target_mob = target_atom
						CHECK_TICK
						if(istype(target_mob, /mob/living/carbon)) //Ignore people, but not animals
							continue
						if(GLOB.serialization_turf_mob_count >= max_mob_limit)
							continue

						GLOB.serialization_turf_mob_count++
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

				total_mobs_saved += GLOB.serialization_turf_mob_count
				total_objs_saved += GLOB.serialization_turf_obj_count

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

