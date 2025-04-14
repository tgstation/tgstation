/obj/machinery/chem_dispenser
	name = "chem dispenser"
	desc = "Creates and dispenses chemicals."
	density = TRUE
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "dispenser"
	base_icon_state = "dispenser"
	interaction_flags_machine = INTERACT_MACHINE_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OFFLINE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_dispenser
	processing_flags = NONE

	/// The cell used to dispense reagents
	var/obj/item/stock_parts/power_store/cell
	/// Efficiency used when converting cell power to reagents. Joule per volume.
	var/power_cost = 0.1 KILO WATTS
	/// The current amount this machine is dispensing
	var/amount = 30
	/// The rate at which this machine recharges the power cell.
	var/recharge_amount = 0.3 KILO WATTS
	/// The temperature reagents are dispensed into the beaker
	var/dispensed_temperature = DEFAULT_REAGENT_TEMPERATURE
	/// If the UI has the pH meter shown
	var/show_ph = TRUE
	/// The overlay used to display the beaker on the machine
	var/mutable_appearance/beaker_overlay
	/// Icon to display when the machine is powered
	var/working_state = "dispenser_working"
	/// Icon to display when the machine is not powered
	var/nopower_state = "dispenser_nopower"
	/// Should we display the open panel overlay when the panel is opened with a screwdriver
	var/has_panel_overlay = TRUE
	/// The actual beaker inserted into this machine
	var/obj/item/reagent_containers/beaker = null
	/// Dispensable_reagents is copypasted in plumbing synthesizers. Please update accordingly. (I didn't make it global because that would limit custom chem dispensers)
	var/list/dispensable_reagents = list()
	/// These become available once the manipulator has been upgraded to tier 4 (femto)
	var/list/upgrade_reagents = list()
	/// These become available once the machine has been emaged
	var/list/emagged_reagents = list()
	/// Starting purity of the created reagents
	var/base_reagent_purity = 1
	/// Records the reagents dispensed by the user if this list is not null
	var/list/recording_recipe
	/// Saves all the recipes recorded by the machine
	var/list/saved_recipes = list()

	/// The default list of dispensable_reagents
	var/static/list/default_dispensable_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel
	)
	/// The default list of reagents upgrade_reagents
	var/static/list/default_upgrade_reagents = list(
		/datum/reagent/acetone,
		/datum/reagent/ammonia,
		/datum/reagent/ash,
		/datum/reagent/diethylamine,
		/datum/reagent/fuel/oil,
		/datum/reagent/saltpetre
	)
	/// The default list of reagents emagged_reagents
	var/static/list/default_emagged_reagents = list(
		/datum/reagent/toxin/carpotoxin,
		/datum/reagent/medicine/mine_salve,
		/datum/reagent/medicine/morphine,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/toxin
	)
/obj/machinery/chem_dispenser/Initialize(mapload)
	if(dispensable_reagents != null && !dispensable_reagents.len)
		dispensable_reagents = default_dispensable_reagents
	if(dispensable_reagents)
		dispensable_reagents = sort_list(dispensable_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))

	if(upgrade_reagents != null && !upgrade_reagents.len)
		upgrade_reagents = default_upgrade_reagents
	if(upgrade_reagents)
		upgrade_reagents = sort_list(upgrade_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))

	if(emagged_reagents != null && !emagged_reagents.len)
		emagged_reagents = default_emagged_reagents
	if(emagged_reagents)
		emagged_reagents = sort_list(emagged_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))

	. = ..() // So that we call RefreshParts() after adjusting the lists

	if(is_operational)
		begin_processing()
	update_appearance()

/obj/machinery/chem_dispenser/Destroy()
	cell = null
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_dispenser/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("[src]'s maintenance hatch is open!")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:\n\
		Recharge rate: <b>[display_power(recharge_amount, convert = FALSE)]</b>.\n\
		Energy cost: <b>[siunit(power_cost, "J/u", 3)]</b>.")
	. += span_notice("Use <b>RMB</b> to eject a stored beaker.")

/obj/machinery/chem_dispenser/on_set_is_operational(old_value)
	if(old_value) //Turned off
		end_processing()
	else //Turned on
		begin_processing()

