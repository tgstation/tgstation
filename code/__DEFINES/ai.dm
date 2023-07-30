#define GET_AI_BEHAVIOR(behavior_type) SSai_behaviors.ai_behaviors[behavior_type]
#define HAS_AI_CONTROLLER_TYPE(thing, type) istype(thing?.ai_controller, type)

#define AI_STATUS_ON 1
#define AI_STATUS_OFF 2

///For JPS pathing, the maximum length of a path we'll try to generate. Should be modularized depending on what we're doing later on
#define AI_MAX_PATH_LENGTH 30 // 30 is possibly overkill since by default we lose interest after 14 tiles of distance, but this gives wiggle room for weaving around obstacles

///Cooldown on planning if planning failed last time

#define AI_FAILED_PLANNING_COOLDOWN (1.5 SECONDS)

///Flags for ai_behavior new()
#define AI_CONTROLLER_INCOMPATIBLE (1<<0)

///Does this task require movement from the AI before it can be performed?
#define AI_BEHAVIOR_REQUIRE_MOVEMENT (1<<0)
///Does this require the current_movement_target to be adjacent and in reach?
#define AI_BEHAVIOR_REQUIRE_REACH (1<<1)
///Does this task let you perform the action while you move closer? (Things like moving and shooting)
#define AI_BEHAVIOR_MOVE_AND_PERFORM (1<<2)
///Does finishing this task not null the current movement target?
#define AI_BEHAVIOR_KEEP_MOVE_TARGET_ON_FINISH (1<<3)
///Does finishing this task make the AI stop moving towards the target?
#define AI_BEHAVIOR_KEEP_MOVING_TOWARDS_TARGET_ON_FINISH (1<<4)
///Does this behavior NOT block planning?
#define AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION (1<<5)

///AI flags
/// Don't move if being pulled
#define STOP_MOVING_WHEN_PULLED (1<<0)
/// Continue processing even if dead
#define CAN_ACT_WHILE_DEAD	(1<<1)

//Base Subtree defines

///This subtree should cancel any further planning, (Including from other subtrees)
#define SUBTREE_RETURN_FINISH_PLANNING 1

//Generic subtree defines

/// probability that the pawn should try resisting out of restraints
#define RESIST_SUBTREE_PROB 50
///macro for whether it's appropriate to resist right now, used by resist subtree
#define SHOULD_RESIST(source) (source.on_fire || source.buckled || HAS_TRAIT(source, TRAIT_RESTRAINED) || (source.pulledby && source.pulledby.grab_state > GRAB_PASSIVE))
///macro for whether the pawn can act, used generally to prevent some horrifying ai disasters
#define IS_DEAD_OR_INCAP(source) (source.incapacitated() || source.stat)

//Generic BB keys
#define BB_CURRENT_MIN_MOVE_DISTANCE "min_move_distance"
///time until we should next eat, set by the generic hunger subtree
#define BB_NEXT_HUNGRY "BB_NEXT_HUNGRY"
///what we're going to eat next
#define BB_FOOD_TARGET "bb_food_target"
///Path we should use next time we use the JPS movement datum
#define BB_PATH_TO_USE "BB_path_to_use"

//for songs

///song instrument blackboard, set by instrument subtrees
#define BB_SONG_INSTRUMENT "BB_SONG_INSTRUMENT"
///song lines blackboard, set by default on controllers
#define BB_SONG_LINES "song_lines"

// Monkey AI controller blackboard keys

#define BB_MONKEY_AGGRESSIVE "BB_monkey_aggressive"
#define BB_MONKEY_GUN_NEURONS_ACTIVATED "BB_monkey_gun_aware"
#define BB_MONKEY_GUN_WORKED "BB_monkey_gun_worked"
#define BB_MONKEY_BEST_FORCE_FOUND "BB_monkey_bestforcefound"
#define BB_MONKEY_ENEMIES "BB_monkey_enemies"
#define BB_MONKEY_BLACKLISTITEMS "BB_monkey_blacklistitems"
#define BB_MONKEY_PICKUPTARGET "BB_monkey_pickuptarget"
#define BB_MONKEY_PICKPOCKETING "BB_monkey_pickpocketing"
#define BB_MONKEY_CURRENT_ATTACK_TARGET "BB_monkey_current_attack_target"
#define BB_MONKEY_CURRENT_PRESS_TARGET "BB_monkey_current_press_target"
#define BB_MONKEY_CURRENT_GIVE_TARGET "BB_monkey_current_give_target"
#define BB_MONKEY_TARGET_DISPOSAL "BB_monkey_target_disposal"
#define BB_MONKEY_TARGET_MONKEYS "BB_monkey_target_monkeys"
#define BB_MONKEY_DISPOSING "BB_monkey_disposing"
#define BB_MONKEY_RECRUIT_COOLDOWN "BB_monkey_recruit_cooldown"

