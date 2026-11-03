/// What Ratwood's NPC people do besides trading blows (the blow itself is ai/human_npc.dm), on TG's behavior trees, after
/// Vibelin's human_npc (datums/ai/subtrees: use_bandage, use_healing_drink, bow_usage, use_throwing_weapon, call_for_help,
/// flank, harass, loot, retrieve_arrow) and Ratwood's npc/_npc.dm (npc_try_jump, npc_taunt_target, npc_try_make_grab,
/// npc_try_use_grab, npc_detect_sneak).
///
/// Out of a fight an NPC binds a bleeding limb with a clean cloth it carries, and gathers from the ground what it can use:
/// cloth, healing potions, throwing knives and javelins, rounds for its quiver. Hurt, it drinks a healing potion it carries,
/// in a fight too. In a fight it shoots the bow, crossbow or sling it carries while the foe is not close, throws a throwing
/// knife or javelin, calls its own kind once badly hurt, spreads around a foe others of its kind are fighting (flanking), and
/// once hurt or winded strikes and backs off out of reach before the next blow. Ratwood's NPCs also leap at a far foe, the
/// rude ones laugh at or point to a foe out of reach right above them, they grab with a free hand and twist, choke or smash
/// what they hold, and they look for whoever sneaks near - now and then by themselves, at once when their foe hides or a
/// hidden one strikes them. Numbers are npc_* of config/redtard/mechanics/values/pve.txt.

/// Strike-and-back-off (Vibelin harass): until when the NPC backs off, and where to.
#define BB_ROGUE_NPC_HARASS_UNTIL "rogue_npc_harass_until"
#define BB_ROGUE_NPC_RETREAT_TURF "rogue_npc_retreat_turf"
/// Flanking (Vibelin squad_flank): the angle around the foe it took, the tile of it, when to look again.
#define BB_ROGUE_NPC_FLANK_ANGLE "rogue_npc_flank_angle"
#define BB_ROGUE_NPC_FLANK_TURF "rogue_npc_flank_turf"
#define BB_ROGUE_NPC_FLANK_AT "rogue_npc_flank_at"
/// The launcher and quiver it shoots with, until when they are known, and until when it does not try to shoot.
#define BB_ROGUE_NPC_LAUNCHER "rogue_npc_launcher"
#define BB_ROGUE_NPC_QUIVER "rogue_npc_quiver"
#define BB_ROGUE_NPC_KIT_AT "rogue_npc_kit_at"
#define BB_ROGUE_NPC_NO_SHOT_UNTIL "rogue_npc_no_shot_until"
/// When it may next do each of these.
#define BB_ROGUE_NPC_HELP_AT "rogue_npc_help_at"
#define BB_ROGUE_NPC_POTION_AT "rogue_npc_potion_at"
#define BB_ROGUE_NPC_BANDAGE_AT "rogue_npc_bandage_at"
#define BB_ROGUE_NPC_THROW_AT "rogue_npc_throw_at"
#define BB_ROGUE_NPC_JUMP_AT "rogue_npc_jump_at"
#define BB_ROGUE_NPC_LOOT_AT "rogue_npc_loot_at"
#define BB_ROGUE_NPC_SEEK_AT "rogue_npc_seek_at"
/// Ratwood next_passive_detect: after failing to spot a sneaker it does not look by itself before this.
#define BB_ROGUE_NPC_SEEK_PAUSE "rogue_npc_seek_pause"
/// Things it would not pick up, with when it gave up on them.
#define BB_ROGUE_NPC_LOOT_IGNORED "rogue_npc_loot_ignored"

#define NPC_SEARCH_PAUSE rogue_value("npc_search_pause")
#define NPC_POTION_DAMAGE rogue_value("npc_potion_damage")
#define NPC_POTION_COOLDOWN rogue_value("npc_potion_cooldown")
#define NPC_BANDAGE_COOLDOWN rogue_value("npc_bandage_cooldown")
#define NPC_HELP_DAMAGE rogue_value("npc_help_damage")
#define NPC_HELP_COOLDOWN rogue_value("npc_help_cooldown")
#define NPC_HELP_RANGE rogue_value("npc_help_range")
#define NPC_HARASS_HEALTH rogue_value("npc_harass_health")
#define NPC_HARASS_FATIGUE rogue_value("npc_harass_fatigue")
#define NPC_HARASS_RETREAT rogue_value("npc_harass_retreat")
#define NPC_HARASS_PAUSE rogue_value("npc_harass_pause")
#define NPC_HARASS_PAUSE_PER_STAMINA rogue_value("npc_harass_pause_per_stamina")
#define NPC_HARASS_HURT_FACTOR rogue_value("npc_harass_hurt_factor")
#define NPC_FLANK_RANGE rogue_value("npc_flank_range")
#define NPC_FLANK_RADIUS rogue_value("npc_flank_radius")
#define NPC_FLANK_GAP rogue_value("npc_flank_gap")
#define NPC_FLANK_ENGAGE rogue_value("npc_flank_engage")
#define NPC_FLANK_COMMIT rogue_value("npc_flank_commit")
#define NPC_FLANK_RECHECK rogue_value("npc_flank_recheck")
#define NPC_SHOT_MIN_RANGE rogue_value("npc_shot_min_range")
#define NPC_SHOT_RANGE rogue_value("npc_shot_range")
#define NPC_SHOT_DRAW_MAX rogue_value("npc_shot_draw_max")
#define NPC_KIT_CACHE rogue_value("npc_kit_cache")
/// rogue_npc_shoot(): the launcher could not be readied.
#define NPC_SHOT_JAMMED -1
#define NPC_THROW_MIN rogue_value("npc_throw_min")
#define NPC_THROW_MAX rogue_value("npc_throw_max")
#define NPC_THROW_COOLDOWN rogue_value("npc_throw_cooldown")
#define NPC_LOOT_RANGE rogue_value("npc_loot_range")
#define NPC_LOOT_INTERVAL rogue_value("npc_loot_interval")
#define NPC_LOOT_CARRY rogue_value("npc_loot_carry")
#define NPC_LOOT_IGNORE rogue_value("npc_loot_ignore")
#define NPC_LOOT_PATIENCE rogue_value("npc_loot_patience")
#define NPC_JUMP_CHANCE rogue_value("npc_jump_chance")
#define NPC_JUMP_DISTANCE rogue_value("npc_jump_distance")
#define NPC_JUMP_FATIGUE rogue_value("npc_jump_fatigue")
#define NPC_JUMP_COOLDOWN rogue_value("npc_jump_cooldown")
#define NPC_TAUNT_CHANCE rogue_value("npc_taunt_chance")
#define NPC_GRAB_ARMED rogue_value("npc_grab_armed")
#define NPC_GRAB_UNARMED rogue_value("npc_grab_unarmed")
#define NPC_GRAB_USE rogue_value("npc_grab_use")
#define NPC_GRAB_UPGRADE rogue_value("npc_grab_upgrade")
#define NPC_GRAB_CLUMSY rogue_value("npc_grab_clumsy")
#define NPC_GRAB_CLUMSY_USE rogue_value("npc_grab_clumsy_use")
#define NPC_SNEAK_SEEK rogue_value("npc_sneak_seek")
#define NPC_SNEAK_RANGE rogue_value("npc_sneak_range")
#define NPC_SNEAK_PER_PERCEPTION rogue_value("npc_sneak_per_perception")
#define NPC_SNEAK_PASSIVE rogue_value("npc_sneak_passive")
#define NPC_SNEAK_SKILL rogue_value("npc_sneak_skill")
#define NPC_SNEAK_LOUD_ARMOR rogue_value("npc_sneak_loud_armor")
#define NPC_SNEAK_LUCK rogue_value("npc_sneak_luck")
#define NPC_SNEAK_HURT rogue_value("npc_sneak_hurt")
#define NPC_SNEAK_FRANTIC rogue_value("npc_sneak_frantic")

