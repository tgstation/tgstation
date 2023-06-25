/datum/action/item_action/zipper
	name = "Un-Zip Duffel"
	desc = "Un-Zip the equipped duffelbag so you can root around in it"

/datum/action/item_action/zipper/New(Target)
	. = ..()
	RegisterSignal(target, COMSIG_DUFFEL_ZIP_CHANGE, PROC_REF(on_zip_change))
	var/obj/item/storage/backpack/duffelbag/duffle_target = target
	on_zip_change(target, duffle_target.zipped_up)

/datum/action/item_action/zipper/proc/on_zip_change(datum/source, new_zip)
	SIGNAL_HANDLER
	var/zip = new_zip ? "Un-Zip" : "Zip"
	name = "[zip] Duffel"
	desc = "[zip] the equipped duffelbag so you can root around in it"
	build_all_button_icons(UPDATE_BUTTON_NAME)
