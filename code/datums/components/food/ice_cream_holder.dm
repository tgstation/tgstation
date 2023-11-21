#define SWEETENER_PER_SCOOP 10
#define EXTRA_MAX_VOLUME_PER_SCOOP 20

/// Ice Cream Holder: Allows the edible parent object to be used as an ice cream cone (or cup... in a next future).
/datum/component/ice_cream_holder
	/// List of servings of ice cream it is holding at the moment.
	var/list/scoops
	/// Servings of ice cream with custom names as key, and their base ones as assoc. (useful for mob/custom ice cream)
	var/list/special_scoops
	/*
	 * List of scoop overlays to add on update_overlays(). Separated from list/scoops considering how byond is inconsistent
	 * at handling duplicate keys and assocs.
	 */
	var/list/scoop_overlays
	/// Number of servings of ice cream it can get through normal methods.
	var/max_scoops = DEFAULT_MAX_ICE_CREAM_SCOOPS
	/// Changes the name of the food depending on amount and flavours of ice cream on it.
	var/change_name = TRUE
	/// name to use, if set, in place of [src] on update_name.
	var/filled_name
	/*
	 * Ditto as change_name, but for descriptions.
	 * If false, an examine signal is registered to let the amount and types of held ice cream be known anyway.
	 */
	var/change_desc = FALSE
	/// pixel offsets for scoop overlays. Useful for objects with off-centered sprites.
	var/x_offset = 0
	var/y_offset = 0
	/*
	 * Extra reagent generated each time a new serving is added. Because apparently our sundaes are instead banana splits!
	 * And banana juice plus sugar equals laughter! (I'll leave it unchanged for honkdaes though)
	 */
	var/datum/reagent/sweetener


/datum/component/ice_cream_holder/Initialize(max_scoops = DEFAULT_MAX_ICE_CREAM_SCOOPS,
											change_name = TRUE,
											filled_name,
											change_desc = FALSE,
											x_offset = 0,
											y_offset = 0,
											datum/reagent/sweetener = /datum/reagent/consumable/sugar,
											list/prefill_flavours)
	if(!IS_EDIBLE(parent)) /// There is no easy way to add servings to those non-item edibles, but I won't stop you.
		return COMPONENT_INCOMPATIBLE

	var/atom/owner = parent

	src.max_scoops = max_scoops
	src.change_name = change_name
	src.filled_name = filled_name
	src.change_desc = change_desc
	src.x_offset = x_offset
	src.y_offset = y_offset
	src.sweetener = sweetener

	RegisterSignal(owner, COMSIG_ITEM_ATTACK_ATOM, PROC_REF(on_item_attack_obj))
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	if(change_name)
		RegisterSignal(owner, COMSIG_ATOM_UPDATE_NAME, PROC_REF(on_update_name))
	if(!change_desc)
		RegisterSignal(owner, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))
	else
		RegisterSignal(owner, COMSIG_ATOM_UPDATE_DESC, PROC_REF(on_update_desc))

	RegisterSignal(owner, COMSIG_ITEM_IS_CORRECT_CUSTOM_ORDER, PROC_REF(check_food_order))

	RegisterSignal(owner, COMSIG_ITEM_SOLD_TO_CUSTOMER, PROC_REF(sell_ice_cream))

	if(prefill_flavours)
		for(var/entry in prefill_flavours)
			var/list/flavour_args = list(src) + prefill_flavours[entry]
			var/datum/ice_cream_flavour/flavour = GLOB.ice_cream_flavours[entry]
			flavour?.add_flavour(arglist(flavour_args))

/datum/component/ice_cream_holder/proc/on_update_name(atom/source, updates)
	SIGNAL_HANDLER
	var/obj/obj = source
	if(istype(obj) && obj.renamedByPlayer) //Renamed by the player.
		return
	var/scoops_len = length(scoops)
	if(!scoops_len)
		source.name = initial(source.name)
	else
		var/name_to_use = filled_name || initial(source.name)
		var/list/unique_list = unique_list(scoops)
		if(scoops_len > 1 && length(unique_list) == 1) // multiple flavours, and all of the same type
			source.name = "[make_tuple(scoops_len)] [scoops[1]] [name_to_use]" // "double vanilla" sounds cooler than just "vanilla"
		else
			source.name = "[english_list(unique_list)] [name_to_use]"

