/// A mob that slaps people around and can be tamed as a mount
/mob/living/basic/vatbeast
	name = "vatbeast"
	desc = "A strange molluscoidal creature carrying a busted growing vat.\nYou wonder if this burden is a voluntary undertaking in order to achieve comfort and protection, or simply because the creature is fused to its metal shell?"
	icon = 'icons/mob/vatgrowing.dmi'
	icon_state = "vat_beast"
	icon_living = "vat_beast"
	icon_dead = "vat_beast_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	mob_size = MOB_SIZE_LARGE
	gender = NEUTER
	speak_emote = list("roars")
	health = 250
	maxHealth = 250
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 1, STAMINA = 1, OXY = 1)
	melee_damage_lower = 25
	melee_damage_upper = 25
	obj_damage = 40
	unsuitable_atmos_damage = 0
	attack_sound = 'sound/items/weapons/punch3.ogg'
	attack_verb_continuous = "slaps"
	attack_verb_simple = "slap"
	// Greenish darkvision
	lighting_cutoff_red = 10
	lighting_cutoff_green = 25
	lighting_cutoff_blue = 20
	ai_controller = /datum/ai_controller/basic_controller/vatbeast
	faction = list(FACTION_HOSTILE)
	blood_volume = BLOOD_VOLUME_NORMAL
	/// What can you feed a vatbeast to tame it?
	var/static/list/enjoyed_food = list(
		/obj/item/food/carrotfries,
		/obj/item/food/cheesyfries,
		/obj/item/food/cornchips,
		/obj/item/food/fries,
	)

/mob/living/basic/vatbeast/Initialize(mapload)
	. = ..()

	add_cell_sample()
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/ai_target_timer)
	AddComponent(/datum/component/tameable, food_types = enjoyed_food, tame_chance = 30, bonus_tame_chance = 0)

	var/datum/action/cooldown/tentacle_slap/slapper = new (src)
	slapper.Grant(src)

	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, slapper)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(enjoyed_food))

/mob/living/basic/vatbeast/tamed(mob/living/tamer, obj/item/food)
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/vatbeast)
	faction = list(FACTION_NEUTRAL)

/mob/living/basic/vatbeast/proc/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_VATBEAST, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/vatbeast/get_bloodtype()
	return get_blood_type(BLOOD_TYPE_LIZARD) // Green and alien

/// Attack people and slap them
/datum/ai_controller/basic_controller/vatbeast
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/targeted_mob_ability/vatbeast_slap,
		/datum/ai_planning_subtree/basic_melee_attack_subtree
	)

/// Only do this if we are adjacent to target and have been mad at the same guy for at least 10 seconds
/// That slap REALLY hurts
/datum/ai_planning_subtree/targeted_mob_ability/vatbeast_slap
	operational_datums = list(/datum/component/ai_target_timer)

/datum/ai_planning_subtree/targeted_mob_ability/vatbeast_slap/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[target_key]
	if (!isliving(target) || !controller.pawn.Adjacent(target))
		return
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if (time_on_target < 10 SECONDS)
		return
	return ..()

/// Ability that allows the owner to slap other mobs a short distance away.
/// For vatbeats, this ability is shared with the rider.
/datum/action/cooldown/tentacle_slap
	name = "Tentacle slap"
	desc = "Slap a creature with your tentacles."
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "tentacle_slap"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	cooldown_time = 12 SECONDS
	click_to_activate = TRUE
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'

/datum/action/cooldown/tentacle_slap/update_button_name(atom/movable/screen/movable/action_button/button, force)
	if (button.our_hud?.mymob != owner)
		// For buttons given to mobs which are not our owner, give it this alt name
		button.name = "Command Tentacle Slap"
		button.desc = "Command your steed to slap a creature with its tentacles."
		return

	return ..()

/datum/action/cooldown/tentacle_slap/set_click_ability(mob/on_who)
	. = ..()
	if (!.)
		return
	to_chat(on_who, span_notice("You prepare your [on_who == owner ? "":"steed's "]pimp-tentacle. <b>Left-click to slap a target!</b>"))

/datum/action/cooldown/tentacle_slap/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if (!.)
		return
	if(refund_cooldown)
		to_chat(on_who, span_notice("You stop preparing your [on_who == owner ? "":"steed's "]pimp-tentacle."))

/datum/action/cooldown/tentacle_slap/InterceptClickOn(mob/living/clicker, params, atom/target)
	// Check if we can slap
	if (!isliving(target) || target == owner)
		return FALSE

	if (!owner.Adjacent(target))
		owner.balloon_alert(clicker, "too far!")
		return FALSE

	// Do the slap
	. =  ..()
	if (!.)
		return FALSE

	// Give feedback from the slap.
	// Additional feedback for if a rider did it
	if (clicker != owner)
		to_chat(clicker, span_notice("You command [owner] to slap [target] with its tentacles."))

	return TRUE

/datum/action/cooldown/tentacle_slap/Activate(atom/to_slap)
	var/mob/living/living_to_slap = to_slap

	owner.visible_message(
		span_warning("[owner] slaps [to_slap] with its tentacle!"),
		span_notice("You slap [to_slap] with your tentacle."),
	)
	playsound(owner, 'sound/effects/emotes/assslap.ogg', 90)
	var/atom/throw_target = get_edge_target_turf(to_slap, owner.dir)
	living_to_slap.throw_at(throw_target, 6, 4, owner)
	living_to_slap.apply_damage(30, BRUTE)

	StartCooldown()
	return TRUE
