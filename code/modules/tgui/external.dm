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
/atom/movable/proc/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, \
								force_open = 0, datum/tgui/master_ui = null, \
								datum/ui_state/state = default_state)
	return -1 // Sorta implemented.

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
/atom/movable/proc/get_ui_data(mob/user)
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
/atom/movable/proc/ui_act(action, list/params)
	return // Not implemented.


 /**
  * private
  *
  * The UI's host object (usually src_object).
  * Used internally by ui_state(s).
 **/
/atom/proc/ui_host()
	return src

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
/client/verb/uiclose(uiref as text)
	// Name the verb, and hide it from the user panel.
	set name = "uiclose"
	set hidden = 1

	// Get the UI based on the ref.
	var/datum/tgui/ui = locate(uiref)

	// If we found the UI, close it.
	if(istype(ui))
		ui.close()
		// If there is a custom ref, call that atom's Topic().
		if(ui.ref)
			var/href = "close=1"
			src.Topic(href, params2list(href), ui.ref)
		// Otherwise, if we use the legacy logic, unset the mob's machine.
		else if(src && src.mob)
			src.mob.unset_machine()