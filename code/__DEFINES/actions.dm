///Action button checks if hands are unusable
#define AB_CHECK_HANDS_BLOCKED (1<<0)
///Action button checks if user is immobile
#define AB_CHECK_IMMOBILE (1<<1)
///Action button checks if user is resting
#define AB_CHECK_LYING (1<<2)
///Action button checks if user is conscious
#define AB_CHECK_CONSCIOUS (1<<3)

///Action button triggered with right click
#define TRIGGER_SECONDARY_ACTION (1<<0)

// Defines for formatting cooldown actions for the stat panel.
/// The stat panel the action is displayed in.
#define PANEL_DISPLAY_PANEL "panel"
/// The status shown in the stat panel.
/// Can be stuff like "ready", "on cooldown", "active", "charges", "charge cost", etc.
#define PANEL_DISPLAY_STATUS "status"
/// The name shown in the stat panel.
#define PANEL_DISPLAY_NAME "name"
