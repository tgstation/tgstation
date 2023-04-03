/**
 * Machine that allows to identify and separate reagents in fitting container
 * as well as to create new containers with separated reagents in it.
 *
 * Contains logic for both ChemMaster and CondiMaster, switched by "condi".
 */
/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to separate chemicals and distribute them in a variety of forms."
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "mixer0"
	base_icon_state = "mixer"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.2
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_master

	/// Input reagents container
	var/obj/item/reagent_containers/beaker
	/// Pill bottle for newly created pills
	var/obj/item/storage/pill_bottle/bottle
	/// Whether separated reagents should be moved back to container or destroyed. 1 - move, 0 - destroy
	var/mode = 1
	/// Decides what UI to show. If TRUE shows UI of CondiMaster, if FALSE - ChemMaster
	var/condi = FALSE
	/// Currently selected pill style
	var/chosen_pill_style = 1
	/// Currently selected condiment bottle style
	var/chosen_condi_style = CONDIMASTER_STYLE_AUTO
	/// Current UI screen. On the moment of writing this comment there were two: 'home' - main screen, and 'analyze' - info about specific reagent
	var/screen = "home"
	/// Info to display on 'analyze' screen
	var/analyze_vars[0]
	/// List of available pill styles for UI
	var/list/pill_styles
	/// List of available condibottle styles for UI
	var/list/condi_styles
	/// Currently selected patch style
	var/patch_style = DEFAULT_PATCH_STYLE
	/// List of available patch styles for UI
	var/list/patch_styles

/obj/machinery/chem_master/Initialize(mapload)
	create_reagents(100)
	. = ..()

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(bottle)
	return ..()

/obj/machinery/chem_master/RefreshParts()
	. = ..()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/cup/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

/obj/machinery/chem_master/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return FALSE
	return ..()

/obj/machinery/chem_master/contents_explosion(severity, target)
	. = ..()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(beaker)
				SSexplosions.high_mov_atom += beaker
			if(bottle)
				SSexplosions.high_mov_atom += bottle
		if(EXPLODE_HEAVY)
			if(beaker)
				SSexplosions.med_mov_atom += beaker
			if(bottle)
				SSexplosions.med_mov_atom += bottle
		if(EXPLODE_LIGHT)
			if(beaker)
				SSexplosions.low_mov_atom += beaker
			if(bottle)
				SSexplosions.low_mov_atom += bottle

/obj/machinery/chem_master/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		reagents.clear_reagents()
		update_appearance()
	else if(A == bottle)
		bottle = null

/obj/machinery/chem_master/update_icon_state()
	icon_state = "[base_icon_state][beaker ? 1 : 0][(machine_stat & BROKEN) ? "_b" : (powered() ? null : "_nopower")]"
	return ..()

/obj/machinery/chem_master/update_overlays()
	. = ..()
	if(machine_stat & BROKEN)
		. += "waitlight"

/obj/machinery/chem_master/blob_act(obj/structure/blob/B)
	if (prob(50))
		qdel(src)

