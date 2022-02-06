#define ADVENTURE_DIR "[global.config.directory]/adventures/"

//Special preset nodes

/// Victory node - Get loot and exit
#define WIN_NODE "WIN"
/// Failure node - No loot, get damaged and exit.
#define FAIL_NODE "FAIL"
/// Failure node - No loot and drone blown up.
#define FAIL_DEATH_NODE "FAIL_DEATH"
/// Return node - navigates to previous adventure node.
#define GO_BACK_NODE "GO BACK"

//Adventure results
#define ADVENTURE_RESULT_SUCCESS "success"
#define ADVENTURE_RESULT_DAMAGE "damage"
#define ADVENTURE_RESULT_DEATH "death"

// Exploration drone states

/// Drone is stationside - allow changing tools and such.
#define EXODRONE_IDLE "idle"
/// Drone is traveling from or to the exploration site
#define EXODRONE_TRAVEL "travel"
/// Drone is in adventure/event caused timeout
#define EXODRONE_BUSY "busy"
/// Drone is at exploration site either idle or in simple event
#define EXODRONE_EXPLORATION "exploration"
/// Drone is currently playing an adventure
#define EXODRONE_ADVENTURE "adventure"


// Scanner bands, use these to guess what's in the site and prepare drone accordingly.
#define EXOSCANNER_BAND_PLASMA "Plasma absorption band"
#define EXOSCANNER_BAND_LIFE "Hydrocarbons/Molecular oxygen"
#define EXOSCANNER_BAND_TECH "Narrow-band radio waves"
#define EXOSCANNER_BAND_RADIATION "Exotic Radiation"
#define EXOSCANNER_BAND_DENSITY "Increased Density"
// Exodrone tools
#define EXODRONE_TOOL_WELDER "welder"
#define EXODRONE_TOOL_TRANSLATOR "translator"
#define EXODRONE_TOOL_LASER "laser"
#define EXODRONE_TOOL_MULTITOOL "multitool"
#define EXODRONE_TOOL_DRILL "drill"

GLOBAL_LIST_INIT(exodrone_tool_metadata,list(
	EXODRONE_TOOL_WELDER = list("description"="A heavy duty welder.","icon"="burn"),
	EXODRONE_TOOL_TRANSLATOR = list("description"="Powerful translation and data recording software.","icon"="language"),
	EXODRONE_TOOL_LASER = list("description"="Multipurpose tool suitable for combat and precision cutting.","icon"="bolt"),
	EXODRONE_TOOL_MULTITOOL = list("description"="Multipurpose tool for electronics manipulation. Comes with suite of radiation and radiowave sensors.","icon"="broadcast-tower"),
	EXODRONE_TOOL_DRILL = list("description"="Heavy duty drill useful for mining.","icon"="screwdriver")
))

// Site traits

/// Some kind of ruined interior
#define EXPLORATION_SITE_RUINS "ruins"
/// Power, wires and machinery present.
#define EXPLORATION_SITE_TECHNOLOGY "technology present"
/// It's a space station
#define EXPLORATION_SITE_STATION "space station"
/// It's ancient alien site
#define EXPLORATION_SITE_ALIEN "alien"
/// Carbon-based life-forms can live here
#define EXPLORATION_SITE_HABITABLE "habitable"
/// Site is in space
#define EXPLORATION_SITE_SPACE "in space"
/// Site is located on planet/moon/whatever surface
#define EXPLORATION_SITE_SURFACE "on surface"
/// Site is a space ship
#define EXPLORATION_SITE_SHIP "spaceship"
/// Site is civilized and populated, trading stations,cities etc. Lack of this trait means it's wilderness
#define EXPLORATION_SITE_CIVILIZED "civilized"


/// Scan types

// Wide scan, untargeted scan only reveals interest points. Cost increases exponentially with each firing. No scan conditions.
#define EXOSCAN_WIDE "wide"
// Point scan, reveals name/description and general band information. Flat cost. Affected by scan conditions of the site
#define EXOSCAN_POINT "point"
// Deep scan, reveals event scan texts. Linear cost increase with distance. Affected by scan conditions of the site.
#define EXOSCAN_DEEP "deep"

///  Adventure Effect Types

//completely removes the quality
#define ADVENTURE_EFFECT_TYPE_REMOVE "Remove"
//adds/substracts value from quality
#define ADVENTURE_EFFECT_TYPE_ADD "Add"
//sets quality to specific value
#define ADVENTURE_EFFECT_TYPE_SET "Set"

/// Adventure Effect Value Types

/// rolls value between low and high inclusive
#define ADVENTURE_QUALITY_TYPE_RANDOM "random"
#define ADVENTURE_RANDOM_QUALITY_LOW_FIELD "low"
#define ADVENTURE_RANDOM_QUALITY_HIGH_FIELD "high"
