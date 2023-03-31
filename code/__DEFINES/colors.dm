// This is eventually for wjohn to add more color standardization stuff like I keep asking him >:(

//different types of atom colorations
/// Only used by rare effects like greentext coloring mobs and when admins varedit color
#define ADMIN_COLOUR_PRIORITY 1
/// e.g. purple effect of the revenant on a mob, black effect when mob electrocuted
#define TEMPORARY_COLOUR_PRIORITY 2
/// Color splashed onto an atom (e.g. paint on turf)
#define WASHABLE_COLOUR_PRIORITY 3
/// Color inherent to the atom (e.g. blob color)
#define FIXED_COLOUR_PRIORITY 4
///how many colour priority levels there are.
#define COLOUR_PRIORITY_AMOUNT 4

#define COLOR_DARKMODE_BACKGROUND "#202020"
#define COLOR_DARKMODE_DARKBACKGROUND "#171717"
#define COLOR_DARKMODE_TEXT "#a4bad6"

#define COLOR_WHITE "#FFFFFF"
#define COLOR_OFF_WHITE "#FFF5ED"
#define COLOR_VERY_LIGHT_GRAY "#EEEEEE"
#define COLOR_SILVER "#C0C0C0"
#define COLOR_GRAY "#808080"
#define COLOR_FLOORTILE_GRAY "#8D8B8B"
#define COLOR_ASSISTANT_GRAY "#6E6E6E"
#define COLOR_DARK "#454545"
#define COLOR_WEBSAFE_DARK_GRAY "#484848"
#define COLOR_ALMOST_BLACK "#333333"
#define COLOR_FULL_TONER_BLACK "#101010"
#define COLOR_PRISONER_BLACK "#292929"
#define COLOR_NEARLY_ALL_BLACK "#111111"
#define COLOR_BLACK "#000000"
#define COLOR_HALF_TRANSPARENT_BLACK "#0000007A"

#define COLOR_RED "#FF0000"
#define COLOR_SYNDIE_RED "#F10303"
#define COLOR_MOSTLY_PURE_RED "#FF3300"
#define COLOR_DARK_RED "#A50824"
#define COLOR_RED_LIGHT "#FF3333"
#define COLOR_FIRE_LIGHT_RED "#B61C1C"
#define COLOR_MAROON "#800000"
#define COLOR_SECURITY_RED "#CB0000"
#define COLOR_VIVID_RED "#FF3232"
#define COLOR_LIGHT_GRAYISH_RED "#E4C7C5"
#define COLOR_SOFT_RED "#FA8282"
#define COLOR_CULT_RED "#960000"
#define COLOR_BUBBLEGUM_RED "#950A0A"

#define COLOR_YELLOW "#FFFF00"
#define COLOR_VIVID_YELLOW "#FBFF23"
#define COLOR_VERY_SOFT_YELLOW "#FAE48E"

#define COLOR_OLIVE "#808000"
#define COLOR_ASSISTANT_OLIVE "#828163"
#define COLOR_VIBRANT_LIME "#00FF00"
#define COLOR_SERVICE_LIME "#58C800"
#define COLOR_LIME "#32CD32"
#define COLOR_DARK_LIME "#00aa00"
#define COLOR_VERY_PALE_LIME_GREEN "#DDFFD3"
#define COLOR_VERY_DARK_LIME_GREEN "#003300"
#define COLOR_GREEN "#008000"
#define COLOR_DARK_MODERATE_LIME_GREEN "#44964A"
#define COLOR_PAI_GREEN "#00FF88"
#define COLOR_PALE_GREEN "#20e28e"

