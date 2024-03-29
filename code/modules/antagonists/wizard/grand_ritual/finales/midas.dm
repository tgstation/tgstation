/// Completely transform the station
/datum/grand_finale/midas
	name = "Transformation"
	desc = "The ultimate use of your gathered power! Turn their precious station into something much MORE precious, materially speaking!"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "sheet-gold_2"
	glow_colour = "#dbdd4c48"
	var/static/list/permitted_transforms = list( // Non-dangerous only
		/datum/dimension_theme/gold,
		/datum/dimension_theme/meat,
		/datum/dimension_theme/pizza,
		/datum/dimension_theme/natural,
	)
	var/datum/dimension_theme/chosen_theme

// I sure hope this doesn't have performance implications
/datum/grand_finale/midas/trigger(mob/living/carbon/human/invoker)
	var/theme_path = pick(permitted_transforms)
	chosen_theme = new theme_path()
	var/turf/start_turf = get_turf(invoker)
	var/greatest_dist = 0
	var/list/turfs_to_transform = list()
	for (var/turf/transform_turf as anything in GLOB.station_turfs)
		if (!chosen_theme.can_convert(transform_turf))
			continue
		var/dist = get_dist(start_turf, transform_turf)
		if (dist > greatest_dist)
			greatest_dist = dist
		if (!turfs_to_transform["[dist]"])
			turfs_to_transform["[dist]"] = list()
		turfs_to_transform["[dist]"] += transform_turf

	if (chosen_theme.can_convert(start_turf))
		chosen_theme.apply_theme(start_turf)

	for (var/iterator in 1 to greatest_dist)
		if(!turfs_to_transform["[iterator]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(transform_area), turfs_to_transform["[iterator]"]), (5 SECONDS) * iterator)

/datum/grand_finale/midas/proc/transform_area(list/turfs)
	chosen_theme.apply_theme_to_list_of_turfs(turfs)
