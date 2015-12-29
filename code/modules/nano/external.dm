 /**
  * NanoUI External
  *
  * Contains all external NanoUI declarations.
  *
  * /tg/station user interface library
  * thanks to baystation12
  *
  * modified by neersighted
 **/

 /**
  * public
  *
  * Used to open and update NanoUIs.
  * If this proc is not implemented properly, the NanoUI will not update correctly.
  *
  * required user mob The mob who opened/is using the NanoUI.
  * optional ui_key string The ui_key of the NanoUI.
  * optional ui datum/nanoui The UI to be updated, if it exists.
  * optional force_open bool If the UI should be re-opened instead of updated.
  * optional master_ui datum/nanoui The parent NanoUI.
  * optional state datum/nano_state The state used to determine status.
 **/
/atom/movable/proc/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, \
								force_open = 0, datum/nano_ui/master_ui = null, \
								datum/nano_state/state = default_state)
	return -1 // Sorta implemented.

 /**
  * public
  *
  * Data to be sent to the NanoUI.
  * This must be implemented for a NanoUI to work.
  *
  * required user mob The mob interacting with the NanoUI.
  *
  * return list Data to be sent to the NanoUI.
 **/
/atom/movable/proc/get_ui_data(mob/user)
	return list() // Not implemented.


 /**
  * public
  *
  * Called on a NanoUI when the UI receieves a href.
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
  * The NanoUI's host object (usually src_object).
  * Used internally by nano_state(s).
 **/
/atom/proc/nano_host()
	return src

 /**
  * global
  *
  * Used to track NanoUIs for a mob.
 **/
/mob/var/list/open_uis = list()

 /**
  * verb
  *
  * Called by NanoUIs when they are closed.
  * Must be a verb so winset() can call it.
  *
  * required uiref ref The UI that was closed.
 **/
/client/verb/nanoclose(uiref as text)
	// Name the verb, and hide it from the user panel.
	set name = "nanoclose"
	set hidden = 1

	// Get the UI based on the ref.
	var/datum/nanoui/ui = locate(uiref)

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