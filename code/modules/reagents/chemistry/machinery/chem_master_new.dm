#define MODE_DESTROY 0
#define MODE_MOVE 1
#define BEAKER "beaker"
#define BUFFER "buffer"
#define CONDIMENTS "condiments"
#define TUBES "tubes"
#define PILLS "pills"
#define PATCHES "patches"

/// List of containers the Chem Master machine can print
GLOBAL_LIST_INIT(chem_master_containers, list(
	CONDIMENTS = list(
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/condiment/flour,
		/obj/item/reagent_containers/condiment/sugar,
		/obj/item/reagent_containers/condiment/rice,
		/obj/item/reagent_containers/condiment/cornmeal,
		/obj/item/reagent_containers/condiment/milk,
		/obj/item/reagent_containers/condiment/soymilk,
		/obj/item/reagent_containers/condiment/yoghurt,
		/obj/item/reagent_containers/condiment/saltshaker,
		/obj/item/reagent_containers/condiment/peppermill,
		/obj/item/reagent_containers/condiment/soysauce,
		/obj/item/reagent_containers/condiment/bbqsauce,
		/obj/item/reagent_containers/condiment/enzyme,
		/obj/item/reagent_containers/condiment/hotsauce,
		/obj/item/reagent_containers/condiment/coldsauce,
		/obj/item/reagent_containers/condiment/mayonnaise,
		/obj/item/reagent_containers/condiment/ketchup,
		/obj/item/reagent_containers/condiment/quality_oil,
		/obj/item/reagent_containers/condiment/cooking_oil,
		/obj/item/reagent_containers/condiment/peanut_butter,
		/obj/item/reagent_containers/condiment/cherryjelly,
		/obj/item/reagent_containers/condiment/honey,
		/obj/item/reagent_containers/condiment/pack,
	),
	TUBES = list(
		/obj/item/reagent_containers/cup/tube
	),
	PILLS = typecacheof(list(
		/obj/item/reagent_containers/pill/style
	)),
	PATCHES = typecacheof(list(
		/obj/item/reagent_containers/pill/patch/style
	)),
))

/obj/machinery/chem_master_new
	name = "ChemMaster 3000"
	desc = "Used to separate chemicals and distribute them in a variety of forms."
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "chemmaster"
	base_icon_state = "chemmaster"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.2
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_master
	/// Inserted reagent container
	var/obj/item/reagent_containers/beaker
	/// Whether separated reagents should be moved back to container or destroyed.
	var/mode = MODE_MOVE
	/// List of printable container types
	var/list/printable_containers = list()
	/// Selected printable container type
	var/selected_container

/obj/machinery/chem_master_new/Initialize(mapload)
	create_reagents(100)
	load_printable_containers()
	var/obj/item/reagent_containers/default_container = printable_containers[printable_containers[1]][1]
	selected_container = REF(default_container)
	return ..()

/obj/machinery/chem_master_new/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_master_new/on_deconstruction()
	replace_beaker()
	return ..()

/obj/machinery/chem_master_new/RefreshParts()
	. = ..()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/cup/beaker/beaker in component_parts)
		reagents.maximum_volume += beaker.reagents.maximum_volume

/obj/machinery/chem_master_new/update_icon_state()
	icon_state = "[base_icon_state]"

	if(machine_stat & BROKEN)
		icon_state += "_broken"
	else if(machine_stat & NOPOWER)
		icon_state += "_nopower"

	return ..()

/obj/machinery/chem_master_new/update_overlays()
	. = ..()
	if(!isnull(beaker))
		. += mutable_appearance(icon, base_icon_state + "_overlay_container_idle")
	if(!(machine_stat & (NOPOWER | BROKEN)))
		. += emissive_appearance(icon, base_icon_state + "_overlay_lightmask", src, alpha = src.alpha)
	if(machine_stat & BROKEN)
		. += mutable_appearance(icon, base_icon_state + "_overlay_brokenlight")
		. += emissive_appearance(icon, base_icon_state + "_overlay_brokenlight", src, alpha = src.alpha)

/obj/machinery/chem_master_new/attackby(obj/item/item, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, item))
		update_appearance(UPDATE_ICON)
		return
	else if(default_deconstruction_crowbar(item))
		return
	else if(is_reagent_container(item) && !(item.item_flags & ABSTRACT) && item.is_open_container())
		. = TRUE // No afterattack
		var/obj/item/reagent_containers/beaker = item
		replace_beaker(user, beaker)
		if(!panel_open)
			ui_interact(user)
	return ..()

/obj/machinery/chem_master_new/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH|FORBID_TELEKINESIS_REACH))
		return
	replace_beaker(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/chem_master_new/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/chem_master_new/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/// Insert new beaker and/or eject the inserted one
/obj/machinery/chem_master_new/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(!user.transferItemToLoc(new_beaker, src))
		return FALSE
	if(beaker)
		try_put_in_hand(beaker, user)
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/machinery/chem_master_new/proc/load_printable_containers()
	printable_containers = list(
		TUBES = GLOB.chem_master_containers[TUBES],
		PILLS = GLOB.chem_master_containers[PILLS],
		PATCHES = GLOB.chem_master_containers[PATCHES],
	)

/obj/machinery/chem_master_new/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/chemmaster)
	)

/obj/machinery/chem_master_new/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMasterNew", name)
		ui.open()

/obj/machinery/chem_master_new/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	for(var/category in printable_containers)
		var/container_data = list()
		for(var/obj/item/reagent_containers/container as anything in printable_containers[category])
			container_data += list(list(
				"icon" = sanitize_css_class_name("[container]"),
				"ref" = REF(container),
				"name" = initial(container.name),
				"volume" = initial(container.volume),
			))
		data["categories"]+= list(list(
			"name" = category,
			"containers" = container_data,
		))

	return data

