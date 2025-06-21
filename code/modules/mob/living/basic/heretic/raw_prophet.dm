/**
 * A funny little rolling guy who is great at scouting.
 * It can see through walls, jaunt, and create a psychic network to report its findings.
 * It can blind people to make a getaway, but also get stronger if it attacks the same target consecutively.
 */
/mob/living/basic/heretic_summon/raw_prophet
	name = "\improper Raw Prophet"
	real_name = "Raw Prophet"
	desc = "An abomination stitched together from a few severed arms and one swollen, orphaned eye."
	icon_state = "raw_prophet"
	icon_living = "raw_prophet"
	status_flags = CANPUSH
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 65
	health = 65
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS
	/// List of innate abilities we have to add.
	var/static/list/innate_abilities = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/long = null,
		/datum/action/cooldown/spell/list_target/telepathy/eldritch = null,
		/datum/action/innate/expand_sight = null,
	)

/mob/living/basic/heretic_summon/raw_prophet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wheel)
	var/static/list/body_parts = list(/obj/effect/gibspawner/human, /obj/item/bodypart/arm/left, /obj/item/organ/eyes)
	AddElement(/datum/element/death_drops, body_parts)
	AddComponent(/datum/component/focused_attacker)
	var/on_link_message = "You feel something new enter your sphere of mind... \
		You hear whispers of people far away, screeches of horror and a huming of welcome to [src]'s Mansus Link."
	var/on_unlink_message = "Your mind shatters as [src]'s Mansus Link leaves your mind."
	AddComponent( \
		/datum/component/mind_linker/active_linking, \
		network_name = "Mansus Link", \
		chat_color = "#568b00", \
		post_unlink_callback = CALLBACK(src, PROC_REF(after_unlink)), \
		speech_action_background_icon_state = "bg_heretic", \
		speech_action_overlay_state = "bg_heretic_border", \
		linker_action_path = /datum/action/cooldown/spell/pointed/manse_link, \
		link_message = on_link_message, \
		unlink_message = on_unlink_message, \
	)

	grant_actions_by_list(get_innate_abilities())

/// Returns a list of abilities that we should add.
/mob/living/basic/heretic_summon/raw_prophet/proc/get_innate_abilities()
	var/list/returnable_list = innate_abilities.Copy()
	returnable_list += list(/datum/action/cooldown/spell/pointed/blind/eldritch = BB_TARGETED_ACTION)
	return returnable_list

/*
 * Callback for the mind_linker component.
 * Stuns people who are ejected from the network.
 */
/mob/living/basic/heretic_summon/raw_prophet/proc/after_unlink(mob/living/unlinked_mob)
	if(QDELETED(unlinked_mob) || unlinked_mob.stat == DEAD)
		return

	INVOKE_ASYNC(unlinked_mob, TYPE_PROC_REF(/mob, emote), "scream")
	unlinked_mob.AdjustParalyzed(0.5 SECONDS) //micro stun

/mob/living/basic/heretic_summon/raw_prophet/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	SpinAnimation(speed = 5, loops = 1)
	if (target == src)
		return
	return ..()

/// Variant raw prophet used by eldritch transformation with more base attack power
/mob/living/basic/heretic_summon/raw_prophet/ascended
	melee_damage_lower = 15
	melee_damage_upper = 20

/// NPC variant with a less bullshit ability
/mob/living/basic/heretic_summon/raw_prophet/ruins
	ai_controller = /datum/ai_controller/basic_controller/raw_prophet

/mob/living/basic/heretic_summon/raw_prophet/ruins/get_innate_abilities()
	var/list/returnable_list = innate_abilities.Copy()
	returnable_list += list(/datum/action/cooldown/mob_cooldown/watcher_gaze = BB_TARGETED_ACTION)
	return returnable_list

/// Walk and attack people, blind them when we can
/datum/ai_controller/basic_controller/raw_prophet
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
