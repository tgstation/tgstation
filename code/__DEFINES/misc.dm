#define MIDNIGHT_ROLLOVER		864000	//number of deciseconds in a day

#define JANUARY		1
#define FEBRUARY	2
#define MARCH		3
#define APRIL		4
#define MAY			5
#define JUNE		6
#define JULY		7
#define AUGUST		8
#define SEPTEMBER	9
#define OCTOBER		10
#define NOVEMBER	11
#define DECEMBER	12

//Select holiday names -- If you test for a holiday in the code, make the holiday's name a define and test for that instead
#define NEW_YEAR				"New Year"
#define VALENTINES				"Valentine's Day"
#define APRIL_FOOLS				"April Fool's Day"
#define EASTER					"Easter"
#define HALLOWEEN				"Halloween"
#define CHRISTMAS				"Christmas"
#define FRIDAY_13TH				"Friday the 13th"

//Human Overlays Indexes/////////
#define SPECIES_LAYER			26		// mutantrace colors... these are on a seperate layer in order to prvent
#define BODY_BEHIND_LAYER		25
#define BODY_LAYER				24		//underwear, undershirts, socks, eyes, lips(makeup)
#define BODY_ADJ_LAYER			23
#define MUTATIONS_LAYER			22		//Tk headglows etc.
#define AUGMENTS_LAYER			21
#define DAMAGE_LAYER			20		//damage indicators (cuts and burns)
#define UNIFORM_LAYER			19
#define ID_LAYER				18
#define SHOES_LAYER				17
#define GLOVES_LAYER			16
#define EARS_LAYER				15
#define SUIT_LAYER				14
#define GLASSES_LAYER			13
#define BELT_LAYER				12		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		11
#define BACK_LAYER				10
#define HAIR_LAYER				9		//TODO: make part of head layer?
#define FACEMASK_LAYER			8
#define HEAD_LAYER				7
#define HANDCUFF_LAYER			6
#define LEGCUFF_LAYER			5
#define L_HAND_LAYER			4
#define R_HAND_LAYER			3		//Having the two hands seperate seems rather silly, merge them together? It'll allow for code to be reused on mobs with arbitarily many hands
#define BODY_FRONT_LAYER		2
#define FIRE_LAYER				1		//If you're on fire
#define TOTAL_LAYERS			26		//KEEP THIS UP-TO-DATE OR SHIT WILL BREAK ;_;

//Human Overlay Index Shortcuts for alternate_worn_layer, layers
//Because I *KNOW* somebody will think layer+1 means "above"
//IT DOESN'T OK, IT MEANS "UNDER"
#define UNDER_SPECIES_LAYER			SPECIES_LAYER+1
#define UNDER_BODY_BEHIND_LAYER		BODY_BEHIND_LAYER+1
#define UNDER_BODY_LAYER			BODY_LAYER+1
#define UNDER_BODY_ADJ_LAYER		BODY_ADJ_LAYER+1
#define UNDER_MUTATIONS_LAYER		MUTATIONS_LAYER+1
#define UNDER_AUGMENTS_LAYER		AUGMENTS_LAYER+1
#define UNDER_DAMAGE_LAYER			DAMAGE_LAYER+1
#define UNDER_UNIFORM_LAYER			UNIFORM_LAYER+1
#define UNDER_ID_LAYER				ID_LAYER+1
#define UNDER_SHOES_LAYER			SHOES_LAYER+1
#define UNDER_GLOVES_LAYER			GLOVES_LAYER+1
#define UNDER_EARS_LAYER			EARS_LAYER+1
#define UNDER_SUIT_LAYER			SUIT_LAYER+1
#define UNDER_GLASSES_LAYER			GLASSES_LAYER+1
#define UNDER_BELT_LAYER			BELT_LAYER+1
#define UNDER_SUIT_STORE_LAYER		SUIT_STORE_LAYER+1
#define UNDER_BACK_LAYER			BACK_LAYER+1
#define UNDER_HAIR_LAYER			HAIR_LAYER+1
#define UNDER_FACEMASK_LAYER		FACEMASK_LAYER+1
#define UNDER_HEAD_LAYER			HEAD_LAYER+1
#define UNDER_HANDCUFF_LAYER		HANDCUFF_LAYER+1
#define UNDER_LEGCUFF_LAYER			LEGCUFF_LAYER+1
#define UNDER_L_HAND_LAYER			L_HAND_LAYER+1
#define UNDER_R_HAND_LAYER			R_HAND_LAYER+1
#define UNDER_BODY_FRONT_LAYER		BODY_FRONT_LAYER+1
#define UNDER_FIRE_LAYER			FIRE_LAYER+1

