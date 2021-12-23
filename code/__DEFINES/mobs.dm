/*ALL MOB-RELATED DEFINES THAT DON'T BELONG IN ANOTHER FILE GO HERE*/

//Misc mob defines

//Ready states at roundstart for mob/dead/new_player
#define PLAYER_NOT_READY 0
#define PLAYER_READY_TO_PLAY 1

//movement intent defines for the m_intent var
#define MOVE_INTENT_WALK "walk"
#define MOVE_INTENT_RUN  "run"

//Blood levels
#define BLOOD_VOLUME_MAX_LETHAL 2150
#define BLOOD_VOLUME_EXCESS 2100
#define BLOOD_VOLUME_MAXIMUM 2000
#define BLOOD_VOLUME_SLIME_SPLIT 1120
#define BLOOD_VOLUME_NORMAL 560
#define BLOOD_VOLUME_SAFE 475
#define BLOOD_VOLUME_OKAY 336
#define BLOOD_VOLUME_BAD 224
#define BLOOD_VOLUME_SURVIVE 122

/// How efficiently humans regenerate blood.
#define BLOOD_REGEN_FACTOR 0.25

//Sizes of mobs, used by mob/living/var/mob_size
#define MOB_SIZE_TINY 0
#define MOB_SIZE_SMALL 1
#define MOB_SIZE_HUMAN 2
#define MOB_SIZE_LARGE 3
#define MOB_SIZE_HUGE 4 // Use this for things you don't want bluespace body-bagged

//Ventcrawling defines
#define VENTCRAWLER_NONE   0
#define VENTCRAWLER_NUDE   1
#define VENTCRAWLER_ALWAYS 2

//Mob bio-types flags
#define MOB_ORGANIC (1 << 0)
#define MOB_MINERAL (1 << 1)
#define MOB_ROBOTIC (1 << 2)
#define MOB_UNDEAD (1 << 3)
#define MOB_HUMANOID (1 << 4)
#define MOB_BUG (1 << 5)
#define MOB_BEAST (1 << 6)
#define MOB_EPIC (1 << 7) //megafauna
#define MOB_REPTILE (1 << 8)
#define MOB_SPIRIT (1 << 9)
#define MOB_PLANT (1 << 10)

//Organ defines for carbon mobs
#define ORGAN_ORGANIC   1
#define ORGAN_ROBOTIC   2

#define BODYPART_ORGANIC   1
#define BODYPART_ROBOTIC   2

#define DEFAULT_BODYPART_ICON_ORGANIC 'icons/mob/human_parts_greyscale.dmi'
#define DEFAULT_BODYPART_ICON_ROBOTIC 'icons/mob/augmentation/augments.dmi'

#define MONKEY_BODYPART "monkey"
#define ALIEN_BODYPART "alien"
#define LARVA_BODYPART "larva"


///Body type bitfields for allowed_animal_origin used to check compatible surgery body types (use NONE for no matching body type)
#define HUMAN_BODY (1 << 0)
#define MONKEY_BODY (1 << 1)
#define ALIEN_BODY (1 << 2)
#define LARVA_BODY (1 << 3)
/*see __DEFINES/inventory.dm for bodypart bitflag defines*/

// Health/damage defines
#define MAX_LIVING_HEALTH 100

#define HUMAN_MAX_OXYLOSS 3
#define HUMAN_CRIT_MAX_OXYLOSS (SSMOBS_DT/3)

#define STAMINA_REGEN_BLOCK_TIME (10 SECONDS)

#define HEAT_DAMAGE_LEVEL_1 1 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 4 //Amount of damage applied when your body temperature passes the 460K point and you are on fire

#define COLD_DAMAGE_LEVEL_1 0.25 //Amount of damage applied when your body temperature just passes the 260.15k safety point
#define COLD_DAMAGE_LEVEL_2 0.75 //Amount of damage applied when your body temperature passes the 200K point
#define COLD_DAMAGE_LEVEL_3 1.5 //Amount of damage applied when your body temperature passes the 120K point

//Note that gas heat damage is only applied once every FOUR ticks.
#define HEAT_GAS_DAMAGE_LEVEL_1 2 //Amount of damage applied when the current breath's temperature just passes the 360.15k safety point
#define HEAT_GAS_DAMAGE_LEVEL_2 4 //Amount of damage applied when the current breath's temperature passes the 400K point
#define HEAT_GAS_DAMAGE_LEVEL_3 8 //Amount of damage applied when the current breath's temperature passes the 1000K point