#define COLOR_CYAN "#00FFFF"
#define COLOR_HEALING_CYAN "#80F5FF"
#define COLOR_DARK_CYAN "#00A2FF"
#define COLOR_TEAL "#008080"
#define COLOR_BLUE "#0000FF"
#define COLOR_STRONG_BLUE "#1919c8"
#define COLOR_CENTCOM_BLUE "#134975"
#define COLOR_BRIGHT_BLUE "#2CB2E8"
#define COLOR_COMMAND_BLUE "#1B67A5"
#define COLOR_MEDICAL_BLUE "#5B97BC"
#define COLOR_MODERATE_BLUE "#555CC2"
#define COLOR_AMETHYST "#822BFF"
#define COLOR_BLUE_LIGHT "#33CCFF"
#define COLOR_NAVY "#000080"
#define COLOR_BLUE_GRAY "#75A2BB"

#define COLOR_PINK "#FFC0CB"
#define COLOR_LIGHT_PINK "#FF3CC8"
#define COLOR_SCIENCE_PINK "#C96DBF"
#define COLOR_MOSTLY_PURE_PINK "#E4005B"
#define COLOR_ADMIN_PINK "#D100D1"
#define COLOR_BLUSH_PINK "#DE5D83"
#define COLOR_FADED_PINK "#ff80d5"
#define COLOR_MAGENTA "#FF00FF"
#define COLOR_STRONG_MAGENTA "#B800B8"
#define COLOR_PURPLE "#800080"
#define COLOR_VIOLET "#B900F7"
#define COLOR_STRONG_VIOLET "#6927C5"
#define COLOR_DARK_PURPLE "#551A8B"

#define COLOR_ORANGE "#FF9900"
#define COLOR_ENGINEERING_ORANGE "#FFA62B"
#define COLOR_MOSTLY_PURE_ORANGE "#ff8000"
#define COLOR_TAN_ORANGE "#FF7B00"
#define COLOR_BRIGHT_ORANGE "#E2853D"
#define COLOR_LIGHT_ORANGE "#ffc44d"
#define COLOR_PALE_ORANGE "#FFBE9D"
#define COLOR_BEIGE "#CEB689"
#define COLOR_DARK_ORANGE "#C3630C"
#define COLOR_PRISONER_ORANGE "#A54900"
#define COLOR_DARK_MODERATE_ORANGE "#8B633B"

#define COLOR_BROWN "#BA9F6D"
#define COLOR_DARK_BROWN "#997C4F"
#define COLOR_DARKER_BROWN "#330000"
#define COLOR_ORANGE_BROWN "#a9734f"
#define COLOR_CARGO_BROWN "#B18644"
#define COLOR_DRIED_TAN "#ad7257"
#define COLOR_LIGHT_BROWN "#996666"
#define COLOR_BROWNER_BROWN "#663300"

//Color defines used by the soapstone (based on readability against grey tiles)
#define COLOR_SOAPSTONE_PLASTIC "#a19d94"
#define COLOR_SOAPSTONE_IRON "#b2b2b2"
#define COLOR_SOAPSTONE_BRONZE "#FE8001"
#define COLOR_SOAPSTONE_SILVER "#FFFFFF"
#define COLOR_SOAPSTONE_GOLD "#FFD900"
#define COLOR_SOAPSTONE_DIAMOND "#00ffee"

#define COLOR_GREEN_GRAY "#99BB76"
#define COLOR_RED_GRAY "#B4696A"
#define COLOR_PALE_BLUE_GRAY "#98C5DF"
#define COLOR_PALE_GREEN_GRAY "#B7D993"
#define COLOR_PALE_RED_GRAY "#D59998"
#define COLOR_PALE_PURPLE_GRAY "#CBB1CA"
#define COLOR_PURPLE_GRAY "#AE8CA8"

//Color defines used by the assembly detailer.
#define COLOR_ASSEMBLY_BLACK "#545454"
#define COLOR_ASSEMBLY_BGRAY "#9497AB"
#define COLOR_ASSEMBLY_WHITE "#E2E2E2"
#define COLOR_ASSEMBLY_RED "#CC4242"
#define COLOR_ASSEMBLY_ORANGE "#E39751"
#define COLOR_ASSEMBLY_BEIGE "#AF9366"
#define COLOR_ASSEMBLY_BROWN "#97670E"
#define COLOR_ASSEMBLY_GOLD "#AA9100"
#define COLOR_ASSEMBLY_YELLOW "#CECA2B"
#define COLOR_ASSEMBLY_GURKHA "#999875"
#define COLOR_ASSEMBLY_LGREEN "#789876"
#define COLOR_ASSEMBLY_GREEN "#44843C"
#define COLOR_ASSEMBLY_LBLUE "#5D99BE"
#define COLOR_ASSEMBLY_BLUE "#38559E"
#define COLOR_ASSEMBLY_PURPLE "#6F6192"

