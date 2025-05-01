/datum/asset/json/spawnpanel
	name = "spawnpanel"

/datum/asset/json/spawnpanel/generate()
	var/list/data = list()
	var/list/objects = typesof(/obj)
	var/list/turfs = typesof(/turf)
	var/list/mobs = typesof(/mob)

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

	data["Objects"] = list()
	data["Turfs"] = list()
	data["Mobs"] = list()

	for(var/item in objects)
		var/obj/temp = item;
		data["Objects"][item] = list(
			"icon" = temp?.icon || "none",
			"icon_state" = temp?.icon_state || "none",
			"name" = temp.name,
			"description" = temp.desc,
			"mapping" = is_type_in_typecache(temp, mapping_objects)
		)

	for(var/item in turfs)
		var/turf/temp = item;
		data["Turfs"][item] = list(
			"icon" = temp?.icon || "noneturf",
			"icon_state" = temp?.icon_state || "noneturf",
			"name" = temp.name,
			"description" = temp.desc,
			"mapping" = is_type_in_typecache(temp, mapping_objects)
		)

	for(var/item in mobs)
		var/mob/temp = item;
		data["Mobs"][item] = list(
			"icon" = temp?.icon || "nonemob",
			"icon_state" = temp?.icon_state || "nonemob",
			"name" = temp.name,
			"description" = temp.desc,
			"mapping" = is_type_in_typecache(temp, mapping_objects)
		)

	return data
