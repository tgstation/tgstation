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
	. = ..()

/datum/cellular_emporium/ui_state(mob/user)
	return GLOB.always_state

/datum/cellular_emporium/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CellularEmporium", name)
		ui.open()

/datum/cellular_emporium/ui_data(mob/user)
	var/list/data = list()

	data["can_readapt"] = changeling.can_respec

	var/genetic_points_remaining = changeling.genetic_points
	var/absorbed_dna_count = changeling.absorbed_count
	var/true_absorbs = changeling.trueabsorbs

	data["genetic_points_remaining"] = genetic_points_remaining
	data["absorbed_dna_count"] = absorbed_dna_count

	var/list/abilities = list()

	for(var/datum/action/changeling/ability_path as anything in changeling.all_powers)

		var/dna_cost = initial(ability_path.dna_cost)
		var/req_dna = initial(ability_path.req_dna)
		var/req_absorbs = initial(ability_path.req_absorbs)

		if(dna_cost <= 0)
			continue

		var/list/ability_data = list()
		ability_data["name"] = initial(ability_path.name)
		ability_data["desc"] = initial(ability_path.desc)
		ability_data["path"] = ability_path
		ability_data["helptext"] = initial(ability_path.helptext)
		ability_data["owned"] = is_path_in_list_of_types(ability_path, changeling.purchased_powers)
		ability_data["dna_cost"] = dna_cost
		ability_data["can_purchase"] = ((req_absorbs <= true_absorbs) && (req_dna <= absorbed_dna_count) && (dna_cost <= genetic_points_remaining))

		abilities += list(ability_data)

	data["abilities"] = abilities

	return data

/datum/cellular_emporium/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("readapt")
			if(changeling.can_respec)
				changeling.readapt()
		if("evolve")
			var/sting_path = text2path(params["path"])
			if(!ispath(sting_path, /datum/action/changeling))
				return
			changeling.purchase_power(sting_path)

/datum/action/innate/cellular_emporium
	name = "Cellular Emporium"
	icon_icon = 'icons/obj/drinks.dmi'
	button_icon_state = "changelingsting"
	background_icon_state = "bg_changeling"
	var/datum/cellular_emporium/cellular_emporium

/datum/action/innate/cellular_emporium/New(our_target)
	. = ..()
	button.name = name
	if(istype(our_target, /datum/cellular_emporium))
		cellular_emporium = our_target
	else
		CRASH("cellular_emporium action created with non emporium")

/datum/action/innate/cellular_emporium/Activate()
	cellular_emporium.ui_interact(owner)
