#define MAXIMUM_GUTLUNCH_POP 20
/datum/ai_controller/basic_controller/gutlunch
	ai_movement = /datum/ai_movement/basic_avoidance

/datum/ai_controller/basic_controller/gutlunch/gutlunch_warrior
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/mining/gutlunch/milk),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/mining/gutlunch/grub),
		BB_MAX_CHILDREN = 5,
	)
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/gutlunchers/gutlunch_warrior.bt.json"

/datum/ai_controller/basic_controller/gutlunch/gutlunch_baby
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/mining/gutlunch/milk),
	)
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/gutlunchers/gutlunch_baby.bt.json"

/datum/ai_controller/basic_controller/gutlunch/gutlunch_milk
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/gutlunchers/gutlunch_milk.bt.json"

/datum/pet_command/mine_walls
	command_name = "Mine"
	radial_icon_state = "mine"
	command_desc = "Command your pet to mine down walls."
	speech_commands = list("mine", "smash")

/datum/pet_command/mine_walls/try_activate_command(mob/living/commander, radial_command)
	var/mob/living/parent = weak_parent.resolve()
	if(isnull(parent))
		return
	//no walls for us to mine
	var/target_in_vicinity = locate(/turf/closed/mineral) in oview(9, parent)
	if(isnull(target_in_vicinity))
		return
	return ..()

/datum/pet_command/mine_walls/execute_action(datum/ai_controller/controller)
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/pet_command/mine_walls)

/datum/pet_command/mine_walls/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to start mining!"

//pet commands
/datum/pet_command/breed/gutlunch

/datum/pet_command/breed/gutlunch/set_command_target(mob/living/parent, atom/target)
	if(GLOB.gutlunch_count >= MAXIMUM_GUTLUNCH_POP)
		parent.balloon_alert_to_viewers("can't reproduce anymore!")
		return FALSE
	return ..()

#undef MAXIMUM_GUTLUNCH_POP
