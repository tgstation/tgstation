/// Blackboard field for the most recent command the pet was given
#define BB_ACTIVE_PET_COMMAND "BB_active_pet_command"
/// Follow your normal behaviour
#define PET_COMMAND_NONE "pet_command_none"
/// Don't take any actions at all
#define PET_COMMAND_IDLE "pet_command_idle"
/// Pursue and attack the pointed target
#define PET_COMMAND_ATTACK "pet_command_attack"
/// Pursue the person who made this command
#define PET_COMMAND_FOLLOW "pet_commmand_follow"
/// Use a targetted mob ability
#define PET_COMMAND_USE_ABILITY "pet_command_use_ability"

/// Blackboard field for what we actually want the pet to target
#define BB_CURRENT_PET_TARGET "BB_current_pet_target"
/// Blackboard field for how we target things, as usually we want to be more permissive than normal
#define BB_PET_TARGETTING_DATUM "BB_pet_targetting"
/// Typecache of weakrefs to mobs this mob is friends with, will follow their instructions and won't attack them
#define BB_FRIENDS_LIST "BB_friends_list"