/// What an NPC throws and gathers to throw: Ratwood's throwing knives (Vibelin AI_ITEM_THROWING) and javelins.
GLOBAL_LIST_INIT(rogue_npc_throwables, typecacheof(list(
	/obj/item/rogueweapon/huntingknife/throwingknife,
	/obj/item/ammo_casing/caseless/rogue/javelin,
)))

/// What a potion an NPC drinks when hurt holds (Vibelin AI_ITEM_HEALING_DRINK, the alchemist's healing potions).
GLOBAL_LIST_INIT(rogue_npc_healing_reagents, list(
	/datum/reagent/medicine/healthpot,
	/datum/reagent/medicine/stronghealth,
))

/// The kinds that taunt and leap otherwise than the rest (Ratwood rude, npc_jump_chance, npc_jump_distance of goblin.dm, orc.dm,
/// skeleton.dm, deadite.dm and the like) are the porter's (rockhill/ported/npcs.dm).
/mob/living/carbon/human
	/// Ratwood rude: laughs at and points to a foe out of its reach.
	var/rogue_npc_rude = FALSE
	/// Ratwood npc_jump_chance and npc_jump_distance: how likely it leaps at a far foe and from how far; null - npc_jump_chance
	/// and npc_jump_distance of pve.txt.
	var/rogue_npc_jump_chance
	var/rogue_npc_jump_distance

// The mind.

/// The NPC's roots, highest first: breaking free, running when badly hurt (the fleeing kinds), tending its wounds, then the fight
/// or its idle pastimes, with the search for foes and for sneakers alongside.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_roots()
	. = list(/datum/bt_node/subtree/escape_captivity)
	if(rogue_flees)
		. += /datum/bt_node/subtree/run_away_from_target
	. += /datum/bt_node/subtree/rogue_npc_self_care
	. += list(rogue_npc_mind())

/// TG's simple_hostile_combat with the NPC's fight and its pastimes: a parallel of what it does (fighting while it has a foe,
/// else gathering, taunting, walking about) and of what it watches (foes, sneakers).
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_mind()
	var/list/actions = list(
		list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_call_help, "target_key" = BB_CURRENT_TARGET),
		list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_spot_target, "target_key" = BB_CURRENT_TARGET),
		list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_taunt, "target_key" = BB_CURRENT_TARGET),
		list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_harass, "target_key" = BB_CURRENT_TARGET),
		list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_shoot, "target_key" = BB_CURRENT_TARGET),
		list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_throw, "target_key" = BB_CURRENT_TARGET),
		list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_jump, "target_key" = BB_CURRENT_TARGET),
		list(
			BT_DESC_TYPE = /datum/bt_node/ai_behavior/basic_melee_attack,
			"target_key" = BB_CURRENT_TARGET,
			"targeting_strategy" = BB_TARGETING_STRATEGY,
			"hiding_location_key" = BB_CURRENT_TARGET_HIDING_LOCATION,
		),
	)
	var/list/fight = list(
		BT_DESC_TYPE = /datum/bt_node/composite/parallel,
		"failure_policy" = BT_PARALLEL_FAILURE_ANY,
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,
		"repeat_secondary" = TRUE,
		"finish_on_primary" = TRUE,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/subplan,
				"success_policy" = BT_SUBPLAN_LOOP_ON_SUCCESS,
				"failure_policy" = BT_SUBPLAN_LOOP_ON_FAILURE,
				BT_DESC_CHILDREN = list(list(
					BT_DESC_TYPE = /datum/bt_node/composite/selector,
					BT_DESC_CHILDREN = actions,
				)),
			),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_maneuver, "target_key" = BB_CURRENT_TARGET),
		),
	)
	return list(
		BT_DESC_TYPE = /datum/bt_node/composite/parallel,
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,
		"repeat_secondary" = TRUE,
		"repeat_secondary_delay" = BASIC_MOB_FIND_TARGET_RATE,
		"finish_on_primary" = TRUE,
		BT_DESC_CHILDREN = list(
			list(
				BT_DESC_TYPE = /datum/bt_node/composite/selector,
				BT_DESC_CHILDREN = list(
					list(
						BT_DESC_TYPE = /datum/bt_node/decorator/bb_key_set,
						"key" = BB_CURRENT_TARGET,
						"observer_abort" = BT_ABORT_BOTH,
						BT_DESC_CHILDREN = list(fight),
					),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_scavenge),
					list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_taunt, "target_key" = BB_CURRENT_TARGET),
					list(BT_DESC_TYPE = /datum/bt_node/subtree/random_walk),
				),
			),
			list(
				BT_DESC_TYPE = rogue_hunts ? /datum/bt_node/ai_behavior/acquire_target/update_combat_targets : /datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list,
				"target_key" = BB_CURRENT_TARGET,
				"targeting_strategy" = BB_TARGETING_STRATEGY,
				"hiding_location_key" = BB_CURRENT_TARGET_HIDING_LOCATION,
			),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_seek_hidden),
		),
	)

/// The fight is over: what belonged to it goes.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_forget_fight()
	clear_blackboard_key(BB_ROGUE_NPC_HARASS_UNTIL)
	clear_blackboard_key(BB_ROGUE_NPC_RETREAT_TURF)
	clear_blackboard_key(BB_ROGUE_NPC_FLANK_ANGLE)
	clear_blackboard_key(BB_ROGUE_NPC_FLANK_TURF)
	clear_blackboard_key(BB_ROGUE_NPC_FLANK_AT)

/// Backing off after a blow (rogue_npc_harass).
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_harassing()
	return world.time < blackboard[BB_ROGUE_NPC_HARASS_UNTIL]

// What the NPC carries.

/// What the NPC carries where a hand can get at it: in its hands and on it, what lies in its bags and pouches, and its quivers'
/// rounds.
/mob/living/carbon/human/proc/rogue_npc_gear()
	. = list()
	for(var/obj/item/carried as anything in get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		. += carried
		if(carried.atom_storage || istype(carried, /obj/item/rogue_quiver))
			for(var/obj/item/inside in carried)
				. += inside

/proc/rogue_npc_is_potion(obj/item/thing)
	if(!istype(thing, /obj/item/reagent_containers/cup) || !thing.reagents?.total_volume)
		return FALSE
	for(var/reagent_type in GLOB.rogue_npc_healing_reagents)
		if(thing.reagents.has_reagent(reagent_type))
			return TRUE
	return FALSE

/proc/rogue_npc_is_clean_cloth(obj/item/thing)
	var/obj/item/natural/cloth/cloth = thing
	return istype(cloth) && !cloth.rogue_soaked

/mob/living/carbon/human/proc/rogue_npc_find_potion()
	for(var/obj/item/carried as anything in rogue_npc_gear())
		if(rogue_npc_is_potion(carried))
			return carried

/mob/living/carbon/human/proc/rogue_npc_find_cloth()
	for(var/obj/item/carried as anything in rogue_npc_gear())
		if(rogue_npc_is_clean_cloth(carried))
			return carried

/mob/living/carbon/human/proc/rogue_npc_find_throwable()
	for(var/obj/item/carried as anything in rogue_npc_gear())
		if(is_type_in_typecache(carried, GLOB.rogue_npc_throwables))
			return carried

/// Takes a thing it carries into a free hand, putting away what the other hand holds if both are full.
/mob/living/carbon/human/proc/rogue_npc_take_in_hand(obj/item/thing)
	if(is_holding(thing))
		return TRUE
	if(!length(get_empty_held_indexes()))
		rogue_npc_put_away(get_inactive_held_item())
	if(!length(get_empty_held_indexes()))
		return FALSE
	if(get_slot_by_item(thing) && !temporarilyRemoveItemFromInventory(thing))
		return FALSE
	return put_in_hands(thing)

/// Puts a held thing back on itself (a slot, else a bag), or down; an emptied vessel is dropped (Vibelin drop_empty_container).
/mob/living/carbon/human/proc/rogue_npc_put_away(obj/item/thing)
	if(QDELETED(thing) || !is_holding(thing))
		return
	if(istype(thing, /obj/item/reagent_containers) && !thing.reagents?.total_volume)
		dropItemToGround(thing)
		return
	if(equip_to_appropriate_slot(thing))
		return
	for(var/obj/item/worn as anything in get_equipped_items())
		if(worn.atom_storage?.attempt_insert(thing, src, messages = FALSE))
			return
	dropItemToGround(thing)

// Tending its wounds (Vibelin use_healing_drink, use_bandage).

/// Wounds come before the fight: a hurt NPC drinks, a bleeding one out of a fight binds the limb.
/datum/bt_node/subtree/rogue_npc_self_care

/datum/bt_node/subtree/rogue_npc_self_care/New()
	behavior_nodes = list(
		BT_DESC_TYPE = /datum/bt_node/composite/selector,
		BT_DESC_CHILDREN = list(
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_drink),
			list(BT_DESC_TYPE = /datum/bt_node/ai_behavior/rogue_npc_bandage),
		),
	)
	return ..()

