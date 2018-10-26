/obj/machinery/chem_dispenser
	name = "chem dispenser"
	desc = "Creates and dispenses chemicals."
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	interaction_flags_machine = INTERACT_MACHINE_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OFFLINE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_dispenser
	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell
	var/powerefficiency = 0.1
	var/amount = 30
	var/recharge_amount = 10
	var/recharge_counter = 0
	var/mutable_appearance/beaker_overlay
	var/working_state = "dispenser_working"
	var/nopower_state = "dispenser_nopower"
	var/has_panel_overlay = TRUE
	var/macrotier = 1
	var/obj/item/reagent_containers/beaker = null
	var/list/dispensable_reagents = list(
		"hydrogen",
		"lithium",
		"carbon",
		"nitrogen",
		"oxygen",
		"fluorine",
		"sodium",
		"aluminium",
		"silicon",
		"phosphorus",
		"sulfur",
		"chlorine",
		"potassium",
		"iron",
		"copper",
		"mercury",
		"radium",
		"water",
		"ethanol",
		"sugar",
		"sacid",
		"welding_fuel",
		"silver",
		"iodine",
		"bromine",
		"stable_plasma"
	)
	//these become available once the manipulator has been upgraded to tier 4 (femto)
	var/list/upgrade_reagents = list(
		"oil",
		"ash",
		"acetone",
		"saltpetre",
		"ammonia",
		"diethylamine"
	)
	var/list/emagged_reagents = list(
		"space_drugs",
		"morphine",
		"carpotoxin",
		"mine_salve",
		"toxin"
	)

	var/list/saved_recipes = list()

/obj/machinery/chem_dispenser/Initialize()
	. = ..()
	cell = new cell_type
	dispensable_reagents = sortList(dispensable_reagents)
	update_icon()

/obj/machinery/chem_dispenser/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(cell)
	return ..()

/obj/machinery/chem_dispenser/examine(mob/user)
	..()
	if(panel_open)
		to_chat(user, "<span class='notice'>[src]'s maintenance hatch is open!</span>")

/obj/machinery/chem_dispenser/process()
	if (recharge_counter >= 4)
		if(!is_operational())
			return
		var/usedpower = cell.give(recharge_amount)
		if(usedpower)
			use_power(250*recharge_amount)
		recharge_counter = 0
		return
	recharge_counter++

/obj/machinery/chem_dispenser/proc/display_beaker()
	..()
	var/mutable_appearance/b_o = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	b_o.pixel_y = -4
	b_o.pixel_x = -7
	return b_o

/obj/machinery/chem_dispenser/proc/work_animation()
	if(working_state)
		flick(working_state,src)

/obj/machinery/chem_dispenser/power_change()
	..()
	icon_state = "[(nopower_state && !powered()) ? nopower_state : initial(icon_state)]"

/obj/machinery/chem_dispenser/update_icon()
	cut_overlays()
	if(has_panel_overlay && panel_open)
		add_overlay(mutable_appearance(icon, "[initial(icon_state)]_panel-o"))

	if(beaker)
		beaker_overlay = display_beaker()
		add_overlay(beaker_overlay)



/obj/machinery/chem_dispenser/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>[src] has no functional safeties to emag.</span>")
		return
	to_chat(user, "<span class='notice'>You short out [src]'s safeties.</span>")
	dispensable_reagents |= emagged_reagents//add the emagged reagents to the dispensable ones
	obj_flags |= EMAGGED

/obj/machinery/chem_dispenser/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/chem_dispenser/contents_explosion(severity, target)
	..()
	if(beaker)
		beaker.ex_act(severity, target)

/obj/machinery/chem_dispenser/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		cut_overlays()

/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_dispenser", name, 565, 550, master_ui, state)
		if(user.hallucinating())
			ui.set_autoupdate(FALSE) //to not ruin the immersion by constantly changing the fake chemicals
		ui.open()

