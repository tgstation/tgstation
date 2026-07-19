
///sent from ai controllers when they possess a pawn: (datum/ai_controller/source_controller)
#define COMSIG_AI_CONTROLLER_POSSESSED_PAWN "ai_controller_possessed_pawn"
///sent from ai controllers when they stop possessing a pawn: (datum/ai_controller/source_controller)
#define COMSIG_AI_CONTROLLER_UNPOSSESSED_PAWN "ai_controller_unpossessed_pawn"
///sent from the pawn of an ai controller when a runtime subtree override slot changes: (new_type) new_type is null when cleared
#define COMSIG_AI_OVERRIDE_SLOT_CHANGED(id) "ai_override_slot_changed_[id]"
