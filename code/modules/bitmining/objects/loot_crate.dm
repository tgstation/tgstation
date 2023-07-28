#define ORE_MULTIPLIER_IRON 3
#define ORE_MULTIPLIER_GLASS 2
#define ORE_MULTIPLIER_PLASMA 1
#define ORE_MULTIPLIER_SILVER 0.7
#define ORE_MULTIPLIER_GOLD 0.6
#define ORE_MULTIPLIER_TITANIUM 0.5
#define ORE_MULTIPLIER_URANIUM 0.4
#define ORE_MULTIPLIER_DIAMOND 0.3
#define ORE_MULTIPLIER_BLUESPACE_CRYSTAL 0.2

/obj/structure/closet/crate/secure/bitminer_loot // Base class. Do not spawn this.
	name = "base class loot crate"
	desc = "Talk to a coder."

/// The virtual domain - side of the bitmining crate. Deliver to the send location.
/obj/structure/closet/crate/secure/bitminer_loot/encrypted
	name = "encrypted loot crate"
	desc = "Needs delivered back station side to be opened."
	locked = TRUE

/obj/structure/closet/crate/secure/bitminer_loot/encrypted/can_unlock(mob/living/user, obj/item/card/id/player_id, obj/item/card/id/registered_id)
	return FALSE

/// The bitminer den - side of the bitmining crate. Appears in the receive location.
/obj/structure/closet/crate/secure/bitminer_loot/decrypted
	name = "decrypted loot crate"
	desc = "Materialized from the virtual domain. The reward of a successful bitminer."
	locked = FALSE

/obj/structure/closet/crate/secure/bitminer_loot/decrypted/Initialize(
	mapload,
	datum/map_template/virtual_domain/completed_domain,
	rewards_multiplier = 1,
	)
	. = ..()
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)

	if(isnull(completed_domain))
		return

	PopulateContents(completed_domain.extra_loot, rewards_multiplier)

/obj/structure/closet/crate/secure/bitminer_loot/decrypted/PopulateContents(list/extra_loot, rewards_multiplier)
	. = ..()
	var/sum = 10 + rewards_multiplier

	for(var/path in extra_loot)
		if(ispath(path))
			new path()

	new /obj/item/stack/ore/iron(src, sum * ORE_MULTIPLIER_IRON)
	new /obj/item/stack/ore/glass(src, sum * ORE_MULTIPLIER_GLASS)
	new /obj/item/stack/ore/plasma(src, sum * ORE_MULTIPLIER_PLASMA)

	if(rewards_multiplier > 2)
		new /obj/item/stack/ore/silver(src, sum * ORE_MULTIPLIER_SILVER)
		new /obj/item/stack/ore/gold(src, sum * ORE_MULTIPLIER_GOLD)
		new /obj/item/stack/ore/titanium(src, sum * ORE_MULTIPLIER_TITANIUM)

	if(rewards_multiplier > 3)
		new /obj/item/stack/ore/uranium(src, sum * ORE_MULTIPLIER_URANIUM)
		new /obj/item/stack/ore/diamond(src, sum * ORE_MULTIPLIER_DIAMOND)
		new /obj/item/stack/ore/bluespace_crystal(src, sum * ORE_MULTIPLIER_BLUESPACE_CRYSTAL)

#undef ORE_MULTIPLIER_IRON
#undef ORE_MULTIPLIER_GLASS
#undef ORE_MULTIPLIER_PLASMA
#undef ORE_MULTIPLIER_SILVER
#undef ORE_MULTIPLIER_GOLD
#undef ORE_MULTIPLIER_TITANIUM
#undef ORE_MULTIPLIER_URANIUM
#undef ORE_MULTIPLIER_DIAMOND
#undef ORE_MULTIPLIER_BLUESPACE_CRYSTAL