/obj/machinery/chem_dispenser/ui_data(mob/user)
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
	var/recipes[0]
	var/is_hallucinating = FALSE
	if(user.hallucinating())
		is_hallucinating = TRUE
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			var/chemname = temp.name
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			chemicals.Add(list(list("title" = chemname, "id" = temp.id)))
	for(var/recipe in saved_recipes)
		recipes.Add(list(recipe))
	data["chemicals"] = chemicals
	data["recipes"] = recipes
	return data

/obj/machinery/chem_dispenser/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("amount")
			if(!is_operational() || QDELETED(beaker))
				return
			var/target = text2num(params["target"])
			if(target in beaker.possible_transfer_amounts)
				amount = target
				work_animation()
				. = TRUE
		if("dispense")
			if(!is_operational() || QDELETED(cell))
				return
			var/reagent = params["reagent"]
			if(beaker && dispensable_reagents.Find(reagent))
				var/datum/reagents/R = beaker.reagents
				var/free = R.maximum_volume - R.total_volume
				var/actual = min(amount, (cell.charge * powerefficiency)*10, free)

				if(!cell.use(actual / powerefficiency))
					say("Not enough energy to complete operation!")
					return
				R.add_reagent(reagent, actual)

				work_animation()
				. = TRUE
		if("remove")
			if(!is_operational())
				return
			var/amount = text2num(params["amount"])
			if(beaker && amount in beaker.possible_transfer_amounts)
				beaker.reagents.remove_all(amount)
				work_animation()
				. = TRUE
		if("eject")
			if(beaker)
				beaker.forceMove(drop_location())
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(beaker)
				beaker = null
				update_icon()
				. = TRUE
		if("dispense_recipe")
			if(!is_operational() || QDELETED(cell))
				return
			var/recipe_to_use = params["recipe"]
			var/list/chemicals_to_dispense = process_recipe_list(recipe_to_use)
			var/res = get_macro_resolution()
			for(var/key in chemicals_to_dispense) // i suppose you could edit the list locally before passing it
				var/list/keysplit = splittext(key," ")
				var/r_id = keysplit[1]
				if(beaker && dispensable_reagents.Find(r_id)) // but since we verify we have the reagent, it'll be fine
					var/datum/reagents/R = beaker.reagents
					var/free = R.maximum_volume - R.total_volume
					var/actual = min(round(chemicals_to_dispense[key], res), (cell.charge * powerefficiency)*10, free)
					if(actual)
						if(!cell.use(actual / powerefficiency))
							say("Not enough energy to complete operation!")
							return
						R.add_reagent(r_id, actual)
						work_animation()
		if("clear_recipes")
			if(!is_operational())
				return
			var/yesno = alert("Clear all recipes?",, "Yes","No")
			if(yesno == "Yes")
				saved_recipes = list()
		if("add_recipe")
			if(!is_operational())
				return
			var/name = stripped_input(usr,"Name","What do you want to name this recipe?", "Recipe", MAX_NAME_LEN)
			var/recipe = stripped_input(usr,"Recipe","Insert recipe with chem IDs")
			if(!usr.canUseTopic(src, !issilicon(usr)))
				return
			if(name && recipe)
				var/list/first_process = splittext(recipe, ";")
				if(!LAZYLEN(first_process))
					return
				var/res = get_macro_resolution()
				var/resmismatch = FALSE
				for(var/reagents in first_process)
					var/list/reagent = splittext(reagents, "=")
					if(dispensable_reagents.Find(reagent[1]))
						if (!resmismatch && !check_macro_part(reagents, res))
							resmismatch = TRUE
						continue
					else
						var/chemid = reagent[1]
						visible_message("<span class='warning'>[src] buzzes.</span>", "<span class='italics'>You hear a faint buzz.</span>")
						to_chat(usr, "<span class ='danger'>[src] cannot find Chemical ID: <b>[chemid]</b>!</span>")
						playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
						return
				if (resmismatch && alert("[src] is not yet capable of replicating this recipe with the precision it needs, do you want to save it anyway?",, "Yes","No") == "No")
					return
				saved_recipes += list(list("recipe_name" = name, "contents" = recipe))

