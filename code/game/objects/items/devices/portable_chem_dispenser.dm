/obj/item/portable_chem_dispenser
	name = "Portable Chemical Dispenser" //Thanks to antropod for the help
	desc = "A miniaturized version of a chemical dispenser attached to a belt. The label indicates that the power cell needs to be taken out with a screwdriver to recharge it. It seems as if the integrated stock parts are proprietary and cannot be upgraded. An imprint on the side reads S&T."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "portablechemicaldispenser_empty"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BELT
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	custom_price = 2000
	custom_premium_price = 2000
	var/machine_stat = 0
	var/ui_x = 565
	var/ui_y = 620


	var/obj/item/stock_parts/cell/cell
	var/obj/item/reagent_containers/beaker = null
	var/powerefficiency = 0.1
	var/amount = 30
	var/working_state = "dispenser_working"
	var/nopower_state = "dispenser_nopower"
	var/list/dispensable_reagents = list(
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
		/datum/reagent/fuel
	)
	var/list/emagged_reagents = list(
		/datum/reagent/toxin/carpotoxin,
		/datum/reagent/medicine/mine_salve,
		/datum/reagent/medicine/morphine,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/toxin
	)

	var/list/recording_recipe

	var/list/saved_recipes = list()


/obj/item/portable_chem_dispenser/get_cell()
	return cell


/obj/item/portable_chem_dispenser/proc/is_operational()
	return !(machine_stat & (NOPOWER|BROKEN|MAINT))


//----------------------------------------------------------------------------------------------------------
//	Add and remove beakers and power cells
//----------------------------------------------------------------------------------------------------------