/// Vibelin consume_healing_drink: with npc_potion_damage of brute or burn it drinks a healing potion it carries, once in
/// npc_potion_cooldown.
/datum/bt_node/ai_behavior/rogue_npc_drink
	var/datum/weakref/potion_ref

/datum/bt_node/ai_behavior/rogue_npc_drink/setup(datum/ai_controller/controller)
	var/mob/living/carbon/human/drinker = controller.pawn
	if(!istype(drinker) || world.time < controller.blackboard[BB_ROGUE_NPC_POTION_AT])
		return FALSE
	if(drinker.get_brute_loss() < NPC_POTION_DAMAGE && drinker.get_fire_loss() < NPC_POTION_DAMAGE)
		return FALSE
	var/obj/item/potion = drinker.rogue_npc_find_potion()
	if(!potion)
		controller.set_blackboard_key(BB_ROGUE_NPC_POTION_AT, world.time + NPC_SEARCH_PAUSE)
		return FALSE
	potion_ref = WEAKREF(potion)
	return TRUE

/datum/bt_node/ai_behavior/rogue_npc_drink/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags
	return start_async()

/datum/bt_node/ai_behavior/rogue_npc_drink/perform_async(datum/ai_controller/controller)
	var/mob/living/carbon/human/drinker = controller.pawn
	controller.set_blackboard_key(BB_ROGUE_NPC_POTION_AT, world.time + NPC_POTION_COOLDOWN)
	var/drank = drinker.rogue_npc_drink(potion_ref?.resolve())
	if(!async_still_valid())
		return
	finish_async(drank ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/datum/bt_node/ai_behavior/rogue_npc_drink/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	potion_ref = null

/// A gulp of the potion, uncorked and drunk from the hand; then it goes back, or down when empty.
/mob/living/carbon/human/proc/rogue_npc_drink(obj/item/reagent_containers/cup/potion)
	if(!istype(potion) || QDELETED(potion) || !rogue_npc_take_in_hand(potion))
		return FALSE
	var/obj/item/reagent_containers/glass/bottle/bottle = potion
	if(istype(bottle) && bottle.corked)
		bottle.toggle_cork(src)
	. = !!(potion.try_drink(src, src) & ITEM_INTERACT_SUCCESS)
	rogue_npc_put_away(potion)

/// Vibelin apply_bandage: out of a fight it binds a bleeding limb with a clean cloth it carries, once in npc_bandage_cooldown.
/datum/bt_node/ai_behavior/rogue_npc_bandage
	var/datum/weakref/cloth_ref
	var/zone

/datum/bt_node/ai_behavior/rogue_npc_bandage/setup(datum/ai_controller/controller)
	var/mob/living/carbon/human/patient = controller.pawn
	if(!istype(patient) || controller.blackboard_key_exists(BB_CURRENT_TARGET) || world.time < controller.blackboard[BB_ROGUE_NPC_BANDAGE_AT])
		return FALSE
	controller.set_blackboard_key(BB_ROGUE_NPC_BANDAGE_AT, world.time + NPC_SEARCH_PAUSE)
	var/obj/item/bodypart/limb = patient.rogue_npc_bleeding_limb()
	if(!limb)
		return FALSE
	var/obj/item/cloth = patient.rogue_npc_find_cloth()
	if(!cloth)
		return FALSE
	cloth_ref = WEAKREF(cloth)
	zone = limb.body_zone
	return TRUE

/datum/bt_node/ai_behavior/rogue_npc_bandage/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags
	return start_async()

/datum/bt_node/ai_behavior/rogue_npc_bandage/perform_async(datum/ai_controller/controller)
	var/mob/living/carbon/human/patient = controller.pawn
	controller.set_blackboard_key(BB_ROGUE_NPC_BANDAGE_AT, world.time + NPC_BANDAGE_COOLDOWN)
	var/bound = patient.rogue_npc_bandage(cloth_ref?.resolve(), zone)
	if(!async_still_valid())
		return
	finish_async(bound ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/datum/bt_node/ai_behavior/rogue_npc_bandage/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	cloth_ref = null
	zone = null

/// The first bleeding limb that has no bandage yet.
/mob/living/carbon/human/proc/rogue_npc_bleeding_limb()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!limb.rogue_bandage && limb.rogue_limb_bleed_rate() > 0)
			return limb

/// Binds the limb of this zone with the cloth (combat/medicine.dm rogue_bandage()); a cloth left over goes back.
/mob/living/carbon/human/proc/rogue_npc_bandage(obj/item/natural/cloth/cloth, zone)
	if(!istype(cloth) || QDELETED(cloth) || !zone || !rogue_npc_take_in_hand(cloth))
		return FALSE
	var/old_zone = zone_selected
	zone_selected = zone
	cloth.rogue_bandage(src, src)
	zone_selected = old_zone
	if(is_holding(cloth))
		rogue_npc_put_away(cloth)
		return FALSE
	return TRUE

// Fighting.

/// Vibelin call_for_help: badly hurt (npc_help_damage of brute or burn), it screams and its own kind around it that do not
/// fight its foe yet turn on it; once in npc_help_cooldown.
/datum/bt_node/ai_behavior/rogue_npc_call_help
	var/target_key

/datum/bt_node/ai_behavior/rogue_npc_call_help/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/carbon/human/crier = controller.pawn
	var/mob/living/foe = controller.blackboard[target_key]
	if(!isliving(foe) || world.time < controller.blackboard[BB_ROGUE_NPC_HELP_AT])
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(crier.get_brute_loss() < NPC_HELP_DAMAGE && crier.get_fire_loss() < NPC_HELP_DAMAGE)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/list/allies = list()
	for(var/mob/living/carbon/human/ally in range(NPC_HELP_RANGE, crier))
		if(ally == crier || ally.client || ally.stat == DEAD || !crier.faction_check_atom(ally))
			continue
		var/datum/ai_controller/basic_controller/simple/rogue_human/mind = ally.ai_controller
		if(istype(mind) && mind.blackboard[BB_CURRENT_TARGET] != foe)
			allies += mind
	if(!length(allies))
		controller.set_blackboard_key(BB_ROGUE_NPC_HELP_AT, world.time + NPC_SEARCH_PAUSE)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(BB_ROGUE_NPC_HELP_AT, world.time + NPC_HELP_COOLDOWN)
	crier.emote("scream")
	for(var/datum/ai_controller/mind as anything in allies)
		mind.set_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, foe, world.time)
		mind.set_blackboard_key(BB_CURRENT_TARGET, foe)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Ratwood handle_combat(): when its foe has vanished into hiding it tries once to spot it again.
/datum/bt_node/ai_behavior/rogue_npc_spot_target
	var/target_key
	/// The hider it already tried for, so it tries once a hiding.
	var/datum/weakref/tried_ref

/datum/bt_node/ai_behavior/rogue_npc_spot_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/carbon/human/seeker = controller.pawn
	var/mob/living/carbon/human/hider = controller.blackboard[target_key]
	if(!istype(hider) || !hider.rogue_is_hidden())
		tried_ref = null
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(tried_ref?.resolve() == hider)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	tried_ref = WEAKREF(hider)
	if(!seeker.rogue_npc_spot(hider))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Ratwood npc_taunt_target(): a rude NPC laughs at or points to a foe right above it (in a tree), out of its reach - its foe,