/datum/component/ice_cream_holder/proc/on_update_desc(atom/source, updates)
	SIGNAL_HANDLER
	var/obj/obj = source
	if(istype(obj) && obj.renamedByPlayer) //Renamed by the player.
		return
	var/scoops_len = length(scoops)
	if(!scoops_len)
		source.desc = initial(source.desc)
	else if(scoops_len == 1 || length(unique_list(scoops)) == 1) /// Only one flavour.
		var/key = scoops[1]
		var/datum/ice_cream_flavour/flavour = GLOB.ice_cream_flavours[LAZYACCESS(special_scoops, key) || key]
		if(!flavour?.desc) //I scream.
			source.desc = initial(source.desc)
		else
			source.desc = replacetext(replacetext("[flavour.desc_prefix] [flavour.desc]", "$CONE_NAME", initial(source.name)), "$CUSTOM_NAME", key)
	else /// Many flavours.
		source.desc = "A delicious [initial(source.name)] filled with scoops of [english_list(scoops)] icecream. That's as many as [scoops_len] scoops!"

/datum/component/ice_cream_holder/proc/on_examine_more(atom/source, mob/mob, list/examine_list)
	SIGNAL_HANDLER
	var/scoops_len = length(scoops)
	if(scoops_len == 1 || length(unique_list(scoops)) == 1) /// Only one flavour.
		var/key = scoops[1]
		var/datum/ice_cream_flavour/flavour = GLOB.ice_cream_flavours[LAZYACCESS(special_scoops, key) || key]
		if(flavour?.desc) //I scream.
			examine_list += "[source.p_Theyre()] filled with scoops of [flavour ? flavour.name : "broken, unhappy"] icecream."
		else
			examine_list += replacetext(replacetext("[source.p_Theyre()] [flavour.desc]", "$CONE_NAME", initial(source.name)), "$CUSTOM_NAME", key)
	else /// Many flavours.
		examine_list += "[source.p_Theyre()] filled with scoops of [english_list(scoops)] icecream. That's as many as [scoops_len] scoops!"

/datum/component/ice_cream_holder/proc/on_update_overlays(atom/source, list/new_overlays)
	SIGNAL_HANDLER
	if(!scoops)
		return
	var/added_offset = 0
	for(var/i in 1 to length(scoop_overlays))
		var/image/overlay = scoop_overlays[i]
		if(istext(overlay))
			overlay = image('icons/obj/service/kitchen.dmi', overlay)
		overlay.pixel_x = x_offset
		overlay.pixel_y = y_offset + added_offset
		new_overlays += overlay
		added_offset += ICE_CREAM_SCOOP_OFFSET

/// Attack the ice cream vat to get some ice cream. This will change as new ways of getting ice cream are added.
/datum/component/ice_cream_holder/proc/on_item_attack_obj(obj/item/source, obj/target, mob/user)
	SIGNAL_HANDLER
	if(!istype(target, /obj/machinery/icecream_vat))
		return
	var/obj/machinery/icecream_vat/dispenser = target
	if(length(scoops) < max_scoops)
		if(dispenser.product_types[dispenser.selected_flavour] > 0)
			var/datum/ice_cream_flavour/flavour = GLOB.ice_cream_flavours[dispenser.selected_flavour]
			if(flavour.add_flavour(src, dispenser.beaker?.reagents.total_volume ? dispenser.beaker.reagents : null))
				dispenser.visible_message("[icon2html(dispenser, viewers(source))] [span_info("[user] scoops delicious [dispenser.selected_flavour] ice cream into [source].")]")
				dispenser.product_types[dispenser.selected_flavour]--
				INVOKE_ASYNC(dispenser, TYPE_PROC_REF(/obj/machinery/icecream_vat, updateDialog))
		else
			to_chat(user, span_warning("There is not enough ice cream left!"))
	else
		to_chat(user, span_warning("[source] can't hold anymore ice cream!"))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/ice_cream_holder/proc/check_food_order(obj/item/source, datum/custom_order/our_order)
	SIGNAL_HANDLER
	if(!istype(our_order, /datum/custom_order/icecream))
		return FALSE
	var/datum/custom_order/icecream/icecream_order = our_order
	if(parent.type != icecream_order.cone_type) //check that the cone type matches
		return FALSE

	// We don't want to stop ice creams from being sold because of their order. we aren't that finnicky.
	var/our_scoops = scoops.Copy()
	sortTim(our_scoops, cmp = GLOBAL_PROC_REF(cmp_text_asc))

	//Make sure the flavors and number of scoops match.
	if(compare_list(our_scoops, icecream_order.wanted_flavors))
		return COMPONENT_CORRECT_ORDER

/datum/component/ice_cream_holder/proc/sell_ice_cream(obj/item/source, mob/living/simple_animal/robot_customer/sold_to)
	SIGNAL_HANDLER

	//the price of ice cream scales with the number of scoops. Yummy.
	var/venue_price = length(scoops) * FOOD_PRICE_TRASH * 2

	var/datum/venue/venue_to_pay = sold_to.ai_controller?.blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	new /obj/item/holochip(get_turf(source), venue_price)
	venue_to_pay.total_income += venue_price
	playsound(get_turf(source), 'sound/effects/cashregister.ogg', 60, TRUE)


