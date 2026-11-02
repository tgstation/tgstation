/// Minds for Ratwood's NPC people (goblins, orcs, skeletons, highwaymen, bog deserters, drow, deadites; the porter marks them
/// and dresses them in rockhill/ported/npcs.dm) on TG's behavior trees, with the fighting of Vibelin's human_npc
/// (datums/ai/subtrees/human_basic_attack.dm) laid over every blow: the NPC takes up its best weapon (from the other hand, a
/// sheath, its belt or back, or the ground beside it) and wields it two-handed when that hits harder, picks one of the weapon's
/// intents, now and then changes stance (strong, swift or feint, weighed by its fatigue, its skill and the foe's guard), may feint
/// with the right button or use the weapon's special, aims at arms, chest or head and switches every few blows, or at a weak
/// point it spots (a wounded limb, bare skin, armor its blade goes through), and after the blow may step back to a side tile.
///
/// The mind follows Ratwood's class of the NPC: an aggressive one hunts whoever is not of its faction, the others fight back
/// when attacked; one that flees in pain runs once badly hurt. Like Ratwood's NPCs (cmode) they stay in combat mode while
/// they have a target, so they parry and dodge. What they do besides the blow - bandages and potions, bows and throwing
/// knives, calling for help, flanking, stepping back, gathering, leaping, taunting, grabbing, spotting sneakers - and the
/// tree of the mind itself are in ai/human_npc_tactics.dm.

#define BB_ROGUE_NPC_STANCE_LEFT "rogue_npc_stance_left"
#define BB_ROGUE_NPC_ZONE_COUNT "rogue_npc_zone_count"
#define BB_ROGUE_NPC_WEAKPOINT "rogue_npc_weakpoint"
#define BB_ROGUE_NPC_JUKE_AT "rogue_npc_juke_at"
/// Azure Peak BB_HUMAN_NPC_SPECIAL_EVAL_AT: after a missed roll for its special, the NPC does not roll again before this.
#define BB_ROGUE_NPC_SPECIAL_EVAL_AT "rogue_npc_special_eval_at"
/// Azure Peak BB_HUMAN_NPC_TECHNIQUE_CD: after a special, the NPC does not use another before this.
#define BB_ROGUE_NPC_TECHNIQUE_AT "rogue_npc_technique_at"
/// Azure Peak BB_HUMAN_NPC_SWINGS_TAKEN and BB_HUMAN_NPC_SWINGS_TARGET: the blows struck at the current foe, and that foe.
#define BB_ROGUE_NPC_BLOWS "rogue_npc_blows"
#define BB_ROGUE_NPC_BLOWS_AT "rogue_npc_blows_at"

#define ROGUE_NPC_FLEE_HEALTH rogue_value("npc_flee_health")
#define ROGUE_NPC_FLEE_STOP rogue_value("npc_flee_stop")
#define ROGUE_NPC_STANCE_CHANCE rogue_value("npc_stance_chance")
#define ROGUE_NPC_STANCE_MIN rogue_value("npc_stance_min")
#define ROGUE_NPC_STANCE_MAX rogue_value("npc_stance_max")
#define ROGUE_NPC_RMB_CHANCE rogue_value("npc_rmb_chance")
#define ROGUE_NPC_SPECIAL_CHANCE rogue_value("npc_special_chance")
#define ROGUE_NPC_WEAKPOINT_CHANCE rogue_value("npc_weakpoint_chance")
#define ROGUE_NPC_WEAKPOINT_TIME rogue_value("npc_weakpoint_time")
#define ROGUE_NPC_ZONE_BLOWS rogue_value("npc_zone_blows")
#define ROGUE_NPC_JUKE_CHANCE rogue_value("npc_juke_chance")
#define ROGUE_NPC_JUKE_PER_SPEED rogue_value("npc_juke_per_speed")
#define ROGUE_NPC_JUKE_COOLDOWN rogue_value("npc_juke_cooldown")
#define ROGUE_NPC_REACTION_MIN rogue_value("npc_reaction_min")
#define ROGUE_NPC_REACTION_MAX rogue_value("npc_reaction_max")
#define ROGUE_NPC_SPECIAL_EVAL rogue_value("npc_special_eval")
#define ROGUE_NPC_SPECIAL_COOLDOWN_FACTOR rogue_value("npc_special_cooldown_factor")
#define ROGUE_NPC_SPECIAL_PAUSE rogue_value("npc_special_pause")
#define ROGUE_NPC_SPECIAL_SHARE_RANGE rogue_value("npc_special_share_range")
#define ROGUE_NPC_SPECIAL_OPENER rogue_value("npc_special_opener")
#define ROGUE_NPC_SPECIAL_MIN_INT rogue_value("npc_special_min_int")
/// Azure Peak: after a special the next blow waits this many times the usual click delay.
#define ROGUE_NPC_SPECIAL_RECOVERY 1.8

