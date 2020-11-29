#define GET_AI_BEHAVIOR(behavior_type) SSai_controllers.ai_behaviors[behavior_type]

#define AI_STATUS_ON		1
#define AI_STATUS_OFF		2


///Monkey checks
#define SHOULD_RESIST(source) (source.on_fire || source.buckled || HAS_TRAIT(source, TRAIT_RESTRAINED) || (source.pulledby && source.pulledby.grab_state > GRAB_PASSIVE))
#define IS_DEAD_OR_INCAP(source) (HAS_TRAIT(source, TRAIT_INCAPACITATED) || HAS_TRAIT(source, TRAIT_HANDS_BLOCKED) || IS_IN_STASIS(source))

///Max pathing attempts before auto-fail
#define MAX_PATHING_ATTEMPTS 10

///Flags for ai_behavior new()
#define AI_BEHAVIOR_INCOMPATIBLE (1<<0)

///Does this task require movement from the AI?
#define AI_BEHAVIOR_REQUIRE_MOVEMENT (1<<0)




///Monkey AI controller blackboard keys

#define BB_MONKEY_AGRESSIVE "BB_monkey_agressive"
#define BB_MONKEY_BEST_FORCE_FOUND "BB_monkey_bestforcefound"
#define BB_MONKEY_ENEMIES "BB_monkey_enemies"
#define BB_MONKEY_BLACKLISTITEMS "BB_monkey_blacklistitems"
#define BB_MONKEY_PICKUPTARGET "BB_monkey_pickuptarget"
#define BB_MONKEY_PICKPOCKETING "BB_monkey_pickpocketing"
#define BB_MONKEY_CURRENT_ATTACK_TARGET "BB_monkey_current_attack_target"
#define BB_MONKEY_FRUSTRATION "BB_monkey_frustration"
#define BB_MONKEY_TARGET_DISPOSAL "BB_monkey_target_disposal"
#define BB_MONKEY_DISPOSING "BB_monkey_disposing"