/obj/machinery/chem_dispenser/process(seconds_per_tick)
	if(cell.maxcharge == cell.charge)
		return
	use_energy(active_power_usage * seconds_per_tick) //Additional power cost before charging the cell.
	charge_cell(recharge_amount * seconds_per_tick, cell) //This also costs power.


/obj/machinery/chem_dispenser/proc/display_beaker()
	var/mutable_appearance/b_o = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	b_o.pixel_w = -7
	b_o.pixel_z = -4
	return b_o

/obj/machinery/chem_dispenser/proc/work_animation()
	if(working_state)
		flick(working_state,src)

/obj/machinery/chem_dispenser/update_icon_state()
	icon_state = "[(nopower_state && !powered()) ? nopower_state : base_icon_state]"
	return ..()

/obj/machinery/chem_dispenser/update_overlays()
	. = ..()
	if(has_panel_overlay && panel_open)
		. += mutable_appearance(icon, "[base_icon_state]_panel-o")

	if(beaker)
		beaker_overlay = display_beaker()
		. += beaker_overlay

/obj/machinery/chem_dispenser/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		balloon_alert(user, "already emagged!")
		return FALSE
	balloon_alert(user, "safeties shorted out")
	dispensable_reagents |= emagged_reagents//add the emagged reagents to the dispensable ones
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/chem_dispenser/ex_act(severity, target)
	return severity <= EXPLODE_LIGHT ? FALSE : ..()

/obj/machinery/chem_dispenser/contents_explosion(severity, target)
	. = ..()
	if(!beaker)
		return

	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += beaker
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += beaker
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += beaker

/obj/machinery/chem_dispenser/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker)
		beaker = null
		cut_overlays()

/obj/machinery/chem_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDispenser", name)
		ui.open()

	var/is_hallucinating = FALSE
	if(isliving(user))
		var/mob/living/living_user = user
		is_hallucinating = !!living_user.has_status_effect(/datum/status_effect/hallucination)
	ui.set_autoupdate(!is_hallucinating) //to not ruin the immersion by constantly changing the fake chemicals

/obj/machinery/chem_dispenser/ui_data(mob/user)
	. = list()
	.["amount"] = amount
	.["energy"] = cell.charge ? cell.charge : 0 //To prevent NaN in the UI.
	.["maxEnergy"] = cell.maxcharge
	.["displayedUnits"] = cell.charge ? (cell.charge / power_cost) : 0
	.["displayedMaxUnits"] = cell.maxcharge / power_cost
	.["showpH"] = isnull(recording_recipe) ? show_ph : FALSE //virtual beakers have no ph to compute & display

	var/list/chemicals = list()
	var/is_hallucinating = FALSE
	if(isliving(user))
		var/mob/living/living_user = user
		is_hallucinating = !!living_user.has_status_effect(/datum/status_effect/hallucination)

	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			var/chemname = temp.name
			var/chemcolor = temp.color
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
				chemcolor = random_colour()
			chemicals += list(list("title" = chemname, "id" = temp.name, "pH" = temp.ph, "color" = chemcolor, "pHCol" = convert_ph_to_readable_color(temp.ph)))
	.["chemicals"] = chemicals
	.["recipes"] = saved_recipes

	.["recordingRecipe"] = recording_recipe
	.["recipeReagents"] = list()
	if(beaker?.reagents.ui_reaction_id)
		var/datum/chemical_reaction/reaction = get_chemical_reaction(beaker.reagents.ui_reaction_id)
		for(var/_reagent in reaction.required_reagents)
			var/datum/reagent/reagent = find_reagent_object_from_type(_reagent)
			.["recipeReagents"] += reagent.name

	var/list/beaker_data = null
	if(!QDELETED(beaker))
		beaker_data = list()
		beaker_data["maxVolume"] = beaker.volume
		beaker_data["transferAmounts"] = beaker.possible_transfer_amounts
		beaker_data["pH"] = round(beaker.reagents.ph, 0.01)
		beaker_data["currentVolume"] = round(beaker.reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)
		var/list/beakerContents = list()
		if(length(beaker.reagents.reagent_list))
			for(var/datum/reagent/reagent as anything in beaker.reagents.reagent_list)
				beakerContents += list(list("name" = reagent.name, "volume" = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING))) // list in a list because Byond merges the first list...
		beaker_data["contents"] = beakerContents
	.["beaker"] = beaker_data

