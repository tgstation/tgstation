/*ALL DNA, SPECIES, AND GENETICS-RELATED DEFINES GO HERE*/

#define CHECK_DNA_AND_SPECIES(C) if(!(C.dna?.species)) return

//Defines copying names of mutations in all cases, make sure to change this if you change mutation's type
#define HULK /datum/mutation/human/hulk
#define XRAY /datum/mutation/human/thermal/x_ray
#define SPACEMUT /datum/mutation/human/space_adaptation
#define TK /datum/mutation/human/telekinesis
#define NERVOUS /datum/mutation/human/nervousness
#define EPILEPSY /datum/mutation/human/epilepsy
#define MUTATE /datum/mutation/human/bad_dna
#define COUGH /datum/mutation/human/cough
#define DWARFISM /datum/mutation/human/dwarfism
#define GIGANTISM /datum/mutation/human/gigantism
#define CLOWNMUT /datum/mutation/human/clumsy
#define TOURETTES /datum/mutation/human/tourettes
#define DEAFMUT /datum/mutation/human/deaf
#define BLINDMUT /datum/mutation/human/blind
#define RACEMUT /datum/mutation/human/race
#define BADSIGHT /datum/mutation/human/nearsight
#define LASEREYES /datum/mutation/human/laser_eyes
#define CHAMELEON /datum/mutation/human/chameleon
#define WACKY /datum/mutation/human/wacky
#define MUT_MUTE /datum/mutation/human/mute
#define STONER /datum/mutation/human/stoner
#define UNINTELLIGIBLE /datum/mutation/human/unintelligible
#define SWEDISH /datum/mutation/human/swedish
#define CHAV /datum/mutation/human/chav
#define ELVIS /datum/mutation/human/elvis
#define MEDIEVAL /datum/mutation/human/medieval
#define RADIOACTIVE /datum/mutation/human/radioactive
#define GLOWY /datum/mutation/human/glow
#define ANTIGLOWY /datum/mutation/human/glow/anti
#define TELEPATHY /datum/mutation/human/telepathy
#define FIREBREATH /datum/mutation/human/firebreath
#define VOID /datum/mutation/human/void
#define TONGUESPIKE /datum/mutation/human/tonguespike
#define TONGUESPIKECHEM /datum/mutation/human/tongue_spike/chem
#define STRONG /datum/mutation/human/strong
#define STIMMED /datum/mutation/human/stimmed
#define FIRESWEAT /datum/mutation/human/fire
#define THERMAL /datum/mutation/human/thermal
#define ANTENNA /datum/mutation/human/antenna
#define PARANOIA /datum/mutation/human/paranoia
#define MINDREAD /datum/mutation/human/mindreader
#define INSULATED /datum/mutation/human/insulated
#define SHOCKTOUCH /datum/mutation/human/shock
#define OLFACTION /datum/mutation/human/olfaction
#define ACIDFLESH /datum/mutation/human/acidflesh
#define BADBLINK /datum/mutation/human/badblink
#define SPASTIC /datum/mutation/human/spastic
#define EXTRASTUN /datum/mutation/human/extrastun
#define GELADIKINESIS /datum/mutation/human/geladikinesis
#define CRYOKINESIS /datum/mutation/human/cryokinesis
#define SPIDER_WEB /datum/mutation/human/webbing
#define MARTYRDOM /datum/mutation/human/martyrdom
#define HARS /datum/mutation/human/headless
#define BIOTECHCOMPAT /datum/mutation/human/biotechcompat

#define UI_CHANGED "ui changed"
#define UE_CHANGED "ue changed"

#define CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY 204

// String identifiers for associative list lookup

//Types of usual mutations
#define POSITIVE 1
#define NEGATIVE 2
#define MINOR_NEGATIVE 4


//Mutation classes. Normal being on them, extra being additional mutations with instability and other being stuff you dont want people to fuck with like wizard mutate
#define MUT_NORMAL 1
#define MUT_EXTRA 2
#define MUT_OTHER 3

//DNA - Because fuck you and your magic numbers being all over the codebase.
#define DNA_BLOCK_SIZE 3

#define DNA_UNI_IDENTITY_BLOCKS 7
#define DNA_HAIR_COLOR_BLOCK 1
#define DNA_FACIAL_HAIR_COLOR_BLOCK 2
#define DNA_SKIN_TONE_BLOCK 3
#define DNA_EYE_COLOR_BLOCK 4
#define DNA_GENDER_BLOCK 5
#define DNA_FACIAL_HAIRSTYLE_BLOCK 6
#define DNA_HAIRSTYLE_BLOCK 7

#define DNA_SEQUENCE_LENGTH 4
#define DNA_MUTATION_BLOCKS 8
#define DNA_UNIQUE_ENZYMES_LEN 32


#define CLONER_FRESH_CLONE "fresh"
#define CLONER_MATURE_CLONE "mature"

