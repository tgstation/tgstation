
///sent from ai controllers when they possess a pawn: (datum/ai_controller/source_controller)
#define COMSIG_AI_CONTROLLER_POSSESSED_PAWN "ai_controller_possessed_pawn"
///sent from ai controllers when they pick behaviors: (list/datum/ai_behavior/old_behaviors, list/datum/ai_behavior/new_behaviors)
#define COMSIG_AI_CONTROLLER_PICKED_BEHAVIORS "ai_controller_picked_behaviors"
///sent from ai controllers when a behavior is inserted into the queue: (list/new_arguments)
#define AI_CONTROLLER_BEHAVIOR_QUEUED(type) "ai_controller_behavior_queued_[type]"

/// sent from ai controllers when the pawn becomes friendly : (mob/living/new_friend, is_first_friend)
#define COMSIG_AI_CONTROLLER_GAINED_FRIEND "ai_controller_gained_friend"
/// sent from ai controllers when the pawn loses friendship : (mob/living/old_friend, has_remaining_friends)
#define COMSIG_AI_CONTROLLER_LOST_FRIEND "ai_controller_losts_friend"
/// sent from ai controllers when the pawn becomes friendly : (mob/living/new_friend, is_first_enemy)
#define COMSIG_AI_CONTROLLER_GAINED_ENEMY "ai_controller_gained_enemy"
/// sent from ai controllers when the pawn forgives an enemy : (mob/living/old_enemy, has_remaining_enemies)
#define COMSIG_AI_CONTROLLER_LOST_ENEMY "ai_controller_lost_enemy"
