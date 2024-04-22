/turf/open/misc/asteroid/airless/tospace
	explodable = TRUE
	baseturfs = /turf/baseturf_bottom
	turf_type = /turf/open/misc/asteroid/airless/tospace


/obj/effect/forcefield/asteroid_magnet
	name = "magnetic field"
	desc = "This looks dangerous."
	icon = 'goon/icons/obj/effects.dmi'
	icon_state = "forcefield"

	initial_duration = 0
	opacity = TRUE


/proc/button_element(trg, text, action, class, style)
	return "<a href='?src=\ref[trg];[action]'[class ? "class='[class]'" : ""][style ? "style='[style]'" : ""]>[text]</a>"

/proc/color_button_element(trg, color, action)
	return "<a href='?src=\ref[trg];[action]' class='box' style='background-color: [color]'></a>"

/// Inline script for an animated ellipsis
/proc/ellipsis(number_of_dots = 3, millisecond_delay = 500)
	var/static/unique_id = 0
	unique_id++
	return {"<span id='[unique_id]' style='display: inline-block'></span>
			<script>
			var count = 0;
			document.addEventListener("DOMContentLoaded", function() {
				setInterval(function(){
					count++;
					document.getElementById('[unique_id]').innerHTML = new Array(count % [number_of_dots + 2]).join('.');
				}, [millisecond_delay]);
			});
			</script>
	"}

/// Breaks down to an asteroid floor that breaks down to space
/turf/closed/mineral/random/asteroid/tospace
	baseturfs = /turf/open/misc/asteroid/airless/tospace

/turf/closed/mineral/random/asteroid/tospace/mineral_chances()
	return list(
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 2,
		/obj/item/stack/ore/iron = 10,
		/obj/item/stack/ore/plasma = 5,
		/obj/item/stack/ore/silver = 1,
		/obj/item/stack/ore/titanium = 1,
		/obj/item/stack/ore/uranium = 1,
		/turf/closed/mineral/artifact = 15,
		/turf/closed/mineral/mineral_sample = 15,
	)

/datum/controller/subsystem/mapping/proc/generate_asteroid(datum/mining_template/template, datum/callback/asteroid_generator)
	Master.StartLoadingMap()

	SSatoms.map_loader_begin(REF(template))
	var/list/turfs = asteroid_generator.Invoke()
	template.Populate(turfs.Copy())
	SSatoms.map_loader_stop(REF(template))

	var/list/atoms = list()
	// Initialize all of the atoms in the asteroid
	for(var/turf/T as anything in turfs)
		atoms += T
		atoms += T.contents

	SSatoms.InitializeAtoms(atoms)
	for(var/turf/T as turf in turfs)
		T.AfterChange(CHANGETURF_IGNORE_AIR)
	Master.StopLoadingMap()

	template.AfterInitialize(atoms)

/// Cleanup our currently loaded mining template
/proc/CleanupAsteroidMagnet(turf/center, size)
	var/list/turfs_to_destroy = ReserveTurfsForAsteroidGeneration(center, size, baseturf_only = FALSE)
	for(var/turf/T as anything in turfs_to_destroy)
		CHECK_TICK

		for(var/atom/movable/AM as anything in T)
			CHECK_TICK
			if(isdead(AM) || iscameramob(AM) || iseffect(AM) || iseminence(AM) || ismob(AM))
				continue
			qdel(AM)

		T.ChangeTurf(/turf/baseturf_bottom)

/// Sanitizes a block of turfs to prevent writing over undesired locations
/proc/ReserveTurfsForAsteroidGeneration(turf/center, size, baseturf_only = TRUE)
	. = list()

	var/list/turfs = RANGE_TURFS(size, center)
	for(var/turf/T as anything in turfs)
		if(baseturf_only && !islevelbaseturf(T))
			continue
		if(!(istype(T.loc, /area/station/cargo/mining/asteroid_magnet)))
			continue
		. += T
		CHECK_TICK

/// Generates a circular asteroid.
/proc/GenerateRoundAsteroid(datum/mining_template/template, turf/center = template.center, initial_turf_path = /turf/closed/mineral/random/asteroid/tospace, size = template.size || 6, list/turfs, hollow = FALSE)
	. = list()
	if(!length(turfs))
		return list()

	if(template)
		center = template.center
		size = template.size

	size = size + 2 //This is just for generating "smoother" asteroids, it will not go out of reservation space.

	if (hollow)
		center = center.ChangeTurf(/turf/open/misc/asteroid/airless/tospace, flags = (CHANGETURF_DEFER_CHANGE|CHANGETURF_DEFAULT_BASETURF))
	else
		center = center.ChangeTurf(initial_turf_path, flags = (CHANGETURF_DEFER_CHANGE|CHANGETURF_DEFAULT_BASETURF))
		GENERATOR_CHECK_TICK

	. += center

	var/corner_range = round(size * 1.5)
	var/total_distance = 0
	var/current_dist_from_center = 0

	for (var/turf/current_turf in turfs)
		GENERATOR_CHECK_TICK

		current_dist_from_center = get_dist(center, current_turf)

		total_distance = abs(center.x - current_turf.x) + abs(center.y - current_turf.y) + (current_dist_from_center / 2)
		// Keep us round
		if (total_distance > corner_range)
			continue

		if (hollow && total_distance < size / 2)
			var/turf/T = locate(current_turf.x, current_turf.y, current_turf.z)
			T = T.ChangeTurf(/turf/open/misc/asteroid/airless/tospace, flags = (CHANGETURF_DEFER_CHANGE|CHANGETURF_DEFAULT_BASETURF))
			. += T

		else
			var/turf/T = locate(current_turf.x, current_turf.y, current_turf.z)
			T = T.ChangeTurf(initial_turf_path, flags = (CHANGETURF_DEFER_CHANGE|CHANGETURF_DEFAULT_BASETURF))
			GENERATOR_CHECK_TICK
			. += T

	return .
