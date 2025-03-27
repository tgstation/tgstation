#define ORE_MULTIPLIER_IRON 3
#define ORE_MULTIPLIER_GLASS 2
#define ORE_MULTIPLIER_PLASMA 1
#define ORE_MULTIPLIER_SILVER 0.7
#define ORE_MULTIPLIER_GOLD 0.6
#define ORE_MULTIPLIER_TITANIUM 0.5
#define ORE_MULTIPLIER_URANIUM 0.4
#define ORE_MULTIPLIER_DIAMOND 0.3
#define ORE_MULTIPLIER_BLUESPACE_CRYSTAL 0.2

/obj/structure/closet/crate/secure/bitrunning // Base class. Do not spawn this.
	name = "base class cache"
	desc = "Talk to a coder."
	icon_state = "bitrunning"
	base_icon_state = "bitrunning"

/// The virtual domain - side of the bitrunning crate. Deliver to the send location.
/obj/structure/closet/crate/secure/bitrunning/encrypted
	name = "encrypted cache"
	desc = "Needs to be decrypted at the safehouse to be opened."
	locked = TRUE
	damage_deflection = 30
	resistance_flags =  INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/closet/crate/secure/bitrunning/encrypted/can_unlock(mob/living/user, obj/item/card/id/player_id, obj/item/card/id/registered_id)
	return FALSE

/// The bitrunner den - side of the bitrunning crate. Appears in the receive location.
/obj/structure/closet/crate/secure/bitrunning/decrypted
	name = "decrypted cache"
	desc = "Compiled from the virtual domain. The reward of a successful bitrunner."
	locked = FALSE

/obj/structure/closet/crate/secure/bitrunning/decrypted/Initialize(
	mapload,
	datum/lazy_template/virtual_domain/completed_domain,
	rewards_multiplier = 1,
	)
	. = ..()
	playsound(src, 'sound/effects/magic/blink.ogg', 50, TRUE)

	if(isnull(completed_domain))
		return

	PopulateContents(completed_domain.reward_points, completed_domain.completion_loot, rewards_multiplier)

/obj/structure/closet/crate/secure/bitrunning/decrypted/PopulateContents(reward_points, list/completion_loot, rewards_multiplier)
	. = ..()
	spawn_loot(completion_loot)

	new /obj/item/stack/ore/iron(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_IRON))
	new /obj/item/stack/ore/glass(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_GLASS))

	if(reward_points > 1)
		new /obj/item/stack/ore/silver(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_SILVER))
		new /obj/item/stack/ore/titanium(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_TITANIUM))

	if(reward_points > 2)
		new /obj/item/stack/ore/plasma(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_PLASMA))
		new /obj/item/stack/ore/gold(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_GOLD))
		new /obj/item/stack/ore/uranium(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_URANIUM))

	if(reward_points > 3)
		new /obj/item/stack/ore/diamond(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_DIAMOND))
		new /obj/item/stack/ore/bluespace_crystal(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_BLUESPACE_CRYSTAL))

/// Handles generating random numbers & calculating loot totals
/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/calculate_loot(reward_points, rewards_multiplier, ore_multiplier)
	var/base = rewards_multiplier + reward_points
	var/random_sum = (rand() + 0.5) * base
	return ROUND_UP(random_sum * ore_multiplier)

/// Handles spawning completion loot. This tries to handle bad flat and assoc lists
/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/spawn_loot(list/completion_loot)
	for(var/path in completion_loot)
		if(!ispath(path))
			return FALSE

		if(isnull(completion_loot[path]))
			return FALSE

		for(var/i in 1 to completion_loot[path])
			new path(src)

	return TRUE

#undef ORE_MULTIPLIER_IRON
#undef ORE_MULTIPLIER_GLASS
#undef ORE_MULTIPLIER_PLASMA
#undef ORE_MULTIPLIER_SILVER
#undef ORE_MULTIPLIER_GOLD
#undef ORE_MULTIPLIER_TITANIUM
#undef ORE_MULTIPLIER_URANIUM
#undef ORE_MULTIPLIER_DIAMOND
#undef ORE_MULTIPLIER_BLUESPACE_CRYSTAL