///Colors for grayscale tools
#define COLOR_TOOL_BLUE "#1861d5"
#define COLOR_TOOL_RED "#951710"
#define COLOR_TOOL_PINK "#d5188d"
#define COLOR_TOOL_BROWN "#a05212"
#define COLOR_TOOL_GREEN "#0e7f1b"
#define COLOR_TOOL_CYAN "#18a2d5"
#define COLOR_TOOL_YELLOW "#d58c18"

///Colors for xenobiology vatgrowing
#define COLOR_SAMPLE_YELLOW "#c0b823"
#define COLOR_SAMPLE_PURPLE "#342941"
#define COLOR_SAMPLE_GREEN "#98b944"
#define COLOR_SAMPLE_BROWN "#91542d"
#define COLOR_SAMPLE_GRAY "#5e5856"

///Main colors for UI themes
#define COLOR_THEME_MIDNIGHT "#6086A0"
#define COLOR_THEME_PLASMAFIRE "#FFB200"
#define COLOR_THEME_RETRO "#24CA00"
#define COLOR_THEME_SLIMECORE "#4FB259"
#define COLOR_THEME_OPERATIVE "#b01232"
#define COLOR_THEME_GLASS "#75A4C4"
#define COLOR_THEME_CLOCKWORK "#CFBA47"
#define COLOR_THEME_TRASENKNOX "#3ce375"

///Colors for eigenstates
#define COLOR_PERIWINKLEE "#9999FF"

/// Starlight!
#define COLOR_STARLIGHT "#8589fa"
/**
 * Some defines to generalise colours used in lighting.
 *
 * Important note: colors can end up significantly different from the basic html picture, especially when saturated
 */
/// Bright but quickly dissipating neon green. rgb(100, 200, 100)
#define LIGHT_COLOR_GREEN "#64C864"
/// Vivid, slightly blue green. rgb(60, 240, 70)
#define LIGHT_COLOR_VIVID_GREEN "#3CF046"
/// Electric green. rgb(0, 255, 0)
#define LIGHT_COLOR_ELECTRIC_GREEN "#00FF00"
/// Cold, diluted blue. rgb(100, 150, 250)
#define LIGHT_COLOR_BLUE "#6496FA"
/// Faint white blue. rgb(222, 239, 255)
#define LIGHT_COLOR_FAINT_BLUE "#DEEFFF"
/// Light blueish green. rgb(125, 225, 175)
#define LIGHT_COLOR_BLUEGREEN "#7DE1AF"
/// Diluted cyan. rgb(125, 225, 225)
#define LIGHT_COLOR_CYAN "#7DE1E1"
/// Baby Blue rgb(0, 170, 220)
#define LIGHT_COLOR_BABY_BLUE "#00AADC"
/// Electric cyan rgb(0, 255, 255)
#define LIGHT_COLOR_ELECTRIC_CYAN "#00FFFF"
/// More-saturated cyan. rgb(64, 206, 255)
#define LIGHT_COLOR_LIGHT_CYAN "#40CEFF"
/// Saturated blue. rgb(51, 117, 248)
#define LIGHT_COLOR_DARK_BLUE "#6496FA"
/// Diluted, mid-warmth pink. rgb(225, 125, 225)
#define LIGHT_COLOR_PINK "#E17DE1"
/// Dimmed yellow, leaning kaki. rgb(225, 225, 125)
#define LIGHT_COLOR_DIM_YELLOW "#E1E17D"
/// Bright yellow. rgb(255, 255, 150)
#define LIGHT_COLOR_BRIGHT_YELLOW "#FFFF99"
/// Clear brown, mostly dim. rgb(150, 100, 50)
#define LIGHT_COLOR_BROWN "#966432"
/// Mostly pure orange. rgb(250, 150, 50)
#define LIGHT_COLOR_ORANGE "#FA9632"
/// Light Purple. rgb(149, 44, 244)
#define LIGHT_COLOR_PURPLE "#952CF4"
/// Less-saturated light purple. rgb(155, 81, 255)
#define LIGHT_COLOR_LAVENDER "#9B51FF"
///slightly desaturated bright yellow.
#define LIGHT_COLOR_HOLY_MAGIC "#FFF743"
/// deep crimson
#define LIGHT_COLOR_BLOOD_MAGIC "#D00000"

