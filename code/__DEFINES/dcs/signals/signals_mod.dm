//MODsuit signals
/// Called when a module is selected to be the active one from on_select()
#define COMSIG_MOD_MODULE_SELECTED "mod_module_selected"
/// Called when a MOD activation is called from toggle_activate(mob/user)
#define COMSIG_MOD_ACTIVATE "mod_activate"
	/// Cancels the suit's activation
	#define MOD_CANCEL_ACTIVATE (1 << 0)
/// Called when a MOD is having modules removed from crowbar_act(mob/user, obj/crowbar)
#define COMSIG_MOD_PART_REMOVAL "mod_part_removal"
	/// Cancels the removal of modules
	#define MOD_CANCEL_REMOVAL (1 << 0)
