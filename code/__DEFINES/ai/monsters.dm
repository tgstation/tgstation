// Bileworm AI keys

#define BB_BILEWORM_SPEW_BILE "BB_bileworm_spew_bile"
#define BB_BILEWORM_RESURFACE "BB_bileworm_resurface"
#define BB_BILEWORM_DEVOUR "BB_bileworm_devour"

// Meteor Heart AI keys
/// Key where we keep the spike trail ability
#define BB_METEOR_HEART_GROUND_SPIKES "BB_meteor_ground_spikes"
/// Key where we keep the spine traps ability
#define BB_METEOR_HEART_SPINE_TRAPS "BB_meteor_spine_traps"

// Cybersun AI core AI keys
///key for lightning strike attack
#define BB_CYBERSUN_CORE_LIGHTNING "BB_lightning_strike"
///key for big laser attack
#define BB_CYBERSUN_CORE_BARRAGE "BB_cybersun_barrage"

// Donk Exenteration Drone keys
// key for aoe slash attack
#define BB_DEDBOT_SLASH "BB_dedbot_exenterate"

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

// Goliath AI keys
/// Key where we store the tentacleing ability
#define BB_GOLIATH_TENTACLES "BB_goliath_tentacles"
/// Key where goliath stores a hole it wants to get into
#define BB_GOLIATH_HOLE_TARGET "BB_goliath_hole"

// bee keys
///the bee hive we live inside
#define BB_CURRENT_HOME "BB_current_home"
///the hydro we will pollinate
#define BB_TARGET_HYDRO "BB_target_hydro"
///key to swarm around
#define BB_SWARM_TARGET "BB_swarm_target"

// bear keys
///the hive with honey that we will steal from
#define BB_FOUND_HONEY "BB_found_honey"
///the tree that we will climb
#define BB_CLIMBED_TREE "BB_climbed_tree"

/// Lobstrosities will only attack people with one of these traits
#define BB_LOBSTROSITY_EXPLOIT_TRAITS "BB_lobstrosity_exploit_traits"
/// Key where we store some tasty fingers
#define BB_LOBSTROSITY_TARGET_LIMB "BB_lobstrosity_target_limb"
/// We increment this counter every time we try to move while dragging an arm and if we go too long we'll give up trying to get out of line of sight and just eat the fingers
#define BB_LOBSTROSITY_FINGER_LUST "BB_lobstrosity_finger_lust"
/// Does this carp still target lying mobs even if they aren't stunned, and flee from sary fishermen?
#define BB_LOBSTROSITY_NAIVE_HUNTER "BB_lobstrosity_naive_hunter"

/// Does this carp run from scary fishermen?
#define BB_CARPS_FEAR_FISHERMAN "BB_carp_fear_fisherman"

// eyeball keys
///the death glare ability
#define BB_GLARE_ABILITY "BB_glare_ability"
///the blind target we must protect
#define BB_BLIND_TARGET "BB_blind_target"
///value to store the minimum eye damage to prevent us from attacking a human
#define BB_EYE_DAMAGE_THRESHOLD "BB_eye_damage_threshold"

// hivebot keys
///the machine we must go to repair
#define BB_MACHINE_TARGET "BB_machine_target"
///the hivebot partner we will go communicate with
#define BB_HIVE_PARTNER "BB_hive_partner"

// Ice Whelps
///whelp's straight line fire ability
#define BB_WHELP_STRAIGHTLINE_FIRE "BB_whelp_straightline_fire"
///whelp's secondary enraged ability
#define BB_WHELP_WIDESPREAD_FIRE "BB_whelp_widespread_fire"
///the target rock we will attempt to create a sculpture out of
#define BB_TARGET_ROCK "BB_target_rock"
///the cannibal target we shall consume
#define BB_TARGET_CANNIBAL "BB_target_cannibal"
///the tree we will burn down
#define BB_TARGET_TREE "BB_target_tree"

// Regal Rats
/// The rat's ability to corrupt an area.
#define BB_DOMAIN_ABILITY "BB_domain_ability"
/// The rat's ability to raise a horde of soldiers.
#define BB_RAISE_HORDE_ABILITY "BB_raise_horde_ability"

// mega arachnid keys
/// ability to throw restrain projectiles
#define BB_ARACHNID_RESTRAIN "BB_arachnid_restrain"
/// the found surveillance item we must destroy
#define BB_SURVEILLANCE_TARGET "BB_surveillance_target"
/// our acid slip ability
#define BB_ARACHNID_SLIP "BB_arachnid_slip"

// goldgrub keys
/// key that tells if a storm is coming
#define BB_STORM_APPROACHING "BB_storm_approaching"
/// key that tells the wall we will mine
#define BB_TARGET_MINERAL_WALL "BB_target_mineral_wall"
/// key that holds our spit ability
#define BB_SPIT_ABILITY "BB_spit_ability"
/// key that holds our dig ability
#define BB_BURROW_ABILITY "BB_burrow_ability"
/// key that holds the ore we will eat
#define BB_ORE_TARGET "BB_ore_target"
/// which ore types we will not eat
#define BB_ORE_IGNORE_TYPES "BB_ore_ignore_types"
/// key that holds the boulder we will break
#define BB_BOULDER_TARGET "BB_boulder_target"
/// key that holds the ore_vent we will harvest boulders from
#define BB_VENT_TARGET "BB_vent_target"