/// Vibelin's stance weights and their shifts.
#define ROGUE_NPC_STRONG_WEIGHT 45
#define ROGUE_NPC_SWIFT_WEIGHT 40
#define ROGUE_NPC_FEINT_WEIGHT 15
#define ROGUE_NPC_TIRED_SHIFT 20
#define ROGUE_NPC_SKILLED_STRONG 15
#define ROGUE_NPC_GUARD_FEINT 25
/// Share of stamina spent past which the NPC drops the strong stance.
#define ROGUE_NPC_SPENT 0.6
/// Share of stamina spent past which strong gives way to swift.
#define ROGUE_NPC_TIRED 0.4
/// Share of stamina spent past which the NPC no longer feints.
#define ROGUE_NPC_FEINT_FATIGUE 0.7
/// Brute or burn on a limb from which a trained eye sees it as wounded.
#define ROGUE_NPC_WOUND_SEEN 20
/// Weapon skill ranks of Vibelin's checks (novice, journeyman, expert).
#define ROGUE_NPC_RANK_NOVICE 1
#define ROGUE_NPC_RANK_JOURNEYMAN 3
#define ROGUE_NPC_RANK_EXPERT 4
/// Share a weak point is kept longer per tile of reach past the first.
#define ROGUE_NPC_REACH_TIME 0.1
#define ROGUE_NPC_TRAIT "rogue_npc"

/mob/living/carbon/human
	/// Ratwood mode = NPC_AI_IDLE: one of Ratwood's NPCs, with a mind of its own.
	var/rogue_npc = FALSE
	/// Ratwood aggressive: hunts on sight whoever is not of its faction; otherwise it only fights back.
	var/rogue_aggressive = FALSE
	/// Ratwood flee_in_pain: runs from its foe once badly hurt.
	var/rogue_flee_in_pain = FALSE
	/// Ratwood's outfits for the NPC (gob_outfit, skel_outfit, equipOutfit in after_creation); one is picked and worn at spawn.
	var/list/rogue_npc_outfits
	/// Traits Ratwood gives the NPC in after_creation.
	var/list/rogue_npc_traits
	/// How Ratwood's after_creation shapes the NPC: "random_sex", "skin", "eyes", "hair_color", the hairstyles and beards
	/// it picks from ("hair_m", "hair_f", "beards") and the name lists ("names_m", "names_f") or the one name ("name").
	var/list/rogue_npc_look

/mob/living/carbon/human/Initialize(mapload)
	if(rogue_npc && !ai_controller)
		ai_controller = rogue_npc_controller()
	. = ..()
	if(rogue_npc)
		rogue_npc_setup()

/mob/living/carbon/human/proc/rogue_npc_controller()
	if(rogue_aggressive)
		return rogue_flee_in_pain ? /datum/ai_controller/basic_controller/simple/rogue_human/fleeing : /datum/ai_controller/basic_controller/simple/rogue_human
	return rogue_flee_in_pain ? /datum/ai_controller/basic_controller/simple/rogue_human/retaliate/fleeing : /datum/ai_controller/basic_controller/simple/rogue_human/retaliate

