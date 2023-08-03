#define ORE_MULTIPLIER_IRON 3
#define ORE_MULTIPLIER_GLASS 2
#define ORE_MULTIPLIER_PLASMA 1
#define ORE_MULTIPLIER_SILVER 0.7
#define ORE_MULTIPLIER_GOLD 0.6
#define ORE_MULTIPLIER_TITANIUM 0.5
#define ORE_MULTIPLIER_URANIUM 0.4
#define ORE_MULTIPLIER_DIAMOND 0.3
#define ORE_MULTIPLIER_BLUESPACE_CRYSTAL 0.2

/obj/structure/closet/crate/secure/bitrunner_loot // Base class. Do not spawn this.
	name = "base class loot crate"
	desc = "Talk to a coder."

/// The virtual domain - side of the bitrunning crate. Deliver to the send location.
/obj/structure/closet/crate/secure/bitrunner_loot/encrypted
	name = "encrypted loot crate"
	desc = "Needs decrypted at the safehouse to be opened."
	locked = TRUE

/obj/structure/closet/crate/secure/bitrunner_loot/encrypted/can_unlock(mob/living/user, obj/item/card/id/player_id, obj/item/card/id/registered_id)
	return FALSE

/// The bitrunner den - side of the bitrunning crate. Appears in the receive location.
/obj/structure/closet/crate/secure/bitrunner_loot/decrypted
	name = "decrypted loot crate"
	desc = "Materialized from the virtual domain. The reward of a successful bitrunner."
	locked = FALSE

/obj/structure/closet/crate/secure/bitrunner_loot/decrypted/Initialize(
	mapload,
	datum/map_template/virtual_domain/completed_domain,
	rewards_multiplier = 1,
	)
	. = ..()
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)

	if(isnull(completed_domain))
		return

	PopulateContents(completed_domain.reward_points, completed_domain.extra_loot, rewards_multiplier)

/obj/structure/closet/crate/secure/bitrunner_loot/decrypted/PopulateContents(reward_points, list/extra_loot, rewards_multiplier)
	. = ..()
	for(var/path in extra_loot)
		if(!ispath(path))
			continue

		for(var/i in 1 to extra_loot[path])
			new path(src)

	new /obj/item/stack/ore/iron(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_IRON))
	new /obj/item/stack/ore/glass(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_GLASS))
	new /obj/item/stack/ore/plasma(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_PLASMA))

	if(reward_points > 1)
		new /obj/item/stack/ore/silver(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_SILVER))
		new /obj/item/stack/ore/gold(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_GOLD))
		new /obj/item/stack/ore/titanium(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_TITANIUM))

	if(reward_points > 2)
		new /obj/item/stack/ore/uranium(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_URANIUM))
		new /obj/item/stack/ore/diamond(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_DIAMOND))
		new /obj/item/stack/ore/bluespace_crystal(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_BLUESPACE_CRYSTAL))

/// Handles generating random numbers & calculating loot totals
/obj/structure/closet/crate/secure/bitrunner_loot/decrypted/proc/calculate_loot(reward_points, rewards_multiplier, ore_multiplier)
	var/base = 2 * (rewards_multiplier + reward_points)
	var/random_sum = (rand() * 1.0 + 0.5) * base
	return ROUND_UP(random_sum * ore_multiplier)

/// In case you want to gate the crate behind a special condition.
/obj/effect/bitrunner_loot_signal
	name = "Mysterious aura"
	/// The amount required to spawn a crate
	var/points_goal = 10
	/// A special condition limits this from spawning a crate
	var/points_received = 0
	/// Finished the special condition
	var/revealed = FALSE

/obj/effect/bitrunner_loot_signal/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BITRUNNER_GOAL_POINT, PROC_REF(on_add_point))

/// Listens for points to be added which will eventually spawn a crate.
/obj/effect/bitrunner_loot_signal/proc/on_add_point(datum/source, points_to_add)
	SIGNAL_HANDLER

	if(revealed)
		return

	points_received += points_to_add

	if(points_received < points_goal)
		return

	reveal()

/// Spawns the crate with some effects
/obj/effect/bitrunner_loot_signal/proc/reveal()
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)
	var/turf/tile = get_turf(src)
	var/obj/structure/closet/crate/secure/bitrunner_loot/encrypted/loot = new(tile)
	var/datum/effect_system/spark_spread/quantum/sparks = new(tile)
	sparks.set_up(5, 1, get_turf(loot))
	sparks.start()
	qdel(src)

#undef ORE_MULTIPLIER_IRON
#undef ORE_MULTIPLIER_GLASS
#undef ORE_MULTIPLIER_PLASMA
#undef ORE_MULTIPLIER_SILVER
#undef ORE_MULTIPLIER_GOLD
#undef ORE_MULTIPLIER_TITANIUM
#undef ORE_MULTIPLIER_URANIUM
#undef ORE_MULTIPLIER_DIAMOND
#undef ORE_MULTIPLIER_BLUESPACE_CRYSTAL
