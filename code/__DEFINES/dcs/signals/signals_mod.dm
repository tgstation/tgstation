//MODsuit signals
/// Called when a module is selected to be the active one from on_select()
#define COMSIG_MOD_MODULE_SELECTED "mod_module_selected"
/// Called when a MOD activation is called from toggle_activate(mob/user)
#define COMSIG_MOD_ACTIVATE "mod_activate"
	/// Cancels the suit's activation
	#define MOD_CANCEL_ACTIVATE (1 << 0)
/// Called when a MOD is having modules removed from crowbar_act(mob/user, obj/crowbar)
#define COMSIG_MOD_MODULE_REMOVAL "mod_module_removal"
	/// Cancels the removal of modules
	#define MOD_CANCEL_REMOVAL (1 << 0)
/// Called when a module attempts to activate, however it does. At the end of checks so you can add some yourself, or work on trigger behavior (mob/user)
#define COMSIG_MOD_MODULE_TRIGGERED "mod_module_triggered"
	// Cancels activation, with no message. include feedback on your cancel.
	#define MOD_ABORT_USE (1<<0)
