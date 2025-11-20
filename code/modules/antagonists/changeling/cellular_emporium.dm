// Cellular Emporium -
// The place where Changelings go to purchase biological weaponry.
/datum/cellular_emporium
	/// The name of the emporium - why does it need a name? Dunno
	var/name = "cellular emporium"
	/// The changeling who owns this emporium
	var/datum/antagonist/changeling/changeling

/datum/cellular_emporium/New(my_changeling)
	. = ..()
	changeling = my_changeling

/datum/cellular_emporium/Destroy()
	changeling = null
	return ..()

/datum/cellular_emporium/ui_state(mob/user)
	return GLOB.always_state

/datum/cellular_emporium/ui_status(mob/user, datum/ui_state/state)
	if(!changeling)
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/cellular_emporium/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CellularEmporium", name)
		ui.open()

/datum/cellular_emporium/ui_static_data(mob/user)
	var/list/data = list()

	var/static/list/abilities
	if(isnull(abilities))
		abilities = list()
		for(var/datum/action/changeling/ability_path as anything in changeling.all_powers)

			var/dna_cost = initial(ability_path.dna_cost)

			if(dna_cost < 0) // 0 = free, but negatives are invalid
				continue

			var/list/ability_data = list()
			ability_data["name"] = initial(ability_path.name)
			ability_data["desc"] = initial(ability_path.desc)
			ability_data["path"] = ability_path
			ability_data["helptext"] = initial(ability_path.helptext)
			ability_data["genetic_point_required"] = dna_cost
			ability_data["absorbs_required"] = initial(ability_path.req_absorbs) // compares against changeling true_absorbs
			ability_data["dna_required"] = initial(ability_path.req_dna) // compares against changeling absorbed_count

			abilities += list(ability_data)

		// Sorts abilities alphabetically by default
		sortTim(abilities, /proc/cmp_assoc_list_name)

	data["abilities"] = abilities
	return data

/datum/cellular_emporium/ui_data(mob/user)
	var/list/data = list()

	data["can_readapt"] = changeling.can_respec
	data["owned_abilities"] = assoc_to_keys(changeling.purchased_powers)
	data["genetic_points_count"] = changeling.genetic_points
	data["absorb_count"] = changeling.true_absorbs
	data["dna_count"] = changeling.absorbed_count

	return data

/datum/cellular_emporium/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("readapt")
			if(changeling.can_respec)
				changeling.readapt()

		if("evolve")
			// purchase_power sanity checks stuff like typepath, DNA, and absorbs for us.
			changeling.purchase_power(text2path(params["path"]))

	return TRUE

/datum/action/cellular_emporium
	name = "Cellular Emporium"
	button_icon = 'icons/obj/drinks/soda.dmi'
	button_icon_state = "changelingsting"
	background_icon_state = "bg_changeling"
	overlay_icon_state = "bg_changeling_border"
	check_flags = NONE

/datum/action/cellular_emporium/New(Target)
	. = ..()
	if(!istype(Target, /datum/cellular_emporium))
		stack_trace("cellular_emporium action created with non-emporium.")
		qdel(src)

/datum/action/cellular_emporium/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	target.ui_interact(owner)
