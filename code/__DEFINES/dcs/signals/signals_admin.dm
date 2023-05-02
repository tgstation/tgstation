/// Admin helps
/// From /datum/admin_help/RemoveActive().
/// Fired when an adminhelp is made inactive either due to closing or resolving.
#define COMSIG_ADMIN_HELP_MADE_INACTIVE "admin_help_made_inactive"

/// Called on the /datum/admin_help when the player replies. From /client/proc/cmd_admin_pm().
#define COMSIG_ADMIN_HELP_REPLIED "admin_help_replied"

/// Called on a client when a player receives an adminhelp. From /client/proc/receive_ahelp(message)
#define COMSIG_ADMIN_HELP_RECEIVED "admin_help_received"
