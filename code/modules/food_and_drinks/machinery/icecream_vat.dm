///How many units of each reagent should be added to the icecream vat on Initialize.
#define PREFILL_AMOUNT 5
///How many units of a reagent is needed to make a cone.
#define CONE_REAGENET_NEEDED 1

///The vat is set to dispense ice cream.
#define VAT_MODE_ICECREAM "cones"
///The vat is set to dispense cones.
#define VAT_MODE_CONES "ice cream"

/obj/machinery/icecream_vat
	name = "ice cream vat"
	desc = "Ding-aling ding dong. Get your Nanotrasen-approved ice cream!"
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "icecream_vat"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	layer = BELOW_OBJ_LAYER
	max_integrity = 300

	///Which mode the icecream vat is set to dispense, VAT_MODE_ICECREAM or VAT_MODE_CONES
	var/vat_mode = VAT_MODE_ICECREAM
	///Boolean on whether or not to add 'icecream_vat_reagents' into the icecream vat on Initialize.
	var/preinstall_reagents = TRUE
	///How much of each product type the ice cream vat can make.
	var/list/product_types = list()
	///The selected flavor of ice cream that we'll dispense when hit with an ice cream cone.
	var/selected_flavour = ICE_CREAM_VANILLA
	///List of ice creams as icons used for the radial menu.
	var/static/list/ice_cream_icons
	/// List of prototypes of dispensable ice cream cones. path as key, instance as assoc.
	var/static/list/obj/item/food/icecream/cone_prototypes
	///List of all reagenets the icecream vat will spawn with, if preinstall_reagents is TRUE.
	var/static/list/icecream_vat_reagents = list(
		/datum/reagent/consumable/milk = 6,
		/datum/reagent/consumable/korta_milk = 6,
		/datum/reagent/consumable/flour = 6,
		/datum/reagent/consumable/korta_flour = 6,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/ice = 6,
		/datum/reagent/consumable/coco = 6,
		/datum/reagent/consumable/vanilla = 6,
		/datum/reagent/consumable/berryjuice = 6,
		/datum/reagent/consumable/ethanol/singulo = 6,
		/datum/reagent/consumable/lemonjuice = 6,
		/datum/reagent/consumable/caramel = 6,
		/datum/reagent/consumable/banana = 6,
		/datum/reagent/consumable/orangejuice = 6,
		/datum/reagent/consumable/cream = 6,
		/datum/reagent/consumable/peachjuice = 6,
		/datum/reagent/consumable/cherryjelly = 6,
	)

/obj/machinery/icecream_vat/no_preinstalled_reagents
	preinstall_reagents = FALSE

/obj/machinery/icecream_vat/Initialize(mapload)
	. = ..()

	if(!cone_prototypes)
		cone_prototypes = list()
		for(var/cone_path in typesof(/obj/item/food/icecream))
			var/obj/item/food/icecream/cone = new cone_path
			if(cone.ingredients)
				cone_prototypes[cone_path] = cone
			else
				qdel(cone)
	if(!ice_cream_icons)
		ice_cream_icons = list()
		for(var/flavor in GLOB.ice_cream_flavours)
			var/datum/ice_cream_flavour/flavor_datum = GLOB.ice_cream_flavours[flavor]
			if(flavor_datum.hidden)
				continue
			ice_cream_icons[flavor] = make_ice_cream_color(flavor_datum)

	RegisterSignal(src, COMSIG_ATOM_REAGENT_EXAMINE, PROC_REF(allow_reagent_scan))

	create_reagents(300, NO_REACT|OPENCONTAINER)
	reagents.chem_temp = T0C //So ice doesn't melt
	register_context()

	if(!preinstall_reagents)
		return

	for(var/flavour in GLOB.ice_cream_flavours)
		if(GLOB.ice_cream_flavours[flavour].hidden)
			continue
		product_types[flavour] = PREFILL_AMOUNT
	for(var/cone in cone_prototypes)
		product_types[cone] = PREFILL_AMOUNT
	for(var/reagent in icecream_vat_reagents)
		reagents.add_reagent(reagent, icecream_vat_reagents[reagent], reagtemp = T0C)

/obj/machinery/icecream_vat/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(held_item)
		if(istype(held_item, /obj/item/food/icecream))
			context[SCREENTIP_CONTEXT_LMB] = "Take scoop of [selected_flavour] ice cream"
		return CONTEXTUAL_SCREENTIP_SET

	switch(vat_mode)
		if(VAT_MODE_ICECREAM)
			context[SCREENTIP_CONTEXT_LMB] = "Select flavor"
			context[SCREENTIP_CONTEXT_RMB] = "Change mode to cones"
		if(VAT_MODE_CONES)
			context[SCREENTIP_CONTEXT_LMB] = "Make cone"
			context[SCREENTIP_CONTEXT_RMB] = "Change mode to flavors"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/icecream_vat/attackby(obj/item/reagent_containers/beaker, mob/user, params)
	. = ..()
	if(.)
		return
	if(!beaker || !istype(beaker) || !beaker.reagents || (beaker.item_flags & ABSTRACT) || !beaker.is_open_container())
		return

	var/added_reagents = FALSE
	for(var/datum/reagent/beaker_reagents in beaker.reagents.reagent_list)
		if(beaker_reagents.type in icecream_vat_reagents)
			added_reagents = TRUE
			beaker.reagents.trans_to(src, beaker_reagents.volume, target_id = beaker_reagents.type)

	if(added_reagents)
		update_appearance()
		balloon_alert(user, "refilling reagents")
		playsound(src, 'sound/items/drink.ogg', 25, TRUE)
	else
		balloon_alert(user, "no reagents to transfer!")