#define COLD_GAS_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when the current breath's temperature just passes the 260.15k safety point
#define COLD_GAS_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when the current breath's temperature passes the 200K point
#define COLD_GAS_DAMAGE_LEVEL_3 3 //Amount of damage applied when the current breath's temperature passes the 120K point

//Brain Damage defines
#define BRAIN_DAMAGE_MILD 20
#define BRAIN_DAMAGE_SEVERE 100
#define BRAIN_DAMAGE_DEATH 200

#define BRAIN_TRAUMA_MILD /datum/brain_trauma/mild
#define BRAIN_TRAUMA_SEVERE /datum/brain_trauma/severe
#define BRAIN_TRAUMA_SPECIAL /datum/brain_trauma/special
#define BRAIN_TRAUMA_MAGIC /datum/brain_trauma/magic

#define TRAUMA_RESILIENCE_BASIC 1      //Curable with chems
#define TRAUMA_RESILIENCE_SURGERY 2    //Curable with brain surgery
#define TRAUMA_RESILIENCE_LOBOTOMY 3   //Curable with lobotomy
#define TRAUMA_RESILIENCE_WOUND 4    //Curable by healing the head wound
#define TRAUMA_RESILIENCE_MAGIC 5      //Curable only with magic
#define TRAUMA_RESILIENCE_ABSOLUTE 6   //This is here to stay

//Limit of traumas for each resilience tier
#define TRAUMA_LIMIT_BASIC 3
#define TRAUMA_LIMIT_SURGERY 2
#define TRAUMA_LIMIT_WOUND 2
#define TRAUMA_LIMIT_LOBOTOMY 3
#define TRAUMA_LIMIT_MAGIC 3
#define TRAUMA_LIMIT_ABSOLUTE INFINITY

#define BRAIN_DAMAGE_INTEGRITY_MULTIPLIER 0.5

//Surgery Defines
#define BIOWARE_GENERIC "generic"
#define BIOWARE_NERVES "nerves"
#define BIOWARE_CIRCULATION "circulation"
#define BIOWARE_LIGAMENTS "ligaments"
#define BIOWARE_CORTEX "cortex"

//Health hud screws for carbon mobs
#define SCREWYHUD_NONE 0
#define SCREWYHUD_CRIT 1
#define SCREWYHUD_DEAD 2
#define SCREWYHUD_HEALTHY 3

//Health doll screws for human mobs
#define SCREWYDOLL_HEAD /obj/item/bodypart/head
#define SCREWYDOLL_CHEST /obj/item/bodypart/chest
#define SCREWYDOLL_L_ARM /obj/item/bodypart/l_arm
#define SCREWYDOLL_R_ARM /obj/item/bodypart/r_arm
#define SCREWYDOLL_L_LEG /obj/item/bodypart/l_leg
#define SCREWYDOLL_R_LEG /obj/item/bodypart/r_leg

//Threshold levels for beauty for humans
#define BEAUTY_LEVEL_HORRID -66
#define BEAUTY_LEVEL_BAD -33
#define BEAUTY_LEVEL_DECENT 33
#define BEAUTY_LEVEL_GOOD 66
#define BEAUTY_LEVEL_GREAT 100

//Moods levels for humans
#define MOOD_LEVEL_HAPPY4 15
#define MOOD_LEVEL_HAPPY3 10
#define MOOD_LEVEL_HAPPY2 6
#define MOOD_LEVEL_HAPPY1 2
#define MOOD_LEVEL_NEUTRAL 0
#define MOOD_LEVEL_SAD1 -3
#define MOOD_LEVEL_SAD2 -7
#define MOOD_LEVEL_SAD3 -15
#define MOOD_LEVEL_SAD4 -20

//Sanity levels for humans
#define SANITY_MAXIMUM 150
#define SANITY_GREAT 125
#define SANITY_NEUTRAL 100
#define SANITY_DISTURBED 75
#define SANITY_UNSTABLE 50
#define SANITY_CRAZY 25
#define SANITY_INSANE 0