/// or anyone not of its kind up there when it has none.
/datum/bt_node/ai_behavior/rogue_npc_taunt
	var/target_key

/datum/bt_node/ai_behavior/rogue_npc_taunt/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/carbon/human/rogue = controller.pawn
	if(!rogue.rogue_npc_rude || !prob(NPC_TAUNT_CHANCE))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/living/foe = rogue.rogue_npc_foe_above(controller.blackboard[target_key])
	if(!foe)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	rogue.rogue_npc_taunt(foe)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// The foe right above, seen through open space: its target if that is where it is, else someone not of its kind.
/mob/living/carbon/human/proc/rogue_npc_foe_above(atom/target)
	var/turf/here = get_turf(src)
	if(!here)
		return null
	var/turf/above = GET_TURF_ABOVE(here)
	if(!above || !istransparentturf(above))
		return null
	if(isliving(target) && get_turf(target) == above)
		return target
	for(var/mob/living/up_there in above)
		if(up_there.stat != DEAD && up_there.invisibility <= see_invisible && !faction_check_atom(up_there))
			return up_there
	return null

/mob/living/carbon/human/proc/rogue_npc_taunt(mob/living/foe)
	if(usable_hands && !HAS_TRAIT(src, TRAIT_RESTRAINED) && prob(50))
		point_at(foe)
		return
	emote("laugh")

/// Ratwood npc_try_jump(): now and then (rogue_npc_jump_chance, a roll every npc_jump_cooldown) it leaps at a foe farther than
/// its jump distance, if the way there is clear and it is not too winded (npc_jump_fatigue).
/datum/bt_node/ai_behavior/rogue_npc_jump
	var/target_key

/datum/bt_node/ai_behavior/rogue_npc_jump/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/carbon/human/leaper = controller.pawn
	var/atom/foe = controller.blackboard[target_key]
	if(QDELETED(foe) || world.time < controller.blackboard[BB_ROGUE_NPC_JUMP_AT])
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(BB_ROGUE_NPC_JUMP_AT, world.time + NPC_JUMP_COOLDOWN)
	var/chance = isnull(leaper.rogue_npc_jump_chance) ? NPC_JUMP_CHANCE : leaper.rogue_npc_jump_chance
	if(!prob(chance) || leaper.get_stamina_loss() > NPC_JUMP_FATIGUE || foe.z != leaper.z)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/distance = get_dist(leaper, foe)
	if(distance <= (isnull(leaper.rogue_npc_jump_distance) ? NPC_JUMP_DISTANCE : leaper.rogue_npc_jump_distance))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/range = leaper.move_intent == MOVE_INTENT_RUN ? ROGUE_JUMP_RUN_RANGE : ROGUE_JUMP_WALK_RANGE
	if(!rogue_npc_clear_way(leaper, foe, min(distance - 1, range)) || !leaper.rogue_try_jump(foe))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Ratwood inLineOfTravel(): the first tiles of the straight way to the target are free to cross.
/proc/rogue_npc_clear_way(atom/from, atom/to_atom, tiles)
	var/turf/start = get_turf(from)
	var/count = 0
	for(var/turf/crossed as anything in get_line(start, get_turf(to_atom)))
		if(crossed == start)
			continue
		if(++count > tiles)
			break
		if(crossed.is_blocked_turf(exclude_mobs = TRUE))
			return FALSE
	return TRUE

/// Vibelin wounded_harass: hurt (below npc_harass_health of its health) or winded (stamina spent past npc_harass_fatigue of it,
/// sooner the more it is hurt), it strikes its foe once and backs off up to npc_harass_retreat tiles for a while
/// (npc_harass_pause, longer the more it is winded and hurt), then darts in for the next blow.
/datum/bt_node/ai_behavior/rogue_npc_harass
	var/target_key

/datum/bt_node/ai_behavior/rogue_npc_harass/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/carbon/human/fighter = controller.pawn
	var/mob/living/foe = controller.blackboard[target_key]
	if(!isliving(foe))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(world.time < controller.blackboard[BB_ROGUE_NPC_HARASS_UNTIL])
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	controller.clear_blackboard_key(BB_ROGUE_NPC_RETREAT_TURF)
	if(!fighter.rogue_npc_wants_harass())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(world.time < fighter.next_move || !foe.IsReachableBy(fighter))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])
	if(!strategy?.is_valid_target(fighter, foe, controller = controller))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(BB_ROGUE_NPC_HARASS_UNTIL, world.time + fighter.rogue_npc_harass_pause())
	controller.set_blackboard_key(BB_ROGUE_NPC_RETREAT_TURF, fighter.rogue_npc_retreat_turf(foe))
	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), foe, TRUE)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/mob/living/carbon/human/proc/rogue_npc_wants_harass()
	var/health_share = maxHealth > 0 ? health / maxHealth : 1
	return health_share < NPC_HARASS_HEALTH || get_stamina_loss() > max_stamina * NPC_HARASS_FATIGUE * health_share

/// Vibelin's pause after the blow: npc_harass_pause, more for every point of stamina spent past the threshold, up to
/// npc_harass_hurt_factor times at no health.
/mob/living/carbon/human/proc/rogue_npc_harass_pause()
	var/health_share = clamp(maxHealth > 0 ? health / maxHealth : 1, 0, 1)
	var/winded = max(get_stamina_loss() - max_stamina * NPC_HARASS_FATIGUE, 0)
	return (NPC_HARASS_PAUSE + winded * NPC_HARASS_PAUSE_PER_STAMINA) * (1 + (NPC_HARASS_HURT_FACTOR - 1) * (1 - health_share))

/// The tile to back off to: straight away from the foe, as far as the way is free.
/mob/living/carbon/human/proc/rogue_npc_retreat_turf(atom/foe)
	var/turf/spot = get_turf(src)
	var/away = REVERSE_DIR(get_dir(src, foe))
	for(var/i in 1 to NPC_HARASS_RETREAT)
		var/turf/next = get_step(spot, away)
		if(!next || next.is_blocked_turf(exclude_mobs = TRUE) || !next.can_cross_safely(src))
			break
		spot = next
	return spot

/// Vibelin ranged_attack_bow: with a bow, crossbow or sling and rounds for it, it shoots a foe that is not close
/// (npc_shot_min_range) and that it sees within npc_shot_range: the launcher to hand (the melee weapon put away, a bow wants the
/// other hand free), the shooting intent, a crossbow cocked, a round nocked or loaded, the draw (the intent's own, at most
/// npc_shot_draw_max), the shot.
/datum/bt_node/ai_behavior/rogue_npc_shoot
	var/target_key

/datum/bt_node/ai_behavior/rogue_npc_shoot/setup(datum/ai_controller/controller)
	var/mob/living/carbon/human/archer = controller.pawn
	var/atom/foe = controller.blackboard[target_key]
	if(!isliving(foe) || HAS_TRAIT(archer, TRAIT_HANDS_BLOCKED) || foe.z != archer.z)
		return FALSE
	var/distance = get_dist(archer, foe)
	if(distance < NPC_SHOT_MIN_RANGE || distance > NPC_SHOT_RANGE)
		return FALSE
	var/datum/ai_controller/basic_controller/simple/rogue_human/mind = controller
	return istype(mind) && mind.rogue_npc_ranged_kit(TRUE) && can_see(archer, foe, NPC_SHOT_RANGE)

/datum/bt_node/ai_behavior/rogue_npc_shoot/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags
	return start_async()

