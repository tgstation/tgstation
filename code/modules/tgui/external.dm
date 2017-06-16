 /**
  * tgui external
  *
  * Contains all external tgui declarations.
 **/

 /**
  * public
  *
  * Used to open and update UIs.
  * If this proc is not implemented properly, the UI will not update correctly.
  *
  * required user mob The mob who opened/is using the UI.
  * optional ui_key string The ui_key of the UI.
  * optional ui datum/tgui The UI to be updated, if it exists.
  * optional force_open bool If the UI should be re-opened instead of updated.
  * optional master_ui datum/tgui The parent UI.
  * optional state datum/ui_state The state used to determine status.
 **/
/datum/proc/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	return -1 // Not implemented.

 /**
  * public
  *
  * Data to be sent to the UI.
  * This must be implemented for a UI to work.
  *
  * required user mob The mob interacting with the UI.
  *
  * return list Data to be sent to the UI.
 **/
/datum/proc/ui_data(mob/user)
	return list() // Not implemented.


 /**
  * public
  *
  * Called on a UI when the UI receieves a href.
  * Think of this as Topic().
  *
  * required action string The action/button that has been invoked by the user.
  * required params list A list of parameters attached to the button.
  *
  * return bool If the UI should be updated or not.
 **/
/datum/proc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(!ui || ui.status != UI_INTERACTIVE)
		return 1 // If UI is not interactive or usr calling Topic is not the UI user, bail.


 /**
  * private
  *
  * The UI's host object (usually src_object).
  * This allows modules/datums to have the UI attached to them,
  * and be a part of another object.
 **/
/datum/proc/ui_host()
	return src // Default src.

 /**
  * global
  *
  * Used to track the current screen.
 **/
/datum/var/ui_screen = "home"

 /**
  * global
  *
  * Used to track UIs for a mob.
 **/
/mob/var/list/open_uis = list()

 /**
  * verb
  *
  * Called by UIs when they are closed.
  * Must be a verb so winset() can call it.
  *
  * required uiref ref The UI that was closed.
 **/
/client/verb/uiclose(ref as text)
	// Name the verb, and hide it from the user panel.
	set name = "uiclose"
	set hidden = 1

	// Get the UI based on the ref.
	var/datum/tgui/ui = locate(ref)

	// If we found the UI, close it.
	if(istype(ui))
		ui.close()
		// Unset machine just to be sure.
		if(src && src.mob)
			src.mob.unset_machine()