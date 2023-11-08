/*
 * Absorbs /obj/item/secstorage.
 * Reimplements it only slightly to use existing storage functionality.
 *
 * Contains:
 * Secure Briefcase
 * Wall Safe
 */

///Generic Safe
/obj/item/storage/secure
	name = "secstorage"
	desc = "This shouldn't exist. If it does, create an issue report."
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/secure/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.max_total_storage = 14
	AddComponent(/datum/component/lockable_storage)

///Secure Briefcase
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "secure"
	base_icon_state = "secure"
	inhand_icon_state = "sec-case"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	desc = "A large briefcase with a digital locking system."
	force = 8
	hitsound = SFX_SWING_HIT
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")

/obj/item/storage/secure/briefcase/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/briefcase/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 21
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

///Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/secure/briefcase/syndie
	force = 15

/obj/item/storage/secure/briefcase/syndie/PopulateContents()
	..()
	for(var/iterator in 1 to 5)
		new /obj/item/stack/spacecash/c1000(src)

/// A briefcase that contains various sought-after spoils
/obj/item/storage/secure/briefcase/riches

/obj/item/storage/secure/briefcase/riches/PopulateContents()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/gun/ballistic/automatic/pistol(src)
	new /obj/item/suppressor(src)
	new /obj/item/melee/baton/telescopic(src)
	new /obj/item/clothing/mask/balaclava(src)
	new /obj/item/bodybag(src)
	new /obj/item/soap/nanotrasen(src)

///Secure Safe
/obj/item/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "wall_safe"
	base_icon_state = "wall_safe"
	desc = "Excellent for securing things away from grubby hands."
	w_class = WEIGHT_CLASS_GIGANTIC
	anchored = TRUE
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/item/storage/secure/safe, 32)

/obj/item/storage/secure/safe/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC
	atom_storage.set_holdable(cant_hold_list = list(/obj/item/storage/secure/briefcase))
	find_and_hang_on_wall()

/obj/item/storage/secure/safe/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/safe/hos
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
/obj/item/storage/secure/safe/caps_spare
	name = "captain's spare ID safe"
	desc = "In case of emergency, do not break glass. All Captains and Acting Captains are provided with codes to access this safe. \
		It is made out of the same material as the station's Black Box and is designed to resist all conventional weaponry. \
		There appears to be a small amount of surface corrosion. It doesn't look like it could withstand much of an explosion.\
		It remains quite flush against the wall, and there only seems to be enough room to fit something as slim as an ID card."
	armor_type = /datum/armor/safe_caps_spare
	max_integrity = 300
	color = "#ffdd33"

MAPPING_DIRECTIONAL_HELPERS(/obj/item/storage/secure/safe/caps_spare, 32)

/datum/armor/safe_caps_spare
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 70
	fire = 80
	acid = 70

/obj/item/storage/secure/safe/caps_spare/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(can_hold_list = list(/obj/item/card/id))
	atom_storage.locked = STORAGE_FULLY_LOCKED
	AddComponent(/datum/component/lockable_storage,
		lock_code = SSid_access.spare_id_safe_code, \
		lock_set = TRUE, \
		can_hack_open = FALSE, \
	)

/obj/item/storage/secure/safe/caps_spare/PopulateContents()
	new /obj/item/card/id/advanced/gold/captains_spare(src)

/obj/item/storage/secure/safe/caps_spare/rust_heretic_act()
	take_damage(damage_amount = 100, damage_type = BRUTE, damage_flag = MELEE, armour_penetration = 100)
