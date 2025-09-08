/obj/effect/spawner/random/weapon
	icon_state = "laser_gun"

/obj/effect/spawner/random/weapon/full_gun
	loot_subtype_path = /obj/item/gun

/obj/effect/spawner/random/weapon/full_gun/can_spawn(atom/loot)
	. = ..()
	var/obj/item/gun/gun_to_spawn = loot
	if(!ispath(gun_to_spawn))
		return FALSE
	#warn remeber what vars TG uses, I forget shiptest has much better gun code.
	/*
	if(gun_to_spawn:spawn_no_ammo == TRUE)
		return FALSE
	if(!gun_to_spawn:default_ammo_type)
		return FALSE
	*/

/* Funny but dont want it to lag unit tests
/obj/effect/spawner/random/weapon/full_gun/all_of_them
	spawn_all_loot = TRUE
*/
