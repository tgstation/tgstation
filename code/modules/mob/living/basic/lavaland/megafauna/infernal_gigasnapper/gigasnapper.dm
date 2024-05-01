///A very, VERY large crab.
/mob/living/basic/mining/megafauna/infernal_gigasnapper
	name = "infernal gigasnapper"
	desc = "\"Magmacarcinidae gigantus\", also known as a very, very large crab. Whether the presence of crustaceans is a cause or effect of this behemoth is uncertain."
	health = 1000
	maxHealth = 1000

	icon = 'icons/mob/simple/lavaland/gigasnapper/gigasnapper.dmi'
	icon_state = "gigasnapper"
	pixel_x = -32
	pixel_y = -16

	faction = list(FACTION_MINING, FACTION_BOSS, FACTION_CRABS, FACTION_GIGASNAPPER)
	mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_SPECIAL

	///arena ability, checked by other abilities often
	var/datum/action/cooldown/mob_cooldown/crab_arena/arena

/mob/living/basic/mining/megafauna/infernal_gigasnapper/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/dir_restricted_movement, (EAST | WEST))
	AddElement(/datum/element/basic_eating, food_types = list(
		///typical bottomfeeder fanfare. healthy crab diets include:
		//fish, dead or alive
		/obj/item/fish,
		//shrimp
		/obj/item/food/chips/shrimp,
		//snails
		/obj/item/food/canned/desert_snails,
		/obj/item/food/lizard_escargot,
		/obj/item/food/spaghetti/snail_nizaya,
		//worms
		/obj/item/food/bait/worm,
		/obj/item/food/bait/worm/premium,
		//cannibalism (raw)
		/obj/item/food/meat/slab/rawcrab
	))
	//not friendly, just not killing you
	AddElement(/datum/component/tameable, tame_chance = 25, bonus_tame_chance = 5)

	// the boss is obviously hostile, but there is a way to get it at least neutral.
	// this is about cases where the neutrality is ruined, permanently.
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/boss_music, 'sound/lavaland/gigasnapper_boss.ogg', 106 SECONDS)


	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/crab_dig = BB_GIGASNAPPER_DIG,
		/datum/action/cooldown/mob_cooldown/crab_collide = BB_GIGASNAPPER_COLLIDE,
		/datum/action/cooldown/mob_cooldown/crab_arena = BB_GIGASNAPPER_ARENA,
		/datum/action/cooldown/mob_cooldown/crab_minions = BB_GIGASNAPPER_MINIONS,
	)
	var/list/key_abilities = grant_actions_by_list(innate_actions)
	arena = key_abilities[BB_GIGASNAPPER_ARENA]

/// returns all the turfs that the crab sprite touches
/mob/living/basic/mining/megafauna/infernal_gigasnapper/proc/get_crab_turfs(include_self_turf = FALSE) as /list
	var/list/dirs = list(NORTH, NORTHEAST, EAST, WEST, NORTHWEST)
	var/list/turfs = list()
	for(var/dir in dirs)
		var/turf/stepped = get_step(src, dir)
		if(stepped)
			turfs += stepped
	if(include_self_turf)
		turfs += get_turf(src)
	return turfs
