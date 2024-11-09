/// Sent from /datum/hud/proc/on_eye_change(): (atom/old_eye, atom/new_eye)
#define COMSIG_HUD_EYE_CHANGED "hud_eye_changed"
/// Sent from /datum/hud/proc/eye_z_changed() : (new_z)
#define COMSIG_HUD_Z_CHANGED "hud_z_changed"
/// Sent from /datum/hud/proc/eye_z_changed() : (old_offset, new_offset)
#define COMSIG_HUD_OFFSET_CHANGED "hud_offset_changed"
/// Sent from /atom/movable/screen/lobby/button/collapse/proc/collapse_buttons() : ()
#define COMSIG_HUD_LOBBY_COLLAPSED "hud_lobby_collapsed"
/// Sent from /atom/movable/screen/lobby/button/collapse/proc/expand_buttons() : ()
#define COMSIG_HUD_LOBBY_EXPANDED "hud_lobby_expanded"
/// Sent from /atom/movable/screen/lobby/button/ready/Click() : ()
#define COMSIG_HUD_PLAYER_READY_TOGGLE "hud_player_ready_toggle"