/obj/machinery/chem_master/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", I))
		return

	else if(default_deconstruction_crowbar(I))
		return

	if(is_reagent_container(I) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE // no afterattack
		if(panel_open)
			to_chat(user, span_warning("You can't use the [src.name] while its panel is opened!"))
			return
		var/obj/item/reagent_containers/B = I
		. = TRUE // no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, span_notice("You add [B] to [src]."))
		ui_interact(user)
		update_appearance()
	else if(!condi && istype(I, /obj/item/storage/pill_bottle))
		if(bottle)
			to_chat(user, span_warning("A pill bottle is already loaded into [src]!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		bottle = I
		to_chat(user, span_notice("You add [I] into the dispenser slot."))
		ui_interact(user)
	else
		return ..()

/obj/machinery/chem_master/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH|FORBID_TELEKINESIS_REACH))
		return
	replace_beaker(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/chem_master/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/chem_master/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/**
 * Handles process of moving input reagents containers in/from machine
 *
 * When called checks for previously inserted beaker and gives it to user.
 * Then, if new_beaker provided, places it into src.beaker.
 * Returns `boolean`. TRUE if user provided (ignoring whether threre was any beaker change) and FALSE if not.
 *
 * Arguments:
 * * user - Mob that initialized replacement, gets previously inserted beaker if there's any
 * * new_beaker - New beaker to insert. Optional
 */
/obj/machinery/chem_master/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		try_put_in_hand(beaker, user)
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	update_appearance()
	return TRUE

/obj/machinery/chem_master/on_deconstruction()
	replace_beaker()
	if(bottle)
		bottle.forceMove(drop_location())
		adjust_item_drop_location(bottle)
		bottle = null
	return ..()

/obj/machinery/chem_master/proc/load_styles()
	//Calculate the span tags and ids fo all the available pill icons
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
	pill_styles = list()
	for (var/x in 1 to PILL_STYLE_COUNT)
		var/list/SL = list()
		SL["id"] = x
		SL["className"] = assets.icon_class_name("pill[x]")
		pill_styles += list(SL)

	var/datum/asset/spritesheet/simple/patches_assets = get_asset_datum(/datum/asset/spritesheet/simple/patches)
	patch_styles = list()
	for (var/raw_patch_style in PATCH_STYLE_LIST)
		//adding class_name for use in UI
		var/list/patch_style = list()
		patch_style["style"] = raw_patch_style
		patch_style["class_name"] = patches_assets.icon_class_name(raw_patch_style)
		patch_styles += list(patch_style)

	condi_styles = strip_condi_styles_to_icons(get_condi_styles())

/obj/machinery/chem_master/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/pills),
		get_asset_datum(/datum/asset/spritesheet/simple/condiments),
		get_asset_datum(/datum/asset/spritesheet/simple/patches),
	)

/obj/machinery/chem_master/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", name)
		ui.open()