//Nutrition levels for humans
#define NUTRITION_LEVEL_FAT 600
#define NUTRITION_LEVEL_FULL 550
#define NUTRITION_LEVEL_WELL_FED 450
#define NUTRITION_LEVEL_FED 350
#define NUTRITION_LEVEL_HUNGRY 250
#define NUTRITION_LEVEL_STARVING 150

#define NUTRITION_LEVEL_START_MIN 250
#define NUTRITION_LEVEL_START_MAX 400

//Disgust levels for humans
#define DISGUST_LEVEL_MAXEDOUT 150
#define DISGUST_LEVEL_DISGUSTED 75
#define DISGUST_LEVEL_VERYGROSS 50
#define DISGUST_LEVEL_GROSS 25

//Used as an upper limit for species that continuously gain nutriment
#define NUTRITION_LEVEL_ALMOST_FULL 535

//Charge levels for Ethereals
#define ETHEREAL_CHARGE_NONE 0
#define ETHEREAL_CHARGE_LOWPOWER 400
#define ETHEREAL_CHARGE_NORMAL 1000
#define ETHEREAL_CHARGE_ALMOSTFULL 1500
#define ETHEREAL_CHARGE_FULL 2000
#define ETHEREAL_CHARGE_OVERLOAD 2500
#define ETHEREAL_CHARGE_DANGEROUS 3000


#define CRYSTALIZE_COOLDOWN_LENGTH 120 SECONDS
#define CRYSTALIZE_PRE_WAIT_TIME 40 SECONDS
#define CRYSTALIZE_DISARM_WAIT_TIME 120 SECONDS
#define CRYSTALIZE_HEAL_TIME 60 SECONDS

#define BRUTE_DAMAGE_REQUIRED_TO_STOP_CRYSTALIZATION 30

#define CRYSTALIZE_STAGE_ENGULFING 100 //Cant use second defines
#define CRYSTALIZE_STAGE_ENCROACHING 300 //In switches
#define CRYSTALIZE_STAGE_SMALL 600 //Because they're not static

//Slime evolution threshold. Controls how fast slimes can split/grow
#define SLIME_EVOLUTION_THRESHOLD 10

//Slime extract crossing. Controls how many extracts is required to feed to a slime to core-cross.
#define SLIME_EXTRACT_CROSSING_REQUIRED 10

//Slime commands defines
#define SLIME_FRIENDSHIP_FOLLOW 3 //Min friendship to order it to follow
#define SLIME_FRIENDSHIP_STOPEAT 5 //Min friendship to order it to stop eating someone
#define SLIME_FRIENDSHIP_STOPEAT_NOANGRY 7 //Min friendship to order it to stop eating someone without it losing friendship
#define SLIME_FRIENDSHIP_STOPCHASE 4 //Min friendship to order it to stop chasing someone (their target)
#define SLIME_FRIENDSHIP_STOPCHASE_NOANGRY 6 //Min friendship to order it to stop chasing someone (their target) without it losing friendship
#define SLIME_FRIENDSHIP_STAY 3 //Min friendship to order it to stay
#define SLIME_FRIENDSHIP_ATTACK 8 //Min friendship to order it to attack

//Sentience types, to prevent things like sentience potions from giving bosses sentience
#define SENTIENCE_ORGANIC 1
#define SENTIENCE_ARTIFICIAL 2
#define SENTIENCE_HUMANOID 3
#define SENTIENCE_MINEBOT 4
#define SENTIENCE_BOSS 5

//Mob AI Status
#define POWER_RESTORATION_OFF 0
#define POWER_RESTORATION_START 1
#define POWER_RESTORATION_SEARCH_APC 2
#define POWER_RESTORATION_APC_FOUND 3

//Hostile simple animals
//If you add a new status, be sure to add a list for it to the simple_animals global in _globalvars/lists/mobs.dm
#define AI_ON 1
#define AI_IDLE 2
#define AI_OFF 3
#define AI_Z_OFF 4

//The range at which a mob should wake up if you spawn into the z level near it
#define MAX_SIMPLEMOB_WAKEUP_RANGE 5

//determines if a mob can smash through it
#define ENVIRONMENT_SMASH_NONE 0
#define ENVIRONMENT_SMASH_STRUCTURES (1<<0) //crates, lockers, ect
#define ENVIRONMENT_SMASH_WALLS (1<<1)  //walls
#define ENVIRONMENT_SMASH_RWALLS (1<<2) //rwalls