/* These ones aren't a direct colour like the ones above, because nothing would fit */
/// Warm orange color, leaning strongly towards yellow. rgb(250, 160, 25)
#define LIGHT_COLOR_FIRE "#FAA019"
/// Very warm yellow, leaning slightly towards orange. rgb(196, 138, 24)
#define LIGHT_COLOR_LAVA "#C48A18"
/// Bright, non-saturated red. Leaning slightly towards pink for visibility. rgb(250, 100, 75)
#define LIGHT_COLOR_FLARE "#FA644B"
/// Vivid red. Leans a bit darker to accentuate red colors and leave other channels a bit dry.  rgb(200, 25, 25)
#define LIGHT_COLOR_INTENSE_RED "#C81919"
/// Weird color, between yellow and green, very slimy. rgb(175, 200, 75)
#define LIGHT_COLOR_SLIME_LAMP "#AFC84B"
/// Extremely diluted yellow, close to skin color (for some reason). rgb(255, 214, 170)
#define LIGHT_COLOR_TUNGSTEN "#FFD6AA"
/// Barely visible cyan-ish hue, as the doctor prescribed. rgb(240, 250, 250)
#define LIGHT_COLOR_HALOGEN "#F0FAFA"

//The GAGS greyscale_colors for each department's computer/machine circuits
#define CIRCUIT_COLOR_GENERIC "#1A7A13"
#define CIRCUIT_COLOR_COMMAND "#1B4594"
#define CIRCUIT_COLOR_SECURITY "#9A151E"
#define CIRCUIT_COLOR_SCIENCE "#BC4A9B"
#define CIRCUIT_COLOR_SERVICE "#92DCBA"
#define CIRCUIT_COLOR_MEDICAL "#00CCFF"
#define CIRCUIT_COLOR_ENGINEERING "#F8D700"
#define CIRCUIT_COLOR_SUPPLY "#C47749"

/// Colors for pride week
#define COLOR_PRIDE_RED "#FF6666"
#define COLOR_PRIDE_ORANGE "#FC9F3C"
#define COLOR_PRIDE_YELLOW "#EAFF51"
#define COLOR_PRIDE_GREEN "#41FC66"
#define COLOR_PRIDE_BLUE "#42FFF2"
#define COLOR_PRIDE_PURPLE "#5D5DFC"

/// The default color for admin say, used as a fallback when the preference is not enabled
#define DEFAULT_ASAY_COLOR COLOR_MOSTLY_PURE_RED

#define DEFAULT_HEX_COLOR_LEN 6

// Color filters
/// Icon filter that creates ambient occlusion
#define AMBIENT_OCCLUSION filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")
/// Icon filter that creates gaussian blur
#define GAUSSIAN_BLUR(filter_size) filter(type="blur", size=filter_size)

#define CABLE_COLOR_BLUE "blue"
	#define CABLE_HEX_COLOR_BLUE COLOR_STRONG_BLUE
#define CABLE_COLOR_BROWN "brown"
	#define CABLE_HEX_COLOR_BROWN COLOR_ORANGE_BROWN