//AND -1 MEANS "ABOVE", OK?, OK!?!
#define ABOVE_SPECIES_LAYER			SPECIES_LAYER-1
#define ABOVE_BODY_BEHIND_LAYER		BODY_BEHIND_LAYER-1
#define ABOVE_BODY_LAYER			BODY_LAYER-1
#define ABOVE_BODY_ADJ_LAYER		BODY_ADJ_LAYER-1
#define ABOVE_MUTATIONS_LAYER		MUTATIONS_LAYER-1
#define ABOVE_AUGMENTS_LAYER		AUGMENTS_LAYER-1
#define ABOVE_DAMAGE_LAYER			DAMAGE_LAYER-1
#define ABOVE_UNIFORM_LAYER			UNIFORM_LAYER-1
#define ABOVE_ID_LAYER				ID_LAYER-1
#define ABOVE_SHOES_LAYER			SHOES_LAYER-1
#define ABOVE_GLOVES_LAYER			GLOVES_LAYER-1
#define ABOVE_EARS_LAYER			EARS_LAYER-1
#define ABOVE_SUIT_LAYER			SUIT_LAYER-1
#define ABOVE_GLASSES_LAYER			GLASSES_LAYER-1
#define ABOVE_BELT_LAYER			BELT_LAYER-1
#define ABOVE_SUIT_STORE_LAYER		SUIT_STORE_LAYER-1
#define ABOVE_BACK_LAYER			BACK_LAYER-1
#define ABOVE_HAIR_LAYER			HAIR_LAYER-1
#define ABOVE_FACEMASK_LAYER		FACEMASK_LAYER-1
#define ABOVE_HEAD_LAYER			HEAD_LAYER-1
#define ABOVE_HANDCUFF_LAYER		HANDCUFF_LAYER-1
#define ABOVE_LEGCUFF_LAYER			LEGCUFF_LAYER-1
#define ABOVE_L_HAND_LAYER			L_HAND_LAYER-1
#define ABOVE_R_HAND_LAYER			R_HAND_LAYER-1
#define ABOVE_BODY_FRONT_LAYER		BODY_FRONT_LAYER-1
#define ABOVE_FIRE_LAYER			FIRE_LAYER-1


//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

#define MANIFEST_ERROR_NAME		1
#define MANIFEST_ERROR_COUNT	2
#define MANIFEST_ERROR_ITEM		4

#define TRANSITIONEDGE			7 //Distance from edge to move to another z-level



//HUD styles. Please ensure HUD_VERSIONS is the same as the maximum index. Index order defines how they are cycled in F12.
#define HUD_STYLE_STANDARD 1
#define HUD_STYLE_REDUCED 2
#define HUD_STYLE_NOHUD 3


#define HUD_VERSIONS 3	//used in show_hud()
//1 = standard hud
//2 = reduced hud (just hands and intent switcher)
//3 = no hud (for screenshots)

#define MINERAL_MATERIAL_AMOUNT 2000
//The amount of materials you get from a sheet of mineral like iron/diamond/glass etc
#define MAX_STACK_SIZE 50
//The maximum size of a stack object.

#define CLICK_CD_MELEE 8
#define CLICK_CD_RANGE 4
#define CLICK_CD_BREAKOUT 100
#define CLICK_CD_HANDCUFFED 10
#define CLICK_CD_TKSTRANGLE 10
#define CLICK_CD_RESIST 20
//click cooldowns, in tenths of a second