//species traits for mutantraces
#define MUTCOLORS 1
#define HAIR 2
#define FACEHAIR 3
#define EYECOLOR 4
#define LIPS 5
#define NOBLOOD 6
#define NOTRANSSTING 7
/// Used if we want the mutant colour to be only used by mutant bodyparts. Don't combine this with MUTCOLORS, or it will be useless.
#define MUTCOLORS_PARTSONLY 8
#define NOZOMBIE 9
/// Uses weird leg sprites. Optional for Lizards, required for ashwalkers. Don't give it to other races unless you make sprites for this (see human_parts_greyscale.dmi)
#define DIGITIGRADE 10
#define NO_UNDERWEAR 11
#define NOSTOMACH 12
#define NO_DNA_COPY     13
#define DRINKSBLOOD 14
/// Use this if you want to change the race's color without the player being able to pick their own color. AKA special color shifting
#define DYNCOLORS 15
#define AGENDER 16
/// Do not draw eyes or eyeless overlay
#define NOEYESPRITES 17
/// Used for determining which wounds are applicable to this species.
/// if we have flesh (can suffer slash/piercing/burn wounds, requires they don't have NOBLOOD)
#define HAS_FLESH 18
/// if we have bones (can suffer bone wounds)
#define HAS_BONE 19
///If we have a limb-specific overlay sprite
#define HAS_MARKINGS 20
/// Do not draw blood overlay
#define NOBLOODOVERLAY 21
///No augments, for monkeys in specific because they will turn into fucking freakazoids https://cdn.discordapp.com/attachments/326831214667235328/791313258912153640/102707682-fa7cad80-4294-11eb-8f13-8c689468aeb0.png
#define NOAUGMENTS 22

//organ slots
#define ORGAN_SLOT_BRAIN "brain"
#define ORGAN_SLOT_APPENDIX "appendix"
#define ORGAN_SLOT_RIGHT_ARM_AUG "r_arm_device"
#define ORGAN_SLOT_LEFT_ARM_AUG "l_arm_device"
#define ORGAN_SLOT_STOMACH "stomach"
#define ORGAN_SLOT_STOMACH_AID "stomach_aid"
#define ORGAN_SLOT_BREATHING_TUBE "breathing_tube"
#define ORGAN_SLOT_EARS "ears"
#define ORGAN_SLOT_EYES "eye_sight"
#define ORGAN_SLOT_LUNGS "lungs"
#define ORGAN_SLOT_HEART "heart"
#define ORGAN_SLOT_ZOMBIE "zombie_infection"
#define ORGAN_SLOT_THRUSTERS "thrusters"
#define ORGAN_SLOT_HUD "eye_hud"
#define ORGAN_SLOT_LIVER "liver"
#define ORGAN_SLOT_TONGUE "tongue"
#define ORGAN_SLOT_VOICE "vocal_cords"
#define ORGAN_SLOT_ADAMANTINE_RESONATOR "adamantine_resonator"
#define ORGAN_SLOT_HEART_AID "heartdrive"
#define ORGAN_SLOT_BRAIN_ANTIDROP "brain_antidrop"
#define ORGAN_SLOT_BRAIN_ANTISTUN "brain_antistun"
#define ORGAN_SLOT_TAIL "tail"
#define ORGAN_SLOT_PARASITE_EGG "parasite_egg"
#define ORGAN_SLOT_REGENERATIVE_CORE "hivecore"

/// Xenomorph organ slots
#define ORGAN_SLOT_XENO_PLASMAVESSEL "plasma_vessel"
#define ORGAN_SLOT_XENO_HIVENODE "hive_node"
#define ORGAN_SLOT_XENO_RESINSPINNER "resin_spinner"
#define ORGAN_SLOT_XENO_ACIDGLAND "acid_gland"
#define ORGAN_SLOT_XENO_NEUROTOXINGLAND "neurotoxin_gland"
#define ORGAN_SLOT_XENO_EGGSAC "eggsac"

//organ defines
#define STANDARD_ORGAN_THRESHOLD 100
#define STANDARD_ORGAN_HEALING 0.001
/// designed to fail organs when left to decay for ~15 minutes
#define STANDARD_ORGAN_DECAY 0.00222

//used for the can_chromosome var on mutations
#define CHROMOSOME_NEVER 0
#define CHROMOSOME_NONE 1
#define CHROMOSOME_USED 2

//used for mob's genetic gender (mainly just for pronouns, members of sexed species with plural gender refer to their body_type for the actual sprites, which is not genetic)
#define G_MALE 1
#define G_FEMALE 2
#define G_PLURAL 3

///Organ slot processing order for life proc
GLOBAL_LIST_INIT(organ_process_order, list(
	ORGAN_SLOT_BRAIN,
	ORGAN_SLOT_APPENDIX,
	ORGAN_SLOT_RIGHT_ARM_AUG,
	ORGAN_SLOT_LEFT_ARM_AUG,
	ORGAN_SLOT_STOMACH,
	ORGAN_SLOT_STOMACH_AID,
	ORGAN_SLOT_BREATHING_TUBE,
	ORGAN_SLOT_EARS,
	ORGAN_SLOT_EYES,
	ORGAN_SLOT_LUNGS,
	ORGAN_SLOT_HEART,
	ORGAN_SLOT_ZOMBIE,
	ORGAN_SLOT_THRUSTERS,
	ORGAN_SLOT_HUD,
	ORGAN_SLOT_LIVER,
	ORGAN_SLOT_TONGUE,
	ORGAN_SLOT_VOICE,
	ORGAN_SLOT_ADAMANTINE_RESONATOR,
	ORGAN_SLOT_HEART_AID,
	ORGAN_SLOT_BRAIN_ANTIDROP,
	ORGAN_SLOT_BRAIN_ANTISTUN,
	ORGAN_SLOT_TAIL,
	ORGAN_SLOT_PARASITE_EGG,
	ORGAN_SLOT_REGENERATIVE_CORE,
	ORGAN_SLOT_XENO_PLASMAVESSEL,
	ORGAN_SLOT_XENO_HIVENODE,
	ORGAN_SLOT_XENO_RESINSPINNER,
	ORGAN_SLOT_XENO_ACIDGLAND,
	ORGAN_SLOT_XENO_NEUROTOXINGLAND,
	ORGAN_SLOT_XENO_EGGSAC,))
