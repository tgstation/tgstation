/// Does 4 spaces. Used as a makeshift tabulator.
#define FOURSPACES "&nbsp;&nbsp;&nbsp;&nbsp;"

/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/// Prepares a text to be used for maptext, using a font that can handle larger text better.
#define MAPTEXT_VCR_OSD_MONO(text) {"<span style='font-family: \"VCR OSD Mono\"'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc.
/// resolves the MeasureText() return value once, then resolves the height, then sets return_var to that.
#define WXH_TO_HEIGHT(measurement, return_var) \
	do { \
		var/_measurement = measurement; \
		return_var = text2num(copytext(_measurement, findtextEx(_measurement, "x") + 1)); \
	} while(FALSE);

/// Removes characters incompatible with file names.
#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))

/// Simply removes the < and > characters, and limits the length of the message.
#define STRIP_HTML_SIMPLE(text, limit) (GLOB.angular_brackets.Replace(copytext(text, 1, limit), ""))

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
/// File location for hallucination lines
#define HALLUCINATION_FILE "hallucination.json"
/// File location for ninja lines
#define NINJA_FILE "ninja.json"
/// File loation for title splashes
#define SPLASH_FILE "splashes.json"
