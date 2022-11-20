
/obj/item/infuser_book
	name = "DNA infusion book"
	desc = "An entire book on how to not turn yourself into a fly mutant."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	worn_icon_state = "book"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	/// A list of all infuser entries
	var/static/list/entries = list()

/obj/item/infuser_book/Initialize(mapload)
	. = ..()
	if(!entries.len)
		prepare_entries()

/obj/item/infuser_book/proc/prepare_entries()
	for(var/datum/infuser_entry/entry_type as anything in typesof(/datum/infuser_entry))
		var/datum/infuser_entry/entry = new entry_type()
		entries += entry

/obj/item/infuser_book/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InfuserBook")
		ui.open()

/obj/item/infuser_book/ui_static_data(mob/user)
	var/list/data = list()
	// Collect all info from each intry.
	var/list/entry_data = list()
	for(var/datum/infuser_entry/entry as anything in entries)
		var/list/individual_entry_data = list()
		individual_entry_data["name"] = entry.name
		individual_entry_data["infuse_mob_name"] = entry.infuse_mob_name
		individual_entry_data["desc"] = entry.desc
		individual_entry_data["threshold_desc"] = entry.threshold_desc
		individual_entry_data["qualities"] = entry.qualities
		entry_data += list(individual_entry_data)
	data["entries"] = entry_data
	return data



/datum/infuser_entry
	//info for the book

	/// name of the mutant you become
	var/name = "Rejected"
	/// what you have to infuse to become it
	var/infuse_mob_name = "rejected creature"
	/// general desc
	var/desc = "For whatever reason, when the body rejects DNA, the DNA goes sour, ending up as some kind of fly-like DNA jumble."
	/// desc of what passing the threshold gets you
	var/threshold_desc = "The DNA mess takes over, and you become a full-fledged flyperson."
	/// various little bits
	var/list/qualities = list(
		"buzzy-like speech",
		"vomit drinking",
		"unidentifiable organs",
		"this is a bad idea",
	)

	//info for the machine

	/// organs that the machine could spit out in relation
	var/list/valid_organs = {

	}

/datum/infuser_entry/rat
	name = "Rat"
	infuse_mob_name = "rodent"
	desc = "Frail, small, positively cheesed to face the world. Easy to stuff yourself full of rat DNA, but perhaps not the best choice?"
	threshold_desc = "You become lithe enough to crawl through ventilation."
	qualities = list(
		"cheesy lines",
		"will eat anything",
		"wants to eat anything, constantly",
		"frail but quick",
	)

/datum/infuser_entry/carp
	name = "Carp"
	infuse_mob_name = "space-cyprinidae"
	desc = "Carp-mutants are very well-prepared for long term deep space exploration. In fact, they can't stand not doing it!"
	threshold_desc = "The DNA mess takes over, and you become a full-fledged flyperson."
	qualities = list(
		"big jaws, big teeth",
		"swim through space, no problem",
		"face every problem when you go back on station",
		"always wants to travel",
	)
