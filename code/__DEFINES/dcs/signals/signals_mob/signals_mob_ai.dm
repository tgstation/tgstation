/// Signal sent when a blackboard key is set to a new value
#define COMSIG_AI_BLACKBOARD_KEY_SET(blackboard_key) "ai_blackboard_key_set_[blackboard_key]"

/// Signal sent when a blackboard key is cleared
#define COMSIG_AI_BLACKBOARD_KEY_CLEARED(blackboard_key) "ai_blackboard_key_clear_[blackboard_key]"

///Signal sent when a bot is reset
#define COMSIG_BOT_RESET "bot_reset"

///From base of /mob/living/basic/bot/proc/set_bot_mode_flags(): (old_flags, new_flags)
#define COMSIG_BOT_SET_MODE_FLAGS "bot_set_mode_flags"
