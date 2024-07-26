// VENDOR
/obj/machinery/armament_station/assault_operatives
	name = "Military Grade Armament Station"

	// required_access = list(ACCESS_SYNDICATE) TESTING

	armament_type = /datum/armament_entry/assault_operatives

// POINTS CARDS

/obj/item/armament_points_card/assaultops
	points = 50

// ARMAMENT ENTRIES

#define ARMAMENT_CATEGORY_OTHER "Miscellaneous"
#define ARMAMENT_CATEGORY_OTHER_LIMIT 3

/datum/armament_entry/assault_operatives
	var/mags_to_spawn = 3

/datum/armament_entry/assault_operatives/after_equip(turf/safe_drop_location, obj/item/item_to_equip)
	if(istype(item_to_equip, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/spawned_ballistic_gun = item_to_equip
		if(spawned_ballistic_gun.magazine && !istype(spawned_ballistic_gun.magazine, /obj/item/ammo_box/magazine/internal))
			var/obj/item/storage/box/ammo_box/spawned_box = new(safe_drop_location)
			spawned_box.name = "ammo box - [spawned_ballistic_gun.name]"
			for(var/i in 1 to mags_to_spawn)
				new spawned_ballistic_gun.spawn_magazine_type (spawned_box)
