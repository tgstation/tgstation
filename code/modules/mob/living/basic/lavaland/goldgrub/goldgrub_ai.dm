/datum/ai_controller/basic_controller/goldgrub
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_ORE_IGNORE_TYPES = list(/obj/item/stack/ore/iron, /obj/item/stack/ore/glass),
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/goldgrub/goldgrub.bt.json"

/datum/ai_controller/basic_controller/babygrub
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_ORE_IGNORE_TYPES = list(/obj/item/stack/ore/glass),
		BB_FIND_MOM_TYPES = list(/mob/living/basic/mining/goldgrub),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/mining/goldgrub/baby),
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/goldgrub/babygrub.bt.json"

/datum/pet_command/grub_spit
	command_name = "Spit"
	radial_icon = 'icons/obj/ore.dmi'
	radial_icon_state = "uranium"
	command_desc = "Ask your grub pet to spit out its ores."
	speech_commands = list("spit", "ores")

/datum/pet_command/grub_spit/execute_action(datum/ai_controller/controller)
	var/datum/action/cooldown/spit_ability = controller.blackboard[BB_SPIT_ABILITY]
	if(!spit_ability?.IsAvailable())
		return
	controller.set_blackboard_key(BB_PET_ACTIVE_ABILITY, spit_ability)
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/pet_command/untargeted_ability)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/grub_spit/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to spit its ores!"
