#define REPAIRBOT_SPEECH_TIMER 30 SECONDS

/// Emagged repairbot behavior: mug robots then deconstruct structures.
/datum/bt_node/subtree/repairbot_emagged
	behavior_tree_json = "repairbot_emagged.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/sequence,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_ROBOT_TARGET, 0, FALSE)),\
							list("__t" = /datum/bt_node/ai_behavior/bot_interact/tip_robot, "default_behavior_args" = list(BB_ROBOT_TARGET)),\
							list("__t" = /datum/bt_node/ai_behavior/grab_target, "default_behavior_args" = list(BB_ROBOT_TARGET))\
						)\
					)\
				),\
				"key" = BB_ROBOT_TARGET\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/sequence,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_DECONSTRUCT_TARGET, 0, FALSE)),\
							list("__t" = /datum/bt_node/ai_behavior/bot_interact, "default_behavior_args" = list(BB_DECONSTRUCT_TARGET))\
						)\
					)\
				),\
				"key" = BB_DECONSTRUCT_TARGET\
			)\
		)\
	)
	// @bt-generated end

/datum/ai_controller/basic_controller/bot/repairbot
	behavior_tree_json = "repairbot.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/parallel,\
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
		"repeat_secondary" = TRUE,\
		"finish_on_primary" = TRUE,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/selector,\
				"__c" = list(\
					/datum/bt_node/subtree/escape_captivity/pacifist,\
					list(\
						"__t" = /datum/bt_node/composite/parallel,\
						"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
						"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
						"repeat_secondary" = TRUE,\
						"finish_on_primary" = TRUE,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/selector,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/decorator/bot_is_emagged,\
										"__c" = list(\
											/datum/bt_node/subtree/repairbot_emagged\
										),\
										"observer_abort" = BT_ABORT_BOTH\
									),\
									list(\
										"__t" = /datum/bt_node/decorator/bot_is_emagged,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/decorator/bb_key_set,\
												"__c" = list(\
													list(\
														"__t" = /datum/bt_node/composite/sequence,\
														"__c" = list(\
															list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_REFILLABLE_TARGET, 1, FALSE, /datum/ai_movement/basic_avoidance)),\
															list(\
																"__t" = /datum/bt_node/composite/selector,\
																"__c" = list(\
																	list(\
																		"__t" = /datum/bt_node/decorator/bb_key_equals,\
																		"__c" = list(\
																			list("__t" = /datum/bt_node/ai_behavior/bot_interact, "default_behavior_args" = list(BB_CURRENT_TARGET))\
																		),\
																		"key" = BB_REPAIRBOT_INTERACTION_TYPEBB_REPAIRBOT_INTERACTION_TYPE,\
																		"value" = REPAIRBOT_INTERACTION_INTERACT\
																	),\
																	list(\
																		"__t" = /datum/bt_node/decorator/bb_key_equals,\
																		"__c" = list(\
																			list("__t" = /datum/bt_node/ai_behavior/targeted_mob_ability/build_girder, "default_behavior_args" = list(BB_GIRDER_BUILD_ABILITY, BB_CURRENT_TARGET))\
																		),\
																		"key" = BB_REPAIRBOT_INTERACTION_TYPE,\
																		"value" = REPAIRBOT_INTERACTION_BUILD_GIRDERS\
																	)\
																)\
															)\
														)\
													)\
												),\
												"key" = BB_CURRENT_TARGET\
											)\
										),\
										"observer_abort" = BT_ABORT_SELF,\
										"invert" = TRUE\
									),\
									/datum/bt_node/subtree/bot_salute_authority,\
									/datum/bt_node/subtree/bot_patrol\
								)\
							),\
							list(\
								"__t" = /datum/bt_node/composite/selector,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/decorator/bot_is_emagged,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/decorator/bb_key_set,\
												"__c" = list(\
													list(\
														"__t" = /datum/bt_node/composite/selector,\
														"__c" = list(\
															list(\
																"__t" = /datum/bt_node/composite/sequence,\
																"__c" = list(\
																	list(\
																		"__t" = /datum/bt_node/composite/selector,\
																		"__c" = list(\
																			list("__t" = /datum/bt_node/ai_behavior/bot_search/refillable_target, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
																			list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_plateless_turf/breached, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
																			list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_wall_target, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
																			list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_grille_target, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
																			list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_plateless_turf, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
																			list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_window_fix, "default_behavior_args" = list(BB_CURRENT_TARGET))\
																		)\
																	),\
																	list("__t" = /datum/bt_node/ai_behavior/set_bb_key, "default_behavior_args" = list(BB_REPAIRBOT_INTERACTION_TYPE, REPAIRBOT_INTERACTION_INTERACT)),\
																	list("__t" = /datum/bt_node/ai_behavior/cancel_current_plan, "default_behavior_args" = list())\
																)\
															),\
															list(\
																"__t" = /datum/bt_node/composite/sequence,\
																"__c" = list(\
																	list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_girder, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
																	list("__t" = /datum/bt_node/ai_behavior/set_bb_key, "default_behavior_args" = list(BB_REPAIRBOT_INTERACTION_TYPE, REPAIRBOT_INTERACTION_BUILD_GIRDER)),\
																	list("__t" = /datum/bt_node/ai_behavior/cancel_current_plan, "default_behavior_args" = list())\
																)\
															)\
														)\
													)\
												),\
												"observer_abort" = BT_ABORT_NONE,\
												"invert" = TRUE,\
												"key" = BB_CURRENT_TARGET\
											)\
										)\
									),\
									list(\
										"__t" = /datum/bt_node/decorator/bot_is_emagged,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/composite/selector,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_robot, "default_behavior_args" = list(BB_ROBOT_TARGET)),\
													list("__t" = /datum/bt_node/ai_behavior/bot_search/deconstructable, "default_behavior_args" = list(BB_DECONSTRUCT_TARGET))\
												)\
											)\
										),\
										"invert" = TRUE\
									)\
								)\
							)\
						)\
					)\
				)\
			)\
		)\
	)
	// @bt-generated end
	reset_keys = list(
		BB_TILELESS_FLOOR,
		BB_GIRDER_TARGET,
		BB_GIRDER_TO_WALL_TARGET,
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_WELDER_TARGET,
		BB_WINDOW_FRAMETARGET,
	)
	minimum_distance = 1