/// What Ratwood's after_creation does for the NPC: its name, traits and outfit; then the mind's reactions to being hurt.
/mob/living/carbon/human/proc/rogue_npc_setup()
	if(real_name == initial(real_name))
		real_name = name
	if(length(rogue_npc_look))
		rogue_npc_shape()
	for(var/trait in rogue_npc_traits)
		ADD_TRAIT(src, trait, ROGUE_NPC_TRAIT)
	if(length(rogue_npc_outfits))
		equipOutfit(pick(rogue_npc_outfits))
	if(!ai_controller)
		return
	AddElement(/datum/element/ai_retaliate)
	if(rogue_flee_in_pain)
		AddElement(/datum/element/ai_flee_while_injured, ROGUE_NPC_FLEE_STOP, ROGUE_NPC_FLEE_HEALTH)

/// The NPC's sex, skin, eyes, hair, beard and name, as Ratwood's after_creation picks them (orcs: green skin, red eyes,
/// dark braids and beards; dark elves: grey skin, amber eyes, white hair).
/mob/living/carbon/human/proc/rogue_npc_shape()
	var/list/look = rogue_npc_look
	if(look["random_sex"])
		gender = pick(MALE, FEMALE)
		physique = gender
	if(look["skin"])
		dna.features[FEATURE_MUTANT_COLOR] = look["skin"]
	if(look["eyes"])
		set_eye_color(look["eyes"])
	var/list/styles = look[gender == FEMALE ? "hair_f" : "hair_m"]
	if(length(styles))
		set_hairstyle(pick(styles), update = FALSE)
	var/list/beards = look["beards"]
	if(gender != FEMALE && length(beards))
		set_facial_hairstyle(pick(beards), update = FALSE)
	if(look["hair_color"])
		set_haircolor(look["hair_color"], update = FALSE)
		set_facial_haircolor(look["hair_color"], update = FALSE)
	var/names = look[gender == FEMALE ? "names_f" : "names_m"]
	var/list/picked = names && (world.file2list(names) - "")
	if(length(picked))
		fully_replace_character_name(real_name, pick(picked))
	else if(look["name"])
		fully_replace_character_name(real_name, look["name"])
	update_body(is_creating = TRUE)

/// Hunts on sight. The trees tick their roots in order (rogue_npc_roots(), ai/human_npc_tactics.dm): breaking free first,
/// then running when ai_flee_while_injured says so (only the fleeing kinds), then tending its wounds, then the fight or, with
/// nobody to fight, its idle pastimes.
/datum/ai_controller/basic_controller/simple/rogue_human
	behavior_tree_json = null
	behavior_nodes = list(
		/datum/bt_node/subtree/escape_captivity,
		/datum/bt_node/subtree/simple_hostile_combat,
	)
	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	/// Ratwood aggressive: hunts whoever is not of its faction; otherwise fights whoever attacked it.
	var/rogue_hunts = TRUE
	/// Ratwood flee_in_pain: runs from its foe once badly hurt.
	var/rogue_flees = FALSE

/datum/ai_controller/basic_controller/simple/rogue_human/New(atom/new_pawn)
	behavior_nodes = rogue_npc_roots()
	return ..()

/datum/ai_controller/basic_controller/simple/rogue_human/fleeing
	rogue_flees = TRUE

/// Fights whoever attacked it.
/datum/ai_controller/basic_controller/simple/rogue_human/retaliate
	rogue_hunts = FALSE

/datum/ai_controller/basic_controller/simple/rogue_human/retaliate/fleeing
	rogue_flees = TRUE

/datum/ai_controller/basic_controller/simple/rogue_human/TryPossessPawn(atom/new_pawn)
	if(!ishuman(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_SET(BB_CURRENT_TARGET), PROC_REF(on_target_set))
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_CURRENT_TARGET), PROC_REF(on_target_cleared))
	RegisterSignal(new_pawn, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(rogue_npc_on_attacked))
	return ..()

/datum/ai_controller/basic_controller/simple/rogue_human/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(BB_CURRENT_TARGET), COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_CURRENT_TARGET), COMSIG_ATOM_WAS_ATTACKED))
	return ..()

/datum/ai_controller/basic_controller/simple/rogue_human/proc/on_target_set(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	if(!source.combat_mode)
		INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living, set_combat_mode), TRUE)