/obj/machinery/chem_master/ui_data(mob/user)
	var/list/data = list()
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? round(beaker.reagents.total_volume, 0.01) : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["mode"] = mode
	data["condi"] = condi
	data["screen"] = screen
	data["analyzeVars"] = analyze_vars
	data["chosenPillStyle"] = chosen_pill_style
	data["chosenCondiStyle"] = chosen_condi_style
	data["autoCondiStyle"] = CONDIMASTER_STYLE_AUTO
	data["isPillBottleLoaded"] = bottle ? 1 : 0
	if(bottle)
		data["pillBottleCurrentAmount"] = bottle.contents.len
		data["pillBottleMaxAmount"] = bottle.atom_storage.max_slots

	var/beaker_contents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beaker_contents.Add(list(list("name" = R.name, "id" = ckey(R.name), "volume" = round(R.volume, 0.01)))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beaker_contents

	var/buffer_contents[0]
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			buffer_contents.Add(list(list("name" = N.name, "id" = ckey(N.name), "volume" = round(N.volume, 0.01)))) // ^
	data["bufferContents"] = buffer_contents

	//Calculated once since it'll never change
	if(!pill_styles || !condi_styles || !patch_style || !patch_styles)
		load_styles()
	data["pillStyles"] = pill_styles
	data["condiStyles"] = condi_styles
	data["patch_style"] = patch_style
	data["patch_styles"] = patch_styles
	return data

/obj/machinery/chem_master/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "eject")
		replace_beaker(usr)
		return TRUE

	if(action == "ejectPillBottle")
		if(!bottle)
			return FALSE
		bottle.forceMove(drop_location())
		adjust_item_drop_location(bottle)
		bottle = null
		return TRUE

	if(action == "transfer")
		var/reagent = GLOB.name2reagent[params["id"]]
		var/amount = text2num(params["amount"])
		var/to_container = params["to"]
		// Custom amount
		if (amount == -1)
			amount = text2num(input(
				"Enter the amount you want to transfer:",
				name, ""))
		if (amount == null || amount <= 0)
			return FALSE
		use_power(active_power_usage)
		if (to_container == "beaker" && !mode)
			reagents.remove_reagent(reagent, amount)
			return TRUE
		if (!beaker)
			return FALSE
		if (to_container == "buffer")
			var/datum/reagent/R = beaker.reagents.get_reagent(reagent)
			if(!check_reactions(R, beaker.reagents))
				return FALSE
			beaker.reagents.trans_id_to(src, reagent, amount)
			return TRUE
		if (to_container == "beaker" && mode)
			var/datum/reagent/R = reagents.get_reagent(reagent)
			if(!check_reactions(R, reagents))
				return FALSE
			reagents.trans_id_to(beaker, reagent, amount)
			return TRUE
		return FALSE

	if(action == "toggleMode")
		mode = !mode
		return TRUE

	if(action == "pillStyle")
		var/id = text2num(params["id"])
		chosen_pill_style = id
		return TRUE

	if(action == "condiStyle")
		chosen_condi_style = params["id"]
		return TRUE

	if(action == "create")
		if(reagents.total_volume == 0)
			return FALSE
		var/item_type = params["type"]
		// Get amount of items
		var/amount = text2num(params["amount"])
		if(amount == null)
			amount = text2num(input(usr,
				"Max 10. Buffer content will be split evenly.",
				"How many to make?", 1))
		amount = clamp(round(amount), 0, 10)
		if (amount <= 0)
			return FALSE
		// Get units per item
		var/vol_each = text2num(params["volume"])
		var/vol_each_text = params["volume"]
		var/vol_each_max = reagents.total_volume / amount
		var/list/style
		use_power(active_power_usage)
		if (item_type == "pill")
			vol_each_max = min(50, vol_each_max)
		else if (item_type == "patch")
			vol_each_max = min(40, vol_each_max)
		else if (item_type == "bottle")
			vol_each_max = min(30, vol_each_max)
		else if (item_type == "condimentPack")
			vol_each_max = min(10, vol_each_max)
		else if (item_type == "condimentBottle")
			var/list/styles = get_condi_styles()
			if (chosen_condi_style == CONDIMASTER_STYLE_AUTO || !(chosen_condi_style in styles))
				style = guess_condi_style(reagents)
			else
				style = styles[chosen_condi_style]
			vol_each_max = min(50, vol_each_max)
		else
			return FALSE
		if(vol_each_text == "auto")
			vol_each = vol_each_max
		if(vol_each == null)
			vol_each = text2num(input(usr,
				"Maximum [vol_each_max] units per item.",
				"How many units to fill?",
				vol_each_max))
		vol_each = round(clamp(vol_each, 0, vol_each_max), 0.01)
		if(vol_each <= 0)
			return FALSE
		// Get item name
		var/name = strip_html(params["name"], limit = 100)
		var/name_has_units = item_type == "pill" || item_type == "patch"
		if(!name)
			var/name_default
			if (style && style["name"] && !style["generate_name"])
				name_default = style["name"]
			else
				name_default = reagents.get_master_reagent_name()
			if (name_has_units)
				name_default += " ([vol_each]u)"
			name = tgui_input_text(usr,
				"Give it a name!",
				"Name",
				name_default,
				MAX_NAME_LEN)
		if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.can_perform_action(src, ALLOW_SILICON_REACH))
			return FALSE
		// Start filling
		if(item_type == "pill")
			var/obj/item/reagent_containers/pill/P
			var/target_loc = drop_location()
			var/drop_threshold = INFINITY
			if(bottle)
				if(bottle.atom_storage)
					drop_threshold = bottle.atom_storage.max_slots - bottle.contents.len
					target_loc = bottle
			for(var/i in 1 to amount)
				if(i-1 < drop_threshold)
					P = new/obj/item/reagent_containers/pill(target_loc)
				else
					P = new/obj/item/reagent_containers/pill(drop_location())
				P.name = trim("[name] pill")
				if(chosen_pill_style == RANDOM_PILL_STYLE)
					P.icon_state ="pill[rand(1,21)]"
				else
					P.icon_state = "pill[chosen_pill_style]"
				if(P.icon_state == "pill4")
					P.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty and the brutal truths of reality."
				adjust_item_drop_location(P)
				reagents.trans_to(P, vol_each, transfered_by = usr)
			return TRUE
		if(item_type == "patch")
			var/obj/item/reagent_containers/pill/patch/P
			for(var/i in 1 to amount)
				P = new/obj/item/reagent_containers/pill/patch(drop_location())
				P.name = trim("[name] patch")
				P.icon_state = patch_style
				adjust_item_drop_location(P)
				reagents.trans_to(P, vol_each, transfered_by = usr)
			return TRUE
		if(item_type == "bottle")
			var/obj/item/reagent_containers/cup/bottle/P
			for(var/i in 1 to amount)
				P = new/obj/item/reagent_containers/cup/bottle(drop_location())
				P.name = trim("[name] bottle")
				adjust_item_drop_location(P)
				reagents.trans_to(P, vol_each, transfered_by = usr)
			return TRUE
		if(item_type == "condimentPack")
			var/obj/item/reagent_containers/condiment/pack/P
			for(var/i in 1 to amount)
				P = new/obj/item/reagent_containers/condiment/pack(drop_location())
				P.originalname = name
				P.name = trim("[name] pack")
				P.desc = "A small condiment pack. The label says it contains [name]."
				reagents.trans_to(P, vol_each, transfered_by = usr)
			return TRUE
		if(item_type == "condimentBottle")
			var/obj/item/reagent_containers/condiment/P
			for(var/i in 1 to amount)
				P = new/obj/item/reagent_containers/condiment(drop_location())
				if (style)
					apply_condi_style(P, style)
				P.renamedByPlayer = TRUE
				P.name = name
				reagents.trans_to(P, vol_each, transfered_by = usr)
			return TRUE
		return FALSE

	if(action == "analyze")
		var/datum/reagent/analyzed_reagent = GLOB.name2reagent[params["id"]]
		if(analyzed_reagent)
			var/state = "Unknown"
			if(initial(analyzed_reagent.reagent_state) == SOLID)
				state = "Solid"
			else if(initial(analyzed_reagent.reagent_state) == LIQUID)
				state = "Liquid"
			else if(initial(analyzed_reagent.reagent_state) == GAS)
				state = "Gas"
			var/metabolization_rate = initial(analyzed_reagent.metabolization_rate) * (60 / SSMOBS_DT)
			analyze_vars = list("name" = initial(analyzed_reagent.name), "state" = state, "color" = initial(analyzed_reagent.color), "description" = initial(analyzed_reagent.description), "metaRate" = metabolization_rate, "overD" = initial(analyzed_reagent.overdose_threshold), "pH" = initial(analyzed_reagent.ph))
			screen = "analyze"
			return TRUE

	if(action == "goScreen")
		screen = params["screen"]
		return TRUE

	if(action == "change_patch_style")
		patch_style = params["patch_style"]
		return TRUE

	return FALSE