/obj/machinery/icecream_vat/attack_hand_secondary(mob/user, list/modifiers)
	if(swap_modes(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/machinery/icecream_vat/attack_robot_secondary(mob/living/silicon/robot/user)
	if(swap_modes(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/machinery/icecream_vat/AltClick(mob/user)
	. = ..()
	swap_modes(user)

/obj/machinery/icecream_vat/interact(mob/living/user)
	. = ..()
	if (.)
		return

	var/list/choices = list()

	switch(vat_mode)
		if(VAT_MODE_ICECREAM)
			for(var/flavor_key in ice_cream_icons)
				var/datum/ice_cream_flavour/flavor_datum = GLOB.ice_cream_flavours[flavor_key]
				var/datum/radial_menu_choice/option = new
				option.image = ice_cream_icons[flavor_key]
				option.info = span_boldnotice("[flavor_datum.ingredients_text]")
				choices[flavor_key] = option
		if(VAT_MODE_CONES)
			for(var/cone_key in cone_prototypes)
				var/obj/item/food/icecream/cone_item = cone_prototypes[cone_key]
				var/datum/radial_menu_choice/option = new
				option.image = cone_prototypes[cone_key]
				option.info = span_boldnotice("[cone_item.ingredients_text]")
				choices[cone_key] = option

	var/choice = show_radial_menu(
		user,
		src,
		choices,
		require_near = TRUE,
		tooltips = TRUE,
		autopick_single_option = FALSE,
	)

	if(!choice)
		return
	var/datum/ice_cream_flavour/flavor = GLOB.ice_cream_flavours[choice]
	if(flavor)
		selected_flavour = flavor.name
		balloon_alert(user, "making [selected_flavour]")
	var/obj/item/food/icecream/cone = cone_prototypes[choice]
	if(cone)
		make_cone(user, choice, cone.ingredients)

/obj/machinery/icecream_vat/proc/make_ice_cream_color(datum/ice_cream_flavour/flavor)
	if(!flavor.color)
		return
	var/image/ice_cream_icon = image('icons/obj/service/kitchen.dmi', "icecream_custom")
	ice_cream_icon.color = flavor.color
	return ice_cream_icon

/obj/machinery/icecream_vat/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NO_DECONSTRUCTION))
		new /obj/item/stack/sheet/iron(loc, 4)
	qdel(src)

///Makes an ice cream cone of the make_type, using ingredients list as reagents used to make it. Puts in user's hand if possible.
/obj/machinery/icecream_vat/proc/make_cone(mob/user, make_type, list/ingredients)
	for(var/reagents_needed in ingredients)
		if(!reagents.has_reagent(reagents_needed, CONE_REAGENET_NEEDED))
			balloon_alert(user, "not enough ingredients!")
			return
	var/cone_type = cone_prototypes[make_type].type
	if(!cone_type)
		return
	var/obj/item/food/icecream/cone = new cone_type(src)

	for(var/reagents_used in ingredients)
		reagents.remove_reagent(reagents_used, CONE_REAGENET_NEEDED)
	balloon_alert_to_viewers("cooks up [cone.name]", "cooks up [cone.name]")
	try_put_in_hand(cone, user)

///Swaps the mode to the next one meant to be selected, then tells the user who changed it.
/obj/machinery/icecream_vat/proc/swap_modes(mob/user)
	if(!user.can_perform_action(src))
		return FALSE
	switch(vat_mode)
		if(VAT_MODE_ICECREAM)
			vat_mode = VAT_MODE_CONES
		if(VAT_MODE_CONES)
			vat_mode = VAT_MODE_ICECREAM
	balloon_alert(user, "dispensing [vat_mode]")
	return TRUE

///Allows any user to see what reagents are in the ice cream vat regardless of special gear.
/obj/machinery/icecream_vat/proc/allow_reagent_scan(datum/source, mob/user, list/examine_list, can_see_insides = FALSE)
	SIGNAL_HANDLER
	return ALLOW_GENERIC_REAGENT_EXAMINE

#undef VAT_MODE_ICECREAM
#undef VAT_MODE_CONES
#undef CONE_REAGENET_NEEDED
#undef PREFILL_AMOUNT