/obj/machinery/chem_master_new/ui_data(mob/user)
	var/list/data = list()

	data["hasBeaker"] = beaker ? TRUE : FALSE
	data["beakerCurrentVolume"] = beaker ? round(beaker.reagents.total_volume, 0.01) : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	var/list/beaker_contents = list()
	if(beaker)
		for(var/datum/reagent/reagent in beaker.reagents.reagent_list)
			beaker_contents.Add(list(list("name" = reagent.name, "id" = ckey(reagent.name), "volume" = round(reagent.volume, 0.01))))
	data["beakerContents"] = beaker_contents

	var/list/buffer_contents = list()
	if(reagents.total_volume)
		for(var/datum/reagent/reagent in reagents.reagent_list)
			buffer_contents.Add(list(list("name" = reagent.name, "id" = ckey(reagent.name), "volume" = round(reagent.volume, 0.01))))
	data["bufferContents"] = buffer_contents
	data["bufferCurrentVolume"] = round(reagents.total_volume, 0.01)

	data["mode"] = mode

	data["selectedContainerRef"] = selected_container
	var/obj/item/reagent_containers/container = locate(selected_container)
	data["selectedContainerVolume"] = initial(container.volume)

	return data

/obj/machinery/chem_master_new/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "eject")
		replace_beaker(usr)
		return TRUE

	if(action == "transfer")
		var/reagent_type = GLOB.name2reagent[params["reagentId"]]
		var/amount = text2num(params["amount"])
		var/target = params["target"]
		return transfer_reagent(reagent_type, amount, target)

	if(action == "toggleMode")
		mode = !mode
		return TRUE

	if(action == "selectContainer")
		selected_container = params["ref"]
		return TRUE

	if(action == "create")
		if(reagents.total_volume == 0)
			return FALSE
		var/item_count = text2num(params["itemCount"])
		if(item_count <= 0)
			return FALSE
		create_containers(item_count)
		return TRUE

/// Create N selected containers with reagents from buffer split between them
/obj/machinery/chem_master_new/proc/create_containers(item_count = 1)
	var/obj/item/reagent_containers/container_style = locate(selected_container)
	var/vol_each = reagents.total_volume / item_count

	// Generate item name
	var/item_name_default = initial(container_style.name)
	if(!(initial(container_style.reagent_flags) & OPENCONTAINER))
		item_name_default = "[reagents.get_master_reagent_name()] [item_name_default] ([vol_each]u)"
	var/item_name = tgui_input_text(usr,
		"Container name",
		"Name",
		item_name_default,
		MAX_NAME_LEN)
	if(!item_name || !reagents.total_volume || !src || QDELETED(src) || !usr.can_perform_action(src, ALLOW_SILICON_REACH))
		return FALSE

	// Print and fill containers
	use_power(active_power_usage)
	for(var/i in 1 to item_count)
		var/obj/item/reagent_containers/item = new container_style(drop_location())
		adjust_item_drop_location(item)
		item.name = item_name
		item.reagents.clear_reagents()
		reagents.trans_to(item, vol_each, transfered_by = src)
	return TRUE

/// Transfer reagents to specified target from the opposite source
/obj/machinery/chem_master_new/proc/transfer_reagent(reagent_type, amount, target)
	if (amount == -1)
		amount = text2num(input("Enter the amount you want to transfer:", name, ""))
	if (amount == null || amount <= 0)
		return FALSE
	if (!beaker)
		return FALSE

	use_power(active_power_usage)

	if (target == BUFFER)
		var/datum/reagent/reagent = beaker.reagents.get_reagent(reagent_type)
		if(!check_reactions(reagent, beaker.reagents))
			return FALSE
		beaker.reagents.trans_id_to(src, reagent_type, amount)
		return TRUE

	if (target == BEAKER && mode == MODE_DESTROY)
		reagents.remove_reagent(reagent_type, amount)
		return TRUE

	if (target == BEAKER && mode == MODE_MOVE)
		var/datum/reagent/reagent = reagents.get_reagent(reagent_type)
		if(!check_reactions(reagent, reagents))
			return FALSE
		reagents.trans_id_to(beaker, reagent_type, amount)
		return TRUE

	return FALSE

/// Checks to see if the target reagent is being created (reacting) and if so prevents transfer
/// Only prevents reactant from being moved so that people can still manlipulate input reagents
/obj/machinery/chem_master_new/proc/check_reactions(datum/reagent/reagent, datum/reagents/holder)
	if(!reagent)
		return FALSE
	var/canMove = TRUE
	for(var/datum/equilibrium/equilibrium as anything in holder.reaction_list)
		if(equilibrium.reaction.reaction_flags & REACTION_COMPETITIVE)
			continue
		for(var/datum/reagent/result as anything in equilibrium.reaction.required_reagents)
			if(result == reagent.type)
				canMove = FALSE
	if(!canMove)
		say("Cannot move reagent during reaction!")
	return canMove

/obj/machinery/chem_master_new/condimaster
	name = "CondiMaster 3000"
	desc = "Used to create condiments and other cooking supplies."

/obj/machinery/chem_master_new/condimaster/load_printable_containers()
	printable_containers = list(
		CONDIMENTS = GLOB.chem_master_containers[CONDIMENTS],
	)

#undef MODE_DESTROY
#undef MODE_MOVE
#undef BEAKER
#undef BUFFER
#undef CONDIMENTS
#undef TUBES
#undef PILLS
#undef PATCHES
