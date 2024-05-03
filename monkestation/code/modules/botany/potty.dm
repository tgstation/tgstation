/mob/living/basic/pet/potty
	name = "craig the potted plant"
	desc = "A potted plant."

	icon = 'monkestation/code/modules/botany/icons/potty.dmi'
	icon_state = "potty"
	icon_living = "potty_living"
	icon_dead = "potty_dead"

	dexterous = TRUE
	held_items = list(null, null)

	ai_controller = /datum/ai_controller/basic_controller/craig

	/// Instructions you can give to dogs
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/craig_harvest,
		/datum/pet_command/free,
		/datum/pet_command/good_boy/dog,
		/datum/pet_command/follow/dog,
		/datum/pet_command/point_targeting/attack/dog,
		/datum/pet_command/point_targeting/fetch,
		/datum/pet_command/play_dead,
	)

/mob/living/basic/pet/potty/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/plant_tray_overlay, icon, null, null, null, null, null, null, 3, 8)
	AddComponent(/datum/component/plant_growing)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddComponent(/datum/component/emotion_buffer)
	AddComponent(/datum/component/friendship_container, list(FRIENDSHIP_HATED = -100, FRIENDSHIP_DISLIKED = -50, FRIENDSHIP_STRANGER = 0, FRIENDSHIP_NEUTRAL = 1, FRIENDSHIP_ACQUAINTANCES = 3, FRIENDSHIP_FRIEND = 5, FRIENDSHIP_BESTFRIEND = 10), FRIENDSHIP_FRIEND)
	AddElement(/datum/element/waddling)

	SEND_SIGNAL(src, COMSIG_TOGGLE_BIOBOOST)

/mob/living/basic/pet/potty/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	face_atom(target)
	if (!ignore_cooldown)
		changeNext_move(melee_attack_cooldown)
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target, Adjacent(target), modifiers) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE //but more importantly return before attack_animal called
	var/result
	if(held_items[active_hand_index])
		var/obj/item/W = get_active_held_item()
		result = W.melee_attack_chain(src, target)
		SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
		return result
	result = target.attack_basic_mob(src, modifiers)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	return result

/mob/living/basic/pet/potty/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()

	if(!. || !proximity_flag || (locate(/obj/item/reagent_containers/cup/watering_can) in contents))
		return

	if(!istype(attack_target, /obj/item/reagent_containers/cup/watering_can))
		return

	var/obj/item/can_target = attack_target
	can_target.pickup(src)

/datum/pet_command/craig_harvest
	command_name = "Shake"
	command_desc = "Command your pet to stay idle in this location."
	radial_icon = 'icons/obj/objects.dmi'
	radial_icon_state = "dogbed"
	speech_commands = list("shake", "harvest")
	command_feedback = "shakes"

/datum/pet_command/craig_harvest/execute_action(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	pawn.Shake(2, 2, 3 SECONDS)
	SEND_SIGNAL(pawn, COMSIG_TRY_HARVEST_SEEDS, pawn)
	return SUBTREE_RETURN_FINISH_PLANNING // This cancels further AI planning

/datum/ai_controller/basic_controller/craig
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_WEEDLEVEL_THRESHOLD = 3,
		BB_WATERLEVEL_THRESHOLD = 90,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_and_hunt_target/watering_can,
		/datum/ai_planning_subtree/find_and_hunt_target/fill_watercan,
		/datum/ai_planning_subtree/find_and_hunt_target/treat_hydroplants,
	)