// minebot keys
/// key that stores our toggle light ability
#define BB_MINEBOT_LIGHT_ABILITY "minebot_light_ability"
/// key that stores our dump ore ability
#define BB_MINEBOT_DUMP_ABILITY "minebot_dump_ability"
/// key that stores our target turf
#define BB_TARGET_MINERAL_TURF "target_mineral_turf"
///key that holds our missile ability
#define BB_MINEBOT_MISSILE_ABILITY "minebot_missile_ability"
///key that holds our landmine ability
#define BB_MINEBOT_LANDMINE_ABILITY "minebot_landmine_ability"
/// key that stores list of the turfs we ignore
#define BB_BLACKLIST_MINERAL_TURFS "blacklist_mineral_turfs"
/// key that stores the previous blocked wall
#define BB_PREVIOUS_UNREACHABLE_WALL "previous_unreachable_wall"
/// key that stores our mining mode
#define BB_AUTOMATED_MINING "automated_mining"
/// key that stores the nearest dead human
#define BB_NEARBY_DEAD_MINER "nearby_dead_miner"
///key that holds the drone we defend
#define BB_DRONE_DEFEND "defend_drone"
///key that holds the minimum distance before we flee
#define BB_MINIMUM_SHOOTING_DISTANCE "minimum_shooting_distance"
///key that holds the miner we must befriend
#define BB_MINER_FRIEND "miner_friend"
///key that holds the missile target
#define BB_MINEBOT_MISSILE_TARGET "minebot_missile_target"
///should we auto protect?
#define BB_MINEBOT_AUTO_DEFEND "minebot_auto_defend"
///should we repair drones?
#define BB_MINEBOT_REPAIR_DRONE "minebot_repair_drone"
///should we plant mines?
#define BB_MINEBOT_PLANT_MINES "minebot_plant_mines"

//seedling keys
/// the water can we will pick up
#define BB_WATERCAN_TARGET "watercan_target"
/// the hydrotray we will heal
#define BB_HYDROPLANT_TARGET "hydroplant_target"
/// minimum weed levels for us to cure
#define BB_WEEDLEVEL_THRESHOLD "weedlevel_threshold"
/// minimum water levels for us to refill
#define BB_WATERLEVEL_THRESHOLD "waterlevel_threshold"
/// key holds our solarbeam ability
#define BB_SOLARBEAM_ABILITY "solarbeam_ability"
/// key holds our rapid seeds ability
#define BB_RAPIDSEEDS_ABILITY "rapidseeds_ability"
/// key holds the tray we will beam
#define BB_BEAMABLE_HYDROPLANT_TARGET "beamable_hydroplant_target"

//ice demons
///the list of items we are afraid of
#define BB_LIST_SCARY_ITEMS "list_scary_items"
///our teleportation ability
#define BB_DEMON_TELEPORT_ABILITY "demon_teleport_ability"
///the destination of our teleport ability
#define BB_TELEPORT_DESTINATION "teleport_destination"
///the ability to clone ourself
#define BB_DEMON_CLONE_ABILITY "demon_clone_ability"
///our slippery ice ability
#define BB_DEMON_SLIP_ABILITY "demon_slip_ability"
///the turf we are escaping to
#define BB_ESCAPE_DESTINATION "escape_destination"

/// Corpse we have consumed
#define BB_LEGION_CORPSE "legion_corpse"
/// Things our target recently said
#define BB_LEGION_RECENT_LINES "legion_recent_lines"
/// The creator of our legion skull
#define BB_LEGION_BROOD_CREATOR "legion_brood_creator"

//mook keys
/// our home landmark
#define BB_HOME_VILLAGE "home_village"
/// maximum distance we can be from home during a storm
#define BB_MAXIMUM_DISTANCE_TO_VILLAGE "maximum_distance_to_village"
/// stand where we deposit our ores
#define BB_MATERIAL_STAND_TARGET "material_stand_target"
/// our jump ability
#define BB_MOOK_JUMP_ABILITY "mook_jump_ability"
/// our leap ability
#define BB_MOOK_LEAP_ABILITY "mook_leap_ability"
/// the chief we must obey
#define BB_MOOK_TRIBAL_CHIEF "mook_tribal_chief"
/// the injured mook we must heal
#define BB_INJURED_MOOK "injured_mook"
/// the player we will follow and play music for
#define BB_MOOK_MUSIC_AUDIENCE "music_audience"
/// the bonfire we will light up
#define BB_MOOK_BONFIRE_TARGET "bonfire_target"