/obj/machinery/chem_master/adjust_item_drop_location(atom/movable/AM) // Special version for chemmasters and condimasters
	if (AM == beaker)
		AM.pixel_x = AM.base_pixel_x - 8
		AM.pixel_y = AM.base_pixel_y + 8
		return null
	else if (AM == bottle)
		if (length(bottle.contents))
			AM.pixel_x = AM.base_pixel_x - 13
		else
			AM.pixel_x = AM.base_pixel_x - 7
		AM.pixel_y = AM.base_pixel_y - 8
		return null
	else
		var/md5 = md5(AM.name)
		for (var/i in 1 to 32)
			. += hex2num(md5[i])
		. = . % 9
		AM.pixel_x = AM.base_pixel_x + ((.%3)*6)
		AM.pixel_y = AM.base_pixel_y - 8 + (round( . / 3)*8)

/**
 * Translates styles data into UI compatible format
 *
 * Expects to receive list of availables condiment styles in its complete format, and transforms them in simplified form with enough data to get UI going.
 * Returns list(list("id" = <key>, "className" = <icon class>, "title" = <name and desc>),..).
 *
 * Arguments:
 * * styles - List of styles for condiment bottles in internal format: [/obj/machinery/chem_master/proc/get_condi_styles]
 */
/obj/machinery/chem_master/proc/strip_condi_styles_to_icons(list/styles)
	var/list/icons = list()
	for (var/s in styles)
		if (styles[s] && styles[s]["class_name"])
			var/list/icon = list()
			var/list/style = styles[s]
			icon["id"] = s
			icon["className"] = style["class_name"]
			icon["title"] = "[style["name"]]\n[style["desc"]]"
			icons += list(icon)

	return icons