/obj/machinery/chem_dispenser/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("amount")
			if(!is_operational || QDELETED(beaker))
				return
			var/target = text2num(params["target"])
			if(target in beaker.possible_transfer_amounts)
				amount = target
				work_animation()
				return TRUE

		if("dispense")
			if(!is_operational || QDELETED(cell))
				return
			var/reagent_name = params["reagent"]
			if(!recording_recipe)
				var/reagent = GLOB.name2reagent[reagent_name]
				if(beaker && dispensable_reagents.Find(reagent))

					var/datum/reagents/holder = beaker.reagents
					var/to_dispense = max(0, min(amount, holder.maximum_volume - holder.total_volume))
					if(!to_dispense)
						say("The container is full!")
						return
					if(!cell.use(to_dispense * power_cost))
						say("Not enough energy to complete operation!")
						return
					holder.add_reagent(reagent, to_dispense, reagtemp = dispensed_temperature, added_purity = base_reagent_purity)

					work_animation()
			else
				recording_recipe[reagent_name] += amount
			return TRUE

		if("remove")
			if(!is_operational || recording_recipe)
				return
			var/amount = text2num(params["amount"])
			if(beaker && (amount in beaker.possible_transfer_amounts))
				beaker.reagents.remove_all(amount)
				work_animation()
				return TRUE

		if("eject")
			replace_beaker(ui.user)
			return TRUE

		if("dispense_recipe")
			if(!is_operational || QDELETED(cell))
				return

			var/list/chemicals_to_dispense = saved_recipes[params["recipe"]]
			if(!LAZYLEN(chemicals_to_dispense))
				return
			for(var/key in chemicals_to_dispense)
				var/reagent = GLOB.name2reagent[key]
				var/dispense_amount = chemicals_to_dispense[key]
				if(!dispensable_reagents.Find(reagent))
					return
				if(!recording_recipe)
					if(!beaker)
						return

					var/datum/reagents/holder = beaker.reagents
					var/to_dispense = max(0, min(dispense_amount, holder.maximum_volume - holder.total_volume))
					if(!to_dispense)
						continue
					if(!cell.use(to_dispense * power_cost))
						say("Not enough energy to complete operation!")
						return
					holder.add_reagent(reagent, to_dispense, reagtemp = dispensed_temperature, added_purity = base_reagent_purity)
					work_animation()
				else
					recording_recipe[key] += dispense_amount
			return TRUE

		if("clear_recipes")
			if(is_operational && tgui_alert(ui.user, "Clear all recipes?", "Clear?", list("Yes", "No")) == "Yes")
				saved_recipes = list()
				return TRUE

		if("record_recipe")
			if(is_operational)
				recording_recipe = list()
				return TRUE

		if("save_recording")
			if(!is_operational)
				return
			var/name = tgui_input_text(ui.user, "What do you want to name this recipe?", "Recipe Name", max_length = MAX_NAME_LEN)
			if(!ui.user.can_perform_action(src, ALLOW_SILICON_REACH))
				return
			if(saved_recipes[name] && tgui_alert(ui.user, "\"[name]\" already exists, do you want to overwrite it?",, list("Yes", "No")) == "No")
				return
			if(name && recording_recipe)
				for(var/reagent in recording_recipe)
					var/reagent_id = GLOB.name2reagent[reagent]
					if(!dispensable_reagents.Find(reagent_id))
						visible_message(span_warning("[src] buzzes."), span_hear("You hear a faint buzz."))
						to_chat(ui.user, span_warning("[src] cannot find <b>[reagent]</b>!"))
						playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
						return
				saved_recipes[name] = recording_recipe
				recording_recipe = null
				return TRUE

		if("cancel_recording")
			if(is_operational)
				recording_recipe = null
				return TRUE

		if("reaction_lookup")
			if(beaker)
				beaker.reagents.ui_interact(ui.user)

	var/result = handle_ui_act(action, params, ui, state)
	if(isnull(result))
		result = FALSE
	return result

/// Same as ui_act() but to be used by subtypes exclusively
/obj/machinery/chem_dispenser/proc/handle_ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	return null

/obj/machinery/chem_dispenser/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/chem_dispenser/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/chem_dispenser/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/chem_dispenser/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(is_reagent_container(tool) && !(tool.item_flags & ABSTRACT) && tool.is_open_container())
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		replace_beaker(user, tool)
		ui_interact(user)
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/chem_dispenser/get_cell()
	return cell