/datum/ai_controller/basic_controller/simple/rogue_human/proc/on_target_cleared(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	clear_blackboard_key(BB_ROGUE_NPC_WEAKPOINT)
	clear_blackboard_key(BB_ROGUE_NPC_STANCE_LEFT)
	clear_blackboard_key(BB_ROGUE_NPC_BLOWS)
	clear_blackboard_key(BB_ROGUE_NPC_BLOWS_AT)
	rogue_npc_forget_fight()
	if(source.combat_mode)
		INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living, set_combat_mode), FALSE)

/// Every blow of the fight comes here (basic_melee_attack): Vibelin's preparation, the blow, then a slower reaction and maybe a
/// step back.
/datum/ai_controller/basic_controller/simple/rogue_human/ai_interact(target, combat_mode, list/modifiers)
	var/mob/living/carbon/human/fighter = pawn
	var/mob/living/foe = isdatum(target) ? target : blackboard[target]
	if(!combat_mode || !isliving(foe) || foe == fighter)
		return ..()
	rogue_ready_weapon(fighter)
	rogue_choose_intent(fighter)
	if(prob(ROGUE_NPC_WEAKPOINT_CHANCE))
		rogue_scan_weakpoint(fighter, foe)
	fighter.face_atom(foe)
	rogue_choose_zone(fighter, foe)
	rogue_count_blow(foe)
	if(rogue_try_grab(fighter, foe))
		return TRUE
	if(rogue_try_special(fighter, foe))
		return TRUE
	rogue_choose_stance(fighter, foe)
	if(prob(ROGUE_NPC_RMB_CHANCE) && fighter.rogue_rmb_is(/datum/rogue_rmb_intent/feint) && fighter.get_stamina_loss() < fighter.max_stamina * ROGUE_NPC_FEINT_FATIGUE)
		modifiers = list(RIGHT_CLICK = TRUE)
	. = ..(target, combat_mode, modifiers)
	if(QDELETED(fighter) || QDELETED(foe))
		return
	rogue_slow_reaction(fighter)
	if(prob(ROGUE_NPC_WEAKPOINT_CHANCE))
		rogue_scan_weakpoint(fighter, foe)
	rogue_try_backstep(fighter, foe)

/// A weapon to strike with: a bow, crossbow or sling is not one (ai/human_npc_tactics.dm shoots it).
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_is_weapon(obj/item/item)
	return istype(item) && !istype(item, /obj/item/gun) && item.associated_skill && length(item.possible_item_intents) && item.force > 0

/// The stronger weapon goes to the active hand (Ratwood do_best_melee_attack); an empty hand draws one; a weapon that hits
/// harder in both hands is wielded when the other hand is free. A bow still in hand when the foe is close is put away first
/// (Vibelin's archers take up their stashed weapon).
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_ready_weapon(mob/living/carbon/human/fighter)
	for(var/obj/item/gun/launcher in fighter.held_items)
		fighter.rogue_npc_put_away(launcher)
	var/obj/item/main = fighter.get_active_held_item()
	var/obj/item/off = fighter.get_inactive_held_item()
	if(rogue_is_weapon(off) && (!rogue_is_weapon(main) || off.force > main.force))
		fighter.swap_hand(fighter.get_inactive_hand_index())
		main = fighter.get_active_held_item()
		off = fighter.get_inactive_held_item()
	if(!main)
		main = rogue_draw_weapon(fighter)
	if(!rogue_is_weapon(main) || off || main.rogue_wielded || main.rogue_force_wielded <= main.force)
		return
	var/datum/component/two_handed/grip = main.GetComponent(/datum/component/two_handed)
	grip?.wield(fighter)

/// A weapon for the empty active hand: drawn from a sheath, taken off the belt, hip or back, or picked up beside the NPC
/// (Vibelin's NPCs draw from their slots and grab a weapon lying next to them).
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_draw_weapon(mob/living/carbon/human/fighter)
	for(var/obj/item/worn as anything in fighter.get_equipped_items(INCLUDE_POCKETS))
		if(istype(worn, /obj/item/rogueweapon/scabbard))
			var/obj/item/rogueweapon/scabbard/sheath = worn
			if(rogue_is_weapon(sheath.sheathed))
				sheath.attack_hand(fighter)
				return fighter.get_active_held_item()
			continue
		if(rogue_is_weapon(worn) && fighter.temporarilyRemoveItemFromInventory(worn) && fighter.put_in_active_hand(worn))
			return worn
	for(var/obj/item/lying in range(1, fighter))
		if(isturf(lying.loc) && rogue_is_weapon(lying) && fighter.put_in_active_hand(lying))
			return lying

