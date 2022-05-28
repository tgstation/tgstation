/// Does 4 spaces. Used as a makeshift tabulator.
#define FOURSPACES "&nbsp;&nbsp;&nbsp;&nbsp;"

/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(x) text2num(copytext(x, findtextEx(x, "x") + 1))

/// Gets width from MeasureText proc
#define WXH_TO_WIDTH(x) text2num(copytext(x, 1, findtextEx(x, "x") + 1))

/// Removes characters incompatible with file names.
#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))

/// Simply removes the < and > characters, and limits the length of the message.
#define STRIP_HTML_SIMPLE(text, limit) (GLOB.angular_brackets.Replace(copytext(text, 1, limit), ""))

///Index access defines for paper/var/add_info_style
#define ADD_INFO_COLOR 1
#define ADD_INFO_FONT 2
#define ADD_INFO_SIGN 3

///Adds a html style to a text string. Hacky, but that's how inputted text appear on paper sheets after going through the UI.
#define PAPER_MARK_TEXT(text, color, font) "<span style=\"color:[color];font-family:'[font]';\">[text]</span>\n \n"

/// Folder directory for strings
#define STRING_DIRECTORY "strings"

// JSON text files found in the tgstation/strings folder
/// File location for brain damage traumas
#define BRAIN_DAMAGE_FILE "traumas.json"
/// File location for AI ion laws
#define ION_FILE "ion_laws.json"
/// File location for pirate names
#define PIRATE_NAMES_FILE "pirates.json"
/// File location for redpill questions
#define REDPILL_FILE "redpill.json"
/// File location for arcade names
#define ARCADE_FILE "arcade.json"
/// File location for boomer meme catchphrases
#define BOOMER_FILE "boomer.json"
/// File location for locations on the station
#define LOCATIONS_FILE "locations.json"
/// File location for wanted posters messages
#define WANTED_FILE "wanted_message.json"
/// File location for really dumb suggestions memes
#define VISTA_FILE "steve.json"
/// File location for flesh wound descriptions
#define FLESH_SCAR_FILE "wounds/flesh_scar_desc.json"
/// File location for bone wound descriptions
#define BONE_SCAR_FILE "wounds/bone_scar_desc.json"
/// File location for scar wound descriptions
#define SCAR_LOC_FILE "wounds/scar_loc.json"
/// File location for exodrone descriptions
#define EXODRONE_FILE "exodrone.json"
/// File location for clown honk descriptions
#define CLOWN_NONSENSE_FILE "clown_nonsense.json"
/// File location for cult shuttle curse descriptions
#define CULT_SHUTTLE_CURSE "cult_shuttle_curse.json"
/// File location for eigenstasium lines
#define EIGENSTASIUM_FILE "eigenstasium.json"

/// Index of normal sized character size in runechat lists
#define NORMAL_FONT_INDEX 1
/// Index of small sized character size in runechat lists
#define SMALL_FONT_INDEX 2
/// Index of big sized character size in runechat lists
#define BIG_FONT_INDEX 3

/// Index of maximum possible calculated values
#define MAX_CHAR_WIDTH "max_width"

/// Default font size (defined in skin.dmf), those are 1 size bigger than in skin, to account 1px black outline
#define DEFAULT_FONT_SIZE 8
/// Big font size, used by megaphones and such
#define BIG_FONT_SIZE 9
/// Small font size, used mostly by whispering
#define WHISPER_FONT_SIZE 7

/// Approximation of the height
#define APPROX_HEIGHT(font_size, lines) ((font_size * 1.7 * lines) + 2)

/// Initializes empty list of cache characters for runechat. Space is special case since measuring it returns 0.
#define EMPTY_CHARACTERS_LIST list(\
		"." = null,\
		"," = null,\
		"?" = null,\
		"!" = null,\
		"\"" = null,\
		"/" = null,\
		"$" = null,\
		"(" = null,\
		")" = null,\
		"@" = null,\
		"=" = null,\
		":" = null,\
		"'" = null,\
		";" = null,\
		"+" = null,\
		"-" = null,\
		"\\" = null,\
		"<" = null,\
		">" = null,\
		"&" = null,\
		"*" = null,\
		"%" = null,\
		"^" = null,\
		"{" = null,\
		"}" = null,\
		"|" = null,\
		"~" = null,\
		"`" = null,\
		"A" = null,\
		"B" = null,\
		"C" = null,\
		"D" = null,\
		"E" = null,\
		"F" = null,\
		"G" = null,\
		"H" = null,\
		"I" = null,\
		"J" = null,\
		"K" = null,\
		"L" = null,\
		"M" = null,\
		"N" = null,\
		"O" = null,\
		"P" = null,\
		"Q" = null,\
		"R" = null,\
		"S" = null,\
		"T" = null,\
		"U" = null,\
		"V" = null,\
		"W" = null,\
		"X" = null,\
		"Y" = null,\
		"Z" = null,\
		"a" = null,\
		"b" = null,\
		"c" = null,\
		"d" = null,\
		"e" = null,\
		"f" = null,\
		"g" = null,\
		"h" = null,\
		"i" = null,\
		"j" = null,\
		"k" = null,\
		"l" = null,\
		"m" = null,\
		"n" = null,\
		"o" = null,\
		"p" = null,\
		"q" = null,\
		"r" = null,\
		"s" = null,\
		"t" = null,\
		"u" = null,\
		"v" = null,\
		"w" = null,\
		"x" = null,\
		"y" = null,\
		"z" = null,\
		MAX_CHAR_WIDTH = list(0, 0, 0)\
	)
