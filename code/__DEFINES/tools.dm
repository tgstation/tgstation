// Tool types, if you add new ones please add them to /obj/item/debug/omnitool in code/game/objects/items/debug_items.dm
#define TOOL_CROWBAR "crowbar"
#define TOOL_MULTITOOL "multitool"
#define TOOL_SCREWDRIVER "screwdriver"
#define TOOL_WIRECUTTER "wirecutter"
#define TOOL_WRENCH "wrench"
#define TOOL_WELDER "welder"
#define TOOL_ANALYZER "analyzer"
#define TOOL_MINING "mining"
#define TOOL_SHOVEL "shovel"
#define TOOL_RETRACTOR "retractor"
#define TOOL_HEMOSTAT "hemostat"
#define TOOL_CAUTERY "cautery"
#define TOOL_DRILL "drill"
#define TOOL_SCALPEL "scalpel"
#define TOOL_SAW "saw"
#define TOOL_BONESET "bonesetter"
#define TOOL_KNIFE "knife"
#define TOOL_BLOODFILTER "bloodfilter"
#define TOOL_ROLLINGPIN "rollingpin"
/// Can be used to scrape rust off an any atom; which will result in the Rust Component being qdel'd
#define TOOL_RUSTSCRAPER "rustscraper"

// If delay between the start and the end of tool operation is less than MIN_TOOL_SOUND_DELAY,
// tool sound is only played when op is started. If not, it's played twice.
#define MIN_TOOL_SOUND_DELAY 20

// tool_act chain flags

/// When a tooltype_act proc is successful
#define TOOL_ACT_TOOLTYPE_SUCCESS (1<<0)
/// When [COMSIG_ATOM_TOOL_ACT] blocks the act
#define TOOL_ACT_SIGNAL_BLOCKING (1<<1)

/// When [TOOL_ACT_TOOLTYPE_SUCCESS] or [TOOL_ACT_SIGNAL_BLOCKING] are set
#define TOOL_ACT_MELEE_CHAIN_BLOCKING (TOOL_ACT_TOOLTYPE_SUCCESS | TOOL_ACT_SIGNAL_BLOCKING)

/// Temperature of the gas released and glove temperature protection required for power tools.
#define TOOL_POWER_HEAT_TEMPERATURE 1000

/// Returns a 75% co2 25% h2o [TOOL_POWER_HEAT_TEMPERATURE] Kelvin gasmixture string. Higher duration increases the amount of gas released. Power tools use this.
#define TOOL_POWER_CONTAMINATE(duration) "co2=[(duration) / 5];water_vapor=[(duration) / 15];TEMP=[TOOL_POWER_HEAT_TEMPERATURE]"

/// The divisor for the damage dealt from using power tools without heat resistant gloves.
#define TOOL_POWER_HEAT_DAMAGE_DIVISOR 5
