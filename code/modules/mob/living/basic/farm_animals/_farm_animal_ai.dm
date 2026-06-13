/// Shared farm-animal subtree: flee from anything that attacks us while occasionally speaking.
/// The speech behavior is supplied per-animal through a binding so each one keeps its own noises.
/datum/bt_node/subtree/skittish_and_speak
	behavior_tree_json = "skittish_and_speak.bt.json"

/// Shared farm-animal subtree: graze on nearby food, brawl with anything that angers us, and
/// occasionally fly into a random rage (capricious retaliate). The food-finding leaf is supplied
/// via binding so picky eaters like geese can use their own search.
/datum/bt_node/subtree/forage_and_retaliate
	behavior_tree_json = "forage_and_retaliate.bt.json"

/// Default forager: finds anything in BB_BASIC_FOODS nearby and stashes it in BB_TARGET_FOOD.
/datum/bt_node/subtree/forage_for_food
	behavior_tree_json = "forage_for_food.bt.json"

/// Picks a target from our retaliate list (real attackers only).
/datum/bt_node/subtree/pick_retaliate_target
	behavior_tree_json = "pick_retaliate_target.bt.json"

/// Like [/datum/bt_node/subtree/pick_retaliate_target], but first rolls to randomly aggro on or
/// forgive a nearby mob. Used by animals that pick fights for no reason.
/datum/bt_node/subtree/capricious_pick_target
	behavior_tree_json = "capricious_pick_target.bt.json"

/// Cowardly brawler combat: keep our distance from attackers, fleeing if they get close but
/// turning to bite if they hang back just out of reach.
/datum/bt_node/subtree/skittish_brawler_combat
	behavior_tree_json = "skittish_brawler_combat.bt.json"