//gutlunch keys
///the trough we will eat from
#define BB_TROUGH_TARGET "trough_target"
//leaper keys
///key holds our volley ability
#define BB_LEAPER_VOLLEY "leaper_volley"
///key holds our flop ability
#define BB_LEAPER_FLOP "leaper_flop"
///key holds our bubble ability
#define BB_LEAPER_BUBBLE "leaper_bubble"
///key holds our summon ability
#define BB_LEAPER_SUMMON "leaper_summon"
///key holds the world timer for swimming
#define BB_KEY_SWIM_TIME "key_swim_time"
///key holds the water or land target turf
#define BB_SWIM_ALTERNATE_TURF "swim_alternate_turf"
///key holds our state of swimming
#define BB_CURRENTLY_SWIMMING "currently_swimming"
///key holds how long we will be swimming for
#define BB_KEY_SWIMMER_COOLDOWN "key_swimmer_cooldown"
//Wizard AI keys
/// Key where we store our main targeted spell
#define BB_WIZARD_TARGETED_SPELL "BB_wizard_targeted_spell"
/// Key where we store our secondary, untargeted spell
#define BB_WIZARD_SECONDARY_SPELL "BB_wizard_secondary_spell"
/// Key where we store our blink spell
#define BB_WIZARD_BLINK_SPELL "BB_wizard_blink_spell"
/// Key for the next time we can cast a spell
#define BB_WIZARD_SPELL_COOLDOWN "BB_wizard_spell_cooldown"


//cat AI keys
/// key that holds the target we will battle over our turf
#define BB_TRESSPASSER_TARGET "tresspasser_target"
/// key that holds angry meows
#define BB_HOSTILE_MEOWS "hostile_meows"
/// key that holds the mouse target
#define BB_MOUSE_TARGET "mouse_target"
/// key that holds our dinner target
#define BB_CAT_FOOD_TARGET "cat_food_target"
/// key that holds the food we must deliver
#define BB_FOOD_TO_DELIVER "food_to_deliver"
/// key that holds things we can hunt
#define BB_HUNTABLE_PREY "huntable_prey"
/// key that holds target kitten to feed
#define BB_KITTEN_TO_FEED "kitten_to_feed"
/// key that holds our hungry meows
#define BB_HUNGRY_MEOW "hungry_meows"
/// key that holds maximum distance food is to us so we can pursue it
#define BB_MAX_DISTANCE_TO_FOOD "max_distance_to_food"
/// key that holds the stove we must turn off
#define BB_STOVE_TARGET "stove_target"
/// key that holds the donut we will decorate
#define BB_DONUT_TARGET "donut_target"
/// key that holds our home...
#define BB_CAT_HOME "cat_home"
/// key that holds the human we will beg
#define BB_HUMAN_BEG_TARGET "human_beg_target"
//netguardians
/// rocket launcher
#define BB_NETGUARDIAN_ROCKET_ABILITY "netguardian_rocket"

//deer
///our water target
#define BB_DEER_WATER_TARGET "deer_water_target"
///our grass target
#define BB_DEER_GRASS_TARGET "deer_grass_target"
///our tree target
#define BB_DEER_TREE_TARGET "deer_tree_target"
///our temporary playmate
#define BB_DEER_PLAYFRIEND "deer_playfriend"
///our home target
#define BB_DEER_TREEHOME "deer_home"
///our resting duration
#define BB_DEER_RESTING "deer_resting"
///time till our next rest duration
#define BB_DEER_NEXT_REST_TIMER "deer_next_rest_timer"

//the thing boss
#define BB_THETHING_CHARGE "BB_THETHING_CHARGE"
#define BB_THETHING_DECIMATE "BB_THETHING_DECIMATE"
#define BB_THETHING_BIGTENDRILS "BB_THETHING_BIGTENDRILS"
#define BB_THETHING_SHRIEK "BB_THETHING_SHRIEK"
#define BB_THETHING_CARDTENDRILS "BB_THETHING_CARDTENDRILS"
#define BB_THETHING_ACIDSPIT "BB_THETHING_ACIDSPIT"
/// Blackboard key for The Thing boss that determines attack mode. TRUE means it will focus on closing the distance and murdering the person in question. Otherwise AOE.
#define BB_THETHING_ATTACKMODE "BB_THETHING_ATTACKMODE"
/// The Thing will be in attack mode forever if true
#define BB_THETHING_NOAOE "BB_THETHING_NOAOE"
/// What (first in combo) attack was last executed
#define BB_THETHING_LASTAOE "BB_THETHING_LASTAOE"

//turtle
///our tree's ability
#define BB_TURTLE_TREE_ABILITY "turtle_tree_ability"
///people we headbutt!
#define BB_TURTLE_HEADBUTT_VICTIM "turtle_headbutt_victim"
///flore we must smell
#define BB_TURTLE_FLORA_TARGET "turtle_flora_target"

#define BB_GUNMIMIC_GUN_EMPTY "BB_GUNMIMIC_GUN_EMPTY"

//snails
///snails retreat ability
#define BB_SNAIL_RETREAT_ABILITY "snail_retreat_ability"
