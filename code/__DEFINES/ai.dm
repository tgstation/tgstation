#define GET_AI_BEHAVIOR(behavior_type) SSai_controllers.ai_behaviors[behavior_type]

#define AI_STATUS_ON		1
#define AI_STATUS_OFF		2

///Flags for ai_behavior new()
#define AI_BEHAVIOR_INCOMPATIBLE (1<<0)


///Types of behavior, used for parallel behavior sets.

///Used for the current movement action of an AI
#define AI_BEHAVIOR_MOVEMENT "ai_behavior_movement"
///Used for the current physical action of an AI e.g. shooting a gun, punching something.
#define AI_BEHAVIOR_ACTION "ai_behavior_action"
///Used for speech beaviors, e.g. a man yelling.
#define AI_BEHAVIOR_SPEECH "ai_behavior_speech"



#define BB_NEXT_SCREECH "BB_next_screech"

///Monkey AI controller blackboard keys

#define BB_MONKEY_AGRESSIVE "BB_monkey_agressive"
#define BB_MONKEY_BEST_FORCE_FOUND "BB_monkey_bestforcefound"
#define BB_MONKEY_ENEMIES "BB_monkey_enemies"
#define BB_MONKEY_BLACKLISTITEMS "BB_monkey_blacklistitems"
#define BB_MONKEY_PICKUPTARGET "BB_monkey_pickuptarget"
#define BB_MONKEY_PICKPOCKETING "BB_monkey_pickpocketing"
