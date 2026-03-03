/obj/effect/spawner/random/weapon
	icon_state = "laser_gun"

/obj/effect/spawner/random/weapon/full_gun
	loot_subtype_path = /obj/item/gun

/obj/effect/spawner/random/weapon/full_gun/make_item(spawn_loc, type_path_to_make)
	var/obj/item/gun/spawned_gun = new type_path_to_make(spawn_loc)
	spawned_gun.unlock()
	return spawned_gun
