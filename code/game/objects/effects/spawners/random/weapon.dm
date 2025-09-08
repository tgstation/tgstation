/obj/effect/spawner/random/weapon
	icon_state = "laser_gun"

/obj/effect/spawner/random/weapon/full_gun
	loot_subtype_path = /obj/item/gun

/obj/effect/spawner/random/weapon/full_gun/can_spawn(atom/loot)
	. = ..()
	var/obj/item/gun/gun_to_spawn = loot
	if(!ispath(gun_to_spawn))
		return FALSE
	// With shiptest guncode this resulted in every gun being ready to go.
	// Need to recreate this so the guns shoved into your hands are ready to blast assistants.
	/*
	if(gun_to_spawn:spawn_no_ammo == TRUE)
		return FALSE
	if(!gun_to_spawn:default_ammo_type)
		return FALSE
	*/

/obj/effect/spawner/random/weapon/full_gun/make_item(spawn_loc, type_path_to_make)
	var/obj/item/gun/spawned_gun = new type_path_to_make(spawn_loc)
	spawned_gun.unlock()
	return spawned_gun

/* Funny but dont want it to lag unit tests
/obj/effect/spawner/random/weapon/full_gun/all_of_them
	spawn_all_loot = TRUE
*/
