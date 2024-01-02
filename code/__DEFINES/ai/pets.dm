///Dog AI controller blackboard keys
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

/// The current string that this parrot will repeat back to someone
#define BB_PARROT_REPEAT_STRING "BB_parrot_repeat_string"
/// The odds that this parrot will repeat back a string
#define BB_PARROT_REPEAT_PROBABILITY "BB_parrot_repeat_probability"
/// The odds that this parrot will choose another string to repeat
#define BB_PARROT_PHRASE_CHANGE_PROBABILITY "BB_parrot_phrase_change_probability"
/// A copy of the string buffer that we end the shift with. DO NOT ACCESS THIS DIRECTLY - YOU SHOULD USE THE COMPONENT IN MOST CASES
#define BB_EXPORTABLE_STRING_BUFFER_LIST "BB_parrot_repeat_string_buffer"
/// The types of perches we desire to use
#define BB_PARROT_PERCH_TYPES "BB_parrot_perch_types"
/// key that holds our perch target
#define BB_PERCH_TARGET "perch_target"
/// key that holds our theft item target
#define BB_HOARD_ITEM_TARGET "hoard_item_target"
/// key that holds the mob we will steal from
#define BB_THEFT_VICTIM "theft_victim"
/// key that holds the turf we will be hauling stolen items to
#define BB_HOARD_LOCATION "hoard_location"
/// key that holds the minimum range we must be from the hoard spot
#define BB_HOARD_LOCATION_RANGE "hoard_location_range"
/// key that holds items we arent interested in hoarding
#define BB_IGNORE_ITEMS "ignore_items"