/datum/bt_node/ai_behavior/rogue_npc_shoot/perform_async(datum/ai_controller/controller)
	var/datum/ai_controller/basic_controller/simple/rogue_human/mind = controller
	var/shot = mind.rogue_npc_shoot(controller.blackboard[target_key])
	if(shot == NPC_SHOT_JAMMED && !QDELETED(mind))
		mind.set_blackboard_key(BB_ROGUE_NPC_NO_SHOT_UNTIL, world.time + NPC_KIT_CACHE)
	if(!async_still_valid())
		return
	finish_async(shot == TRUE ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/// The launcher it carries and the quiver that feeds it, known for npc_kit_cache; with need_ammo only when there is a round for
/// it, in it or in the quiver. Null after a shot went wrong (npc_kit_cache) and without a launcher.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_ranged_kit(need_ammo)
	if(world.time < blackboard[BB_ROGUE_NPC_NO_SHOT_UNTIL])
		return null
	var/mob/living/carbon/human/archer = pawn
	var/obj/item/gun/ballistic/rogue_launcher/launcher = blackboard[BB_ROGUE_NPC_LAUNCHER]
	var/obj/item/rogue_quiver/quiver = blackboard[BB_ROGUE_NPC_QUIVER]
	if(world.time >= blackboard[BB_ROGUE_NPC_KIT_AT] || (launcher && get(launcher, /mob) != archer) || (quiver && get(quiver, /mob) != archer))
		launcher = null
		quiver = null
		var/list/gear = archer.get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD)
		for(var/obj/item/gun/ballistic/rogue_launcher/carried in gear)
			launcher = carried
			break
		if(launcher)
			for(var/obj/item/rogue_quiver/carried in gear)
				if(!quiver || rogue_npc_compatible_round(carried, launcher))
					quiver = carried
				if(rogue_npc_compatible_round(carried, launcher))
					break
		set_blackboard_key(BB_ROGUE_NPC_KIT_AT, world.time + NPC_KIT_CACHE)
		if(launcher)
			set_blackboard_key(BB_ROGUE_NPC_LAUNCHER, launcher)
		else
			clear_blackboard_key(BB_ROGUE_NPC_LAUNCHER)
		if(quiver)
			set_blackboard_key(BB_ROGUE_NPC_QUIVER, quiver)
		else
			clear_blackboard_key(BB_ROGUE_NPC_QUIVER)
	if(!launcher)
		return null
	if(need_ammo && !launcher.chambered && !rogue_npc_compatible_round(quiver, launcher))
		return null
	return list(launcher, quiver)

/// The first round in the quiver the launcher takes.
/proc/rogue_npc_compatible_round(obj/item/rogue_quiver/quiver, obj/item/gun/ballistic/launcher)
	if(!quiver || !launcher?.magazine)
		return null
	for(var/obj/item/ammo_casing/round in quiver)
		if(launcher.magazine.is_compatible_round(round))
			return round
	return null

/// One shot at the foe: TRUE when it went off, FALSE when the foe got away or the draw was broken, NPC_SHOT_JAMMED when the
/// launcher could not be readied (it is not tried again for npc_kit_cache). Sleeps: the cocking and the draw are do_afters.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_shoot(atom/foe)
	var/mob/living/carbon/human/archer = pawn
	var/list/kit = rogue_npc_ranged_kit(TRUE)
	if(!kit || QDELETED(foe))
		return FALSE
	var/obj/item/gun/ballistic/rogue_launcher/launcher = kit[1]
	var/obj/item/rogue_quiver/quiver = kit[2]
	if(!archer.rogue_npc_ready_launcher(launcher) || !archer.rogue_npc_aim_intent())
		return NPC_SHOT_JAMMED
	var/obj/item/gun/ballistic/rogue_launcher/crossbow/crossbow = launcher
	if(istype(crossbow) && !crossbow.chambered && !crossbow.cocked)
		crossbow.rogue_cock(archer)
		if(QDELETED(crossbow))
			return FALSE
		if(!crossbow.cocked)
			return archer.is_holding(crossbow) ? FALSE : NPC_SHOT_JAMMED
	if(!launcher.chambered)
		var/obj/item/ammo_casing/round = rogue_npc_compatible_round(quiver, launcher)
		if(!round || !launcher.load_gun(round, archer))
			return NPC_SHOT_JAMMED
	var/datum/intent/shot = archer.rogue_strike_intent(launcher)
	var/draw = shot?.chargetime ? min(shot.rogue_chargetime(archer, launcher), NPC_SHOT_DRAW_MAX) : 0
	if(draw > 0 && !do_after(archer, draw, archer))
		return FALSE
	if(QDELETED(foe) || QDELETED(launcher) || !archer.is_holding(launcher) || !launcher.chambered || !can_see(archer, foe, NPC_SHOT_RANGE))
		return FALSE
	archer.face_atom(foe)
	launcher.try_fire_gun(foe, archer, "")
	return TRUE

/// The launcher to the active hand; a bow wants the other hand free too, so what it holds is put away.
/mob/living/carbon/human/proc/rogue_npc_ready_launcher(obj/item/gun/ballistic/rogue_launcher/launcher)
	if(get_active_held_item() != launcher)
		if(is_holding(launcher))
			swap_hand(get_held_index_of_item(launcher))
		else
			rogue_npc_put_away(get_active_held_item())
			if(get_active_held_item())
				return FALSE
			if(get_slot_by_item(launcher) && !temporarilyRemoveItemFromInventory(launcher))
				return FALSE
			if(!put_in_active_hand(launcher))
				return FALSE
	if(istype(launcher, /obj/item/gun/ballistic/rogue_launcher/bow))
		rogue_npc_put_away(get_inactive_held_item())
	return get_active_held_item() == launcher

/// Selects the first shooting intent of the held launcher.
/mob/living/carbon/human/proc/rogue_npc_aim_intent()
	var/list/intents = rogue_hand_intents()
	for(var/slot in 1 to min(length(intents), ROGUE_INTENT_SLOTS))
		var/datum/intent/intent = rogue_intent(intents[slot])
		if(intent?.tranged)
			rogue_select_intent(slot)
			return TRUE
	return FALSE

/// Vibelin use_throwable: a throwing knife or javelin it carries, at a foe it sees between npc_throw_min and npc_throw_max
/// tiles away (and within the missile's throw range), once in npc_throw_cooldown.
/datum/bt_node/ai_behavior/rogue_npc_throw
	var/target_key

/datum/bt_node/ai_behavior/rogue_npc_throw/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/carbon/human/thrower = controller.pawn
	var/mob/living/foe = controller.blackboard[target_key]
	if(!isliving(foe) || foe.z != thrower.z || world.time < controller.blackboard[BB_ROGUE_NPC_THROW_AT])
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/distance = get_dist(thrower, foe)
	if(distance < NPC_THROW_MIN || distance > NPC_THROW_MAX)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(BB_ROGUE_NPC_THROW_AT, world.time + NPC_THROW_COOLDOWN)
	var/obj/item/missile = thrower.rogue_npc_find_throwable()
	if(!missile || distance > missile.throw_range || !can_see(thrower, foe, NPC_THROW_MAX) || !thrower.rogue_npc_throw(missile, foe))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Throws the missile with a free hand, the weapon hand kept as it was.
/mob/living/carbon/human/proc/rogue_npc_throw(obj/item/missile, atom/foe)
	var/hand = get_held_index_of_item(missile)
	if(!hand)
		var/list/free = get_empty_held_indexes()
		if(!length(free))
			return FALSE
		hand = free[1]
		if(get_slot_by_item(missile) && !temporarilyRemoveItemFromInventory(missile))
			return FALSE
		if(!put_in_hand(missile, hand))
			return FALSE
	var/old_hand = active_hand_index
	if(hand != old_hand)
		swap_hand(hand, silent = TRUE)
	face_atom(foe)
	. = throw_item(foe)
	if(active_hand_index != old_hand)
		swap_hand(old_hand, silent = TRUE)

/// Where the NPC goes while it fights: backing off after a blow (rogue_npc_harass), keeping its distance and holding still to
/// shoot while it can shoot and the foe is not close, to its flank of the foe (rogue_npc_flank_turf()), else to the foe.
/datum/bt_node/ai_behavior/rogue_npc_maneuver
	var/target_key
	var/movement_failed = FALSE
	/// Where it is heading, and how near it means to get.
	var/datum/weakref/heading_ref
	var/heading_distance = -1

