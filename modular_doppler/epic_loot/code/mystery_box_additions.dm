GLOBAL_LIST_INIT(lethal_deathmatch_guns, list(
	/obj/effect/spawner/random/epic_loot/deathmatch_silly_arms,
	/obj/effect/spawner/random/epic_loot/deathmatch_silly_arms_blue,
	/obj/effect/spawner/random/epic_loot/deathmatch_serious_arms,
	/obj/effect/spawner/random/epic_loot/deathmatch_serious_arms_blue,
	/obj/effect/spawner/random/epic_loot/deathmatch_grenade_or_explosive,
))

GLOBAL_LIST_INIT(lethal_funny_mystery_box_items, list(
	/obj/effect/spawner/random/epic_loot/deathmatch_armor,
	/obj/effect/spawner/random/epic_loot/deathmatch_medkit,
	/obj/effect/spawner/random/epic_loot/deathmatch_funny,
))

/obj/structure/mystery_box/guns/generate_valid_types()
	valid_types = GLOB.lethal_deathmatch_guns

/obj/structure/mystery_box/tdome/generate_valid_types()
	valid_types = GLOB.lethal_deathmatch_guns + GLOB.lethal_funny_mystery_box_items

/obj/structure/mystery_box/grant_weapon(mob/living/user)
	new presented_item.selected_path(src)
	for(var/obj/item/iterated_item in contents)
		if(!isitem(iterated_item))
			continue
		user.put_in_hands(iterated_item)

		if(isgun(iterated_item)) // handle pins + possibly extra ammo
			var/obj/item/gun/instantiated_gun = iterated_item
			instantiated_gun.unlock()
			if(grant_extra_mag && istype(instantiated_gun, /obj/item/gun/ballistic))
				var/obj/item/gun/ballistic/instantiated_ballistic = instantiated_gun
				if(!instantiated_ballistic.internal_magazine)
					var/obj/item/ammo_box/magazine/extra_mag = new instantiated_ballistic.spawn_magazine_type(loc)
					user.put_in_hands(extra_mag)

		user.visible_message(span_notice("[user] takes [iterated_item] from [src]."), span_notice("You take [iterated_item] from [src]."), vision_distance = COMBAT_MESSAGE_RANGE)
		playsound(src, grant_sound, 70, FALSE, channel = current_sound_channel, falloff_exponent = 10)
		close_box()
