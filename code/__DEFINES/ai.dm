#define GET_AI_BEHAVIOR(behavior_type) SSai_controllers.ai_behaviors[behavior_type]
#define HAS_AI_CONTROLLER_TYPE(thing, type) istype(thing?.ai_controller, type)

#define AI_STATUS_ON		1
#define AI_STATUS_OFF		2


///Monkey checks
#define SHOULD_RESIST(source) (source.on_fire || source.buckled || HAS_TRAIT(source, TRAIT_RESTRAINED) || (source.pulledby && source.pulledby.grab_state > GRAB_PASSIVE))
#define IS_DEAD_OR_INCAP(source) (HAS_TRAIT(source, TRAIT_INCAPACITATED) || HAS_TRAIT(source, TRAIT_HANDS_BLOCKED) || IS_IN_STASIS(source) || source.stat)

///Max pathing attempts before auto-fail
#define MAX_PATHING_ATTEMPTS 16

///Flags for ai_behavior new()
#define AI_CONTROLLER_INCOMPATIBLE (1<<0)

///Does this task require movement from the AI before it can be performed?
#define AI_BEHAVIOR_REQUIRE_MOVEMENT (1<<0)
///Does this task let you perform the action while you move closer? (Things like moving and shooting)
#define AI_BEHAVIOR_MOVE_AND_PERFORM (1<<1)


///Monkey AI controller blackboard keys

#define BB_MONKEY_AGRESSIVE "BB_monkey_agressive"
#define BB_MONKEY_BEST_FORCE_FOUND "BB_monkey_bestforcefound"
#define BB_MONKEY_ENEMIES "BB_monkey_enemies"
#define BB_MONKEY_BLACKLISTITEMS "BB_monkey_blacklistitems"
#define BB_MONKEY_PICKUPTARGET "BB_monkey_pickuptarget"
#define BB_MONKEY_PICKPOCKETING "BB_monkey_pickpocketing"
#define BB_MONKEY_CURRENT_ATTACK_TARGET "BB_monkey_current_attack_target"
#define BB_MONKEY_TARGET_DISPOSAL "BB_monkey_target_disposal"
#define BB_MONKEY_DISPOSING "BB_monkey_disposing"
#define BB_MONKEY_RECRUIT_COOLDOWN "BB_monkey_recruit_cooldown"



///Haunted item controller defines

///Chance for haunted item to haunt someone
#define HAUNTED_ITEM_ATTACK_HAUNT_CHANCE 10
///Chance for haunted item to try to get itself let go.
#define HAUNTED_ITEM_ESCAPE_GRASP_CHANCE 20
///Chance for haunted item to warp somewhere new
#define HAUNTED_ITEM_TELEPORT_CHANCE 4
///Amount of aggro you get when picking up a haunted item
#define HAUNTED_ITEM_AGGRO_ADDITION 2

///Blackboard keys for haunted items
#define BB_TO_HAUNT_LIST "BB_to_haunt_list"
///Actual mob the item is haunting at the moment
#define BB_HAUNT_TARGET "BB_haunt_target"
///Amount of successful hits in a row this item has had
#define BB_HAUNTED_THROW_ATTEMPT_COUNT "BB_haunted_throw_attempt_count"

///Vending machine AI controller blackboard keys
#define BB_VENDING_CURRENT_TARGET "BB_vending_current_target"
#define BB_VENDING_TILT_COOLDOWN "BB_vending_tilt_cooldown"
#define BB_VENDING_UNTILT_COOLDOWN "BB_vending_untilt_cooldown"
#define BB_VENDING_BUSY_TILTING "BB_vending_busy_tilting"
#define BB_VENDING_LAST_HIT_SUCCESFUL "BB_vending_last_hit_succesful"


///Dog AI controller blackboard keys

#define BB_FETCHING "BB_FETCHING"
#define BB_SIMPLE_CARRY_ITEM "BB_SIMPLE_CARRY_ITEM"
#define BB_FETCH_TARGET "BB_FETCH_TARGET"
#define BB_FETCH_IGNORE_LIST "BB_FETCH_IGNORE_LISTlist"
#define BB_FETCH_DELIVER_TO "BB_FETCH_DELIVER_TO"
#define BB_FETCH_THROW_LISTENERS "BB_FETCH_THROW_LISTENERS"
#define BB_DOG_FRIENDS "BB_DOG_FRIENDS"
#define BB_FETCH_RESET_IGNORE_CD "BB_FETCH_RESET_IGNORE_CD"
#define BB_DOG_ORDER_MODE "BB_DOG_ORDER_MODE"
#define BB_DOG_HEEL_CD "BB_DOG_RELAX_CD"
#define BB_DOG_PLAYING_DEAD "BB_DOG_PLAYING_DEAD"
#define BB_DOG_HARASS_TARGET "BB_DOG_HARASS_TARGET"

/// Basically, what is our vision/hearing range for picking up on things to fetch?
#define AI_DOG_VISION_RANGE	7
/// What are the odds someone petting us will become our friend?
#define AI_DOG_PET_FRIEND_PROB		15
/// After this long without having fetched something, we clear our ignore list
#define AI_FETCH_IGNORE_DURATION	30 SECONDS
/// After being ordered to heel, we spend this long chilling out
#define AI_DOG_HEEL_DURATION	10 SECONDS

// dog command modes (what pointing at something/someone does depending on the last order the dog heard)
/// Don't do anything (will still react to stuff around them though)
#define DOG_COMMAND_NONE	0
/// Will try to pick up and bring back whatever you point to
#define DOG_COMMAND_FETCH	1
/// Will get within a few tiles of whatever you point at and continually growl/bark. If the target is a living mob who gets too close, the dog will attack them with bites
#define DOG_COMMAND_ATTACK	2