#define NO_SLIP_WHEN_WALKING (1<<0)
#define SLIDE (1<<1)
#define GALOSHES_DONT_HELP (1<<2)
#define SLIDE_ICE (1<<3)
#define SLIP_WHEN_CRAWLING (1<<4) //clown planet ruin

#define MAX_CHICKENS 50

///Flags used by the flags parameter of electrocute act.

///Makes it so that the shock doesn't take gloves into account.
#define SHOCK_NOGLOVES (1 << 0)
///Used when the shock is from a tesla bolt.
#define SHOCK_TESLA (1 << 1)
///Used when an illusion shocks something. Makes the shock deal stamina damage and not trigger certain secondary effects.
#define SHOCK_ILLUSION (1 << 2)
///The shock doesn't stun.
#define SHOCK_NOSTUN (1 << 3)

#define INCORPOREAL_MOVE_BASIC 1 /// normal movement, see: [/mob/living/var/incorporeal_move]
#define INCORPOREAL_MOVE_SHADOW 2 /// leaves a trail of shadows
#define INCORPOREAL_MOVE_JAUNT 3 /// is blocked by holy water/salt

//Secbot and ED209 judgement criteria bitflag values
#define JUDGE_EMAGGED (1<<0)
#define JUDGE_IDCHECK (1<<1)
#define JUDGE_WEAPONCHECK (1<<2)
#define JUDGE_RECORDCHECK (1<<3)
//ED209's ignore monkeys
#define JUDGE_IGNOREMONKEYS (1<<4)

#define SHADOW_SPECIES_LIGHT_THRESHOLD 0.2

#define COOLDOWN_UPDATE_SET_MELEE "set_melee"
#define COOLDOWN_UPDATE_ADD_MELEE "add_melee"
#define COOLDOWN_UPDATE_SET_RANGED "set_ranged"
#define COOLDOWN_UPDATE_ADD_RANGED "add_ranged"
#define COOLDOWN_UPDATE_SET_ENRAGE "set_enrage"
#define COOLDOWN_UPDATE_ADD_ENRAGE "add_enrage"
#define COOLDOWN_UPDATE_SET_SPAWN "set_spawn"
#define COOLDOWN_UPDATE_ADD_SPAWN "add_spawn"
#define COOLDOWN_UPDATE_SET_HELP "set_help"
#define COOLDOWN_UPDATE_ADD_HELP "add_help"
#define COOLDOWN_UPDATE_SET_DASH "set_dash"
#define COOLDOWN_UPDATE_ADD_DASH "add_dash"
#define COOLDOWN_UPDATE_SET_TRANSFORM "set_transform"
#define COOLDOWN_UPDATE_ADD_TRANSFORM "add_transform"
#define COOLDOWN_UPDATE_SET_CHASER "set_chaser"
#define COOLDOWN_UPDATE_ADD_CHASER "add_chaser"
#define COOLDOWN_UPDATE_SET_ARENA "set_arena"
#define COOLDOWN_UPDATE_ADD_ARENA "add_arena"

// Offsets defines

#define OFFSET_UNIFORM "uniform"
#define OFFSET_ID "id"
#define OFFSET_GLOVES "gloves"
#define OFFSET_GLASSES "glasses"
#define OFFSET_EARS "ears"
#define OFFSET_SHOES "shoes"
#define OFFSET_S_STORE "s_store"
#define OFFSET_FACEMASK "mask"
#define OFFSET_HEAD "head"
#define OFFSET_FACE "face"
#define OFFSET_BELT "belt"
#define OFFSET_BACK "back"
#define OFFSET_SUIT "suit"
#define OFFSET_NECK "neck"

//MINOR TWEAKS/MISC
#define AGE_MIN 17 //youngest a character can be
#define AGE_MAX 85 //oldest a character can be
#define AGE_MINOR 20  //legal age of space drinking and smoking
#define WIZARD_AGE_MIN 30 //youngest a wizard can be
#define APPRENTICE_AGE_MIN 29 //youngest an apprentice can be
#define SHOES_SLOWDOWN 0 //How much shoes slow you down by default. Negative values speed you up
#define SHOES_SPEED_SLIGHT  SHOES_SLOWDOWN - 1 // slightest speed boost to movement
#define POCKET_STRIP_DELAY (4 SECONDS) //time taken to search somebody's pockets
#define DOOR_CRUSH_DAMAGE 15 //the amount of damage that airlocks deal when they crush you

