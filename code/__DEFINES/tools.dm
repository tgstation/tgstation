// Tool types, if you add new ones please add them to /obj/item/debug/omnitool in code/game/objects/items/debug_items.dm
#define TOOL_CROWBAR 		"crowbar"
#define TOOL_MULTITOOL 		"multitool"
#define TOOL_SCREWDRIVER 	"screwdriver"
#define TOOL_WIRECUTTER 	"wirecutter"
#define TOOL_WRENCH 		"wrench"
#define TOOL_WELDER 		"welder"
#define TOOL_ANALYZER		"analyzer"
#define TOOL_MINING			"mining"
#define TOOL_SHOVEL			"shovel"
#define TOOL_RETRACTOR	 	"retractor"
#define TOOL_HEMOSTAT 		"hemostat"
#define TOOL_CAUTERY 		"cautery"
#define TOOL_DRILL			"drill"
#define TOOL_SCALPEL		"scalpel"
#define TOOL_SAW			"saw"
#define TOOL_BONESET		"bonesetter"
#define TOOL_KNIFE			"knife"
#define TOOL_BLOODFILTER	"bloodfilter"
#define TOOL_ROLLINGPIN		"rollingpin"

// If delay between the start and the end of tool operation is less than MIN_TOOL_SOUND_DELAY,
// tool sound is only played when op is started. If not, it's played twice.
#define MIN_TOOL_SOUND_DELAY 20