///Haunted item controller defines

///Chance for haunted item to haunt someone
#define HAUNTED_ITEM_ATTACK_HAUNT_CHANCE 10
///Chance for haunted item to try to get itself let go.
#define HAUNTED_ITEM_ESCAPE_GRASP_CHANCE 20
///Amount of aggro you get when picking up a haunted item
#define HAUNTED_ITEM_AGGRO_ADDITION 2

///Blackboard keys for haunted items
#define BB_TO_HAUNT_LIST "BB_to_haunt_list"
///Actual mob the item is haunting at the moment
#define BB_HAUNT_TARGET "BB_haunt_target"
///Amount of successful hits in a row this item has had
#define BB_HAUNTED_THROW_ATTEMPT_COUNT "BB_haunted_throw_attempt_count"
///If true, tolerates the equipper holding/equipping the hauntium
#define BB_LIKES_EQUIPPER "BB_likes_equipper"

///Cursed item controller defines

//defines
///how far a cursed item will still try to chase a target
#define CURSED_VIEW_RANGE 7
//blackboards

///Actual mob the item is haunting at the moment
#define BB_CURSE_TARGET "BB_haunt_target"
///Where the item wants to land on
#define BB_TARGET_SLOT "BB_target_slot"
///Amount of successful hits in a row this item has had
#define BB_CURSED_THROW_ATTEMPT_COUNT "BB_cursed_throw_attempt_count"

///Mob the MOD is trying to attach to
#define BB_MOD_TARGET "BB_mod_target"
///The implant the AI was created from
#define BB_MOD_IMPLANT "BB_mod_implant"
///Range for a MOD AI controller.
#define MOD_AI_RANGE 200

///Vending machine AI controller blackboard keys
#define BB_VENDING_CURRENT_TARGET "BB_vending_current_target"
#define BB_VENDING_TILT_COOLDOWN "BB_vending_tilt_cooldown"
#define BB_VENDING_UNTILT_COOLDOWN "BB_vending_untilt_cooldown"
#define BB_VENDING_BUSY_TILTING "BB_vending_busy_tilting"
#define BB_VENDING_LAST_HIT_SUCCESFUL "BB_vending_last_hit_succesful"

//Robot customer AI controller blackboard keys
/// Corresponds to the customer's order.
/// This can be a an item typepath or an instance of a custom order datum
#define BB_CUSTOMER_CURRENT_ORDER "BB_customer_current_order"
#define BB_CUSTOMER_MY_SEAT "BB_customer_my_seat"
#define BB_CUSTOMER_PATIENCE "BB_customer_patience"
/// A reference to a customer data datum, containing stuff like saylines and food desires
#define BB_CUSTOMER_CUSTOMERINFO "BB_customer_customerinfo"
/// Whether we're busy eating something already
#define BB_CUSTOMER_EATING "BB_customer_eating"
/// A reference to the venue being attended
#define BB_CUSTOMER_ATTENDING_VENUE "BB_customer_attending_avenue"
/// Whether we're leaving the venue entirely, either happily or forced out
#define BB_CUSTOMER_LEAVING "BB_customer_leaving"
#define BB_CUSTOMER_CURRENT_TARGET "BB_customer_current_target"
/// Robot customer has said their can't find seat line at least once. Used to rate limit how often they'll complain after the first time.
#define BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE "BB_customer_said_cant_find_seat_line"


///Hostile AI controller blackboard keys
#define BB_HOSTILE_ORDER_MODE "BB_HOSTILE_ORDER_MODE"
#define BB_HOSTILE_FRIEND "BB_HOSTILE_FRIEND"
#define BB_HOSTILE_ATTACK_WORD "BB_HOSTILE_ATTACK_WORD"
#define BB_FOLLOW_TARGET "BB_FOLLOW_TARGET"
#define BB_ATTACK_TARGET "BB_ATTACK_TARGET"
#define BB_VISION_RANGE "BB_VISION_RANGE"

/// Basically, what is our vision/hearing range.
#define BB_HOSTILE_VISION_RANGE 10
/// After either being given a verbal order or a pointing order, ignore further of each for this duration
#define AI_HOSTILE_COMMAND_COOLDOWN (2 SECONDS)

// hostile command modes (what pointing at something/someone does depending on the last order the carp heard)
/// Don't do anything (will still react to stuff around them though)
#define HOSTILE_COMMAND_NONE 0
/// Will attack a target.
#define HOSTILE_COMMAND_ATTACK 1
/// Will follow a target.
#define HOSTILE_COMMAND_FOLLOW 2