/obj/machinery/chem_dispenser/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/list/datum/reagents/R = list()
	var/total = min(rand(7,15), FLOOR(cell.charge*INVERSE(power_cost), 1))
	var/datum/reagents/Q = new(total*10)
	if(beaker?.reagents)
		R += beaker.reagents
	for(var/i in 1 to total)
		Q.add_reagent(pick(dispensable_reagents), 10, reagtemp = dispensed_temperature, added_purity = base_reagent_purity)
	R += Q
	chem_splash(get_turf(src), null, 3, R)
	if(beaker?.reagents)
		beaker.reagents.remove_all()
	cell.use(total * power_cost)
	cell.emp_act(severity)
	work_animation()
	visible_message(span_danger("[src] malfunctions, spraying chemicals everywhere!"))

/obj/machinery/chem_dispenser/RefreshParts()
	. = ..()
	recharge_amount = initial(recharge_amount)
	var/new_power_cost = initial(power_cost)
	var/parts_rating = 0
	for(var/obj/item/stock_parts/power_store/stock_cell in component_parts)
		cell = stock_cell
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		new_power_cost -= (matter_bin.tier * 0.25 KILO WATTS)
		parts_rating += matter_bin.tier
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		recharge_amount *= capacitor.tier
		parts_rating += capacitor.tier
	for(var/datum/stock_part/servo/servo in component_parts)
		if (servo.tier > 3)
			dispensable_reagents |= upgrade_reagents
		else
			dispensable_reagents -= upgrade_reagents
		parts_rating += servo.tier
	power_cost = max(new_power_cost, 0.1 KILO WATTS)

/obj/machinery/chem_dispenser/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		try_put_in_hand(beaker, user)
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	update_appearance()
	return TRUE

/obj/machinery/chem_dispenser/on_deconstruction(disassembled)
	cell = null
	if(beaker)
		beaker.forceMove(drop_location())
		beaker = null
	return ..()

/obj/machinery/chem_dispenser/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH|FORBID_TELEKINESIS_REACH))
		return
	replace_beaker(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/chem_dispenser/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/chem_dispenser/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)


/obj/machinery/chem_dispenser/drinks
	name = "soda dispenser"
	desc = "Contains a large reservoir of soft drinks."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "soda_dispenser"
	base_icon_state = "soda_dispenser"
	has_panel_overlay = FALSE
	dispensed_temperature = WATER_MATTERSTATE_CHANGE_TEMP // magical mystery temperature of 274.5, where ice does not melt, and water does not freeze
	amount = 10
	anchored_tabletop_offset = 6
	circuit = /obj/item/circuitboard/machine/chem_dispenser/drinks
	working_state = null
	nopower_state = null
	pass_flags = PASSTABLE
	show_ph = FALSE
	/// The default list of reagents dispensable by the soda dispenser
	var/static/list/drinks_dispensable_reagents = list(
		/datum/reagent/consumable/coffee,
		/datum/reagent/consumable/space_cola,
		/datum/reagent/consumable/cream,
		/datum/reagent/consumable/dr_gibb,
		/datum/reagent/consumable/grenadine,
		/datum/reagent/consumable/ice,
		/datum/reagent/consumable/icetea,
		/datum/reagent/consumable/lemonjuice,
		/datum/reagent/consumable/lemon_lime,
		/datum/reagent/consumable/limejuice,
		/datum/reagent/consumable/melon_soda,
		/datum/reagent/consumable/menthol,
		/datum/reagent/consumable/orangejuice,
		/datum/reagent/consumable/pineapplejuice,
		/datum/reagent/consumable/pwr_game,
		/datum/reagent/consumable/shamblers,
		/datum/reagent/consumable/spacemountainwind,
		/datum/reagent/consumable/sodawater,
		/datum/reagent/consumable/sol_dry,
		/datum/reagent/consumable/space_up,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/tea,
		/datum/reagent/consumable/tomatojuice,
		/datum/reagent/consumable/tonic,
		/datum/reagent/water,
	)
	upgrade_reagents = null
	/// The default list of emagged reagents dispensable by the soda dispenser
	var/static/list/drink_emagged_reagents = list(
		/datum/reagent/consumable/ethanol/thirteenloko,
		/datum/reagent/consumable/ethanol/whiskey_cola,
		/datum/reagent/toxin/mindbreaker,
		/datum/reagent/toxin/staminatoxin
	)
	base_reagent_purity = 0.5