#define HUNGER_FACTOR 0.05 //factor at which mob nutrition decreases
#define ETHEREAL_CHARGE_FACTOR 0.8 //factor at which ethereal's charge decreases per second
#define REAGENTS_METABOLISM 0.2 //How many units of reagent are consumed per second, by default.
#define REAGENTS_EFFECT_MULTIPLIER (REAGENTS_METABOLISM / 0.4) // By defining the effect multiplier this way, it'll exactly adjust all effects according to how they originally were with the 0.4 metabolism

// Eye protection
#define FLASH_PROTECTION_SENSITIVE -1
#define FLASH_PROTECTION_NONE 0
#define FLASH_PROTECTION_FLASH 1
#define FLASH_PROTECTION_WELDER 2

// Roundstart trait system

#define MAX_QUIRKS 6 //The maximum amount of quirks one character can have at roundstart

// AI Toggles
#define AI_CAMERA_LUMINOSITY 5
#define AI_VOX // Comment out if you don't want VOX to be enabled and have players download the voice sounds.

// /obj/item/bodypart on_mob_life() retval flag
#define BODYPART_LIFE_UPDATE_HEALTH (1<<0)

#define MAX_REVIVE_FIRE_DAMAGE 180
#define MAX_REVIVE_BRUTE_DAMAGE 180

#define HUMAN_FIRE_STACK_ICON_NUM 3

#define GRAB_PIXEL_SHIFT_PASSIVE 6
#define GRAB_PIXEL_SHIFT_AGGRESSIVE 12
#define GRAB_PIXEL_SHIFT_NECK 16

#define PULL_PRONE_SLOWDOWN 1.5
#define HUMAN_CARRY_SLOWDOWN 0.35

//Flags that control what things can spawn species (whitelist)
//Badmin magic mirror
#define MIRROR_BADMIN (1<<0)
//Standard magic mirror (wizard)
#define MIRROR_MAGIC (1<<1)
//Pride ruin mirror
#define MIRROR_PRIDE (1<<2)
//Race swap wizard event
#define RACE_SWAP (1<<3)
//ERT spawn template (avoid races that don't function without correct gear)
#define ERT_SPAWN (1<<4)
//xenobio black crossbreed
#define SLIME_EXTRACT (1<<5)
//Wabbacjack staff projectiles
#define WABBAJACK (1<<6)

// Reasons a defibrilation might fail
#define DEFIB_POSSIBLE (1<<0)
#define DEFIB_FAIL_SUICIDE (1<<1)
#define DEFIB_FAIL_HUSK (1<<2)
#define DEFIB_FAIL_TISSUE_DAMAGE (1<<3)
#define DEFIB_FAIL_FAILING_HEART (1<<4)
#define DEFIB_FAIL_NO_HEART (1<<5)
#define DEFIB_FAIL_FAILING_BRAIN (1<<6)
#define DEFIB_FAIL_NO_BRAIN (1<<7)
#define DEFIB_FAIL_NO_INTELLIGENCE (1<<8)
#define DEFIB_FAIL_BLACKLISTED (1<<9)
#define DEFIB_NOGRAB_AGHOST (1<<10)

// Bit mask of possible return values by can_defib that would result in a revivable patient
#define DEFIB_REVIVABLE_STATES (DEFIB_FAIL_NO_HEART | DEFIB_FAIL_FAILING_HEART | DEFIB_FAIL_HUSK | DEFIB_FAIL_TISSUE_DAMAGE | DEFIB_FAIL_FAILING_BRAIN | DEFIB_POSSIBLE)

#define SLEEP_CHECK_DEATH(X) sleep(X); if(QDELETED(src) || stat == DEAD) return;

#define DOING_INTERACTION(user, interaction_key) (LAZYACCESS(user.do_afters, interaction_key))
#define DOING_INTERACTION_LIMIT(user, interaction_key, max_interaction_count) ((LAZYACCESS(user.do_afters, interaction_key) || 0) >= max_interaction_count)
#define DOING_INTERACTION_WITH_TARGET(user, target) (LAZYACCESS(user.do_afters, target))
#define DOING_INTERACTION_WITH_TARGET_LIMIT(user, target, max_interaction_count) ((LAZYACCESS(user.do_afters, target) || 0) >= max_interaction_count)