/// One of the attacks the held weapon (or the fist) offers, a new one for every blow.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_choose_intent(mob/living/carbon/human/fighter)
	var/list/intents = fighter.rogue_hand_intents()
	var/list/blows = list()
	for(var/slot in 1 to min(length(intents), ROGUE_INTENT_SLOTS))
		var/datum/intent/intent = rogue_intent(intents[slot])
		if(!intent || intent.no_attack || intent.tranged)
			continue
		var/datum/intent/unarmed/fist = intent
		if(istype(fist) && fist.unarmed_action != ROGUE_UNARMED_HARM)
			continue
		blows += slot
	if(length(blows))
		fighter.rogue_select_intent(pick(blows))

/// Every few blows a chance to change stance: strong, swift or feint by Vibelin's weights. A tired fighter turns from strong
/// to swift, a skilled one leans to strong, a guarded foe draws feints.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_choose_stance(mob/living/carbon/human/fighter, mob/living/foe)
	var/left = blackboard[BB_ROGUE_NPC_STANCE_LEFT]
	if(left > 0)
		set_blackboard_key(BB_ROGUE_NPC_STANCE_LEFT, left - 1)
		return
	if(!prob(ROGUE_NPC_STANCE_CHANCE))
		return
	var/list/weights = list(
		/datum/rogue_rmb_intent/strong = ROGUE_NPC_STRONG_WEIGHT,
		/datum/rogue_rmb_intent/swift = ROGUE_NPC_SWIFT_WEIGHT,
		/datum/rogue_rmb_intent/feint = ROGUE_NPC_FEINT_WEIGHT,
	)
	var/fatigue = fighter.get_stamina_loss() / fighter.max_stamina
	if(fatigue > ROGUE_NPC_SPENT)
		weights[/datum/rogue_rmb_intent/strong] = 0
	else if(fatigue > ROGUE_NPC_TIRED)
		weights[/datum/rogue_rmb_intent/strong] -= ROGUE_NPC_TIRED_SHIFT
		weights[/datum/rogue_rmb_intent/swift] += ROGUE_NPC_TIRED_SHIFT
	if(fighter.rogue_weapon_rank(fighter.get_active_held_item()) >= ROGUE_NPC_RANK_JOURNEYMAN)
		weights[/datum/rogue_rmb_intent/strong] += ROGUE_NPC_SKILLED_STRONG
	if(foe.rogue_rmb_is(/datum/rogue_rmb_intent/defend) || foe.has_status_effect(/datum/status_effect/rogue/guard))
		weights[/datum/rogue_rmb_intent/feint] += ROGUE_NPC_GUARD_FEINT
	fighter.rogue_rmb_intent = GLOB.rogue_rmb_intents[pick_weight(weights)]
	SEND_SIGNAL(fighter, COMSIG_MOB_ROGUE_RMB_CHANGED)
	set_blackboard_key(BB_ROGUE_NPC_STANCE_LEFT, rand(ROGUE_NPC_STANCE_MIN, ROGUE_NPC_STANCE_MAX))

/// Azure Peak _choose_attack_zone(): counts the blows struck at this foe, starting over for a new one.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_count_blow(mob/living/foe)
	if(blackboard[BB_ROGUE_NPC_BLOWS_AT] != foe)
		set_blackboard_key(BB_ROGUE_NPC_BLOWS_AT, foe)
		set_blackboard_key(BB_ROGUE_NPC_BLOWS, 0)
	set_blackboard_key(BB_ROGUE_NPC_BLOWS, blackboard[BB_ROGUE_NPC_BLOWS] + 1)