/obj/machinery/chem_dispenser/drinks/Initialize(mapload)
	if(dispensable_reagents != null && !dispensable_reagents.len)
		dispensable_reagents = drinks_dispensable_reagents
	if(emagged_reagents != null && !emagged_reagents.len)
		emagged_reagents = drink_emagged_reagents
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/chem_dispenser/drinks/setDir()
	var/old = dir
	. = ..()
	if(dir != old)
		update_appearance()  // the beaker needs to be re-positioned if we rotate

/obj/machinery/chem_dispenser/drinks/display_beaker()
	var/mutable_appearance/b_o = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	switch(dir)
		if(NORTH)
			b_o.pixel_w = rand(-9, 9)
			b_o.pixel_z = 7
		if(EAST)
			b_o.pixel_w = 4
			b_o.pixel_z = rand(-5, 7)
		if(WEST)
			b_o.pixel_w = -5
			b_o.pixel_z = rand(-5, 7)
		else//SOUTH
			b_o.pixel_w = rand(-9, 9)
			b_o.pixel_z = -7
	return b_o

/obj/machinery/chem_dispenser/drinks/fullupgrade //fully ugpraded stock parts, emagged
	desc = "Contains a large reservoir of soft drinks. This model has had its safeties shorted out."
	obj_flags = CAN_BE_HIT | EMAGGED
	circuit = /obj/item/circuitboard/machine/chem_dispenser/drinks/fullupgrade

/obj/machinery/chem_dispenser/drinks/fullupgrade/Initialize(mapload)
	. = ..()
	dispensable_reagents |= emagged_reagents //adds emagged reagents

/obj/machinery/chem_dispenser/drinks/beer
	name = "booze dispenser"
	desc = "Contains a large reservoir of the good stuff."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "booze_dispenser"
	base_icon_state = "booze_dispenser"
	dispensed_temperature = WATER_MATTERSTATE_CHANGE_TEMP
	circuit = /obj/item/circuitboard/machine/chem_dispenser/drinks/beer
	/// The default list of reagents dispensable by the beer dispenser
	var/static/list/beer_dispensable_reagents = list(
		/datum/reagent/consumable/ethanol/absinthe,
		/datum/reagent/consumable/ethanol/ale,
		/datum/reagent/consumable/ethanol/applejack,
		/datum/reagent/consumable/ethanol/beer,
		/datum/reagent/consumable/ethanol/coconut_rum,
		/datum/reagent/consumable/ethanol/cognac,
		/datum/reagent/consumable/ethanol/creme_de_cacao,
		/datum/reagent/consumable/ethanol/creme_de_coconut,
		/datum/reagent/consumable/ethanol/creme_de_menthe,
		/datum/reagent/consumable/ethanol/curacao,
		/datum/reagent/consumable/ethanol/gin,
		/datum/reagent/consumable/ethanol/hcider,
		/datum/reagent/consumable/ethanol/kahlua,
		/datum/reagent/consumable/ethanol/beer/maltliquor,
		/datum/reagent/consumable/ethanol/navy_rum,
		/datum/reagent/consumable/ethanol/rice_beer,
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/consumable/ethanol/sake,
		/datum/reagent/consumable/ethanol/tequila,
		/datum/reagent/consumable/ethanol/triple_sec,
		/datum/reagent/consumable/ethanol/vermouth,
		/datum/reagent/consumable/ethanol/vodka,
		/datum/reagent/consumable/ethanol/whiskey,
		/datum/reagent/consumable/ethanol/wine,
		/datum/reagent/consumable/ethanol/yuyake,
	)
	upgrade_reagents = null
	/// The default list of emagged reagents dispensable by the beer dispenser
	var/static/list/beer_emagged_reagents = list(
		/datum/reagent/consumable/ethanol,
		/datum/reagent/iron,
		/datum/reagent/consumable/mintextract,
		/datum/reagent/consumable/ethanol/atomicbomb,
		/datum/reagent/consumable/ethanol/fernet
	)

/obj/machinery/chem_dispenser/drinks/beer/Initialize(mapload)
	dispensable_reagents = beer_dispensable_reagents
	emagged_reagents = beer_emagged_reagents
	. = ..()

