/datum/asset/json/spawnpanel
	name = "spawnpanel_atom_data"

/datum/asset/json/spawnpanel/generate()
	var/list/data = list()

	var/static/list/mapping_objects = typecacheof(list(
		/obj/effect/mapping_helpers,
		/obj/effect/landmark,
		/obj/effect/spawner,
		/obj/effect/mob_spawn,
		/obj/effect/holodeck_effect,
		/obj/docking_port,
		/obj/modular_map_connector,
		/obj/modular_map_root,
		/obj/pathfind_guy,
	))

	data["atoms"] = list()

	for(var/obj/each_object as anything in typesof(/obj))
		data["atoms"][each_object] = list(
			"icon" = each_object?.icon_preview || each_object?.icon || "none",
			"icon_state" = each_object?.icon_state_preview || each_object?.icon_state || "none",
			"name" = each_object.name,
			"description" = each_object.desc,
			"mapping" = is_type_in_typecache(each_object, mapping_objects),
			"type" = "Objects"
		)

	for(var/turf/each_turf as anything in typesof(/turf))
		data["atoms"][each_turf] = list(
			"icon" = each_turf?.icon || "noneturf",
			"icon_state" = each_turf?.icon_state || "noneturf",
			"name" = each_turf.name,
			"description" = each_turf.desc,
			"mapping" = is_type_in_typecache(each_turf, mapping_objects),
			"type" = "Turfs"
		)

	for(var/mob/each_mob as anything in typesof(/mob))
		data["atoms"][each_mob] = list(
			"icon" = each_mob?.icon || "nonemob",
			"icon_state" = each_mob?.icon_state || "nonemob",
			"name" = each_mob.name,
			"description" = each_mob.desc,
			"mapping" = is_type_in_typecache(each_mob, mapping_objects),
			"type" = "Mobs"
		)

	return data