/////ICE CREAM FLAVOUR DATUM STUFF

GLOBAL_LIST_INIT_TYPED(ice_cream_flavours, /datum/ice_cream_flavour, init_ice_cream_flavours())

/proc/init_ice_cream_flavours()
	. = list()
	for(var/datum/ice_cream_flavour/flavour as anything in subtypesof(/datum/ice_cream_flavour))
		flavour = new flavour
		.[flavour.name] = flavour

/*
 * The ice cream flavour datum. What makes these digital, frozen snacks so yummy.
 * They are singletons, so please bear with me if they feel a little tortous to use at time.
 */
/datum/ice_cream_flavour
	/// Make sure the same name is not found on other types; These are singletons keyed by their name after all.
	var/name = "Coderlicious Gourmet Double Deluxe Undefined"
	/// The colour of the ice cream for non-custom flavours.
	var/color = COLOR_ICECREAM_VANILLA
	/*
	 * The fluff text sent to the examiner when the snack has only one flavour of ice cream.
	 * $CONE_NAME and $CUSTOM_NAME are both placeholders for the cone and the custom ice cream name respectively.
	 */
	var/desc = ""
	/*
	 * Depending on the value of the [/datum/component/ice_cream/var/change_desc] bool, 'desc' may effectively be the description
	 * or a text string shown on [/atom/proc/examine_more]. In the former case, the desc is joined with this prefix.
	 */
	var/desc_prefix = "A delicious $CONE_NAME"
	/// The ingredients required to produce a unit with the ice cream vat, these are multiplied by 3.
	var/list/ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/vanilla)
	/// The same as above, but in a readable text generated on New() that can also contain fluff ingredients such as "lot of love" or "optional flavorings".
	var/ingredients_text = ""
	/// the reagent added in 'add_flavour()'
	var/reagent_type
	/// the amount of reagent added in 'add_flavour()'
	var/reagent_amount = 3
	/// Is this flavour shown in the ice cream vat menu or not?
	var/hidden = FALSE

/datum/ice_cream_flavour/New()
	if(ingredients)
		ingredients_text = "(Ingredients: [reagent_paths_list_to_text(ingredients, ingredients_text)])"

/// Adds a new flavour to the ice cream cone.
/datum/ice_cream_flavour/proc/add_flavour(datum/component/ice_cream_holder/target, datum/reagents/R, custom_name)
	var/atom/owner = target.parent
	LAZYADD(target.scoops, custom_name || name)
	if(color)
		var/image/flavoring = image('icons/obj/service/kitchen.dmi', "icecream_custom")
		flavoring.color = color
		LAZYADD(target.scoop_overlays, flavoring)
	if(custom_name)
		LAZYSET(target.special_scoops, custom_name, name)

	owner.reagents.maximum_volume += EXTRA_MAX_VOLUME_PER_SCOOP
	if(reagent_type)
		owner.reagents.add_reagent(reagent_type, reagent_amount, reagtemp = T0C)
	// Add some sugar/sweetener to make it a more substantial snack.
	owner.reagents.add_reagent(target.sweetener, SWEETENER_PER_SCOOP, reagtemp = T0C)

	var/update_flags = UPDATE_ICON
	if(target.change_name)
		update_flags |= UPDATE_NAME
	if(target.change_desc)
		update_flags |= UPDATE_DESC
	owner.update_appearance(update_flags)
	return TRUE

///// OUR TYPES OF ICE CREAM, COME GET SOME.

/datum/ice_cream_flavour/vanilla
	name = ICE_CREAM_VANILLA
	desc = "filled with vanilla ice cream. All the other ice creams take content from it."
	reagent_type = /datum/reagent/consumable/vanilla

/datum/ice_cream_flavour/chocolate
	name = ICE_CREAM_CHOCOLATE
	color = COLOR_ICECREAM_CHOCOLATE
	desc = "filled with chocolate ice cream. Surprisingly, made with real cocoa."
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/coco)
	reagent_type = /datum/reagent/consumable/coco

/datum/ice_cream_flavour/strawberry
	name = ICE_CREAM_STRAWBERRY
	color = COLOR_ICECREAM_STRAWBERRY
	desc = "filled with strawberry ice cream. Definitely not made with real strawberries."
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/berryjuice)
	reagent_type = /datum/reagent/consumable/berryjuice

/datum/ice_cream_flavour/blue
	name = ICE_CREAM_BLUE
	color = COLOR_ICECREAM_BLUE
	desc = "filled with blue ice cream. Made with real... blue?"
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/ethanol/singulo)
	reagent_type = /datum/reagent/consumable/ethanol/singulo

