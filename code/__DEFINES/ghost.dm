//Ghost orbit types:
/// Ghosts will orbit objects in a circle
#define GHOST_ORBIT_CIRCLE "circle"
/// Ghosts will orbit objects in a triangle
#define GHOST_ORBIT_TRIANGLE "triangle"
/// Ghosts will orbit objects in a hexagon
#define GHOST_ORBIT_HEXAGON "hexagon"
/// Ghosts will orbit objects in a square
#define GHOST_ORBIT_SQUARE "square"
/// Ghosts will orbit objects in a pentagon
#define GHOST_ORBIT_PENTAGON "pentagon"

//Ghost showing preferences:
/// The main player's ghost will display as a simple white ghost
#define GHOST_ACCS_NONE "Стандартные спрайты"
/// The main player's ghost will display as a transparent mob
#define GHOST_ACCS_DIR "Только направленные спрайты"
/// The main player's ghost will display as a transparent mob with clothing
#define GHOST_ACCS_FULL "Полностью с аксессуарами"

/// The default ghost display selection for the main player
#define GHOST_ACCS_DEFAULT_OPTION GHOST_ACCS_FULL

/// The other players ghosts will display as a simple white ghost
#define GHOST_OTHERS_SIMPLE "Белые призраки"
/// The other players ghosts will display as transparent mobs
#define GHOST_OTHERS_DEFAULT_SPRITE "Стандартные спрайты"
/// The other players ghosts will display as transparent mobs with clothing
#define GHOST_OTHERS_THEIR_SETTING "Их спрайты"

/// The default ghost display selection when viewing other players
#define GHOST_OTHERS_DEFAULT_OPTION GHOST_OTHERS_THEIR_SETTING

/// A ghosts min view range that we won't allow them to go under by.
#define GHOST_MIN_VIEW_RANGE 7
/// A ghosts max view range if they are a BYOND guest or regular account
#define GHOST_MAX_VIEW_RANGE_DEFAULT 10
/// A ghosts max view range if they are a BYOND paid member account (P2W feature)
#define GHOST_MAX_VIEW_RANGE_MEMBER 14

// DEADCHAT MESSAGE TYPES //
/// Deadchat notification for important round events (RED_ALERT, shuttle EVAC, communication announcements, etc.)
#define DEADCHAT_ANNOUNCEMENT "announcement"
/// Deadchat notification for new players who join the round at arrivals
#define DEADCHAT_ARRIVALRATTLE "arrivalrattle"
/// Deadchat notification for players who die during the round
#define DEADCHAT_DEATHRATTLE "deathrattle"
/// Deadchat notification for when there is an AI law change
#define DEADCHAT_LAWCHANGE "lawchange"
/// Deadchat notification for when players enter/leave the server (ignores stealth admins)
#define DEADCHAT_LOGIN_LOGOUT "loginlogout"
/// Deadchat regular ghost chat
#define DEADCHAT_REGULAR "regular-deadchat"

/// Pictures taken by a camera will not display ghosts
#define CAMERA_NO_GHOSTS 0
/// Pictures taken by a camera will display ghosts in the photo
#define CAMERA_SEE_GHOSTS_BASIC 1
/// Pictures taken by a camera will display ghosts and their orbits
#define CAMERA_SEE_GHOSTS_ORBIT 2 // this doesn't do anything right now as of Jan 2022


#define GHOST_DATA_HUDS (1<<0)
#define GHOST_VISION (1<<1)
#define GHOST_HEALTH (1<<2)
#define GHOST_CHEM (1<<3)
#define GHOST_GAS (1<<4)
/// Represents tray view. Not a real view flag, as tray is not persistent, but used as an identifier for one.
#define GHOST_TRAY (1<<5)
/// Repesents darkness level setting. Not a real view flag, as darkness level cycles through values, but used as an identifier for one.
#define GHOST_DARKNESS_LEVEL (1<<6)

#define ALL_GHOST_FLAGS list( \
	GHOST_DATA_HUDS, \
	GHOST_VISION, \
	GHOST_HEALTH, \
	GHOST_CHEM, \
	GHOST_GAS, \
)
