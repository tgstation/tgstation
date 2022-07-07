#define NORTH_JUNCTION NORTH //(1<<0)
#define SOUTH_JUNCTION SOUTH //(1<<1)
#define EAST_JUNCTION EAST  //(1<<2)
#define WEST_JUNCTION WEST  //(1<<3)
#define NORTHEAST_JUNCTION (1<<4)
#define SOUTHEAST_JUNCTION (1<<5)
#define SOUTHWEST_JUNCTION (1<<6)
#define NORTHWEST_JUNCTION (1<<7)


DEFINE_BITFIELD(smoothing_junction, list(
	"NORTH_JUNCTION" = NORTH_JUNCTION,
	"SOUTH_JUNCTION" = SOUTH_JUNCTION,
	"EAST_JUNCTION" = EAST_JUNCTION,
	"WEST_JUNCTION" = WEST_JUNCTION,
	"NORTHEAST_JUNCTION" = NORTHEAST_JUNCTION,
	"SOUTHEAST_JUNCTION" = SOUTHEAST_JUNCTION,
	"SOUTHWEST_JUNCTION" = SOUTHWEST_JUNCTION,
	"NORTHWEST_JUNCTION" = NORTHWEST_JUNCTION,
))

/area
	var/list/adjacent_day_night_turf_cache

/area/proc/initialize_day_night_adjacent_turfs()
	LAZYCLEARLIST(adjacent_day_night_turf_cache)
	LAZYINITLIST(adjacent_day_night_turf_cache)

	for(var/turf/iterated_turf in contents)
		var/bitfield = NONE
		for(var/bit_step in ALL_JUNCTION_DIRECTIONS)
			var/turf/target_turf
			switch(bit_step)
				if(NORTH_JUNCTION)
					target_turf = locate(iterated_turf.x, iterated_turf.y + 1, iterated_turf.z)
				if(SOUTH_JUNCTION)
					target_turf = locate(iterated_turf.x, iterated_turf.y - 1, iterated_turf.z)
				if(EAST_JUNCTION)
					target_turf = locate(iterated_turf.x + 1, iterated_turf.y, iterated_turf.z)
				if(WEST_JUNCTION)
					target_turf = locate(iterated_turf.x - 1, iterated_turf.y, iterated_turf.z)
				if(NORTHEAST_JUNCTION)
					if(bitfield & NORTH_JUNCTION || bitfield & EAST_JUNCTION)
						continue
					target_turf = locate(iterated_turf.x + 1, iterated_turf.y + 1, iterated_turf.z)
				if(SOUTHEAST_JUNCTION)
					if(bitfield & SOUTH_JUNCTION || bitfield & EAST_JUNCTION)
						continue
					target_turf = locate(iterated_turf.x + 1, iterated_turf.y - 1, iterated_turf.z)
				if(SOUTHWEST_JUNCTION)
					if(bitfield & SOUTH_JUNCTION || bitfield & WEST_JUNCTION)
						continue
					target_turf = locate(iterated_turf.x - 1, iterated_turf.y - 1, iterated_turf.z)
				if(NORTHWEST_JUNCTION)
					if(bitfield & NORTH_JUNCTION || bitfield & WEST_JUNCTION)
						continue
					target_turf = locate(iterated_turf.x - 1, iterated_turf.y + 1, iterated_turf.z)
			if(!target_turf)
				continue
			var/area/target_area = target_turf.loc
			if(target_area == src)
				continue
			if(!target_area.outdoors || target_area.underground)
				continue
			bitfield ^= bit_step

		if(!bitfield)
			continue
		adjacent_day_night_turf_cache[iterated_turf] = list(AREA_DAY_NIGHT_INDEX_BITFIELD, AREA_DAY_NIGHT_INDEX_APPEARANCE)
		adjacent_day_night_turf_cache[iterated_turf][AREA_DAY_NIGHT_INDEX_BITFIELD] = bitfield
		RegisterSignal(iterated_turf, COMSIG_PARENT_QDELETING, .proc/clear_adjacent_turf)

	UNSETEMPTY(adjacent_day_night_turf_cache)

/**
 * Completely clears any adjacent turfs from the area while removing the effect.
 */
/area/proc/clear_adjacent_turfs()
	for(var/turf/iterating_turf as anything in adjacent_day_night_turf_cache)
		clear_adjacent_turf(iterating_turf)
	adjacent_day_night_turf_cache = null

/area/proc/clear_adjacent_turf(turf/turf_to_clear)
	SIGNAL_HANDLER

	turf_to_clear.underlays -= adjacent_day_night_turf_cache[turf_to_clear][AREA_DAY_NIGHT_INDEX_APPEARANCE]
	adjacent_day_night_turf_cache -= turf_to_clear
	UnregisterSignal(turf_to_clear, COMSIG_PARENT_QDELETING)

/area/proc/apply_day_night_turfs(datum/day_night_controller/incoming_controller, light_color, light_alpha)
	SIGNAL_HANDLER

	for(var/turf/iterating_turf as anything in adjacent_day_night_turf_cache)
		iterating_turf.underlays -= adjacent_day_night_turf_cache[iterating_turf][AREA_DAY_NIGHT_INDEX_APPEARANCE]
		var/mutable_appearance/appearance_to_add = mutable_appearance(
			'icons/effects/daynight_blend.dmi',
			"[adjacent_day_night_turf_cache[iterating_turf][AREA_DAY_NIGHT_INDEX_BITFIELD]]",
			DAY_NIGHT_LIGHTING_LAYER,
			LIGHTING_PLANE,
			light_alpha,
			RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			)
		appearance_to_add.color = light_color
		iterating_turf.underlays += appearance_to_add
		adjacent_day_night_turf_cache[iterating_turf][AREA_DAY_NIGHT_INDEX_APPEARANCE] = appearance_to_add

/area/proc/update_day_night_turfs(initialize_turfs = FALSE, search_for_controller = FALSE)
	if(search_for_controller)
		for(var/datum/day_night_controller/iterating_controller in SSday_night.cached_controllers)
			if(iterating_controller.affected_z_level == z)
				if(outdoors)
					iterating_controller.register_affected_area(src)
				else
					iterating_controller.register_unaffected_area(src)
	if(initialize_turfs)
		if(adjacent_day_night_turf_cache)
			clear_adjacent_turfs()
		initialize_day_night_adjacent_turfs()

/area/Destroy()
	clear_adjacent_turfs()
	return ..()

// PRESETS
/datum/day_night_controller/icebox
	timezones = list(
		/datum/timezone/midnight,
		/datum/timezone/early_morning,
		/datum/timezone/morning,
		/datum/timezone/midday,
		/datum/timezone/early_evening,
		/datum/timezone/evening,
	)
