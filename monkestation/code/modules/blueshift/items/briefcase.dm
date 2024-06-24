/**
 * Secure briefcase
 * Uses the lockable storage component to give it a lock.
 */
/obj/item/storage/briefcase/secure
	name = "secure briefcase"
	desc = "A large briefcase with a digital locking system."
	icon_state = "secure"
	base_icon_state = "secure"
	inhand_icon_state = "sec-case"

/obj/item/storage/briefcase/secure/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 21
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	AddComponent(/datum/component/lockable_storage)

///Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/briefcase/secure/syndie
	force = 15

/obj/item/storage/briefcase/secure/syndie/PopulateContents()
	. = ..()
	for(var/iterator in 1 to 5)
		new /obj/item/stack/spacecash/c1000(src)

/// A briefcase that contains various sought-after spoils
/obj/item/storage/briefcase/secure/riches

/obj/item/storage/briefcase/secure/riches/PopulateContents()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/gun/ballistic/automatic/pistol(src)
	new /obj/item/suppressor(src)
	new /obj/item/melee/baton/telescopic(src)
	new /obj/item/clothing/mask/balaclava(src)
	new /obj/item/bodybag(src)
	new /obj/item/soap/nanotrasen(src)
