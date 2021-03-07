#define GET_AI_BEHAVIOR(behavior_type) SSai_controllers.ai_behaviors[behavior_type]
#define HAS_AI_CONTROLLER_TYPE(thing, type) istype(thing?.ai_controller, type)

#define AI_STATUS_ON 1
#define AI_STATUS_OFF 2


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

///Robot customer AI controller blackboard keys
#define BB_CUSTOMER_CURRENT_ORDER "BB_customer_current_order"
#define BB_CUSTOMER_MY_SEAT "BB_customer_my_seat"
#define BB_CUSTOMER_PATIENCE "BB_customer_patience"
#define BB_CUSTOMER_CUSTOMERINFO "BB_customer_customerinfo"
#define BB_CUSTOMER_EATING "BB_customer_eating"
#define BB_CUSTOMER_ATTENDING_VENUE "BB_customer_attending_avenue"
#define BB_CUSTOMER_LEAVING "BB_customer_leaving"

///Haunted item controller defines


#define RADIAL_FORGET_BUTTON "Forget Everything"
#define RADIAL_IDLE_BUTTON "Idle Mode"
#define RADIAL_REFUSE_BUTTON "Kitchen Cleaning Mode"
#define RADIAL_THE_GRIDDLER_BUTTON "The Griddler Mode"
#define RADIAL_WAITER_BUTTON "Food Service Mode"
//do nothing. good for transporting?
#define KITCHENBOT_MODE_IDLE 1
//collect dishes, dump them
#define KITCHENBOT_MODE_REFUSE 2
//griddle items for the cooks
#define KITCHENBOT_MODE_THE_GRIDDLER 3
//deliver finished items (wherever they may be) to customers
#define KITCHENBOT_MODE_WAITER 4

///Kitchenbot AI controller blackboard keys

//optional text for completing tasks, has a default
#define BB_KITCHENBOT_TASK_TEXT "BB_kitchenbot_task_text"
//optional sound for completing tasks
#define BB_KITCHENBOT_TASK_SOUND "BB_kitchenbot_task_sound"
//mode they're in
#define BB_KITCHENBOT_RADIAL_OPEN "BB_kitchenbot_radial_open"
#define BB_KITCHENBOT_MODE "BB_kitchenbot_mode"
//dishes mode vars
#define BB_KITCHENBOT_REFUSE_LIST "BB_kitchenbot_refuse_list"
#define BB_KITCHENBOT_TARGET_TO_DISPOSE "BB_kitchenbot_target_to_dispose"
#define BB_KITCHENBOT_TARGET_DISPOSAL "BB_kitchenbot_target_disposal"
//griddle mode vars
#define BB_KITCHENBOT_CHOSEN_GRIDDLE "BB_kitchenbot_chosen_griddle"
#define BB_KITCHENBOT_CHOSEN_STOCKPILE "BB_kitchenbot_chosen_stockpile"
#define BB_KITCHENBOT_ITEMS_WATCHED "BB_kitchenbot_items_watched" //currently griddling
#define BB_KITCHENBOT_ITEMS_BANNED "BB_kitchenbot_items_banned" //items that we know won't grill
#define BB_KITCHENBOT_TAKE_OFF_GRILL "BB_kitchenbot_take_off_grill" //done griddling, high priority to take off grill so it doesnt burn
#define BB_KITCHENBOT_TARGET_IN_STOCKPILE "BB_kitchenbot_target_in_stockpile"
//serving food mode vars
//first time we see a customer, we add them to this
#define BB_KITCHENBOT_CUSTOMERS_NOTED "BB_kitchenbot_customers_noted"
#define BB_KITCHENBOT_ORDERS_WANTED "BB_kitchenbot_orders_wanted"
#define BB_KITCHENBOT_VENUE "BB_kitchenbot_venue"
#define BB_KITCHENBOT_DISH_TO_SERVE "BB_kitchenbot_dish_to_serve"