/datum/bt_node/ai_behavior/rogue_npc_maneuver/setup(datum/ai_controller/controller)
	if(QDELETED(controller.blackboard[target_key]))
		return FALSE
	RegisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED, PROC_REF(on_movement_failed))
	return TRUE

/datum/bt_node/ai_behavior/rogue_npc_maneuver/proc/on_movement_failed(atom/source)
	SIGNAL_HANDLER
	movement_failed = TRUE

/datum/bt_node/ai_behavior/rogue_npc_maneuver/perform(seconds_per_tick, datum/ai_controller/controller)
	if(movement_failed)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/living/carbon/human/fighter = controller.pawn
	var/atom/foe = controller.blackboard[target_key]
	var/datum/ai_controller/basic_controller/simple/rogue_human/mind = controller
	if(QDELETED(foe) || !istype(mind))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/turf/retreat = controller.blackboard[BB_ROGUE_NPC_RETREAT_TURF]
	if(retreat && mind.rogue_npc_harassing())
		fighter.face_atom(foe)
		head(controller, retreat, 0)
		return AI_BEHAVIOR_INSTANT
	var/distance = get_dist(fighter, foe)
	if(distance >= NPC_SHOT_MIN_RANGE && !HAS_TRAIT(fighter, TRAIT_HANDS_BLOCKED) && mind.rogue_npc_ranged_kit(TRUE))
		if(distance <= NPC_SHOT_RANGE && can_see(fighter, foe, NPC_SHOT_RANGE))
			hold(controller)
			return AI_BEHAVIOR_INSTANT
		// Out of range it closes to it; in range but out of sight it walks in until it sees the foe (Ratwood need_los).
		head(controller, foe, distance > NPC_SHOT_RANGE ? NPC_SHOT_RANGE : 1)
		return AI_BEHAVIOR_INSTANT
	var/turf/flank = mind.rogue_npc_flank_turf(foe)
	head(controller, flank || foe, flank ? 0 : 1)
	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/rogue_npc_maneuver/proc/head(datum/ai_controller/controller, atom/destination, distance)
	if(heading_ref?.resolve() == destination && heading_distance == distance && controller.ai_movement.moving_controllers[controller])
		return
	controller.ai_movement.stop_moving_towards(controller)
	controller.ai_movement.start_moving_towards(controller, destination, distance)
	heading_ref = WEAKREF(destination)
	heading_distance = distance

/datum/bt_node/ai_behavior/rogue_npc_maneuver/proc/hold(datum/ai_controller/controller)
	if(heading_ref)
		controller.ai_movement.stop_moving_towards(controller)
	heading_ref = null
	heading_distance = -1

/datum/bt_node/ai_behavior/rogue_npc_maneuver/finish_action(datum/ai_controller/controller, succeeded)
	UnregisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED)
	movement_failed = FALSE
	heading_ref = null
	heading_distance = -1
	controller.ai_movement.stop_moving_towards(controller)
	return ..()

/// Vibelin squad_flank: with others of its kind on the same foe, it takes the middle of the widest gap between them around the
/// foe (when wider than npc_flank_gap degrees), npc_flank_radius tiles from it; looked at again every npc_flank_recheck. Near
/// its flank (npc_flank_engage) it commits to the fight now and then (npc_flank_commit). Null - no flank, go for the foe.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_flank_turf(atom/foe)
	var/mob/living/carbon/human/fighter = pawn
	if(world.time >= blackboard[BB_ROGUE_NPC_FLANK_AT])
		set_blackboard_key(BB_ROGUE_NPC_FLANK_AT, world.time + NPC_FLANK_RECHECK)
		rogue_npc_plan_flank(foe)
	var/turf/spot = blackboard[BB_ROGUE_NPC_FLANK_TURF]
	if(!spot)
		return null
	if(get_dist(fighter, spot) > NPC_FLANK_ENGAGE)
		return spot
	fighter.face_atom(foe)
	if(prob(NPC_FLANK_COMMIT))
		clear_blackboard_key(BB_ROGUE_NPC_FLANK_TURF)
		clear_blackboard_key(BB_ROGUE_NPC_FLANK_ANGLE)
	return null

/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_plan_flank(atom/foe)
	var/mob/living/carbon/human/fighter = pawn
	var/turf/foe_turf = get_turf(foe)
	var/list/angles = list()
	if(foe_turf)
		for(var/mob/living/carbon/human/ally in view(NPC_FLANK_RANGE, fighter))
			if(ally == fighter || ally.stat == DEAD || !fighter.faction_check_atom(ally))
				continue
			var/datum/ai_controller/basic_controller/simple/rogue_human/mind = ally.ai_controller
			if(!istype(mind) || mind.blackboard[BB_CURRENT_TARGET] != foe)
				continue
			var/turf/ally_turf = get_turf(ally)
			angles += round(arctan(ally_turf.x - foe_turf.x, ally_turf.y - foe_turf.y) + 360) % 360
	if(!length(angles))
		clear_blackboard_key(BB_ROGUE_NPC_FLANK_TURF)
		clear_blackboard_key(BB_ROGUE_NPC_FLANK_ANGLE)
		return
	angles = sort_list(angles, GLOBAL_PROC_REF(cmp_numeric_asc))
	var/widest = 0
	var/gap_start = 0
	for(var/i in 1 to length(angles))
		var/gap = (angles[(i % length(angles)) + 1] - angles[i] + 360) % 360
		if(length(angles) == 1)
			gap = 360
		if(gap > widest)
			widest = gap
			gap_start = angles[i]
	if(widest < NPC_FLANK_GAP)
		clear_blackboard_key(BB_ROGUE_NPC_FLANK_TURF)
		clear_blackboard_key(BB_ROGUE_NPC_FLANK_ANGLE)
		return
	var/angle = (gap_start + round(widest / 2)) % 360
	var/old_angle = blackboard[BB_ROGUE_NPC_FLANK_ANGLE]
	var/turf/spot = blackboard[BB_ROGUE_NPC_FLANK_TURF]
	if(spot && !isnull(old_angle))
		var/shift = abs(old_angle - angle)
		if(min(shift, 360 - shift) <= 30)
			return
	spot = locate(clamp(round(foe_turf.x + NPC_FLANK_RADIUS * cos(angle)), 1, world.maxx), clamp(round(foe_turf.y + NPC_FLANK_RADIUS * sin(angle)), 1, world.maxy), foe_turf.z)
	for(var/i in 1 to NPC_FLANK_RADIUS)
		if(!spot || (!spot.is_blocked_turf(exclude_mobs = TRUE) && spot.can_cross_safely(fighter)))
			break
		spot = get_step_towards(spot, foe_turf)
	if(!spot || spot.is_blocked_turf(exclude_mobs = TRUE))
		clear_blackboard_key(BB_ROGUE_NPC_FLANK_TURF)
		clear_blackboard_key(BB_ROGUE_NPC_FLANK_ANGLE)
		return
	set_blackboard_key(BB_ROGUE_NPC_FLANK_ANGLE, angle)
	set_blackboard_key(BB_ROGUE_NPC_FLANK_TURF, spot)