///Dog AI controller blackboard keys

#define BB_SIMPLE_CARRY_ITEM "BB_SIMPLE_CARRY_ITEM"
#define BB_FETCH_IGNORE_LIST "BB_FETCH_IGNORE_LISTlist"
#define BB_FETCH_DELIVER_TO "BB_FETCH_DELIVER_TO"
#define BB_DOG_HARASS_TARGET "BB_DOG_HARASS_TARGET"
#define BB_DOG_HARASS_HARM "BB_DOG_HARASS_HARM"
#define BB_DOG_IS_SLOW "BB_DOG_IS_SLOW"

/// Basically, what is our vision/hearing range for picking up on things to fetch/
#define AI_DOG_VISION_RANGE	10
/// What are the odds someone petting us will become our friend?
#define AI_DOG_PET_FRIEND_PROB 15
/// After this long without having fetched something, we clear our ignore list
#define AI_FETCH_IGNORE_DURATION (30 SECONDS)
/// After being ordered to heel, we spend this long chilling out
#define AI_DOG_HEEL_DURATION (20 SECONDS)
/// After either being given a verbal order or a pointing order, ignore further of each for this duration
#define AI_DOG_COMMAND_COOLDOWN (2 SECONDS)
/// If the dog is set to harass someone but doesn't bite them for this long, give up
#define AI_DOG_HARASS_FRUSTRATE_TIME (50 SECONDS)

// dog command modes (what pointing at something/someone does depending on the last order the dog heard)
/// Don't do anything (will still react to stuff around them though)
#define DOG_COMMAND_NONE 0
/// Will try to pick up and bring back whatever you point to
#define DOG_COMMAND_FETCH 1
/// Will get within a few tiles of whatever you point at and continually growl/bark. If the target is a living mob who gets too close, the dog will attack them with bites
#define DOG_COMMAND_ATTACK 2

//enumerators for parsing command speech
#define COMMAND_HEEL "Heel"
#define COMMAND_FETCH "Fetch"
#define COMMAND_FOLLOW "Follow"
#define COMMAND_STOP "Stop"
#define COMMAND_ATTACK "Attack"
#define COMMAND_DIE "Play Dead"

///bane ai
#define BB_BANE_BATMAN "BB_bane_batman"
//yep thats it

///Hunting BB keys
#define BB_CURRENT_HUNTING_TARGET "BB_current_hunting_target"
#define BB_LOW_PRIORITY_HUNTING_TARGET "BB_low_priority_hunting_target"
#define BB_HUNTING_COOLDOWN "BB_HUNTING_COOLDOWN"

///Basic Mob Keys

///Tipped blackboards
///Bool that means a basic mob will start reacting to being tipped in it's planning
#define BB_BASIC_MOB_TIP_REACTING "BB_basic_tip_reacting"
///the motherfucker who tipped us
#define BB_BASIC_MOB_TIPPER "BB_basic_tip_tipper"

///Targetting subtrees
#define BB_BASIC_MOB_CURRENT_TARGET "BB_basic_current_target"
#define BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION "BB_basic_current_target_hiding_location"
#define BB_TARGETTING_DATUM "targetting_datum"
///some behaviors that check current_target also set this on deep crit mobs
#define BB_BASIC_MOB_EXECUTION_TARGET "BB_basic_execution_target"
///Blackboard key for a whitelist typecache of "things we can target while trying to move"
#define BB_OBSTACLE_TARGETTING_WHITELIST "BB_targetting_whitelist"

///Targetting keys for something to run away from, if you need to store this separately from current target
#define BB_BASIC_MOB_FLEE_TARGET "BB_basic_flee_target"
#define BB_BASIC_MOB_FLEE_TARGET_HIDING_LOCATION "BB_basic_flee_target_hiding_location"
#define BB_FLEE_TARGETTING_DATUM "flee_targetting_datum"

///How long have we spent with no target?
#define BB_TARGETLESS_TIME "BB_targetless_time"