/obj/machinery/chem_dispenser/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return

	if(default_deconstruction_crowbar(I))
		return
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		var/obj/item/reagent_containers/B = I
		. = 1 //no afterattack
		if(beaker)
			to_chat(user, "<span class='warning'>A container is already loaded into [src]!</span>")
			return
		if(!user.transferItemToLoc(B, src))
			return
		beaker = B
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		update_icon()
	else if(user.a_intent != INTENT_HARM && !istype(I, /obj/item/card/emag))
		to_chat(user, "<span class='warning'>You can't load [I] into [src]!</span>")
		return ..()
	else
		return ..()

/obj/machinery/chem_dispenser/get_cell()
	return cell

/obj/machinery/chem_dispenser/emp_act(severity)
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
	work_animation()
	visible_message("<span class='danger'>[src] malfunctions, spraying chemicals everywhere!</span>")


/obj/machinery/chem_dispenser/RefreshParts()
	recharge_amount = initial(recharge_amount)
	var/newpowereff = 0.0666666
	for(var/obj/item/stock_parts/cell/P in component_parts)
		cell = P
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		newpowereff += 0.0166666666*M.rating
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_amount *= C.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		if (M.rating > macrotier)
			macrotier = M.rating
		if (M.rating > 3)
			dispensable_reagents |= upgrade_reagents
	powerefficiency = round(newpowereff, 0.01)



/obj/machinery/chem_dispenser/on_deconstruction()
	cell = null
	if(beaker)
		beaker.forceMove(drop_location())
		beaker = null
	return ..()

/obj/machinery/chem_dispenser/proc/get_macro_resolution()
	. = 5
	if (macrotier > 1)
		. -= macrotier // 5 for tier1, 3 for 2, 2 for 3, 1 for 4.

/obj/machinery/chem_dispenser/proc/check_macro(macro)
	var/res = get_macro_resolution()
	for (var/reagent in splittext(trim(macro), ";"))
		if (!check_macro_part(reagent, res))
			return FALSE
	return TRUE

/obj/machinery/chem_dispenser/proc/check_macro_part(var/part, var/res = get_macro_resolution())
	var/detail = splittext(part, "=")
	if (round(text2num(detail[2]), res) != text2num(detail[2]))
		return FALSE
	return TRUE

/obj/machinery/chem_dispenser/proc/process_recipe_list(var/fucking_hell)
	var/list/key_list = list()
	var/list/final_list = list()
	var/list/first_process = splittext(fucking_hell, ";")
	for(var/reagents in first_process)
		var/list/fuck = splittext(reagents, "=")
		final_list += list(avoid_assoc_duplicate_keys(fuck[1],key_list) = text2num(fuck[2]))
	return final_list

/obj/machinery/chem_dispenser/drinks/Initialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE)

/obj/machinery/chem_dispenser/drinks/setDir()
	var/old = dir
	. = ..()
	if(dir != old)
		update_icon()  // the beaker needs to be re-positioned if we rotate

/obj/machinery/chem_dispenser/drinks/display_beaker()
	var/mutable_appearance/b_o = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	switch(dir)
		if(NORTH)
			b_o.pixel_y = 7
			b_o.pixel_x = rand(-9, 9)
		if(EAST)
			b_o.pixel_x = 4
			b_o.pixel_y = rand(-5, 7)
		if(WEST)
			b_o.pixel_x = -5
			b_o.pixel_y = rand(-5, 7)
		else//SOUTH
			b_o.pixel_y = -7
			b_o.pixel_x = rand(-9, 9)
	return b_o

