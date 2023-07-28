/datum/action/item_action/zipper
	name = "Unzip Duffel"
	desc = "Unzip your equipped duffelbag so you can access its contents."

/datum/action/item_action/zipper/New(Target)
	. = ..()
	RegisterSignal(target, COMSIG_DUFFEL_ZIP_CHANGE, PROC_REF(on_zip_change))
	var/obj/item/storage/backpack/duffelbag/duffle_target = target
	on_zip_change(target, duffle_target.zipped_up)

/datum/action/item_action/zipper/proc/on_zip_change(datum/source, new_zip)
	SIGNAL_HANDLER
	if(new_zip)
		name = "Unzip" 
		desc = "Unzip your equipped duffelbag so you can access its contents."
	else
		name = "Zip"
		desc = "Zip your equipped duffelbag so you can move around faster."
	build_all_button_icons(UPDATE_BUTTON_NAME)