/datum/ice_cream_flavour/lemon
	name = ICE_CREAM_LEMON
	color = COLOR_ICECREAM_LEMON
	desc = "filled with lemon sorbet. Like frozen lemonade in a cone."
	ingredients = list(/datum/reagent/consumable/ice, /datum/reagent/consumable/lemonjuice) //contains no milk
	reagent_type = /datum/reagent/consumable/lemonjuice

/datum/ice_cream_flavour/caramel
	name = ICE_CREAM_CARAMEL
	color = COLOR_ICECREAM_CARAMEL
	desc = "filled with caramel ice cream. It is deliciously sweet."
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/caramel)
	reagent_type = /datum/reagent/consumable/caramel

/datum/ice_cream_flavour/banana
	name = ICE_CREAM_BANANA
	color = COLOR_YELLOW
	desc = "filled with banana ice cream. Honk!"
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/banana)
	reagent_type = /datum/reagent/consumable/banana

/datum/ice_cream_flavour/orange_cream
	name = ICE_CREAM_ORANGE_CREAM
	color = COLOR_ICECREAM_ORANGESICLE
	desc = "filled with orange creamsicle. Not quite the same off the stick..."
	ingredients = list(/datum/reagent/consumable/cream, /datum/reagent/consumable/ice, /datum/reagent/consumable/orangejuice)
	reagent_type = /datum/reagent/consumable/orangejuice

/datum/ice_cream_flavour/peach
	name = ICE_CREAM_PEACH
	color = COLOR_ICECREAM_PEACH
	desc = "filled with limited edition peach flavour. Enjoy it while it lasts!"
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/peachjuice)
	reagent_type = /datum/reagent/consumable/peachjuice

/datum/ice_cream_flavour/vanilla/korta
	name = ICE_CREAM_KORTA_VANILLA
	desc = "filled with vanilla ice cream made with korta milk. Lizards love it!"
	ingredients = list(/datum/reagent/consumable/korta_milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/vanilla)

/datum/ice_cream_flavour/cherry_chocolate
	name = ICE_CREAM_CHERRY_CHOCOLATE
	color = COLOR_ICECREAM_CHERRY_CHOCOLATE
	desc = "filled with cherry chocolate chip ice cream. It is wonderfully tangy and sweet."
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/coco, /datum/reagent/consumable/cherryjelly)
	reagent_type = /datum/reagent/consumable/cherryjelly

/datum/ice_cream_flavour/mob
	name = ICE_CREAM_MOB
	color = COLOR_ICECREAM_STRAWBERRY
	desc = "filled with bright red ice cream. That's probably not strawberry..."
	desc_prefix = "A suspicious $CONE_NAME"
	reagent_type = /datum/reagent/consumable/liquidgibs
	hidden = TRUE

/datum/ice_cream_flavour/custom
	name = ICE_CREAM_CUSTOM
	color = "" //has its own mutable appearance overlay
	desc = "filled with artisanal icecream. Made with real $CUSTOM_NAME. Ain't that something."
	ingredients = list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice)
	ingredients_text = "optional flavorings"

/datum/ice_cream_flavour/custom/korta
	name = ICE_CREAM_KORTA_CUSTOM
	desc = "filled with artisanal lizard-friendly icecream. Made with real $CUSTOM_NAME. Ain't that something."
	ingredients = list(/datum/reagent/consumable/korta_milk, /datum/reagent/consumable/ice)
	ingredients_text = "optional flavorings"

/datum/ice_cream_flavour/custom/add_flavour(datum/component/ice_cream_holder/target, datum/reagents/R, custom_name)
	if(!R || R.total_volume < 4) //consumable reagents have stronger taste so higher volume are required to allow non-food flavourings to break through better.
		return GLOB.ice_cream_flavours[ICE_CREAM_BLAND].add_flavour(target) //Bland, sugary ice and milk.
	var/image/flavoring = image('icons/obj/service/kitchen.dmi', "icecream_custom")
	var/datum/reagent/master = R.get_master_reagent()
	custom_name = lowertext(master.name) // reagent names are capitalized, while items' aren't.
	flavoring.color = master.color
	LAZYADD(target.scoop_overlays, flavoring)
	. = ..() // Make some space for reagents before attempting to transfer some to the target.
	R.trans_to(target.parent, 4)

/datum/ice_cream_flavour/bland
	name = ICE_CREAM_BLAND
	color = COLOR_ICECREAM_CUSTOM
	desc = "filled with anemic, flavorless icecream. You wonder why this was ever scooped..."
	hidden = TRUE

#undef SWEETENER_PER_SCOOP
#undef EXTRA_MAX_VOLUME_PER_SCOOP
