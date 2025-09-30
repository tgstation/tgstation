// A mapping between AI_EMOTION_* string constants, which also double as user readable descriptions, and the name of the iconfile. (used for /obj/machinery/status_display/ai )
GLOBAL_LIST_INIT(ai_status_display_emotes, list(
	// Original AI emotion states
	AI_EMOTION_AWESOME = "ai_awesome",
	AI_EMOTION_BLANK = AI_DISPLAY_DONT_GLOW,
	AI_EMOTION_BLUE_GLOW = "ai_sal",
	AI_EMOTION_BSOD = "ai_bsod",
	AI_EMOTION_CONFUSED = "ai_confused",
	AI_EMOTION_DORFY = "ai_urist",
	AI_EMOTION_FACEPALM = "ai_facepalm",
	AI_EMOTION_FRIEND_COMPUTER = "ai_friend",
	AI_EMOTION_HAPPY = "ai_happy",
	AI_EMOTION_NEUTRAL = "ai_neutral",
	AI_EMOTION_PROBLEMS = "ai_trollface",
	AI_EMOTION_RED_GLOW = "ai_hal",
	AI_EMOTION_SAD = "ai_sad",
	AI_EMOTION_THINKING = "ai_thinking",
	AI_EMOTION_UNSURE = "ai_unsure",
	AI_EMOTION_VERY_HAPPY = "ai_veryhappy",
))

// Mapping from AI core display options to new status display icon states
// This allows AI status displays to show the same choice as AI core displays
GLOBAL_LIST_INIT(ai_core_to_status_display_mapping, list(
	"Alien" = "ai_status_alien",
	"Angel" = "ai_status_angel",
	"Banned" = "ai_status_banned",
	"Bliss" = "ai_status_bliss",
	"Blue" = "ai_status_blue",
	"Clown" = "ai_status_clown",
	"Database" = "ai_status_database",
	"Dorf" = "ai_status_dorf",
	"Firewall" = "ai_status_firewall",
	"Fuzzy" = "ai_status_fuzzy",
	"Gentoo" = "ai_status_gentoo",
	"Glitchman" = "ai_status_glitchman",
	"Gondola" = "ai_status_gondola",
	"Goon" = "ai_status_goon",
	"Hades" = "ai_status_hades",
	"HAL 9000" = "ai_status_hal9000",
	"Heartline" = "ai_status_heartline",
	"Helios" = "ai_status_helios",
	"House" = "ai_status_house",
	"Matrix" = "ai_status_matrix",
	"Monochrome" = "ai_status_monochrome",
	"Murica" = "ai_status_murica",
	"Nanotrasen" = "ai_status_nanotrasen",
	"Not Malf" = "ai_status_not_malf",
	"President" = "ai_status_president",
	"Rainbow" = "ai_status_rainbow",
	"Red October" = "ai_status_red_october",
	"Red" = "ai_status_red",
	"Static" = "ai_status_static",
	"Syndicat Meow" = "ai_status_syndicat_meow",
	"Text" = "ai_status_text",
	"Too Deep" = "ai_status_too_deep",
	"Triumvirate" = "ai_status_triumvirate",
	"Weird" = "ai_status_weird",
))

// Combined list for AI status display preferences, including both emotion states and AI core display options
GLOBAL_LIST_INIT(ai_status_display_all_options, list())

// Initialize the combined list at runtime
/proc/init_ai_status_display_options()
	if(length(GLOB.ai_status_display_all_options)) // Already initialized
		return

	// Start with original emotes
	GLOB.ai_status_display_all_options = GLOB.ai_status_display_emotes.Copy()

	// Add AI core display mappings
	for(var/core_option in GLOB.ai_core_to_status_display_mapping)
		GLOB.ai_status_display_all_options[core_option] = GLOB.ai_core_to_status_display_mapping[core_option]

GLOBAL_LIST_INIT(ai_hologram_category_options, list(
	AI_HOLOGRAM_CATEGORY_ANIMAL = list(
		AI_HOLOGRAM_BEAR,
		AI_HOLOGRAM_CARP,
		AI_HOLOGRAM_CAT,
		AI_HOLOGRAM_CAT_2,
		AI_HOLOGRAM_CHICKEN,
		AI_HOLOGRAM_CORGI,
		AI_HOLOGRAM_COW,
		AI_HOLOGRAM_CRAB,
		AI_HOLOGRAM_FOX,
		AI_HOLOGRAM_GOAT,
		AI_HOLOGRAM_PARROT,
		AI_HOLOGRAM_PUG,
		AI_HOLOGRAM_SPIDER,
	),
	AI_HOLOGRAM_CATEGORY_UNIQUE = list(
		AI_HOLOGRAM_DEFAULT,
		AI_HOLOGRAM_FACE,
		AI_HOLOGRAM_NARSIE,
		AI_HOLOGRAM_RATVAR,
		AI_HOLOGRAM_XENO,
	),
))