/// Sometimes the weapon's special instead of a blow, when it is off cooldown, the fighter knows the weapon well enough and has
/// the breath for it (Azure Peak human_basic_attack _try_weapon_special()). Not as an opener: only after npc_special_opener
/// plain blows at this foe, and not by an NPC too dull for tactics (npc_special_min_int). The special judges the moment itself
/// (rogue_npc_odds() of ai/npc_specials.dm: how many foes and friends its pattern would catch, whether the foe is open); one
/// without an opinion goes by the flat npc_special_chance. A missed roll waits npc_special_eval before the next, and a dull NPC
/// rolls lower (Azure AI_INT_SCALE_PROB). A special used puts its cooldown on the NPC npc_special_cooldown_factor times longer
/// than on a player, and on the NPCs nearby fighting the same foe, so they don't chain specials; the next blow comes later too.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_try_special(mob/living/carbon/human/fighter, mob/living/foe)
	if(blackboard[BB_ROGUE_NPC_BLOWS] <= ROGUE_NPC_SPECIAL_OPENER || fighter.rogue_stat(ROGUE_STAT_INTELLIGENCE) < ROGUE_NPC_SPECIAL_MIN_INT)
		return FALSE
	if(fighter.has_status_effect(/datum/status_effect/rogue/special_cooldown) || world.time < blackboard[BB_ROGUE_NPC_TECHNIQUE_AT])
		return FALSE
	var/obj/item/weapon = fighter.get_active_held_item()
	var/datum/special_intent/special = weapon?.rogue_special()
	if(!special || fighter.rogue_weapon_rank(weapon) < ROGUE_SPECIAL_RANK)
		return FALSE
	var/cost = special.tune("stamcost")
	if(cost && fighter.get_stamina_loss() + (cost < 1 ? fighter.max_stamina * cost : cost) >= fighter.max_stamina)
		return FALSE
	var/chance = special.rogue_npc_odds(fighter, foe)
	if(isnull(chance))
		chance = ROGUE_NPC_SPECIAL_CHANCE
	if(chance <= 0)
		return FALSE
	if(chance < 100)
		if(world.time < blackboard[BB_ROGUE_NPC_SPECIAL_EVAL_AT])
			return FALSE
		var/wits = fighter.rogue_stat(ROGUE_STAT_INTELLIGENCE) / ROGUE_ATTRIBUTE_MIDDLING
		if(!prob(min(chance, chance * wits)))
			set_blackboard_key(BB_ROGUE_NPC_SPECIAL_EVAL_AT, world.time + ROGUE_NPC_SPECIAL_EVAL)
			return FALSE
	if(!fighter.rogue_use_special(foe))
		return FALSE
	var/cooldown = special.tune("cooldown") * ROGUE_NPC_SPECIAL_COOLDOWN_FACTOR
	fighter.apply_status_effect(/datum/status_effect/rogue/special_cooldown, cooldown)
	rogue_share_special_cooldown(fighter, foe, cooldown)
	set_blackboard_key(BB_ROGUE_NPC_TECHNIQUE_AT, world.time + ROGUE_NPC_SPECIAL_PAUSE)
	fighter.changeNext_move(CLICK_CD_MELEE * ROGUE_NPC_SPECIAL_RECOVERY)
	return TRUE

/// Azure Peak propagate_technique_cd(): the other NPCs in view fighting the same foe wait out the special too.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_share_special_cooldown(mob/living/carbon/human/fighter, mob/living/foe, cooldown)
	for(var/mob/living/carbon/human/ally in view(ROGUE_NPC_SPECIAL_SHARE_RANGE, fighter))
		if(ally == fighter || ally.client || ally.stat == DEAD)
			continue
		if(!istype(ally.ai_controller, /datum/ai_controller/basic_controller/simple/rogue_human) || ally.ai_controller.blackboard[BB_CURRENT_TARGET] != foe)
			continue
		ally.apply_status_effect(/datum/status_effect/rogue/special_cooldown, cooldown)

