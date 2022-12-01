
/obj/item/infuser_book
	name = "DNA infusion book"
	desc = "An entire book on how to not turn yourself into a fly mutant."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	worn_icon_state = "book"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY

/obj/item/infuser_book/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InfuserBook")
		ui.open()

/obj/item/infuser_book/ui_static_data(mob/user)
	var/list/data = list()
	// Collect all info from each intry.
	var/list/entry_data = list()
	for(var/datum/infuser_entry/entry as anything in GLOB.infuser_entries)
		var/list/individual_entry_data = list()
		individual_entry_data["name"] = entry.name
		individual_entry_data["infuse_mob_name"] = entry.infuse_mob_name
		individual_entry_data["desc"] = entry.desc
		individual_entry_data["threshold_desc"] = entry.threshold_desc
		individual_entry_data["qualities"] = entry.qualities
		entry_data += list(individual_entry_data)
	data["entries"] = entry_data
	return data
