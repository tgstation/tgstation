//MODsuit signals
/// Called when a module is selected to be the active one from on_select()
#define COMSIG_MOD_MODULE_SELECTED "mod_module_selected"
/// Called when a MOD activation is called from toggle_activate(mob/user)
#define COMSIG_MOD_ACTIVATE "mod_activate"
	/// Cancels the suit's activation
	#define MOD_CANCEL_ACTIVATE (1 << 0)