// =============================================================================
// Repairbot speech (parallel track — announces work-in-progress)
// =============================================================================

/datum/bt_node/ai_behavior/repairbot_speech
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/repairbot_speech/setup(datum/ai_controller/controller)
	if(controller.blackboard[BB_REPAIRBOT_SPEECH_COOLDOWN] > world.time)
		return FALSE
	var/static/list/keys_to_look = list(
		BB_WELDER_TARGET,
		BB_WINDOW_FRAMETARGET,
		BB_TILELESS_FLOOR,
		BB_BREACHED_FLOOR,
		BB_GIRDER_TO_WALL_TARGET,
		BB_GIRDER_TARGET,
		BB_DECONSTRUCT_TARGET,
	)
	for(var/key in keys_to_look)
		if(controller.blackboard_key_exists(key))
			return ..()
	return FALSE

/datum/bt_node/ai_behavior/repairbot_speech/perform(seconds_per_tick, datum/ai_controller/controller)
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	// determine speech type: emagged → emagged speech, otherwise normal
	var/list/speech_to_pick_from
	if(controller.blackboard_key_exists(BB_DECONSTRUCT_TARGET))
		speech_to_pick_from = controller.blackboard[BB_REPAIRBOT_EMAGGED_SPEECH]
	else
		speech_to_pick_from = controller.blackboard[BB_REPAIRBOT_NORMAL_SPEECH]
	if(!length(speech_to_pick_from))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	announcement.announce(pick(speech_to_pick_from))
	controller.set_blackboard_key(BB_REPAIRBOT_SPEECH_COOLDOWN, world.time + REPAIRBOT_SPEECH_TIMER)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Mug robot — grab and tip robots when emagged
