/obj/item/stock_parts/capacitor/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_ITEM_ATTACK_OBJ, PROC_REF(install_polarization_controller))


/**
 * Handles installing the capacitor in the window, to provide it with some
 * polarization functionalities.
 */
/obj/item/stock_parts/capacitor/proc/install_polarization_controller(datum/source, obj/structure/window/target, mob/user)
	SIGNAL_HANDLER

	if(!istype(target))
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN // Just to reduce the unnecessary repetition at every early return.

	var/datum/component/polarization_controller/window_polarization_controller = target.GetComponent(/datum/component/polarization_controller)

	if(window_polarization_controller)
		balloon_alert(user, "polarization controller already installed!")
		return

	target.AddComponent(/datum/component/polarization_controller, src) // No need to do anything else, the component will handle moving the capacitor into the window.

	target.balloon_alert(user, "polarization controller installed")