// recent examine defines
/// How long it takes for an examined atom to be removed from recent_examines. Should be the max of the below time windows
#define RECENT_EXAMINE_MAX_WINDOW 2 SECONDS
/// If you examine the same atom twice in this timeframe, we call examine_more() instead of examine()
#define EXAMINE_MORE_WINDOW 1 SECONDS
/// If you examine another mob who's successfully examined you during this duration of time, you two try to make eye contact. Cute!
#define EYE_CONTACT_WINDOW 2 SECONDS
/// If you yawn while someone nearby has examined you within this time frame, it will force them to yawn as well. Tradecraft!
#define YAWN_PROPAGATION_EXAMINE_WINDOW 2 SECONDS

/// How far away you can be to make eye contact with someone while examining
#define EYE_CONTACT_RANGE 5


#define SILENCE_RANGED_MESSAGE (1<<0)

///Swarmer flags
#define SWARMER_LIGHT_ON (1<<0)

/// Returns whether or not the given mob can succumb
#define CAN_SUCCUMB(target) (HAS_TRAIT(target, TRAIT_CRITICAL_CONDITION) && !HAS_TRAIT(target, TRAIT_NODEATH))

// Body position defines.
/// Mob is standing up, usually associated with lying_angle value of 0.
#define STANDING_UP 0
/// Mob is lying down, usually associated with lying_angle values of 90 or 270.
#define LYING_DOWN 1

///How much a mob's sprite should be moved when they're lying down
#define PIXEL_Y_OFFSET_LYING -6

///Define for spawning megafauna instead of a mob for cave gen
#define SPAWN_MEGAFAUNA "bluh bluh huge boss"

///Squash flags. For squashable element

///Whether or not the squashing requires the squashed mob to be lying down
#define SQUASHED_SHOULD_BE_DOWN (1<<0)
///Whether or not to gib when the squashed mob is moved over
#define SQUASHED_SHOULD_BE_GIBBED (1<<0)

/*
 * Defines for "AI emotions", allowing the AI to expression emotions
 * with status displays via emotes.
 */

#define AI_EMOTION_VERY_HAPPY "Very Happy"
#define AI_EMOTION_HAPPY "Happy"
#define AI_EMOTION_NEUTRAL "Neutral"
#define AI_EMOTION_UNSURE "Unsure"
#define AI_EMOTION_CONFUSED "Confused"
#define AI_EMOTION_SAD "Sad"
#define AI_EMOTION_BSOD "BSOD"
#define AI_EMOTION_BLANK "Blank"
#define AI_EMOTION_PROBLEMS "Problems?"
#define AI_EMOTION_AWESOME "Awesome"
#define AI_EMOTION_FACEPALM "Facepalm"
#define AI_EMOTION_THINKING "Thinking"
#define AI_EMOTION_FRIEND_COMPUTER "Friend Computer"
#define AI_EMOTION_DORFY "Dorfy"
#define AI_EMOTION_BLUE_GLOW "Blue Glow"
#define AI_EMOTION_RED_GLOW "Red Glow"

/// Throw modes, defines whether or not to turn off throw mode after
#define THROW_MODE_DISABLED 0
#define THROW_MODE_TOGGLE 1
#define THROW_MODE_HOLD 2

//Saves a proc call, life is suffering. If who has no targets_from var, we assume it's just who
#define GET_TARGETS_FROM(who) (who.targets_from ? who.get_targets_from() : who)

//defines for grad_color and grad_styles list access keys
#define GRADIENT_HAIR_KEY 1
#define GRADIENT_FACIAL_HAIR_KEY 2
//Keep up to date with the highest key value
#define GRADIENTS_LEN 2

// /datum/sprite_accessory/gradient defines
#define GRADIENT_APPLIES_TO_HAIR (1<<0)
#define GRADIENT_APPLIES_TO_FACIAL_HAIR (1<<1)

/// Sign Language defines
#define SIGN_ONE_HAND 0
#define SIGN_HANDS_FULL 1
#define SIGN_ARMLESS 2
#define SIGN_TRAIT_BLOCKED 3
#define SIGN_CUFFED 4

/// Mob transforming signal
#define COMSIG_MOB_TRANSFORMING "mob_transforming"
