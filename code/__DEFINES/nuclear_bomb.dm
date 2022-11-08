// Nuclear bomb de/construction status
#define NUKESTATE_INTACT 5
#define NUKESTATE_UNSCREWED 4
#define NUKESTATE_PANEL_REMOVED 3
#define NUKESTATE_WELDED 2
#define NUKESTATE_CORE_EXPOSED 1
#define NUKESTATE_CORE_REMOVED 0

// Nuclear bomb UI modes
#define NUKEUI_AWAIT_DISK 0
#define NUKEUI_AWAIT_CODE 1
#define NUKEUI_AWAIT_TIMER 2
#define NUKEUI_AWAIT_ARM 3
#define NUKEUI_TIMING 4
#define NUKEUI_EXPLODED 5

// Nuclear bomb states
#define NUKE_OFF_LOCKED 0
#define NUKE_OFF_UNLOCKED 1
#define NUKE_ON_TIMING 2
#define NUKE_ON_EXPLODING 3

// Nuclear bomb detonation statuses
// These line up with roundend reports
#define DETONATION_HIT_STATION STATION_DESTROYED_NUKE
#define DETONATION_HIT_SYNDIE_BASE NUKE_SYNDICATE_BASE
#define DETONATION_NEAR_MISSED_STATION NUKE_NEAR_MISS
#define DETONATION_MISSED_STATION NUKE_MISS_STATION

/// Default code for nukes, intentionally impossible to enter on the UI
#define NUKE_CODE_UNSET "ADMIN"
