#define PERSISTENCE_FISH_ID "fish_id"
#define PERSISTENCE_FISH_NAME "fish_name"
#define PERSISTENCE_FISH_SIZE "fish_size"
#define PERSISTENCE_FISH_WEIGHT "fish_weight"
#define PERSISTENCE_FISH_MATERIAL "fish_material"
#define PERSISTENCE_FISH_CATCHER "fish_catcher"
#define PERSISTENCE_FISH_CATCH_DATE "fish_catch_date"

///Instantiate a fish, then set its size, weight, eventually materials and finally add it to the mount.
/datum/controller/subsystem/persistence/proc/load_trophy_fish(obj/structure/fish_mount/mount)
	if(!mount.persistence_id)
		return
	if(isnull(trophy_fishes_database))
		trophy_fishes_database = new("data/trophy_fishes.json")

	var/list/data = trophy_fishes_database.get_key(mount.persistence_id)
	if(!length(data))
		return
	var/fish_id = data[PERSISTENCE_FISH_ID]
	if(!fish_id) //For a reason or another, the id isn't there
		return
	var/fish_path = SSfishing.catchable_fish[fish_id]
	if(!fish_path) //the fish was removed, uh uh.
		return
	var/obj/item/fish/fish = new fish_path(mount, /* apply_qualities = */ FALSE)
	fish.fish_traits.Cut()
	fish.update_size_and_weight(data[PERSISTENCE_FISH_SIZE], data[PERSISTENCE_FISH_WEIGHT])
	var/material_path = text2path(data[PERSISTENCE_FISH_MATERIAL])
	if(material_path)
		//setting the list otherwise seems to cause some issues, thank you Byond.
		var/list/mat_list = list()
		mat_list[material_path] = fish.weight
		fish.set_custom_materials(mat_list)
	fish.persistence_load(data)
	fish.name = data[PERSISTENCE_FISH_NAME]
	fish.set_status(FISH_DEAD, silent = TRUE)
	mount.add_fish(fish, from_persistence = TRUE, catcher = data[PERSISTENCE_FISH_CATCHER])
	mount.catch_date = data[PERSISTENCE_FISH_CATCH_DATE]

/datum/controller/subsystem/persistence/proc/save_trophy_fish(obj/structure/fish_mount/mount)
	var/obj/item/fish/fish = mount.mounted_fish
	if(!fish || !mount.persistence_id)
		return
	if(isnull(trophy_fishes_database))
		trophy_fishes_database = new("data/trophy_fishes.json")

	var/list/data = list()
	var/fish_id = fish.fish_id
	if(fish.fish_id_redirect_path)
		var/obj/item/fish/other_path = fish.fish_id_redirect_path
		fish_id = initial(other_path.fish_id)

	data[PERSISTENCE_FISH_ID] = fish_id
	data[PERSISTENCE_FISH_NAME] = fish.name
	data[PERSISTENCE_FISH_SIZE] = fish.size
	data[PERSISTENCE_FISH_WEIGHT] = fish.weight / fish.material_weight_mult
	var/datum/material/material = fish.get_master_material()
	data[PERSISTENCE_FISH_MATERIAL] = "[material?.type]"
	data[PERSISTENCE_FISH_CATCHER] = mount.catcher_name
	data[PERSISTENCE_FISH_CATCH_DATE] = mount.catch_date

	fish.persistence_save(data)
	trophy_fishes_database.set_key(mount.persistence_id, data)

#undef PERSISTENCE_FISH_ID
#undef PERSISTENCE_FISH_NAME
#undef PERSISTENCE_FISH_SIZE
#undef PERSISTENCE_FISH_WEIGHT
#undef PERSISTENCE_FISH_MATERIAL
#undef PERSISTENCE_FISH_CATCHER
#undef PERSISTENCE_FISH_CATCH_DATE