// =============================================================================

/datum/bt_node/ai_behavior/bot_interact/tip_robot

/datum/bt_node/ai_behavior/bot_interact/tip_robot/setup(datum/ai_controller/controller, target_key)
	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if(QDELETED(target) || pawn.pulling != target)
		return FALSE
	return ..()

/datum/bt_node/ai_behavior/bot_interact/tip_robot/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(succeeded)
		var/mob/living/living_pawn = controller.pawn
		living_pawn.stop_pulling()

/datum/bt_node/ai_behavior/bot_search/valid_robot
	action_cooldown = 10 SECONDS

/datum/bt_node/ai_behavior/bot_search/valid_robot/valid_target(datum/ai_controller/basic_controller/bot/controller, atom/my_target)
	if(!istype(my_target, /mob/living/silicon/robot))
		return FALSE
	return (!HAS_TRAIT(my_target, TRAIT_MOB_TIPPED)) && can_see(controller.pawn, my_target)

// =============================================================================
// Deconstruct — find deconstructable targets when emagged
// =============================================================================

/datum/bt_node/ai_behavior/bot_search/deconstructable
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/bot_search/deconstructable/valid_target(datum/ai_controller/basic_controller/bot/controller, atom/my_target)
	return (!(my_target.resistance_flags & INDESTRUCTIBLE) && !isgroundlessturf(my_target))

/datum/bt_node/ai_behavior/bot_search/deconstructable/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, looking_for = null, radius = 5, pathing_distance = 10, bypass_add_blacklist = FALSE, turf_search = FALSE)
	var/static/list/things_to_deconstruct = typecacheof(list(
		/obj/structure/window,
		/turf/open/floor,
		/turf/closed/wall,
	))
	return ..(seconds_per_tick, controller, target_key, things_to_deconstruct, radius, pathing_distance, bypass_add_blacklist, turf_search)

// =============================================================================
// Refill materials — pick up stacks when running low
// =============================================================================

/datum/bt_node/ai_behavior/bot_search/refillable_target
	action_cooldown = 10 SECONDS

/datum/bt_node/ai_behavior/bot_search/refillable_target/valid_target(datum/ai_controller/basic_controller/bot/controller, atom/my_target)
	var/static/list/desired_types = list(
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/tile,
	)
	for(var/object_type in desired_types)
		if(!istype(my_target, object_type))
			continue
		var/obj/item/stack/sheet_type = locate(object_type) in controller.pawn
		if(isnull(sheet_type))
			return TRUE //we dont have any of it!
		if(sheet_type.amount < sheet_type.max_amount && sheet_type.can_merge(my_target))
			return TRUE
	return FALSE

/datum/bt_node/ai_behavior/bot_search/refillable_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, looking_for = null, radius = 5, pathing_distance = 10, bypass_add_blacklist = FALSE, turf_search = FALSE)
	var/static/list/refillable_items = typecacheof(list(
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/tile,
	))
	return ..(seconds_per_tick, controller, target_key, refillable_items, radius, pathing_distance, bypass_add_blacklist, turf_search)

// =============================================================================
// Floor repair — find and fix plateless / breached floors
// =============================================================================

/datum/bt_node/ai_behavior/bot_search/valid_plateless_turf
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/bot_search/valid_plateless_turf/proc/get_turf_type_filter()
	return typecacheof(list(/turf/open/floor/plating))

/datum/bt_node/ai_behavior/bot_search/valid_plateless_turf/setup(datum/ai_controller/controller, target_key)
	var/mob/living/basic/bot/repairbot/bot_pawn = controller.pawn
	if(!(bot_pawn.repairbot_flags & REPAIRBOT_REPLACE_TILES))
		return FALSE
	if(!locate(/obj/item/stack/tile) in bot_pawn)
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/bot_search/valid_plateless_turf/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, looking_for = null, radius = 5, pathing_distance = 10, bypass_add_blacklist = FALSE, turf_search = TRUE)
	return ..(seconds_per_tick, controller, target_key, get_turf_type_filter(), radius, pathing_distance, bypass_add_blacklist, turf_search)