/obj/item/portable_chem_dispenser/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		var/obj/item/reagent_containers/B = I
		. = TRUE //no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_portable_beaker(user, B)
		if(cell)
			icon_state = "portablechemicaldispenser_full"
		else
			icon_state = "portablechemicaldispenser_nocell"
		to_chat(user, "<span class='notice'>You add [B] to the [src].</span>")
		updateUsrDialog()
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		//Removing a powercell 
		if(!beaker)
			remove_cell(user)
			icon_state = "portablechemicaldispenser_nocell"
		else
			to_chat(user, "<span class='warning'>You cannot change the power cell with the beaker still in.</span>")
		return
	else if(istype(I, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='warning'>There is already a power cell inside!</span>")
			return
		else
			if(!user.transferItemToLoc(I, src))
				return
			//Adding a powercell
			cell = I
			if(beaker)
				icon_state = "portablechemicaldispenser_full"
			else
				icon_state = "portablechemicaldispenser_empty"
			return
	else if(user.a_intent != INTENT_HARM && !istype(I, /obj/item/card/emag))
		to_chat(user, "<span class='warning'>You can't load [I] into the [src]!</span>")
		return ..()
	else
		return ..()


/obj/item/portable_chem_dispenser/AltClick(mob/living/user)
	. = ..()
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_portable_beaker(user)
	if (cell)
		icon_state = "portablechemicaldispenser_empty"
	else
		icon_state = "portablechemicaldispenser_nocell"


/obj/item/portable_chem_dispenser/proc/replace_portable_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		user.put_in_hands(beaker)
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	update_icon()
	return TRUE


/obj/item/portable_chem_dispenser/proc/remove_cell(mob/living/user)
	if(!user)
		return FALSE
	if(cell)
		user.put_in_hands(cell)
		cell = null
	return TRUE


//----------------------------------------------------------------------------------------------------------
//	Accessing the Dispenser and moving it back to the hand
//----------------------------------------------------------------------------------------------------------


// /obj/item/portable_chem_dispenser/attack_hand(mob/user)
// 	if(loc == user)
// 		if(slot_flags == ITEM_SLOT_BELT)
// 			if(user.get_item_by_slot(ITEM_SLOT_BELT) == src)
// 				if(cell)
// 					ui_interact(user)
// 				else
// 					to_chat(user, "<span class='warning'>It has no power cell installed!</span>")
// 				return
// 			else
// 				to_chat(user, "<span class='warning'>You must strap the portable chemical dispenser's belt on to handle it properly!</span>")
// 			return
// 	return ..()

/obj/item/portable_chem_dispenser/attack_hand(mob/user)
	if(loc != user)
		return ..()
	if(!(slot_flags & ITEM_SLOT_BELT))
		return
	if(user.get_item_by_slot(ITEM_SLOT_BELT) != src)
		to_chat(user, "<span class='warning'>You must strap the portable chemical dispenser's belt on to handle it properly!</span>")
		return
	if(cell)
		ui_interact(user)
	else
		to_chat(user, "<span class='warning'>It has no power cell installed!</span>")


/obj/item/portable_chem_dispenser/attack_self(mob/user)
	to_chat(user, "<span class='warning'>You must strap the portable chemical dispenser's belt on to handle it properly!")
	

/obj/item/portable_chem_dispenser/MouseDrop(obj/over_object)
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		if(!M.incapacitated() && istype(over_object, /obj/screen/inventory/hand))
			var/obj/screen/inventory/hand/H = over_object
			M.putItemFromInventoryInHandIfPossible(src, H.held_index)



//----------------------------------------------------------------------------------------------------------
//	Dispenser Basic Functionality
//----------------------------------------------------------------------------------------------------------

/obj/item/portable_chem_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ChemDispenser", name, ui_x, ui_y, master_ui, state)
		if(user.hallucinating())
			ui.set_autoupdate(FALSE) //to not ruin the immersion by constantly changing the fake chemicals
		ui.open()



/obj/item/portable_chem_dispenser/ui_data(mob/user)
	if (cell)
		var/data = list()
		data["amount"] = amount
		data["energy"] = cell.charge ? cell.charge * powerefficiency : "0" //To prevent NaN in the UI.
		data["maxEnergy"] = cell.maxcharge * powerefficiency
		data["isBeakerLoaded"] = beaker ? 1 : 0

		var/beakerContents[0]
		var/beakerCurrentVolume = 0
		if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
				beakerCurrentVolume += R.volume
		data["beakerContents"] = beakerContents

		if (beaker)
			data["beakerCurrentVolume"] = beakerCurrentVolume
			data["beakerMaxVolume"] = beaker.volume
			data["beakerTransferAmounts"] = beaker.possible_transfer_amounts
		else
			data["beakerCurrentVolume"] = null
			data["beakerMaxVolume"] = null
			data["beakerTransferAmounts"] = null

		var/chemicals[0]
		var/is_hallucinating = FALSE
		if(user.hallucinating())
			is_hallucinating = TRUE
		for(var/re in dispensable_reagents)
			var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
			if(temp)
				var/chemname = temp.name
				if(is_hallucinating && prob(5))
					chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
				chemicals.Add(list(list("title" = chemname, "id" = ckey(temp.name))))
		data["chemicals"] = chemicals
		data["recipes"] = saved_recipes

		data["recordingRecipe"] = recording_recipe
		return data
	else
		var/data = list()
		data["energy"] = 0
		return data




/obj/item/portable_chem_dispenser/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("amount")
			if(!is_operational() || QDELETED(beaker))
				return
			var/target = text2num(params["target"])
			if(target in beaker.possible_transfer_amounts)
				amount = target
				//work_animation()
				. = TRUE
		if("dispense")
			if(!is_operational() || QDELETED(cell))
				return
			var/reagent_name = params["reagent"]
			if(!recording_recipe)
				var/reagent = GLOB.name2reagent[reagent_name]
				if(beaker && dispensable_reagents.Find(reagent))
					var/datum/reagents/R = beaker.reagents
					var/free = R.maximum_volume - R.total_volume
					var/actual = min(amount, (cell.charge * powerefficiency)*10, free)

					if(!cell.use(actual / powerefficiency))
						say("Not enough energy to complete operation! Please replace the power cell!")
						return
					R.add_reagent(reagent, actual)

					//work_animation()
			else
				recording_recipe[reagent_name] += amount
			. = TRUE
		if("remove")
			if(!is_operational() || recording_recipe)
				return
			var/amount = text2num(params["amount"])
			if(beaker && (amount in beaker.possible_transfer_amounts))
				beaker.reagents.remove_all(amount)
				//work_animation()
				. = TRUE
		if("eject")
			icon_state = "portablechemicaldispenser_empty"
			replace_portable_beaker(usr)
			. = TRUE
		if("dispense_recipe")
			if(!is_operational() || QDELETED(cell))
				return
			var/list/chemicals_to_dispense = saved_recipes[params["recipe"]]
			if(!LAZYLEN(chemicals_to_dispense))
				return
			for(var/key in chemicals_to_dispense)
				var/reagent = GLOB.name2reagent[translate_legacy_chem_id(key)]
				var/dispense_amount = chemicals_to_dispense[key]
				if(!dispensable_reagents.Find(reagent))
					return
				if(!recording_recipe)
					if(!beaker)
						return
					var/datum/reagents/R = beaker.reagents
					var/free = R.maximum_volume - R.total_volume
					var/actual = min(dispense_amount, (cell.charge * powerefficiency)*10, free)
					if(actual)
						if(!cell.use(actual / powerefficiency))
							say("Not enough energy to complete operation! Please replace the power cell!")
							return
						R.add_reagent(reagent, actual)
						//work_animation()
				else
					recording_recipe[key] += dispense_amount
			. = TRUE
		if("clear_recipes")
			if(!is_operational())
				return
			var/yesno = alert("Clear all recipes?",, "Yes","No")
			if(yesno == "Yes")
				saved_recipes = list()
			. = TRUE
		if("record_recipe")
			if(!is_operational())
				return
			recording_recipe = list()
			. = TRUE
		if("save_recording")
			if(!is_operational())
				return
			var/name = stripped_input(usr,"Name","What do you want to name this recipe?", "Recipe", MAX_NAME_LEN)
			if(!usr.canUseTopic(src, !issilicon(usr)))
				return
			if(saved_recipes[name] && alert("\"[name]\" already exists, do you want to overwrite it?",, "Yes", "No") == "No")
				return
			if(name && recording_recipe)
				for(var/reagent in recording_recipe)
					var/reagent_id = GLOB.name2reagent[translate_legacy_chem_id(reagent)]
					if(!dispensable_reagents.Find(reagent_id))
						visible_message("<span class='warning'>[src] buzzes.</span>", "<span class='hear'>You hear a faint buzz.</span>")
						to_chat(usr, "<span class ='danger'>[src] cannot find <b>[reagent]</b>!</span>")
						playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
						return
				saved_recipes[name] = recording_recipe
				recording_recipe = null
				. = TRUE
		if("cancel_recording")
			if(!is_operational())
				return
			recording_recipe = null
			. = TRUE




//----------------------------------------------------------------------------------------------------------
//	Dispenser Additional Functionality
//----------------------------------------------------------------------------------------------------------

/obj/item/portable_chem_dispenser/Initialize()
	. = ..()
	dispensable_reagents = sortList(dispensable_reagents, /proc/cmp_reagents_asc)
	if(emagged_reagents)
		emagged_reagents = sortList(emagged_reagents, /proc/cmp_reagents_asc)
	cell = new(src)
	update_icon()


/obj/item/portable_chem_dispenser/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(cell)
	return ..()


/obj/item/portable_chem_dispenser/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The [src] has no functional safeties to emag.</span>")
		return
	to_chat(user, "<span class='notice'>You short out the [src]'s safeties.</span>")
	dispensable_reagents |= emagged_reagents//add the emagged reagents to the dispensable ones
	obj_flags |= EMAGGED


/obj/item/portable_chem_dispenser/ex_act(severity, target)
	if(severity < 3)
		..()


/obj/item/portable_chem_dispenser/contents_explosion(severity, target)
	..()
	if(beaker)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highobj += beaker
			if(EXPLODE_HEAVY)
				SSexplosions.medobj += beaker
			if(EXPLODE_LIGHT)
				SSexplosions.lowobj += beaker



/obj/item/portable_chem_dispenser/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/list/datum/reagents/R = list()
	var/total = min(rand(7,15), FLOOR(cell.charge*powerefficiency, 1))
	var/datum/reagents/Q = new(total*10)
	if(beaker && beaker.reagents)
		R += beaker.reagents
	for(var/i in 1 to total)
		Q.add_reagent(pick(dispensable_reagents), 10)
	R += Q
	chem_splash(get_turf(src), 3, R)
	if(beaker && beaker.reagents)
		beaker.reagents.remove_all()
	cell.use(total/powerefficiency)
	cell.emp_act(severity)
	//work_animation()
	visible_message("<span class='danger'>The portable chemical dispenser malfunctions, spraying chemicals everywhere!</span>")
