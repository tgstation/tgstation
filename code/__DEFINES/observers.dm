// Various flags for notify_ghosts ghost popups.
/// Determines if the notification will not run if called during mapload.
#define GHOST_NOTIFY_IGNORE_MAPLOAD (1<<0)
/// Determines if the notification will flash the Byond window.
#define GHOST_NOTIFY_FLASH_WINDOW (1<<1)
/// Determines if the notification will notify suiciders.
#define GHOST_NOTIFY_NOTIFY_SUICIDERS (1<<2)

/// The default set of flags to be passed into a notify_ghosts call.
#define NOTIFY_CATEGORY_DEFAULT (GHOST_NOTIFY_FLASH_WINDOW | GHOST_NOTIFY_IGNORE_MAPLOAD | GHOST_NOTIFY_NOTIFY_SUICIDERS)
/// The default set of flags, without the flash_window flag.
#define NOTIFY_CATEGORY_NOFLASH (NOTIFY_CATEGORY_DEFAULT & ~GHOST_NOTIFY_FLASH_WINDOW)

///Assoc List of types of ghost lightings & the player-facing name.
GLOBAL_LIST_INIT(ghost_lightings, list(
	"Стандартное" = LIGHTING_CUTOFF_VISIBLE,
	"Темнее" = LIGHTING_CUTOFF_MEDIUM,
	"Ночное зрение" = LIGHTING_CUTOFF_HIGH,
	"Полное освещение" = LIGHTING_CUTOFF_FULLBRIGHT,
))
