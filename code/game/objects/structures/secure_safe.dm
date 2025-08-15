/obj/item/wallframe/secure_safe
	name = "secure safe frame"
	desc = "A locked safe. It being unpowered prevents any access until placed back onto a wall."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "wall_safe"
	base_icon_state = "wall_safe"
	result_path = /obj/structure/secure_safe
	pixel_shift = 32

/obj/item/wallframe/secure_safe/Initialize(mapload)
	. = ..()
	create_storage(
		max_specific_storage = WEIGHT_CLASS_GIGANTIC,
		max_total_storage = 20,
	)
	atom_storage.set_locked(STORAGE_FULLY_LOCKED)

/obj/item/wallframe/secure_safe/after_attach(obj/attached_to)
	. = ..()
	for(var/obj/item in contents)
		item.forceMove(attached_to)

/**
 * Wall safes
 * Holds items and uses the lockable storage component
 * to allow people to lock items up.
 */
/obj/structure/secure_safe
	name = "secure safe"
	desc = "Excellent for securing things away from grubby hands."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "wall_safe"
	base_icon_state = "wall_safe"
	anchored = TRUE
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/secure_safe, 32)

/obj/structure/secure_safe/Initialize(mapload)
	. = ..()
	//this will create the storage for us.
	AddComponent(/datum/component/lockable_storage)
	if(!density)
		find_and_hang_on_wall()
	if(mapload)
		PopulateContents()

/obj/structure/secure_safe/atom_deconstruct(disassembled)
	if(!density) //if we're a wall item, we'll drop a wall frame.
		var/obj/item/wallframe/secure_safe/new_safe = new(get_turf(src))
		for(var/obj/item in contents)
			item.forceMove(new_safe)

/obj/structure/secure_safe/proc/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/structure/secure_safe/hos
	name = "head of security's safe"

/**
 * This safe is meant to be damn robust. To break in, you're supposed to get creative, or use acid or an explosion.
 *
 * This makes the safe still possible to break in for someone who is prepared and capable enough, either through
 * chemistry, botany or whatever else.
 *
 * The safe is also weak to explosions, so spending some early TC could allow an antag to blow it upen if they can
 * get access to it.
 */
/obj/structure/secure_safe/caps_spare
	name = "captain's spare ID safe"
	desc = "In case of emergency, do not break glass. All Captains and Acting Captains are provided with codes to access this safe. \
		It is made out of the same material as the station's Black Box and is designed to resist all conventional weaponry. \
		There appears to be a small amount of surface corrosion. It doesn't look like it could withstand much of an explosion.\
		Due to the expensive material, it was made incredibly small to cut corners, leaving only enough room to fit something as slim as an ID card."
	icon = 'icons/obj/structures.dmi'
	icon_state = "spare_safe"
	base_icon_state = "spare_safe"
	armor_type = /datum/armor/safe_caps_spare
	max_integrity = 300
	damage_deflection = 30 // prevents stealing the captain's spare using null rods/lavaland monsters/AP projectiles
	density = TRUE
	anchored_tabletop_offset = 6
	custom_materials = list(/datum/material/gold = SMALL_MATERIAL_AMOUNT)
	material_flags = MATERIAL_EFFECTS

/datum/armor/safe_caps_spare
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 70
	fire = 80
	acid = 70

/obj/structure/secure_safe/caps_spare/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(/obj/item/card/id)
	AddComponent(/datum/component/lockable_storage, \
		lock_code = SSid_access.spare_id_safe_code, \
		can_hack_open = FALSE, \
	)

/obj/structure/secure_safe/caps_spare/PopulateContents()
	new /obj/item/card/id/advanced/gold/captains_spare(src)

/obj/structure/secure_safe/caps_spare/rust_heretic_act()
	take_damage(damage_amount = 100, damage_type = BRUTE, damage_flag = MELEE, armour_penetration = 100)