/obj/machinery/chem_dispenser/drinks/beer/fullupgrade //fully ugpraded stock parts, emagged
	desc = "Contains a large reservoir of the good stuff. This model has had its safeties shorted out."
	obj_flags = CAN_BE_HIT | EMAGGED
	circuit = /obj/item/circuitboard/machine/chem_dispenser/drinks/beer/fullupgrade

/obj/machinery/chem_dispenser/drinks/beer/fullupgrade/Initialize(mapload)
	. = ..()
	dispensable_reagents |= emagged_reagents //adds emagged reagents

/obj/machinery/chem_dispenser/mutagen
	name = "mutagen dispenser"
	desc = "Creates and dispenses mutagen."
	/// The default list of reagents dispensable by mutagen chem dispenser
	var/static/list/mutagen_dispensable_reagents = list(/datum/reagent/toxin/mutagen)
	upgrade_reagents = null
	/// The default list of emagged reagents dispensable by mutagen chem dispenser
	var/static/list/mutagen_emagged_reagents = list(/datum/reagent/toxin/plasma)

/obj/machinery/chem_dispenser/mutagen/Initialize(mapload)
	dispensable_reagents = mutagen_dispensable_reagents
	emagged_reagents = mutagen_emagged_reagents
	. = ..()

/obj/machinery/chem_dispenser/mutagensaltpeter
	name = "botanical chemical dispenser"
	desc = "Creates and dispenses chemicals useful for botany."
	circuit = /obj/item/circuitboard/machine/chem_dispenser/mutagensaltpeter

	/// The default list of dispensable reagents available in the mutagensaltpeter chem dispenser
	var/static/list/mutagensaltpeter_dispensable_reagents = list(
		/datum/reagent/toxin/mutagen,
		/datum/reagent/saltpetre,
		/datum/reagent/plantnutriment/eznutriment,
		/datum/reagent/plantnutriment/left4zednutriment,
		/datum/reagent/plantnutriment/robustharvestnutriment,
		/datum/reagent/water,
		/datum/reagent/toxin/plantbgone,
		/datum/reagent/toxin/plantbgone/weedkiller,
		/datum/reagent/toxin/pestkiller,
		/datum/reagent/medicine/cryoxadone,
		/datum/reagent/ammonia,
		/datum/reagent/ash,
		/datum/reagent/diethylamine)
	upgrade_reagents = null

/obj/machinery/chem_dispenser/mutagensaltpeter/Initialize(mapload)
	dispensable_reagents = mutagensaltpeter_dispensable_reagents
	. = ..()

/obj/machinery/chem_dispenser/fullupgrade //fully ugpraded stock parts, emagged
	desc = "Creates and dispenses chemicals. This model has had its safeties shorted out."
	obj_flags = CAN_BE_HIT | EMAGGED
	circuit = /obj/item/circuitboard/machine/chem_dispenser/fullupgrade

/obj/machinery/chem_dispenser/fullupgrade/Initialize(mapload)
	. = ..()
	dispensable_reagents |= emagged_reagents //adds emagged reagents

/obj/machinery/chem_dispenser/abductor
	name = "reagent synthesizer"
	desc = "Synthesizes a variety of reagents using proto-matter."
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "chem_dispenser"
	base_icon_state = "chem_dispenser"
	has_panel_overlay = FALSE
	circuit = /obj/item/circuitboard/machine/chem_dispenser/abductor
	working_state = null
	nopower_state = null
	use_power = NO_POWER_USE

	/// The default list of dispensable reagents available in the abductor chem dispenser
	var/static/list/abductor_dispensable_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/silver,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel,
		/datum/reagent/acetone,
		/datum/reagent/ammonia,
		/datum/reagent/ash,
		/datum/reagent/diethylamine,
		/datum/reagent/fuel/oil,
		/datum/reagent/saltpetre,
		/datum/reagent/medicine/mine_salve,
		/datum/reagent/medicine/morphine,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/toxin,
		/datum/reagent/toxin/plasma,
		/datum/reagent/uranium,
		/datum/reagent/consumable/liquidelectricity/enriched,
		/datum/reagent/medicine/c2/synthflesh,
	)

/obj/machinery/chem_dispenser/abductor/Initialize(mapload)
	dispensable_reagents = abductor_dispensable_reagents
	. = ..()
