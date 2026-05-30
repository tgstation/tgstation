
///sent from ai controllers when they possess a pawn: (datum/ai_controller/source_controller)
#define COMSIG_AI_CONTROLLER_POSSESSED_PAWN "ai_controller_possessed_pawn"
///sent from ai controllers when they stop possessing a pawn: (datum/ai_controller/source_controller)
#define COMSIG_AI_CONTROLLER_UNPOSSESSED_PAWN "ai_controller_unpossessed_pawn"
///sent from ai controllers when they pick behaviors: (list/datum/ai_behavior/old_behaviors, list/datum/ai_behavior/new_behaviors)
#define COMSIG_AI_CONTROLLER_PICKED_BEHAVIORS "ai_controller_picked_behaviors"
///sent from ai controllers when a behavior is inserted into the queue: (list/new_arguments)
#define AI_CONTROLLER_BEHAVIOR_QUEUED(type) "ai_controller_behavior_queued_[type]"
///sent from the pawn of an ai controller when a runtime subtree override slot changes: (new_type) — new_type is null when cleared
#define COMSIG_AI_OVERRIDE_SLOT_CHANGED(id) "ai_override_slot_changed_[id]"
