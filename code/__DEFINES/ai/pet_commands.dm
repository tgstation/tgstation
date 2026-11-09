/// Blackboard field for the most recent command the pet was given
#define BB_ACTIVE_PET_COMMAND "BB_active_pet_command"

/// Blackboard field for what we actually want the pet to target
#define BB_CURRENT_PET_TARGET "BB_current_pet_target"
/// Blackboard field for how we target things, as usually we want to be more permissive than normal
#define BB_PET_TARGETING_STRATEGY "BB_pet_targeting"
/// Hiding location scratch key used by basic_melee_attack in pet command attack subtrees
#define BB_PET_ATTACK_HIDING_LOCATION "BB_pet_attack_hiding_location"
/// Scratch key holding the active untargeted ability datum for /datum/pet_command/untargeted_ability
#define BB_PET_ACTIVE_ABILITY "BB_pet_active_ability"
/// Typecache of weakrefs to mobs this mob is friends with, will follow their instructions and won't attack them
#define BB_FRIENDS_LIST "BB_friends_list"
/// List of strings we might say to encourage someone to make better choices.
#define BB_OWNER_SELF_HARM_RESPONSES "BB_self_harm_responses"