/// Ratwood do_best_melee_attack() grabs: with a grip on its foe in the other hand it uses it now and then (npc_grab_use; more
/// against the clumsy-fingered) - a passive grip it tightens (npc_grab_upgrade), a firm one it twists, chokes, shoves or smashes
/// into a wall or the floor, by where it holds; with a free other hand and its weapon not wielded in both, it grabs instead of
/// striking now and then (npc_grab_armed, npc_grab_unarmed without a weapon). TRUE when that was its move.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_try_grab(mob/living/carbon/human/fighter, mob/living/foe)
	var/obj/item/main = fighter.get_active_held_item()
	var/obj/item/off = fighter.get_inactive_held_item()
	var/clumsy = HAS_TRAIT(foe, TRAIT_CHUNKYFINGERS)
	var/obj/item/hand_item/rogue_grab/grip = off
	if(istype(grip))
		if(grip.grabbed != foe || fighter.pulling != foe || !prob(clumsy ? NPC_GRAB_CLUMSY_USE : NPC_GRAB_USE))
			return FALSE
		if(fighter.grab_state < GRAB_AGGRESSIVE)
			if(!prob(NPC_GRAB_UPGRADE))
				return FALSE
			fighter.changeNext_move(CLICK_CD_GRABBING)
			fighter.rogue_grab_upgrade(grip)
			return TRUE
		return rogue_use_grip(fighter, grip, foe)
	if(off || main?.rogue_wielded || !prob(clumsy ? NPC_GRAB_CLUMSY : (main ? NPC_GRAB_ARMED : NPC_GRAB_UNARMED)))
		return FALSE
	var/list/fists = fighter.rogue_fist_intents()
	var/grab_slot = 0
	for(var/slot in 1 to length(fists))
		if(ispath(fists[slot], /datum/intent/unarmed/grab))
			grab_slot = slot
			break
	if(!grab_slot)
		return FALSE
	fighter.swap_hand(fighter.get_inactive_hand_index())
	if(fighter.get_active_held_item())
		fighter.swap_hand(fighter.get_inactive_hand_index())
		return FALSE
	var/old_slot = fighter.rogue_intent_slot()
	fighter.rogue_select_intent(grab_slot)
	fighter.ClickOn(foe, "")
	fighter.rogue_select_intent(old_slot)
	fighter.swap_hand(fighter.get_inactive_hand_index())
	return TRUE

/// Ratwood npc_try_use_grab(): the grip's second move by where it holds (twist a limb, choke the neck, shove by the chest; smash
/// the head into a wall, or into the floor when they are down).
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_use_grip(mob/living/carbon/human/fighter, obj/item/hand_item/rogue_grab/grip, mob/living/foe)
	var/list/moves = grip.rogue_intents()
	if(length(moves) < 2)
		return FALSE
	var/datum/intent/grab/move = rogue_intent(moves[2])
	if(!istype(move))
		return FALSE
	fighter.changeNext_move(CLICK_CD_GRABBING)
	if(!istype(move, /datum/intent/grab/smash))
		return move.grab_target(grip, fighter)
	var/atom/place = rogue_smash_place(fighter, foe)
	return place ? move.grab_place(grip, fighter, place) : FALSE

/// Ratwood: something next to both to smash the held one into - a dense structure, else a wall for one standing or the floor
/// for one down.
/proc/rogue_smash_place(mob/living/fighter, mob/living/foe)
	for(var/obj/structure/thing in view(1, fighter))
		if(thing.density && foe.Adjacent(thing))
			return thing
	var/standing = foe.body_position == STANDING_UP
	for(var/turf/spot in view(1, fighter))
		if((standing ? isclosedturf(spot) : isopenturf(spot)) && foe.Adjacent(spot))
			return spot
	return null

// Gathering (Vibelin loot, retrieve_arrow).

/// Out of a fight, every npc_loot_interval it looks around (npc_loot_range) for what it can use and has too little of
/// (npc_loot_carry of each): a clean cloth, a healing potion, a throwing knife or javelin, a round for its quiver; it walks
/// there and takes it - the round into the quiver, the rest into a slot or a bag. What it cannot carry it leaves alone for
/// npc_loot_ignore.
/datum/bt_node/ai_behavior/rogue_npc_scavenge
	var/datum/weakref/wanted_ref
	var/movement_failed = FALSE
	/// When it gives up walking to the thing (npc_loot_patience).
	var/give_up_at = 0

/datum/bt_node/ai_behavior/rogue_npc_scavenge/setup(datum/ai_controller/controller)
	var/datum/ai_controller/basic_controller/simple/rogue_human/mind = controller
	if(!istype(mind) || world.time < controller.blackboard[BB_ROGUE_NPC_LOOT_AT])
		return FALSE
	controller.set_blackboard_key(BB_ROGUE_NPC_LOOT_AT, world.time + NPC_LOOT_INTERVAL)
	var/obj/item/wanted = mind.rogue_npc_find_loot()
	if(!wanted)
		return FALSE
	wanted_ref = WEAKREF(wanted)
	give_up_at = world.time + NPC_LOOT_PATIENCE
	RegisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED, PROC_REF(on_movement_failed))
	controller.ai_movement.stop_moving_towards(controller)
	controller.ai_movement.start_moving_towards(controller, wanted, 1)
	return TRUE

/datum/bt_node/ai_behavior/rogue_npc_scavenge/proc/on_movement_failed(atom/source)
	SIGNAL_HANDLER
	movement_failed = TRUE

/datum/bt_node/ai_behavior/rogue_npc_scavenge/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/item/wanted = wanted_ref?.resolve()
	if(movement_failed || QDELETED(wanted) || !isturf(wanted.loc) || world.time > give_up_at)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/living/carbon/human/scavenger = controller.pawn
	if(!scavenger.Adjacent(wanted))
		return AI_BEHAVIOR_INSTANT
	var/datum/ai_controller/basic_controller/simple/rogue_human/mind = controller
	if(!mind.rogue_npc_take_loot(wanted))
		controller.set_blackboard_key_assoc_lazylist(BB_ROGUE_NPC_LOOT_IGNORED, wanted, world.time + NPC_LOOT_IGNORE)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/rogue_npc_scavenge/finish_action(datum/ai_controller/controller, succeeded)
	UnregisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED)
	movement_failed = FALSE
	wanted_ref = null
	controller.ai_movement.stop_moving_towards(controller)
	return ..()

/// The nearest thing on the ground worth taking.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_find_loot()
	var/mob/living/carbon/human/scavenger = pawn
	var/list/kit = rogue_npc_ranged_kit(FALSE)
	var/obj/item/gun/ballistic/launcher = kit?[1]
	var/obj/item/rogue_quiver/quiver = kit?[2]
	var/rounds_wanted = quiver && length(quiver.contents) < quiver.max_storage
	var/cloths = 0
	var/potions = 0
	var/missiles = 0
	for(var/obj/item/carried as anything in scavenger.rogue_npc_gear())
		if(rogue_npc_is_clean_cloth(carried))
			cloths++
		else if(rogue_npc_is_potion(carried))
			potions++
		else if(is_type_in_typecache(carried, GLOB.rogue_npc_throwables))
			missiles++
	var/list/ignored = blackboard[BB_ROGUE_NPC_LOOT_IGNORED]
	var/obj/item/best
	var/best_distance = INFINITY
	for(var/obj/item/thing in view(NPC_LOOT_RANGE, scavenger))
		if(!isturf(thing.loc) || thing.anchored || HAS_TRAIT(thing, TRAIT_NODROP))
			continue
		if(LAZYACCESS(ignored, thing) > world.time)
			continue
		var/wanted = FALSE
		if(rounds_wanted && quiver.rogue_holds(thing) && launcher.magazine?.is_compatible_round(thing))
			wanted = TRUE
		else if(cloths < NPC_LOOT_CARRY && rogue_npc_is_clean_cloth(thing))
			wanted = TRUE
		else if(potions < NPC_LOOT_CARRY && rogue_npc_is_potion(thing))
			wanted = TRUE
		else if(missiles < NPC_LOOT_CARRY && is_type_in_typecache(thing, GLOB.rogue_npc_throwables))
			wanted = TRUE
		if(!wanted)
			continue
		var/distance = get_dist(scavenger, thing)
		if(distance < best_distance)
			best = thing
			best_distance = distance
	return best