/obj/machinery/chem_dispenser/drinks
	name = "soda dispenser"
	desc = "Contains a large reservoir of soft drinks."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "soda_dispenser"
	has_panel_overlay = FALSE
	amount = 10
	pixel_y = 6
	layer = WALL_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/chem_dispenser/drinks
	working_state = null
	nopower_state = null
	pass_flags = PASSTABLE
	dispensable_reagents = list(
		"water",
		"ice",
		"coffee",
		"cream",
		"tea",
		"icetea",
		"cola",
		"spacemountainwind",
		"dr_gibb",
		"space_up",
		"tonic",
		"sodawater",
		"lemon_lime",
		"pwr_game",
		"shamblers",
		"sugar",
		"orangejuice",
		"grenadine",
		"limejuice",
		"tomatojuice",
		"lemonjuice",
		"menthol"
	)
	upgrade_reagents = null
	emagged_reagents = list(
		"thirteenloko",
		"whiskeycola",
		"mindbreaker",
		"tirizene"
	)

/obj/machinery/chem_dispenser/drinks/fullupgrade //fully ugpraded stock parts, emagged
	desc = "Contains a large reservoir of soft drinks. This model has had its safeties shorted out."
	obj_flags = CAN_BE_HIT | EMAGGED
	flags_1 = NODECONSTRUCT_1

/obj/machinery/chem_dispenser/drinks/fullupgrade/Initialize()
	. = ..()
	dispensable_reagents |= emagged_reagents //adds emagged reagents
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/chem_dispenser/drinks(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/cell/bluespace(null)
	RefreshParts()

/obj/machinery/chem_dispenser/drinks/beer
	name = "booze dispenser"
	desc = "Contains a large reservoir of the good stuff."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "booze_dispenser"
	circuit = /obj/item/circuitboard/machine/chem_dispenser/drinks/beer
	dispensable_reagents = list(
		"beer",
		"kahlua",
		"whiskey",
		"wine",
		"vodka",
		"gin",
		"rum",
		"tequila",
		"vermouth",
		"cognac",
		"ale",
		"absinthe",
		"hcider",
		"creme_de_menthe",
		"creme_de_cacao",
		"triple_sec",
		"sake"
	)
	upgrade_reagents = null
	emagged_reagents = list(
		"ethanol",
		"iron",
		"minttoxin",
		"atomicbomb",
		"fernet"
	)

/obj/machinery/chem_dispenser/drinks/beer/fullupgrade //fully ugpraded stock parts, emagged
	desc = "Contains a large reservoir of the good stuff. This model has had its safeties shorted out."
	obj_flags = CAN_BE_HIT | EMAGGED
	flags_1 = NODECONSTRUCT_1

/obj/machinery/chem_dispenser/drinks/beer/fullupgrade/Initialize()
	. = ..()
	dispensable_reagents |= emagged_reagents //adds emagged reagents
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/chem_dispenser/drinks/beer(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/cell/bluespace(null)
	RefreshParts()

/obj/machinery/chem_dispenser/mutagen
	name = "mutagen dispenser"
	desc = "Creates and dispenses mutagen."
	dispensable_reagents = list("mutagen")
	upgrade_reagents = null
	emagged_reagents = list("plasma")


/obj/machinery/chem_dispenser/mutagensaltpeter
	name = "botanical chemical dispenser"
	desc = "Creates and dispenses chemicals useful for botany."
	flags_1 = NODECONSTRUCT_1

	dispensable_reagents = list(
		"mutagen",
		"saltpetre",
		"eznutriment",
		"left4zednutriment",
		"robustharvestnutriment",
		"water",
		"plantbgone",
		"weedkiller",
		"pestkiller",
		"cryoxadone",
		"ammonia",
		"ash",
		"diethylamine")
	upgrade_reagents = null

/obj/machinery/chem_dispenser/mutagensaltpeter/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/cell/bluespace(null)
	RefreshParts()

/obj/machinery/chem_dispenser/fullupgrade //fully ugpraded stock parts, emagged
	desc = "Creates and dispenses chemicals. This model has had its safeties shorted out."
	obj_flags = CAN_BE_HIT | EMAGGED
	flags_1 = NODECONSTRUCT_1

/obj/machinery/chem_dispenser/fullupgrade/Initialize()
	. = ..()
	dispensable_reagents |= emagged_reagents //adds emagged reagents
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/cell/bluespace(null)
	RefreshParts()
