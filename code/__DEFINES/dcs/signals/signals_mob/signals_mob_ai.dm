/// Signal sent when a blackboard key is set to a new value
#define COMSIG_AI_BLACKBOARD_KEY_SET(blackboard_key) "ai_blackboard_key_set_[blackboard_key]"

///Signal sent before a blackboard key is cleared
#define COMSIG_AI_BLACKBOARD_KEY_PRECLEAR(blackboard_key) "ai_blackboard_key_pre_clear_[blackboard_key]"

/// Signal sent when a blackboard key is cleared
#define COMSIG_AI_BLACKBOARD_KEY_CLEARED(blackboard_key) "ai_blackboard_key_clear_[blackboard_key]"

///Signal sent when a bot is reset
#define COMSIG_BOT_RESET "bot_reset"
///Sent off /mob/living/basic/bot/proc/set_mode_flags() : (new_flags)
#define COMSIG_BOT_MODE_FLAGS_SET "bot_mode_flags_set"

///Signal sent off of ai/movement/proc/start_moving_towards
#define COMSIG_MOB_AI_MOVEMENT_STARTED "mob_ai_movement_started"