/**
 * Defines and provides list of available condiment bottle styles
 *
 * Uses typelist() for styles storage after initialization.
 * For fallback style must provide style with key (const) CONDIMASTER_STYLE_FALLBACK
 * Returns list(
 * <key> = list(
 * "icon_state" = <bottle icon_state>,
 * "name" = <bottle name>,
 * "desc" = <bottle desc>,
 * ?"generate_name" = <if truthy, autogenerates default name from reagents instead of using "name">,
 * ?"icon_empty" = <icon_state when empty>,
 * ?"fill_icon_thresholds" = <list of thresholds for reagentfillings, no tresholds if not provided or falsy>,
 * ?"inhand_icon_state" = <inhand icon_state, falsy - no icon, not provided - whatever is initial (currently "beer")>,
 * ?"lefthand_file" = <file for inhand icon for left hand, ignored if "inhand_icon_state" not provided>,
 * ?"righthand_file" = <same as "lefthand_file" but for right hand>,
 * ),
 * ..
 * )
 *
 */
/obj/machinery/chem_master/proc/get_condi_styles()
	var/list/styles = typelist("condi_styles")
	if (!styles.len)
		//Possible_states has the reagent type as key and a list of, in order, the icon_state, the name and the desc as values. Was used in the condiment/on_reagent_change(changetype) to change names, descs and sprites.
		styles += list(
			CONDIMASTER_STYLE_FALLBACK = list("icon_state" = "emptycondiment", "icon_empty" = "", "name" = "condiment bottle", "desc" = "Just your average condiment bottle.", "fill_icon_thresholds" = list(0, 10, 25, 50, 75, 100), "generate_name" = TRUE),
			"enzyme" = list("icon_state" = "enzyme", "icon_empty" = "", "name" = "universal enzyme bottle", "desc" = "Used in cooking various dishes."),
			"flour" = list("icon_state" = "flour", "icon_empty" = "", "name" = "flour sack", "desc" = "A big bag of flour. Good for baking!"),
			"mayonnaise" = list("icon_state" = "mayonnaise", "icon_empty" = "", "name" = "mayonnaise jar", "desc" = "An oily condiment made from egg yolks."),
			"milk" = list("icon_state" = "milk", "icon_empty" = "", "name" = "space milk", "desc" = "It's milk. White and nutritious goodness!"),
			"blackpepper" = list("icon_state" = "peppermillsmall", "inhand_icon_state" = "", "icon_empty" = "emptyshaker", "name" = "pepper mill", "desc" = "Often used to flavor food or make people sneeze."),
			"rice" = list("icon_state" = "rice", "icon_empty" = "", "name" = "rice sack", "desc" = "A big bag of rice. Good for cooking!"),
			"sodiumchloride" = list("icon_state" = "saltshakersmall", "inhand_icon_state" = "", "icon_empty" = "emptyshaker", "name" = "salt shaker", "desc" = "Salt. From dead crew, presumably."),
			"soymilk" = list("icon_state" = "soymilk", "icon_empty" = "", "name" = "soy milk", "desc" = "It's soy milk. White and nutritious goodness!"),
			"soysauce" = list("icon_state" = "soysauce", "inhand_icon_state" = "", "icon_empty" = "", "name" = "soy sauce bottle", "desc" = "A salty soy-based flavoring."),
			"sugar" = list("icon_state" = "sugar", "icon_empty" = "", "name" = "sugar sack", "desc" = "Tasty spacey sugar!"),
			"ketchup" = list("icon_state" = "ketchup", "icon_empty" = "", "name" = "ketchup bottle", "desc" = "A tomato slurry in a tall plastic bottle. Somehow still vaguely American."),
			"capsaicin" = list("icon_state" = "hotsauce", "icon_empty" = "", "name" = "hotsauce bottle", "desc" = "You can almost TASTE the stomach ulcers!"),
			"frostoil" = list("icon_state" = "coldsauce", "icon_empty" = "", "name" = "coldsauce bottle", "desc" = "Leaves the tongue numb from its passage."),
			"cornoil" = list("icon_state" = "oliveoil", "icon_empty" = "", "name" = "corn oil bottle", "desc" = "A delicious oil used in cooking. Made from corn."),
			"bbqsauce" = list("icon_state" = "bbqsauce", "icon_empty" = "", "name" = "bbq sauce bottle", "desc" = "Hand wipes not included."),
			"peanut_butter" = list("icon_state" = "peanutbutter", "icon_empty" = "", "name" = "peanut butter jar", "desc" = "A creamy paste made from ground peanuts."),
			"honey" = list("icon_state" = "honey", "icon_empty" = "", "name" = "honey bottle", "desc" = "A cheerful bear-shaped bottle of tasty honey."),
			"cherryjelly" = list("icon_state" = "cherryjelly", "icon_empty" = "", "name" = "cherry jelly jar", "desc" = "A jar of super-sweet cherry jelly."),
		)
		var/list/carton_in_hand = list(
			"inhand_icon_state" = "carton",
			"lefthand_file" = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi',
			"righthand_file" = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
		)
		for (var/style_reagent in list("flour", "milk", "rice", "soymilk", "sugar"))
			if (style_reagent in styles)
				styles[style_reagent] += carton_in_hand
		var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/condiments)
		for (var/reagent in styles)
			styles[reagent]["class_name"] = assets.icon_class_name(reagent)
	return styles