#define BE_CLOSE 1		//in the case of a silicon, to select if they need to be next to the atom
#define NO_DEXTERY 1	//if other mobs (monkeys, aliens, etc) can use this
//used by canUseTopic()

//Sizes of mobs, used by mob/living/var/mob_size
#define MOB_SIZE_TINY 0
#define MOB_SIZE_SMALL 1
#define MOB_SIZE_HUMAN 2
#define MOB_SIZE_LARGE 3

//singularity defines
#define STAGE_ONE 1
#define STAGE_TWO 3
#define STAGE_THREE 5
#define STAGE_FOUR 7
#define STAGE_FIVE 9
#define STAGE_SIX 11 //From supermatter shard

//zlevel defines, can be overridden for different maps in the appropriate _maps file.
#define ZLEVEL_SPACEMAX 7
#define ZLEVEL_MINING 5
#define ZLEVEL_SPACEMIN 3
#define ZLEVEL_ABANDONNEDTSAT 3
#define ZLEVEL_CENTCOM 2
#define ZLEVEL_STATION 1

//ticker.current_state values
#define GAME_STATE_STARTUP		0
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4
//SOUND:
#define SOUND_MINIMUM_PRESSURE 10
#define FALLOFF_SOUNDS	1
#define SURROUND_CAP	7

//FONTS:
// Used by Paper and PhotoCopier (and PaperBin once a year).
// Used by PDA's Notekeeper.
// Used by NewsCaster and NewsPaper.
#define PEN_FONT "Verdana"
#define CRAYON_FONT "Comic Sans MS"
#define SIGNFONT "Times New Roman"


//NPC DEFINES
#define INTERACTING 2
#define TRAVEL 4
#define FIGHTING 8

//TRAITS

#define TRAIT_ROBUST 2
#define TRAIT_UNROBUST 4
#define TRAIT_SMART 8
#define TRAIT_DUMB 16
#define TRAIT_MEAN 32
#define TRAIT_FRIENDLY 64
#define TRAIT_THIEVING 128

//defines
#define MAX_RANGE_FIND 32
#define MIN_RANGE_FIND 16
#define FUZZY_CHANCE_HIGH 85
#define FUZZY_CHANCE_LOW 50
#define CHANCE_TALK 15
#define MAXCOIL 30
#define RESIZE_DEFAULT_SIZE 1

//transfer_ai() defines. Main proc in ai_core.dm
#define AI_TRANS_TO_CARD	1 //Downloading AI to InteliCard.
#define AI_TRANS_FROM_CARD	2 //Uploading AI from InteliCard
#define AI_MECH_HACK		3 //Malfunctioning AI hijacking mecha

//Material defines
#define MAT_METAL		"$metal"
#define MAT_GLASS		"$glass"
#define MAT_SILVER		"$silver"
#define MAT_GOLD		"$gold"
#define MAT_DIAMOND		"$diamond"
#define MAT_URANIUM		"$uranium"
#define MAT_PLASMA		"$plasma"
#define MAT_BANANIUM	"$bananium"


//check_target_facings() return defines
#define FACING_FAILED											0
#define FACING_SAME_DIR											1
#define FACING_EACHOTHER										2
#define FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR	3 //Do I win the most informative but also most stupid define award?


//Cache of bloody footprint images
//Key:
//"entered-[blood_state]-[dir_of_image]"
//or: "exited-[blood_state]-[dir_of_image]"
var/list/bloody_footprints_cache = list()

//Bloody shoes/footprints
#define MAX_SHOE_BLOODINESS			100
#define BLOODY_FOOTPRINT_BASE_ALPHA	100
#define BLOOD_GAIN_PER_STEP			50
#define BLOOD_LOSS_PER_STEP			5
#define BLOOD_FADEOUT_TIME			2

//Bloody shoe blood states
#define BLOOD_STATE_HUMAN			"blood"
#define BLOOD_STATE_XENO			"xeno"
#define BLOOD_STATE_OIL				"oil"
#define BLOOD_STATE_NOT_BLOODY		"no blood whatsoever"