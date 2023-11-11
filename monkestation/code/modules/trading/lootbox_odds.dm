
//global because its easier long term
//also its own file to make it super easy
//to find and adjust odds of lootbox rolls
/proc/return_rolled()
	var/list/viable_hats = list(
		/obj/item/clothing/head/costume/chicken,
		/obj/item/clothing/head/caphat,
		/obj/item/clothing/head/beanie,
		/obj/item/clothing/head/beret,
	)
	viable_hats += subtypesof(/obj/item/clothing/head/hats)
	var/path = pick(viable_hats)
	var/obj/item/clothing/head/temp = new path
	var/list/viable_unusuals = subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement
	var/picked_path = pick(viable_unusuals)
	temp.AddComponent(/datum/component/unusual_handler, particle_path = picked_path)
	return temp