// New items need to also be added to ai_hologram_icon_state list
GLOBAL_LIST_INIT(ai_hologram_icons, list(
	/* Animal */
	AI_HOLOGRAM_BEAR = 'icons/mob/simple/animal.dmi',
	AI_HOLOGRAM_CARP = 'icons/mob/simple/carp.dmi',
	AI_HOLOGRAM_CAT = 'icons/mob/simple/pets.dmi',
	AI_HOLOGRAM_CAT_2 = 'icons/mob/simple/pets.dmi',
	AI_HOLOGRAM_CHICKEN = 'icons/mob/simple/animal.dmi',
	AI_HOLOGRAM_CORGI = 'icons/mob/simple/pets.dmi',
	AI_HOLOGRAM_COW = 'icons/mob/simple/cows.dmi',
	AI_HOLOGRAM_CRAB = 'icons/mob/simple/animal.dmi',
	AI_HOLOGRAM_FOX = 'icons/mob/simple/pets.dmi',
	AI_HOLOGRAM_GOAT = 'icons/mob/simple/animal.dmi',
	AI_HOLOGRAM_PARROT = 'icons/mob/simple/animal.dmi',
	AI_HOLOGRAM_PUG = 'icons/mob/simple/pets.dmi',
	AI_HOLOGRAM_SPIDER = 'icons/mob/simple/arachnoid.dmi',
	/* Unique */
	AI_HOLOGRAM_DEFAULT = 'icons/mob/silicon/ai.dmi',
	AI_HOLOGRAM_FACE = 'icons/mob/silicon/ai.dmi',
	AI_HOLOGRAM_NARSIE = 'icons/mob/silicon/ai.dmi',
	AI_HOLOGRAM_RATVAR = 'icons/mob/silicon/ai.dmi',
	AI_HOLOGRAM_XENO = 'icons/mob/nonhuman-player/alien.dmi',
))

// New items need to also be added to ai_hologram_icons list
GLOBAL_LIST_INIT(ai_hologram_icon_state, list(
	/* Animal */
	AI_HOLOGRAM_BEAR = "bear",
	AI_HOLOGRAM_CARP = "carp",
	AI_HOLOGRAM_CAT = "cat",
	AI_HOLOGRAM_CAT_2 = "cat2",
	AI_HOLOGRAM_CHICKEN = "chicken_brown",
	AI_HOLOGRAM_CORGI = "corgi",
	AI_HOLOGRAM_COW = "cow",
	AI_HOLOGRAM_CRAB = "crab",
	AI_HOLOGRAM_FOX = "fox",
	AI_HOLOGRAM_GOAT = "goat",
	AI_HOLOGRAM_PARROT = "parrot_fly",
	AI_HOLOGRAM_PUG = "pug",
	AI_HOLOGRAM_SPIDER = "guard",
	/* Unique */
	AI_HOLOGRAM_DEFAULT = "default",
	AI_HOLOGRAM_FACE = "floating face",
	AI_HOLOGRAM_NARSIE = "horror",
	AI_HOLOGRAM_RATVAR = "clock",
	AI_HOLOGRAM_XENO = "alienq",
))


GLOBAL_LIST_INIT(ai_core_display_screens, sort_list(list(
	":thinking:",
	"Alien",
	"Angel",
	"Banned",
	"Bliss",
	"Blue",
	"Clown",
	"Database",
	"Dorf",
	"Firewall",
	"Fuzzy",
	"Gentoo",
	"Glitchman",
	"Gondola",
	"Goon",
	"Hades",
	"HAL 9000",
	"Heartline",
	"Helios",
	"House",
	"Inverted",
	"Matrix",
	"Monochrome",
	"Murica",
	"Nanotrasen",
	"Not Malf",
	"Portrait",
	"President",
	"Rainbow",
	"Random",
	"Red October",
	"Red",
	"Static",
	"Syndicat Meow",
	"Text",
	"Too Deep",
	"Triumvirate-M",
	"Triumvirate",
	"Weird",
)))

/// A form of resolve_ai_icon that is guaranteed to never sleep.
/// Not always accurate, but always synchronous.
/proc/resolve_ai_icon_sync(input)
	SHOULD_NOT_SLEEP(TRUE)

	if(!input || !(input in GLOB.ai_core_display_screens))
		return "ai"
	else
		if(input == "Random")
			input = pick(GLOB.ai_core_display_screens - "Random")
		return "ai-[LOWER_TEXT(input)]"

/proc/resolve_ai_icon(input)
	if (input == "Portrait")
		var/datum/portrait_picker/tgui = new(usr)//create the datum
		tgui.ui_interact(usr)//datum has a tgui component, here we open the window
		return "ai-portrait" //just take this until they decide

	return resolve_ai_icon_sync(input)
