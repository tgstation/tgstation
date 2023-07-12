#define ORE_MULTIPLIER_IRON 1
#define ORE_MULTIPLIER_GLASS 0.9
#define ORE_MULTIPLIER_PLASMA 0.8
#define ORE_MULTIPLIER_SILVER 0.7
#define ORE_MULTIPLIER_GOLD 0.6
#define ORE_MULTIPLIER_TITANIUM 0.5
#define ORE_MULTIPLIER_URANIUM 0.4
#define ORE_MULTIPLIER_DIAMOND 0.3
#define ORE_MULTIPLIER_BLUESPACE_CRYSTAL 0.2

/// The virtual domain - side of the bitmining crate. Deliver to the send location.
/obj/structure/closet/crate/bitminer_locked
	name = "Encrypted Loot Crate"
	desc = "Needs delivered back station side to be opened."

/obj/structure/closet/crate/bitminer_locked/open(mob/living/user, force, special_effects)
	balloon_alert(user, "encrypted! deliver it first.")
	return

/// The bitminer den - side of the bitmining crate. Appears in the receive location.
/obj/structure/closet/crate/bitminer_unlocked
	name = "Decrypted Loot Crate"
	desc = "Materialized from the virtual domain. The reward of a successful bitminer."

/obj/structure/closet/crate/bitminer_unlocked/Initialize(mapload, datum/map_template/virtual_domain/completed_domain)
	. = ..()
	playsound(src, 'sound/magic/blink.ogg')

	if(!completed_domain)
		return

	PopulateContents(completed_domain.difficulty, completed_domain.reward_points, completed_domain.extra_loot)

/obj/structure/closet/crate/bitminer_unlocked/PopulateContents(difficulty, reward_points, list/extra_loot)
	. = ..()
	var/sum = 1 + reward_points

	for(var/path in extra_loot)
		if(ispath(path))
			new path()

	// This is just a showcase of how mats work. It's cash instead for the time being
	new /obj/item/stack/spacecash/c1(src, sum * ORE_MULTIPLIER_IRON)
	new /obj/item/stack/spacecash/c1(src, sum * ORE_MULTIPLIER_GLASS)
	new /obj/item/stack/spacecash/c10(src, sum * ORE_MULTIPLIER_PLASMA)

	if(difficulty > 1)
		new /obj/item/stack/spacecash/c10(src, sum * ORE_MULTIPLIER_SILVER)
		new /obj/item/stack/spacecash/c10(src, sum * ORE_MULTIPLIER_GOLD)
		new /obj/item/stack/spacecash/c10(src, sum * ORE_MULTIPLIER_TITANIUM)

	if(difficulty > 2)
		new /obj/item/stack/spacecash/c100(src, sum * ORE_MULTIPLIER_URANIUM)
		new /obj/item/stack/spacecash/c100(src, sum * ORE_MULTIPLIER_DIAMOND)
		new /obj/item/stack/spacecash/c100(src, sum * ORE_MULTIPLIER_BLUESPACE_CRYSTAL)

#undef ORE_MULTIPLIER_IRON
#undef ORE_MULTIPLIER_GLASS
#undef ORE_MULTIPLIER_PLASMA
#undef ORE_MULTIPLIER_SILVER
#undef ORE_MULTIPLIER_GOLD
#undef ORE_MULTIPLIER_TITANIUM
#undef ORE_MULTIPLIER_URANIUM
#undef ORE_MULTIPLIER_DIAMOND
#undef ORE_MULTIPLIER_BLUESPACE_CRYSTAL