/// Takes the thing: a round into the quiver (Vibelin retrieve_arrow), the rest into a slot or a bag.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_take_loot(obj/item/thing)
	var/mob/living/carbon/human/scavenger = pawn
	var/list/kit = rogue_npc_ranged_kit(FALSE)
	var/obj/item/rogue_quiver/quiver = kit?[2]
	if(quiver && quiver.rogue_holds(thing))
		if(length(quiver.contents) >= quiver.max_storage)
			return FALSE
		thing.forceMove(quiver)
		return TRUE
	for(var/obj/item/worn as anything in scavenger.get_equipped_items())
		if(worn.atom_storage?.attempt_insert(thing, scavenger, messages = FALSE))
			return TRUE
	return scavenger.equip_to_appropriate_slot(thing)

// Spotting sneakers (Ratwood npc_detect_sneak).

/// Ratwood handle_combat() NPC_AI_IDLE: every npc_sneak_seek it glances at those sneaking hidden near it (npc_sneak_range) in
/// its sight - a chance of half its perception for each to try spotting them, a harder try (npc_sneak_passive); missed, it
/// does not look again for a second a point of its perception.
/datum/bt_node/ai_behavior/rogue_npc_seek_hidden

/datum/bt_node/ai_behavior/rogue_npc_seek_hidden/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/carbon/human/seeker = controller.pawn
	if(!istype(seeker) || world.time < controller.blackboard[BB_ROGUE_NPC_SEEK_AT] || world.time < controller.blackboard[BB_ROGUE_NPC_SEEK_PAUSE])
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(BB_ROGUE_NPC_SEEK_AT, world.time + NPC_SNEAK_SEEK)
	var/perception = seeker.rogue_stat(ROGUE_STAT_PERCEPTION)
	for(var/mob/living/carbon/human/hider in SSspatial_grid.orthogonal_range_search(seeker, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, NPC_SNEAK_RANGE))
		if(hider == seeker || !isturf(hider.loc) || !hider.rogue_is_hidden() || !can_see(seeker, hider, NPC_SNEAK_RANGE))
			continue
		if(!prob(perception / 2))
			continue
		if(!seeker.rogue_npc_spot(hider, -NPC_SNEAK_PASSIVE))
			controller.set_blackboard_key(BB_ROGUE_NPC_SEEK_PAUSE, world.time + perception SECONDS)
			break
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Ratwood retaliate(): struck by someone it cannot see, it searches around frantically - spotting them is easier when it is
/// badly hurt (npc_sneak_hurt).
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_npc_on_attacked(mob/living/victim, atom/attacker)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/seeker = pawn
	var/mob/living/carbon/human/hider = attacker
	if(!istype(seeker) || !istype(hider) || hider == seeker || !hider.rogue_is_hidden())
		return
	if(prob(NPC_SNEAK_FRANTIC))
		seeker.visible_message(span_notice("[seeker] begins searching around frantically..."))
	seeker.rogue_npc_spot(hider, seeker.health <= seeker.maxHealth / 2 ? NPC_SNEAK_HURT : 0)

/// Ratwood npc_detect_sneak(): whether this one spots the sneaker - npc_sneak_per_perception in a hundred a point of its
/// perception plus extra, less npc_sneak_skill a rank of the sneaker's Sneaking, much more when their armour is too heavy for
/// them (npc_sneak_loud_armor, and no help from the skill), their fortune either way (npc_sneak_luck a point). Spotted, the
/// sneaker is revealed (ROGUE_LOOK_AROUND_REVEAL).
/mob/living/carbon/human/proc/rogue_npc_spot(mob/living/carbon/human/hider, extra = 0)
	if(!hider.rogue_is_hidden())
		return TRUE
	var/chance = rogue_stat(ROGUE_STAT_PERCEPTION) * NPC_SNEAK_PER_PERCEPTION + extra
	var/stealth = hider.rogue_skill_rank(/datum/attribute/skill/misc/sneaking) * NPC_SNEAK_SKILL
	chance -= stealth
	if(!hider.rogue_armor_trained())
		chance += NPC_SNEAK_LOUD_ARMOR + stealth
	var/fortune = hider.rogue_stat(ROGUE_STAT_FORTUNE)
	if(hider.rogue_badluck(NPC_SNEAK_LUCK))
		chance += (ROGUE_ATTRIBUTE_MIDDLING - fortune) * NPC_SNEAK_LUCK
	if(hider.rogue_goodluck(NPC_SNEAK_LUCK))
		chance -= (fortune - ROGUE_ATTRIBUTE_MIDDLING) * NPC_SNEAK_LUCK
	if(!prob(chance))
		return FALSE
	to_chat(hider, span_danger("[src] sees me! I'm found!"))
	hider.rogue_reveal_sneak(ROGUE_LOOK_AROUND_REVEAL)
	return TRUE

#undef BB_ROGUE_NPC_HARASS_UNTIL
#undef BB_ROGUE_NPC_RETREAT_TURF
#undef BB_ROGUE_NPC_FLANK_ANGLE
#undef BB_ROGUE_NPC_FLANK_TURF
#undef BB_ROGUE_NPC_FLANK_AT
#undef BB_ROGUE_NPC_LAUNCHER
#undef BB_ROGUE_NPC_QUIVER
#undef BB_ROGUE_NPC_KIT_AT
#undef BB_ROGUE_NPC_NO_SHOT_UNTIL
#undef BB_ROGUE_NPC_HELP_AT
#undef BB_ROGUE_NPC_POTION_AT
#undef BB_ROGUE_NPC_BANDAGE_AT
#undef BB_ROGUE_NPC_THROW_AT
#undef BB_ROGUE_NPC_JUMP_AT
#undef BB_ROGUE_NPC_LOOT_AT
#undef BB_ROGUE_NPC_SEEK_AT
#undef BB_ROGUE_NPC_SEEK_PAUSE
#undef BB_ROGUE_NPC_LOOT_IGNORED
#undef NPC_SEARCH_PAUSE
#undef NPC_POTION_DAMAGE
#undef NPC_POTION_COOLDOWN
#undef NPC_BANDAGE_COOLDOWN
#undef NPC_HELP_DAMAGE
#undef NPC_HELP_COOLDOWN
#undef NPC_HELP_RANGE
#undef NPC_HARASS_HEALTH
#undef NPC_HARASS_FATIGUE
#undef NPC_HARASS_RETREAT
#undef NPC_HARASS_PAUSE
#undef NPC_HARASS_PAUSE_PER_STAMINA
#undef NPC_HARASS_HURT_FACTOR
#undef NPC_FLANK_RANGE
#undef NPC_FLANK_RADIUS
#undef NPC_FLANK_GAP
#undef NPC_FLANK_ENGAGE
#undef NPC_FLANK_COMMIT
#undef NPC_FLANK_RECHECK
#undef NPC_SHOT_MIN_RANGE
#undef NPC_SHOT_RANGE
#undef NPC_SHOT_DRAW_MAX
#undef NPC_KIT_CACHE
#undef NPC_SHOT_JAMMED
#undef NPC_THROW_MIN
#undef NPC_THROW_MAX
#undef NPC_THROW_COOLDOWN
#undef NPC_LOOT_RANGE
#undef NPC_LOOT_INTERVAL
#undef NPC_LOOT_CARRY
#undef NPC_LOOT_IGNORE
#undef NPC_LOOT_PATIENCE
#undef NPC_JUMP_CHANCE
#undef NPC_JUMP_DISTANCE
#undef NPC_JUMP_FATIGUE
#undef NPC_JUMP_COOLDOWN
#undef NPC_TAUNT_CHANCE
#undef NPC_GRAB_ARMED
#undef NPC_GRAB_UNARMED
#undef NPC_GRAB_USE
#undef NPC_GRAB_UPGRADE
#undef NPC_GRAB_CLUMSY
#undef NPC_GRAB_CLUMSY_USE
#undef NPC_SNEAK_SEEK
#undef NPC_SNEAK_RANGE
#undef NPC_SNEAK_PER_PERCEPTION
#undef NPC_SNEAK_PASSIVE
#undef NPC_SNEAK_SKILL
#undef NPC_SNEAK_LOUD_ARMOR
#undef NPC_SNEAK_LUCK
#undef NPC_SNEAK_HURT
#undef NPC_SNEAK_FRANTIC