/**
 * Provides condiment bottle style based on reagents.
 *
 * Gets style from available by key, using last part of main reagent type (eg. "rice" for /datum/reagent/consumable/rice) as key.
 * If not available returns fallback style, or null if no such thing.
 * Returns list that is one of condibottle styles from [/obj/machinery/chem_master/proc/get_condi_styles]
 */
/obj/machinery/chem_master/proc/guess_condi_style(datum/reagents/reagents)
	var/list/styles = get_condi_styles()
	if (reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if (main_reagent)
			var/list/path = splittext("[main_reagent]", "/")
			main_reagent = path[path.len]
		if(main_reagent in styles)
			return styles[main_reagent]
	return styles[CONDIMASTER_STYLE_FALLBACK]

/**
 * Applies style to condiment bottle.
 *
 * Applies props provided in "style" assuming that "container" is freshly created with no styles applied before.
 * User specified name for bottle applied after this method during bottle creation,
 * so container.name overwritten here for consistency rather than with some purpose in mind.
 *
 * Arguments:
 * * container - condiment bottle that gets style applied to it
 * * style - assoc list, must probably one from [/obj/machinery/chem_master/proc/get_condi_styles]
 */
/obj/machinery/chem_master/proc/apply_condi_style(obj/item/reagent_containers/condiment/container, list/style)
	container.name = style["name"]
	container.desc = style["desc"]
	container.icon_state = style["icon_state"]
	container.icon_empty = style["icon_empty"]
	container.fill_icon_thresholds = style["fill_icon_thresholds"]
	if ("inhand_icon_state" in style)
		container.inhand_icon_state = style["inhand_icon_state"]
		if (style["lefthand_file"] || style["righthand_file"])
			container.lefthand_file = style["lefthand_file"]
			container.righthand_file = style["righthand_file"]


//Checks to see if the target reagent is being created (reacting) and if so prevents transfer
//Only prevents reactant from being moved so that people can still manlipulate input reagents
/obj/machinery/chem_master/proc/check_reactions(datum/reagent/reagent, datum/reagents/holder)
	if(!reagent)
		return FALSE
	var/canMove = TRUE
	for(var/e in holder.reaction_list)
		var/datum/equilibrium/E = e
		if(E.reaction.reaction_flags & REACTION_COMPETITIVE)
			continue
		for(var/result in E.reaction.required_reagents)
			var/datum/reagent/R = result
			if(R == reagent.type)
				canMove = FALSE
	if(!canMove)
		say("Cannot move arrested chemical reaction reagents!")
	return canMove

/**
 * Machine that allows to identify and separate reagents in fitting container
 * as well as to create new containers with separated reagents in it.
 *
 * All logic related to this is in [/obj/machinery/chem_master] and condimaster specific UI enabled by "condi = TRUE"
 */
/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	desc = "Used to create condiments and other cooking supplies."
	condi = TRUE