/// A weak point while it holds; otherwise the same zone for a few blows, then arms, chest or head (the legs when lying down,
/// the head of a foe with no blood to spill).
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_choose_zone(mob/living/carbon/human/fighter, mob/living/foe)
	var/list/weakpoint = blackboard[BB_ROGUE_NPC_WEAKPOINT]
	if(length(weakpoint) && world.time < weakpoint[2] && weakpoint[3] == WEAKREF(foe))
		rogue_aim(fighter, weakpoint[1])
		return
	var/count = blackboard[BB_ROGUE_NPC_ZONE_COUNT]
	if(count < ROGUE_NPC_ZONE_BLOWS)
		set_blackboard_key(BB_ROGUE_NPC_ZONE_COUNT, count + 1)
		return
	set_blackboard_key(BB_ROGUE_NPC_ZONE_COUNT, 0)
	clear_blackboard_key(BB_ROGUE_NPC_WEAKPOINT)
	if(fighter.body_position == LYING_DOWN)
		rogue_aim(fighter, pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	else if(!CAN_HAVE_BLOOD(foe))
		rogue_aim(fighter, BODY_ZONE_HEAD)
	else
		rogue_aim(fighter, pick(pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM), BODY_ZONE_CHEST, BODY_ZONE_HEAD))

/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_aim(mob/living/carbon/human/fighter, zone)
	fighter.zone_selected = zone
	fighter.rogue_zone_precise = null

/// Looks the foe over for a weak point (Vibelin _scan_for_weakpoint): a wounded limb if the fighter is trained and sharp-eyed,
/// else a limb without armor, else one whose armor the current blow goes through; an expert settles for the weakest armor.
/// A better fighter, and a longer reach, keeps the aim longer.
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_scan_weakpoint(mob/living/carbon/human/fighter, mob/living/foe)
	if(!ishuman(foe))
		return
	var/mob/living/carbon/human/victim = foe
	var/obj/item/weapon = fighter.get_active_held_item()
	var/datum/intent/intent = fighter.rogue_strike_intent(weapon)
	if(!intent)
		return
	var/armor_type = rogue_bclass_to_armor(intent.blade_class)
	var/rank = clamp(fighter.rogue_weapon_rank(weapon), 0, ROGUE_SKILL_RANK_MAX)
	var/sees_wounds = rank >= ROGUE_NPC_RANK_JOURNEYMAN && fighter.rogue_stat(ROGUE_STAT_PERCEPTION) >= ROGUE_ATTRIBUTE_MIDDLING
	var/list/wounded = list()
	var/list/exposed = list()
	var/list/soft = list()
	var/weakest_zone
	var/weakest_tier = INFINITY
	for(var/obj/item/bodypart/part as anything in victim.bodyparts)
		var/zone = part.body_zone
		if(sees_wounds && (part.brute_dam > ROGUE_NPC_WOUND_SEEN || part.burn_dam > ROGUE_NPC_WOUND_SEEN))
			wounded += zone
		if(!length(victim.rogue_armor_layers(zone)))
			exposed += zone
			continue
		var/tier = victim.rogue_armor_tier(zone, armor_type)
		if(rank >= ROGUE_NPC_RANK_NOVICE && tier <= intent.penfactor)
			soft += zone
		if(tier < weakest_tier)
			weakest_tier = tier
			weakest_zone = zone
	var/chosen
	if(length(wounded))
		chosen = pick(wounded)
	else if(length(exposed))
		chosen = pick(exposed)
	else if(length(soft))
		chosen = pick(soft)
	else if(rank >= ROGUE_NPC_RANK_EXPERT)
		chosen = weakest_zone
	if(!chosen)
		return
	var/static/list/rank_hold = list(0.1, 0.5, 0.75, 1, 1.5, 2, 3)
	var/hold = ROGUE_NPC_WEAKPOINT_TIME * rank_hold[rank + 1] * (1 + (max(intent.reach, 1) - 1) * ROGUE_NPC_REACH_TIME)
	set_blackboard_key(BB_ROGUE_NPC_WEAKPOINT, list(chosen, world.time + hold, WEAKREF(foe)))

/// The NPC answers a little slower than its weapon allows, as a person would (Vibelin adds 20-40% to the click delay).
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_slow_reaction(mob/living/carbon/human/fighter)
	var/wait = fighter.next_move - world.time
	if(wait > 0)
		fighter.next_move += round(wait * rand(ROGUE_NPC_REACTION_MIN, ROGUE_NPC_REACTION_MAX) / 100)

