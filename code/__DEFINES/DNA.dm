/*ALL DNA, SPECIES, AND GENETICS-RELATED DEFINES GO HERE*/

#define CHECK_DNA_AND_SPECIES(C) if(!(C.dna?.species)) return

#define UE_CHANGED "ue changed"
#define UI_CHANGED "ui changed"
#define UF_CHANGED "uf changed"

#define CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY 204

// String identifiers for associative list lookup

//Types of usual mutations
#define POSITIVE 1
#define NEGATIVE 2
#define MINOR_NEGATIVE 4


//Mutation classes. Normal being on them, extra being additional mutations with instability and other being stuff you dont want people to fuck with like wizard mutate
/// A mutation that can be activated and deactived by completing a sequence
#define MUT_NORMAL 1
/// A mutation that is in the mutations tab, and can be given and taken away through though the DNA console. Has a 0 before it's name in the mutation section of the dna console
#define MUT_EXTRA 2
/// Cannot be interacted with by players through normal means. I.E. wizards mutate
#define MUT_OTHER 3

//DNA - Because fuck you and your magic numbers being all over the codebase.
#define DNA_BLOCK_SIZE 3

#define DNA_BLOCK_SIZE_COLOR DEFAULT_HEX_COLOR_LEN

#define DNA_EYE_COLOR_LEFT_BLOCK 4
#define DNA_EYE_COLOR_RIGHT_BLOCK 4
#define DNA_FACIAL_HAIR_COLOR_BLOCK 2
#define DNA_FACIAL_HAIRSTYLE_BLOCK 6
#define DNA_GENDER_BLOCK 5
#define DNA_HAIR_COLOR_BLOCK 1
#define DNA_HAIRSTYLE_BLOCK 7
#define DNA_SKIN_TONE_BLOCK 3
#define DNA_UNI_IDENTITY_BLOCKS 7

/// This number needs to equal the total number of DNA blocks
#define DNA_FEATURE_BLOCKS 15

#define DNA_MUTANT_COLOR_BLOCK 1
#define DNA_ETHEREAL_COLOR_BLOCK 2
#define DNA_LIZARD_MARKINGS_BLOCK 3
#define DNA_TAIL_BLOCK 4
#define DNA_LIZARD_TAIL_BLOCK 5
#define DNA_SNOUT_BLOCK 6
#define DNA_HORNS_BLOCK 7
#define DNA_FRILLS_BLOCK 8
#define DNA_SPINES_BLOCK 9
#define DNA_EARS_BLOCK 10
#define DNA_MOTH_WINGS_BLOCK 11
#define DNA_MOTH_ANTENNAE_BLOCK 12
#define DNA_MOTH_MARKINGS_BLOCK 13
#define DNA_MUSHROOM_CAPS_BLOCK 14
#define DNA_POD_HAIR_BLOCK 15

#define DNA_SEQUENCE_LENGTH 4
#define DNA_MUTATION_BLOCKS 8
#define DNA_UNIQUE_ENZYMES_LEN 32

//species traits for mutantraces
#define MUTCOLORS 1
#define HAIR 2
#define FACEHAIR 3
#define EYECOLOR 4
#define LIPS 5
#define NOBLOOD 6
#define NOTRANSSTING 7
#define NOZOMBIE 8
#define NO_UNDERWEAR 9
#define NOSTOMACH 10
#define NO_DNA_COPY 11
#define DRINKSBLOOD 12

/// Use this if you want to change the race's color without the player being able to pick their own color. AKA special color shifting
#define DYNCOLORS 13
#define AGENDER 14
/// Do not draw eyes or eyeless overlay
#define NOEYESPRITES 15
/// Used for determining which wounds are applicable to this species.
/// if we have flesh (can suffer slash/piercing/burn wounds, requires they don't have NOBLOOD)
#define HAS_FLESH 16
/// if we have bones (can suffer bone wounds)
#define HAS_BONE 17
///If we have a limb-specific overlay sprite
#define HAS_MARKINGS 18
/// Do not draw blood overlay
#define NOBLOODOVERLAY 19
///No augments, for monkeys in specific because they will turn into fucking freakazoids https://cdn.discordapp.com/attachments/326831214667235328/791313258912153640/102707682-fa7cad80-4294-11eb-8f13-8c689468aeb0.png
#define NOAUGMENTS 20
///will be assigned a universal vampire themed last name shared by their department. this is preferenced!
#define BLOOD_CLANS 21
/// Stops species from spawning with tongue. Doesn't actually make the species able to talk with no tongue
#define NO_TONGUE 22


//organ slots
#define ORGAN_SLOT_ADAMANTINE_RESONATOR "adamantine_resonator"
#define ORGAN_SLOT_APPENDIX "appendix"
#define ORGAN_SLOT_BRAIN "brain"
#define ORGAN_SLOT_BRAIN_ANTIDROP "brain_antidrop"
#define ORGAN_SLOT_BRAIN_ANTISTUN "brain_antistun"
#define ORGAN_SLOT_BREATHING_TUBE "breathing_tube"
#define ORGAN_SLOT_EARS "ears"
#define ORGAN_SLOT_EYES "eye_sight"
#define ORGAN_SLOT_HEART "heart"
#define ORGAN_SLOT_HEART_AID "heartdrive"
#define ORGAN_SLOT_HUD "eye_hud"
#define ORGAN_SLOT_LIVER "liver"
#define ORGAN_SLOT_LUNGS "lungs"
#define ORGAN_SLOT_PARASITE_EGG "parasite_egg"
#define ORGAN_SLOT_REGENERATIVE_CORE "hivecore"
#define ORGAN_SLOT_RIGHT_ARM_AUG "r_arm_device"
#define ORGAN_SLOT_LEFT_ARM_AUG "l_arm_device" //This one ignores alphabetical order cause the arms should be together
#define ORGAN_SLOT_STOMACH "stomach"
#define ORGAN_SLOT_STOMACH_AID "stomach_aid"
#define ORGAN_SLOT_THRUSTERS "thrusters"
#define ORGAN_SLOT_TONGUE "tongue"
#define ORGAN_SLOT_VOICE "vocal_cords"
#define ORGAN_SLOT_ZOMBIE "zombie_infection"