/datum/bt_node/ai_behavior/bot_search/valid_plateless_turf/valid_target(datum/ai_controller/basic_controller/bot/controller, turf/open/my_target)
	var/static/list/blacklist_objects = typecacheof(list(
		/obj/structure/window,
		/obj/structure/grille,
	))
	for(var/atom/possible_blacklisted in my_target.contents)
		if(is_type_in_typecache(possible_blacklisted, blacklist_objects))
			return FALSE
	if(istype(my_target, /turf/open/floor/plating) && !can_see(controller.pawn, my_target, 5))
		return FALSE
	var/static/list/blacklist_areas = typecacheof(list(
		/area/space,
		/area/station/maintenance,
	))
	var/turf_area = get_area(my_target)
	return !(is_type_in_typecache(turf_area, blacklist_areas))

/// Breach variant: searches /turf/open/space instead, requires REPAIRBOT_FIX_BREACHES flag.
/datum/bt_node/ai_behavior/bot_search/valid_plateless_turf/breached

/datum/bt_node/ai_behavior/bot_search/valid_plateless_turf/breached/setup(datum/ai_controller/controller, target_key)
	var/mob/living/basic/bot/repairbot/bot_pawn = controller.pawn
	if(!(bot_pawn.repairbot_flags & REPAIRBOT_FIX_BREACHES))
		return FALSE
	if(!locate(/obj/item/stack/tile/iron) in bot_pawn)
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/bot_search/valid_plateless_turf/breached/get_turf_type_filter()
	return typecacheof(list(/turf/open/space))

// =============================================================================
// Girder to wall — place iron sheets on girders
// =============================================================================

/datum/bt_node/ai_behavior/bot_search/valid_girder
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/bot_search/valid_girder/setup(datum/ai_controller/controller, target_key)
	var/mob/living/basic/bot/repairbot/bot_pawn = controller.pawn
	if(!(bot_pawn.repairbot_flags & REPAIRBOT_FIX_GIRDERS))
		return FALSE
	var/obj/item/stack/sheet/iron/my_iron = locate() in bot_pawn
	if(isnull(my_iron) || my_iron.amount < 2)
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/bot_search/valid_girder/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, looking_for = null, radius = 5, pathing_distance = 10, bypass_add_blacklist = FALSE, turf_search = FALSE)
	var/static/list/searchable_girder = typecacheof(list(/obj/structure/girder))
	return ..(seconds_per_tick, controller, target_key, searchable_girder, radius, pathing_distance, bypass_add_blacklist, turf_search)

/datum/bt_node/ai_behavior/bot_search/valid_girder/valid_target(datum/ai_controller/basic_controller/bot/controller, obj/my_target)
	if(!istype(my_target, /obj/structure/girder))
		return FALSE
	return isfloorturf(my_target.loc)

// =============================================================================
// Build girder — targeted_mob_ability with prerequisite checks
// =============================================================================

/datum/bt_node/ai_behavior/targeted_mob_ability/build_girder
	required_distance = 1

/datum/bt_node/ai_behavior/targeted_mob_ability/build_girder/setup(datum/ai_controller/controller, ability_key, target_key)
	var/mob/living/basic/bot/repairbot/bot_pawn = controller.pawn
	if(!(bot_pawn.repairbot_flags & REPAIRBOT_BUILD_GIRDERS))
		return FALSE
	var/obj/item/stack/rods/my_rods = locate() in bot_pawn
	if(isnull(my_rods) || my_rods.amount < 2)
		return FALSE
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	if(!ability?.IsAvailable())
		return FALSE
	return ..()