/// After a blow a quick fighter may step to a tile away from or beside the foe, still facing it (Ratwood npc_try_backstep,
/// Vibelin _try_backstep: 15% and 5% for every point of speed over 10).
/datum/ai_controller/basic_controller/simple/rogue_human/proc/rogue_try_backstep(mob/living/carbon/human/fighter, mob/living/foe)
	if(world.time < blackboard[BB_ROGUE_NPC_JUKE_AT] || fighter.body_position == LYING_DOWN || fighter.buckled || fighter.pulledby)
		return
	// Vibelin _try_backstep(): not while striking and backing off (rogue_npc_harassing()).
	if(rogue_npc_harassing())
		return
	if(!isturf(fighter.loc) || !isturf(foe.loc) || HAS_TRAIT(fighter, TRAIT_IMMOBILIZED))
		return
	if(!prob(ROGUE_NPC_JUKE_CHANCE + max(fighter.rogue_stat(ROGUE_STAT_SPEED) - ROGUE_ATTRIBUTE_MIDDLING, 0) * ROGUE_NPC_JUKE_PER_SPEED))
		return
	var/turf/spot = fighter.rogue_dodge_turf(foe)
	if(!spot)
		return
	fighter.Move(spot, get_dir(fighter, spot))
	fighter.face_atom(foe)
	set_blackboard_key(BB_ROGUE_NPC_JUKE_AT, world.time + ROGUE_NPC_JUKE_COOLDOWN)

#undef BB_ROGUE_NPC_STANCE_LEFT
#undef BB_ROGUE_NPC_ZONE_COUNT
#undef BB_ROGUE_NPC_WEAKPOINT
#undef BB_ROGUE_NPC_JUKE_AT
#undef BB_ROGUE_NPC_SPECIAL_EVAL_AT
#undef BB_ROGUE_NPC_TECHNIQUE_AT
#undef BB_ROGUE_NPC_BLOWS
#undef BB_ROGUE_NPC_BLOWS_AT
#undef ROGUE_NPC_SPECIAL_OPENER
#undef ROGUE_NPC_SPECIAL_MIN_INT
#undef ROGUE_NPC_SPECIAL_EVAL
#undef ROGUE_NPC_SPECIAL_COOLDOWN_FACTOR
#undef ROGUE_NPC_SPECIAL_PAUSE
#undef ROGUE_NPC_SPECIAL_SHARE_RANGE
#undef ROGUE_NPC_SPECIAL_RECOVERY
#undef ROGUE_NPC_FLEE_HEALTH
#undef ROGUE_NPC_FLEE_STOP
#undef ROGUE_NPC_STANCE_CHANCE
#undef ROGUE_NPC_STANCE_MIN
#undef ROGUE_NPC_STANCE_MAX
#undef ROGUE_NPC_RMB_CHANCE
#undef ROGUE_NPC_SPECIAL_CHANCE
#undef ROGUE_NPC_WEAKPOINT_CHANCE
#undef ROGUE_NPC_WEAKPOINT_TIME
#undef ROGUE_NPC_ZONE_BLOWS
#undef ROGUE_NPC_JUKE_CHANCE
#undef ROGUE_NPC_JUKE_PER_SPEED
#undef ROGUE_NPC_JUKE_COOLDOWN
#undef ROGUE_NPC_REACTION_MIN
#undef ROGUE_NPC_REACTION_MAX
#undef ROGUE_NPC_STRONG_WEIGHT
#undef ROGUE_NPC_SWIFT_WEIGHT
#undef ROGUE_NPC_FEINT_WEIGHT
#undef ROGUE_NPC_TIRED_SHIFT
#undef ROGUE_NPC_SKILLED_STRONG
#undef ROGUE_NPC_GUARD_FEINT
#undef ROGUE_NPC_SPENT
#undef ROGUE_NPC_TIRED
#undef ROGUE_NPC_FEINT_FATIGUE
#undef ROGUE_NPC_WOUND_SEEN
#undef ROGUE_NPC_RANK_NOVICE
#undef ROGUE_NPC_RANK_JOURNEYMAN
#undef ROGUE_NPC_RANK_EXPERT
#undef ROGUE_NPC_REACH_TIME
#undef ROGUE_NPC_TRAIT