/// Organ slot external
#define ORGAN_SLOT_EXTERNAL_TAIL "tail"
#define ORGAN_SLOT_EXTERNAL_SPINES "spines"
#define ORGAN_SLOT_EXTERNAL_SNOUT "snout"
#define ORGAN_SLOT_EXTERNAL_FRILLS "frills"
#define ORGAN_SLOT_EXTERNAL_HORNS "horns"
#define ORGAN_SLOT_EXTERNAL_WINGS "wings"
#define ORGAN_SLOT_EXTERNAL_ANTENNAE "antennae"
#define ORGAN_SLOT_EXTERNAL_BODYMARKINGS "bodymarkings"
#define ORGAN_SLOT_EXTERNAL_POD_HAIR "pod_hair"

/// Xenomorph organ slots
#define ORGAN_SLOT_XENO_ACIDGLAND "acid_gland"
#define ORGAN_SLOT_XENO_EGGSAC "eggsac"
#define ORGAN_SLOT_XENO_HIVENODE "hive_node"
#define ORGAN_SLOT_XENO_NEUROTOXINGLAND "neurotoxin_gland"
#define ORGAN_SLOT_XENO_PLASMAVESSEL "plasma_vessel"
#define ORGAN_SLOT_XENO_RESINSPINNER "resin_spinner"

//organ defines
#define STANDARD_ORGAN_THRESHOLD 100
#define STANDARD_ORGAN_HEALING 50 / 100000
/// designed to fail organs when left to decay for ~15 minutes
#define STANDARD_ORGAN_DECAY 111 / 100000

//used for the can_chromosome var on mutations
#define CHROMOSOME_NEVER 0
#define CHROMOSOME_NONE 1
#define CHROMOSOME_USED 2

//used for mob's genetic gender (mainly just for pronouns, members of sexed species with plural gender refer to their physique for the actual sprites, which is not genetic)
#define G_MALE 1
#define G_FEMALE 2
#define G_PLURAL 3

/// Defines how a mob's internal_organs_slot is ordered
/// Exists so Life()'s organ process order is consistent
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
	ORGAN_SLOT_PARASITE_EGG,
	ORGAN_SLOT_REGENERATIVE_CORE,
	ORGAN_SLOT_XENO_PLASMAVESSEL,
	ORGAN_SLOT_XENO_HIVENODE,
	ORGAN_SLOT_XENO_RESINSPINNER,
	ORGAN_SLOT_XENO_ACIDGLAND,
	ORGAN_SLOT_XENO_NEUROTOXINGLAND,
	ORGAN_SLOT_XENO_EGGSAC,))

//Defines for Golem Species IDs
#define SPECIES_GOLEM "golem"
#define SPECIES_GOLEM_ADAMANTINE "a_golem"
#define SPECIES_GOLEM_PLASMA "p_golem"
#define SPECIES_GOLEM_DIAMOND "diamond_golem"
#define SPECIES_GOLEM_GOLD "gold_golem"
#define SPECIES_GOLEM_SILVER "silver_golem"
#define SPECIES_GOLEM_PLASTEEL "plasteel_golem"
#define SPECIES_GOLEM_TITANIUM "titanium_golem"
#define SPECIES_GOLEM_PLASTITANIUM "plastitanium_golem"
#define SPECIES_GOLEM_ALIEN "alloy_golem"
#define SPECIES_GOLEM_WOOD "wood_golem"
#define SPECIES_GOLEM_URANIUM "uranium_golem"
#define SPECIES_GOLEM_SAND "sand_golem"
#define SPECIES_GOLEM_GLASS "glass_golem"
#define SPECIES_GOLEM_BLUESPACE "bluespace_golem"
#define SPECIES_GOLEM_BANANIUM "ba_golem"
#define SPECIES_GOLEM_CULT "cultgolem"
#define SPECIES_GOLEM_CLOTH "clothgolem"
#define SPECIES_GOLEM_PLASTIC "plastic_golem"
#define SPECIES_GOLEM_BRONZE "bronze_golem"
#define SPECIES_GOLEM_CARDBOARD "c_golem"
#define SPECIES_GOLEM_LEATHER "leather_golem"
#define SPECIES_GOLEM_DURATHREAD "d_golem"
#define SPECIES_GOLEM_BONE "b_golem"
#define SPECIES_GOLEM_SNOW "sn_golem"
#define SPECIES_GOLEM_HYDROGEN "metallic_hydrogen_golem"

// Defines for used in creating "perks" for the species preference pages.
/// A key that designates UI icon displayed on the perk.
#define SPECIES_PERK_ICON "ui_icon"
/// A key that designates the name of the perk.
#define SPECIES_PERK_NAME "name"
/// A key that designates the description of the perk.
#define SPECIES_PERK_DESC "description"
/// A key that designates what type of perk it is (see below).
#define SPECIES_PERK_TYPE "perk_type"

// The possible types each perk can be.
// Positive perks are shown in green, negative in red, and neutral in grey.
#define SPECIES_POSITIVE_PERK "positive"
#define SPECIES_NEGATIVE_PERK "negative"
#define SPECIES_NEUTRAL_PERK "neutral"
