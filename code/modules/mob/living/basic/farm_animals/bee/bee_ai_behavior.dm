/// if we have a hive, this will be our aggro distance
#define AGGRO_DISTANCE_FROM_HIVE 2

/datum/targeting_strategy/basic/bee

/datum/targeting_strategy/basic/bee/can_attack(mob/living/owner, atom/target, vision_range)
	if(!isliving(target))
		return FALSE
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/mob_target = target

	if(mob_target.mob_biotypes & MOB_PLANT)
		return FALSE

	var/datum/ai_controller/basic_controller/bee_ai = owner.ai_controller
	if(isnull(bee_ai))
		return FALSE

	var/atom/bee_hive = bee_ai.blackboard[BB_CURRENT_HOME]
	if(bee_hive && get_dist(target, bee_hive) > AGGRO_DISTANCE_FROM_HIVE && can_see(owner, bee_hive, 9))
		return FALSE

	return !(mob_target.bee_friendly())


///swirl around the owner in menacing fashion
/datum/pet_command/attack/swirl
	command_name = "Swirl"
	requires_pointing = TRUE
	command_desc = "Your pets will swirl around you and attack whoever you point at!"
	speech_commands = list("swirl", "spiral", "swarm")
	pointed_reaction = null
	refuse_reaction = null
	command_feedback = null
	///the owner we will swarm around
	var/key_to_swarm = BB_SWARM_TARGET

/datum/pet_command/attack/swirl/try_activate_command(mob/living/commander, radial_command)
	var/mob/living/living_pawn = weak_parent.resolve()
	if(isnull(living_pawn))
		return
	var/datum/ai_controller/basic_controller/controller = living_pawn.ai_controller
	if(isnull(controller))
		return
	controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
	controller.set_blackboard_key(key_to_swarm, commander)
	return ..()

/datum/pet_command/attack/swirl/execute_action(datum/ai_controller/controller)
	if(controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		return ..()
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/pet_command/swirl)


/datum/pet_command/beehive
	radial_icon = 'icons/obj/service/hydroponics/equipment.dmi'
	radial_icon_state = "beebox"

/datum/pet_command/beehive/try_activate_command(mob/living/commander, radial_command)
	var/mob/living/living_pawn = weak_parent.resolve()
	if(isnull(living_pawn))
		return
	var/datum/ai_controller/basic_controller/controller = living_pawn.ai_controller
	if(isnull(controller))
		return
	var/obj/hive = controller.blackboard[BB_CURRENT_HOME]
	if(isnull(hive))
		return
	if(!check_beehive_conditions(living_pawn, hive))
		return
	return ..()

/datum/pet_command/beehive/proc/check_beehive_conditions(obj/structure/hive)
	return

/datum/pet_command/beehive/execute_action(datum/ai_controller/controller)
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/pet_command/beehive)

/datum/pet_command/beehive/enter
	command_name = "Enter beehive"
	command_desc = "Your bees will enter their beehive."
	speech_commands = list("enter", "home", "in")

/datum/pet_command/beehive/enter/check_beehive_conditions(mob/living/living_pawn, obj/structure/hive)
	if(living_pawn in hive) //already in hive
		return FALSE
	return can_see(living_pawn, hive, 9)

/datum/pet_command/beehive/exit
	command_name = "Exit beehive"
	command_desc = "Your bees will exit their beehive."
	speech_commands = list("exit", "leave", "out")

/datum/pet_command/beehive/exit/check_beehive_conditions(mob/living/living_pawn, obj/structure/hive)
	return (living_pawn in hive)

/datum/pet_command/scatter
	command_name = "Scatter"
	command_desc = "Command your pets to scatter all around you!"
	speech_commands = list("disperse", "spread", "scatter")

/datum/pet_command/scatter/set_command_active(mob/living/parent, mob/living/commander)
	. = ..()
	set_command_target(parent, commander)

/datum/pet_command/scatter/execute_action(datum/ai_controller/controller)
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/pet_command/scatter)


#undef AGGRO_DISTANCE_FROM_HIVE