#define CABLE_COLOR_CYAN "cyan"
	#define CABLE_HEX_COLOR_CYAN COLOR_CYAN
#define CABLE_COLOR_GREEN "green"
	#define CABLE_HEX_COLOR_GREEN COLOR_DARK_LIME
#define CABLE_COLOR_ORANGE "orange"
	#define CABLE_HEX_COLOR_ORANGE COLOR_MOSTLY_PURE_ORANGE
#define CABLE_COLOR_PINK "pink"
	#define CABLE_HEX_COLOR_PINK COLOR_LIGHT_PINK
#define CABLE_COLOR_RED "red"
	#define CABLE_HEX_COLOR_RED COLOR_RED
#define CABLE_COLOR_WHITE "white"
	#define CABLE_HEX_COLOR_WHITE COLOR_WHITE
#define CABLE_COLOR_YELLOW "yellow"
	#define CABLE_HEX_COLOR_YELLOW COLOR_YELLOW

#define COLOR_CARP_PURPLE "#aba2ff"
#define COLOR_CARP_PINK "#da77a8"
#define COLOR_CARP_GREEN "#70ff25"
#define COLOR_CARP_GRAPE "#df0afb"
#define COLOR_CARP_SWAMP "#e5e75a"
#define COLOR_CARP_TURQUOISE "#04e1ed"
#define COLOR_CARP_BROWN "#ca805a"
#define COLOR_CARP_TEAL "#20e28e"
#define COLOR_CARP_LIGHT_BLUE "#4d88cc"
#define COLOR_CARP_RUSTY "#dd5f34"
#define COLOR_CARP_RED "#fd6767"
#define COLOR_CARP_YELLOW "#f3ca4a"
#define COLOR_CARP_BLUE "#09bae1"
#define COLOR_CARP_PALE_GREEN "#7ef099"
#define COLOR_CARP_SILVER "#fdfbf3"
#define COLOR_CARP_DARK_BLUE "#3a384d"

#define COLOR_GNOME_RED_ONE "#f10b0b"
#define COLOR_GNOME_RED_TWO "#bc5347"
#define COLOR_GNOME_RED_THREE "#b40f1a"
#define COLOR_GNOME_BLUE_ONE "#2e8ff7"
#define COLOR_GNOME_BLUE_TWO "#312bd6"
#define COLOR_GNOME_BLUE_THREE "#4e409a"
#define COLOR_GNOME_GREEN_ONE "#28da1c"
#define COLOR_GNOME_GREEN_TWO "#50a954"
#define COLOR_GNOME_YELLOW "#f6da3c"
#define COLOR_GNOME_ORANGE "#d56f2f"
#define COLOR_GNOME_BROWN_ONE "#874e2a"
#define COLOR_GNOME_BROWN_TWO "#543d2e"
#define COLOR_GNOME_PURPLE "#ac1dd7"
#define COLOR_GNOME_WHITE "#e8e8e8"
#define COLOR_GNOME_GREY "#a9a9a9"
#define COLOR_GNOME_BLACK "#303030"

#define SOFA_BROWN "#a75400"
#define SOFA_MAROON "#830000"

GLOBAL_LIST_INIT(cable_colors, list(
	CABLE_COLOR_BLUE = CABLE_HEX_COLOR_BLUE,
	CABLE_COLOR_CYAN = CABLE_HEX_COLOR_CYAN,
	CABLE_COLOR_GREEN = CABLE_HEX_COLOR_GREEN,
	CABLE_COLOR_ORANGE = CABLE_HEX_COLOR_ORANGE,
	CABLE_COLOR_PINK = CABLE_HEX_COLOR_PINK,
	CABLE_COLOR_RED = CABLE_HEX_COLOR_RED,
	CABLE_COLOR_WHITE = CABLE_HEX_COLOR_WHITE,
	CABLE_COLOR_YELLOW = CABLE_HEX_COLOR_YELLOW,
	CABLE_COLOR_BROWN = CABLE_HEX_COLOR_BROWN
))
