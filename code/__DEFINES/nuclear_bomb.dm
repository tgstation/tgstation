// Nuclear bomb de/construction status
///Pristine condition, no tampering has occurred yet
#define NUKESTATE_INTACT 5
///Front panel has been unscrewed
#define NUKESTATE_UNSCREWED 4
///Front panel has been removed with a crowbar, exposing the reinforced cover
#define NUKESTATE_PANEL_REMOVED 3
///Reinforced cover has been welded, preparing it for removal
#define NUKESTATE_WELDED 2
///Reinforced cover has been removed with a crowbar, revealing the core
#define NUKESTATE_CORE_EXPOSED 1
///Nuke core removed with the special kit
#define NUKESTATE_CORE_REMOVED 0

// Nuclear bomb UI modes
///Device is locked and is awaiting the disk for further operations (additionally shows time left if armed)
#define NUKEUI_AWAIT_DISK 0
///Device is awaiting activation codes input
#define NUKEUI_AWAIT_CODE 1
///Device is awaiting timer input
#define NUKEUI_AWAIT_TIMER 2
///Device is awaiting confirmation of arming process and shows the time set
#define NUKEUI_AWAIT_ARM 3
///Device is counting down to setting off the charge
#define NUKEUI_TIMING 4
///Device is setting off the charge, aka `proc/actually_explode()`
#define NUKEUI_EXPLODED 5

// Nuclear bomb states
///Device has not received activation codes and no timer have been set, all lights are off
#define NUKE_OFF_LOCKED 0
///Device has received activation codes and the timer is set; awaiting arming and the safety warning lights are on
#define NUKE_OFF_UNLOCKED 1
///Device is counting down to setting off the charge, red lights are on
#define NUKE_ON_TIMING 2
///Device is setting off the charge, aka `proc/actually_explode()`, red lights are blinking fast
#define NUKE_ON_EXPLODING 3

// Nuclear bomb detonation statuses
// These line up with roundend reports
#define DETONATION_HIT_STATION STATION_DESTROYED_NUKE
#define DETONATION_HIT_SYNDIE_BASE NUKE_SYNDICATE_BASE
#define DETONATION_NEAR_MISSED_STATION NUKE_NEAR_MISS
#define DETONATION_MISSED_STATION NUKE_MISS_STATION

/// Default code for nukes, intentionally impossible to enter on the UI
#define NUKE_CODE_UNSET "ADMIN"
