// Defines & Blackboard keys for the very similar haunted and cursed AI controllers

///Chance for haunted item to haunt someone
#define HAUNTED_ITEM_ATTACK_HAUNT_CHANCE 10
///Chance for haunted item to try to get itself let go.
#define HAUNTED_ITEM_ESCAPE_GRASP_CHANCE 20
///Amount of aggro you get when picking up a haunted item
#define HAUNTED_ITEM_AGGRO_ADDITION 2
///how far a cursed item will still try to chase a target
#define CURSED_VIEW_RANGE 7

#define BB_TO_HAUNT_LIST "BB_to_haunt_list"
///Actual mob the item is haunting at the moment
#define BB_HAUNT_TARGET "BB_haunt_target"
///Amount of successful hits in a row this item has had
#define BB_HAUNTED_THROW_ATTEMPT_COUNT "BB_haunted_throw_attempt_count"
///If true, tolerates the equipper holding/equipping the hauntium
#define BB_LIKES_EQUIPPER "BB_likes_equipper"

///Actual mob the item is haunting at the moment
#define BB_CURSE_TARGET "BB_haunt_target"
///Where the item wants to land on
#define BB_TARGET_SLOT "BB_target_slot"
///Amount of successful hits in a row this item has had
#define BB_CURSED_THROW_ATTEMPT_COUNT "BB_cursed_throw_attempt_count"