/datum/bt_node/ai_behavior/targeted_mob_ability/build_girder/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// Search for open turfs adjacent to space (valid girder build locations).
/datum/bt_node/ai_behavior/bot_search/valid_wall_target
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/bot_search/valid_wall_target/setup(datum/ai_controller/controller, target_key)
	var/mob/living/basic/bot/repairbot/bot_pawn = controller.pawn
	if(!(bot_pawn.repairbot_flags & REPAIRBOT_BUILD_GIRDERS))
		return FALSE
	var/obj/item/stack/rods/my_rods = locate() in bot_pawn
	if(isnull(my_rods) || my_rods.amount < 2)
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/bot_search/valid_wall_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, looking_for = null, radius = 5, pathing_distance = 10, bypass_add_blacklist = FALSE, turf_search = TRUE)
	var/static/list/searchable_turfs = typecacheof(list(/turf/open))
	return ..(seconds_per_tick, controller, target_key, searchable_turfs, radius, pathing_distance, bypass_add_blacklist, turf_search)

/datum/bt_node/ai_behavior/bot_search/valid_wall_target/valid_target(datum/ai_controller/basic_controller/bot/controller, turf/my_target)
	if(!istype(my_target, /turf/open))
		return FALSE
	if(istype(get_area(my_target), /area/space) || isgroundlessturf(my_target) || my_target.is_blocked_turf())
		return FALSE
	var/static/list/blacklist_objects = typecacheof(list(
		/obj/machinery/door,
		/obj/structure/grille,
	))
	for(var/atom/contents in my_target)
		if(is_type_in_typecache(contents, blacklist_objects))
			return FALSE
	var/turf/adjacent_turfs = get_adjacent_open_turfs(my_target)
	for(var/turf/possible_spaced_turf as anything in adjacent_turfs)
		if(isspaceturf(possible_spaced_turf) && istype(get_area(possible_spaced_turf), /area/space))
			return TRUE
	return FALSE

// =============================================================================
// Window replacement — find grilles missing a window pane
// =============================================================================

/datum/bt_node/ai_behavior/bot_search/valid_grille_target
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/bot_search/valid_grille_target/setup(datum/ai_controller/controller, target_key)
	var/mob/living/basic/bot/repairbot/bot_pawn = controller.pawn
	if(!(bot_pawn.repairbot_flags & REPAIRBOT_REPLACE_WINDOWS))
		return FALSE
	if(!locate(/obj/item/stack/sheet/glass) in bot_pawn)
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/bot_search/valid_grille_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, looking_for = null, radius = 5, pathing_distance = 10, bypass_add_blacklist = FALSE, turf_search = FALSE)
	var/static/list/searchable_grilles = typecacheof(list(/obj/structure/grille))
	return ..(seconds_per_tick, controller, target_key, searchable_grilles, radius, pathing_distance, bypass_add_blacklist, turf_search)

/datum/bt_node/ai_behavior/bot_search/valid_grille_target/valid_target(datum/ai_controller/basic_controller/bot/controller, obj/structure/my_target)
	if(!istype(my_target, /obj/structure/grille))
		return FALSE
	if(locate(/obj/structure/window) in get_turf(my_target))
		return FALSE
	return (!istype(get_area(my_target), /area/space))

// =============================================================================
// Window repair — find damaged or unanchored windows
// =============================================================================

/datum/bt_node/ai_behavior/bot_search/valid_window_fix
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/bot_search/valid_window_fix/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, looking_for = null, radius = 5, pathing_distance = 10, bypass_add_blacklist = FALSE, turf_search = FALSE)
	var/static/list/searchable_objects = typecacheof(list(/obj/structure/window))
	return ..(seconds_per_tick, controller, target_key, searchable_objects, radius, pathing_distance, bypass_add_blacklist, turf_search)

/datum/bt_node/ai_behavior/bot_search/valid_window_fix/valid_target(datum/ai_controller/basic_controller/bot/controller, obj/my_target)
	if(!istype(my_target, /obj/structure/window))
		return FALSE
	return (my_target.get_integrity() < my_target.max_integrity || !my_target.anchored)

#undef REPAIRBOT_SPEECH_TIMER