/// Key that holds a nearby vent that looks like it's a good place to hide
#define BB_ENTRY_VENT_TARGET "BB_entry_vent_target"
/// Key that holds a vent that we want to exit out of (when we're already in a pipenet)
#define BB_EXIT_VENT_TARGET "BB_exit_vent_target"
/// Do we plan on going inside a vent? Boolean.
#define BB_CURRENTLY_TARGETTING_VENT "BB_currently_targetting_vent"
/// How long should we wait before we try and enter a vent again?
#define BB_VENTCRAWL_COOLDOWN "BB_ventcrawl_cooldown"
/// The least amount of time (in seconds) we take to go through the vents.
#define BB_LOWER_VENT_TIME_LIMIT "BB_lower_vent_time_limit"
/// The most amount of time (in seconds) we take to go through the vents.
#define BB_UPPER_VENT_TIME_LIMIT "BB_upper_vent_time_limit"
/// How much time (in seconds) do we take until we completely go bust on vent pathing?
#define BB_TIME_TO_GIVE_UP_ON_VENT_PATHING "BB_seconds_until_we_give_up_on_vent_pathing"
/// The timer ID of the timer that makes us give up on vent pathing.
#define BB_GIVE_UP_ON_VENT_PATHING_TIMER_ID "BB_give_up_on_vent_pathing_timer_id"

/// Is there something that scared us into being stationary? If so, hold the reference here
#define BB_STATIONARY_CAUSE "BB_thing_that_made_us_stationary"
///How long should we remain stationary for?
#define BB_STATIONARY_SECONDS "BB_stationary_time_in_seconds"
///Should we move towards the target that triggered us to be stationary?
#define BB_STATIONARY_MOVE_TO_TARGET "BB_stationary_move_to_target"
/// What targets will trigger us to be stationary? Must be a list.
#define BB_STATIONARY_TARGETS "BB_stationary_targets"
/// How often can we get spooked by a target?
#define BB_STATIONARY_COOLDOWN "BB_stationary_cooldown"

///List of mobs who have damaged us
#define BB_BASIC_MOB_RETALIATE_LIST "BB_basic_mob_shitlist"

/// Flag to set on or off if you want your mob to prioritise running away
#define BB_BASIC_MOB_FLEEING "BB_basic_fleeing"

///list of foods this mob likes
#define BB_BASIC_FOODS "BB_basic_foods"

///Baby-making blackboard
///Types of animal we can make babies with.
#define BB_BABIES_PARTNER_TYPES "BB_babies_partner"
///Types of animal that we make as a baby.
#define BB_BABIES_CHILD_TYPES "BB_babies_child"
///Current partner target
#define BB_BABIES_TARGET "BB_babies_target"

///Finding adult mob
///key holds the adult we found
#define BB_FOUND_MOM "BB_found_mom"
///list of types of mobs we will look for
#define BB_FIND_MOM_TYPES "BB_find_mom_types"
///list of types of mobs we must ignore
#define BB_IGNORE_MOM_TYPES "BB_ignore_mom_types"

// Bileworm AI keys

#define BB_BILEWORM_SPEW_BILE "BB_bileworm_spew_bile"
#define BB_BILEWORM_RESURFACE "BB_bileworm_resurface"
#define BB_BILEWORM_DEVOUR "BB_bileworm_devour"

// Meteor Heart AI keys
/// Key where we keep the spike trail ability
#define BB_METEOR_HEART_GROUND_SPIKES "BB_meteor_ground_spikes"
/// Key where we keep the spine traps ability
#define BB_METEOR_HEART_SPINE_TRAPS "BB_meteor_spine_traps"

// Spider AI keys
/// Key where we store a turf to put webs on
#define BB_SPIDER_WEB_TARGET "BB_spider_web_target"
/// Key where we store the web-spinning ability
#define BB_SPIDER_WEB_ACTION "BB_spider_web_action"

// Fugu AI keys
/// Key where we store the inflating ability
#define BB_FUGU_INFLATE "BB_fugu_inflate"

//Festivus AI keys
/// Key where we store the charging apc ability
#define BB_FESTIVE_APC "BB_festive_apc"

//Paperwizard AI keys
/// Key where we store the summon minions ability
#define BB_WIZARD_SUMMON_MINIONS "BB_summon_minions"
/// Key where we store the mimics ability
#define BB_WIZARD_MIMICS "BB_summon_mimics"
/// Key where we store the paper target
#define BB_FOUND_PAPER "BB_found_paper"
/// Key where we store the list of things we can write on a paper
#define BB_WRITING_LIST "BB_writing_list"
/// Key where we store the tentacleing ability
#define BB_GOLIATH_TENTACLES "BB_goliath_tentacles"
/// Key where goliath stores a hole it wants to get into
#define BB_GOLIATH_HOLE_TARGET "BB_goliath_hole"

///bee keys
///the bee hive we live inside
#define BB_CURRENT_HOME "BB_current_home"
///the hydro we will pollinate
#define BB_TARGET_HYDRO "BB_target_hydro"

///bear keys
///the hive with honey that we will steal from
#define BB_FOUND_HONEY "BB_found_honey"
///the tree that we will climb
#define BB_CLIMBED_TREE "BB_climbed_tree"
