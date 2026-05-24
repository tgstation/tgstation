/datum/ai_controller/basic_controller/bot/secbot/super_beepsky
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity/pacifist),\
		BT_SUBTREE(/datum/bt_node/subtree/bot_respond_to_summon),\
		BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
			BT_PARALLEL(BT_PARALLEL_FAILURE_ONE,\
				BT_LEAF(/datum/bt_node/ai_behavior/basic_melee_attack,\
					BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
				),\
				BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
					BB_BASIC_MOB_CURRENT_TARGET, 1\
				)\
			),\
			"key" = BB_BASIC_MOB_CURRENT_TARGET\
		),\
		BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets,\
			BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
		),\
		BT_SUBTREE(/datum/bt_node/subtree/bot_find_patrol_beacon)\
	)

/datum/ai_controller/basic_controller/bot/secbot/super_beepsky/on_target_set()
	. = ..()
	var/mob/living/basic/bot/secbot/grievous/super_beeps = pawn
	if(!super_beeps.sword_active)
		INVOKE_ASYNC(super_beeps.weapon, TYPE_PROC_REF(/obj/item, attack_self), super_beeps)
	super_beeps.visible_message("<b>[super_beeps]</b> points at [blackboard[BB_BASIC_MOB_CURRENT_TARGET]]!")
