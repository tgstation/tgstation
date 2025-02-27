
/datum/antagonist/traitor/on_gain()
	. = ..()

	var/datum/antag_faction/faction_choice
	var/datum/antag_faction/faction

	while (!faction) // spin up a thing so people can choose what they want
		faction_choice = query_antag_faction_choice(src, owner.current)

		if (!faction_choice)
			return

		if (faction_choice.type == /datum/antag_faction/none)
			return

		to_chat(owner.current, span_boldbig(faction_choice.name))
		to_chat(owner.current, span_boldnotice(faction_choice.description))
		to_chat(owner.current, span_notice("You will gain access to the following extra items/features:"))
		for (var/datum/antag_faction_item/special_item as anything in subtypesof(/datum/antag_faction_item))
			if (special_item.item && special_item.faction == faction_choice.type)
				to_chat(owner.current, span_notice(" - [special_item.name] ([special_item.cost] TC)"))
		if (faction_choice.bonus_tc)
			to_chat(owner.current, span_notice(" - [faction_choice.bonus_tc] extra TC"))

		var/list/confirms = list("Yes", "No")
		var/confirm = tgui_input_list(owner.current, "Is this the faction you want to represent?", "Faction", confirms)
		if (confirm == "Yes")
			faction = faction_choice

	if (faction.entry_line)
		to_chat(owner.current, faction.entry_line) // send them some delectable flavor to let them know what's what

	if (src.type in faction.antagonist_types)
		// apply the TC adjustment
		uplink_handler.telecrystals += faction.bonus_tc
		// add our bespoke items to the uplink
		for (var/datum/antag_faction_item/item_path as anything in subtypesof(/datum/antag_faction_item))
			var/datum/antag_faction_item/faction_item = new item_path()
			if (faction_item.item && faction_item.faction == faction.type)
				uplink_handler.extra_purchasable += faction_item.get_uplink_item()

/proc/query_antag_faction_choice(datum/source, mob/chooser)
	var/list/factions = list()
	for (var/datum/antag_faction/a_faction in GLOB.antag_factions)
		factions += a_faction

	var/datum/antag_faction/faction = tgui_input_list(chooser, "Choose your faction", "Factions", sort_names(factions))

	if (QDELETED(source) || QDELETED(chooser) || QDELETED(faction))
		return

	return faction
