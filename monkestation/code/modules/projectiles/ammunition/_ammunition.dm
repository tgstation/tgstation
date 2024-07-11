/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	update_trash_trait()

/obj/item/ammo_casing/newshot()
	. = ..()
	update_trash_trait()

/obj/item/ammo_casing/on_accidental_consumption(mob/living/carbon/victim, mob/living/carbon/user, obj/item/source_item,  discover_after = TRUE)
	. = ..()
	update_trash_trait()

/obj/item/ammo_casing/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread, atom/fired_from)
	. = ..()
	update_trash_trait()

/obj/item/ammo_casing/refresh_shot()
	. = ..()
	update_trash_trait()

/obj/item/ammo_casing/proc/update_trash_trait()
	if(QDELETED(loaded_projectile))
		ADD_TRAIT(src, TRAIT_TRASH_ITEM, TRAIT_GENERIC)
	else
		REMOVE_TRAIT(src, TRAIT_TRASH_ITEM, TRAIT_GENERIC)
