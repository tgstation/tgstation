#define PREFILL_AMOUNT 5

/obj/machinery/icecream_vat
	name = "ice cream vat"
	desc = "Ding-aling ding dong. Get your Nanotrasen-approved ice cream!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_vat"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	layer = BELOW_OBJ_LAYER
	max_integrity = 300
	var/list/product_types = list()
	var/selected_flavour = ICE_CREAM_VANILLA
	var/obj/item/reagent_containers/beaker
	/// List of prototypes of dispensable ice cream cones. path as key, instance as assoc.
	var/static/list/obj/item/food/icecream/cone_prototypes
	var/static/list/icecream_vat_reagents = list(
		/datum/reagent/consumable/milk = 6,
		/datum/reagent/consumable/flour = 6,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/ice = 6,
		/datum/reagent/consumable/coco = 6,
		/datum/reagent/consumable/vanilla = 6,
		/datum/reagent/consumable/berryjuice = 6,
		/datum/reagent/consumable/ethanol/singulo = 6)

/obj/machinery/icecream_vat/Initialize(mapload)
	. = ..()

	if(!cone_prototypes)
		cone_prototypes = list()
		for(var/cone_path in typesof(/obj/item/food/icecream))
			var/obj/item/food/icecream/cone = new cone_path
			if(cone.ingredients)
				cone_prototypes[cone_path] = cone
				cone.ingredients_text = "(Ingredients: [reagent_paths_list_to_text(cone.ingredients)])"
			else
				qdel(cone)

	create_reagents(300, NO_REACT | OPENCONTAINER)
	reagents.chem_temp = T0C //So ice doesn't melt
	for(var/flavour in GLOB.ice_cream_flavours)
		if(GLOB.ice_cream_flavours[flavour].hidden)
			continue
		product_types[flavour] = PREFILL_AMOUNT
	for(var/cone in cone_prototypes)
		product_types[cone] = PREFILL_AMOUNT

	for(var/reagent in icecream_vat_reagents)
		reagents.add_reagent(reagent, icecream_vat_reagents[reagent], reagtemp = T0C)

/obj/machinery/icecream_vat/ui_interact(mob/user)
	. = ..()
	var/dat
	dat += "<b>ICE CREAM</b><br><div class='statusDisplay'>"
	dat += "<b>Dispensing: [selected_flavour] icecream </b> <br><br>"
	for(var/flavour in GLOB.ice_cream_flavours)
		if(GLOB.ice_cream_flavours[flavour].hidden)
			continue
		dat += "<b>[capitalize(flavour)] ice cream:</b> <a href='?src=[REF(src)];select=[flavour]'><b>Select</b></a> <a href='?src=[REF(src)];make=[flavour];amount=1'><b>Make</b></a> <a href='?src=[REF(src)];make=[flavour];amount=5'><b>x5</b></a> [product_types[flavour]] scoops left[GLOB.ice_cream_flavours[flavour].ingredients_text].<br>"
	dat += "<br><b>CONES</b><br><div class='statusDisplay'>"
	for(var/cone in cone_prototypes)
		dat += "<b>[capitalize(cone_prototypes[cone].name)]s:</b> <a href='?src=[REF(src)];cone=[cone]'><b>Dispense</b></a> <a href='?src=[REF(src)];make_cone=[cone];amount=1'><b>Make</b></a> <a href='?src=[REF(src)];make_cone=[cone];amount=5'><b>x5</b></a> [product_types[cone]] cones left[cone_prototypes[cone].ingredients_text].<br>"
	dat += "<br>"
	if(beaker)
		dat += "<b>BEAKER CONTENT</b><br><div class='statusDisplay'>"
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			dat += "[R.name]: [R.volume]u<br>"
		dat += "<a href='?src=[REF(src)];refill=1'><b>Refill from beaker</b></a></div>"
	dat += "<br>"
	dat += "<b>VAT CONTENT</b><br>"
	for(var/datum/reagent/R in reagents.reagent_list)
		dat += "[R.name]: [R.volume]"
		dat += "<A href='?src=[REF(src)];disposeI=[R.type]'>Purge</A><BR>"
	dat += "<a href='?src=[REF(src)];refresh=1'>Refresh</a> <a href='?src=[REF(src)];close=1'>Close</a>"

	var/datum/browser/popup = new(user, "icecreamvat","Icecream Vat", 700, 500, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/icecream_vat/attackby(obj/item/O, mob/user, params)
	if(is_reagent_container(O) && !(O.item_flags & ABSTRACT) && O.is_open_container())
		. = TRUE //no afterattack
		var/obj/item/reagent_containers/B = O
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, span_notice("You add [B] to [src]."))
		updateUsrDialog()
		update_appearance()
		return
	else if(O.is_drainable())
		return
	else
		return ..()

/obj/machinery/icecream_vat/proc/RefillFromBeaker()
	if(!beaker || !beaker.reagents)
		return
	for(var/datum/reagent/R in beaker.reagents.reagent_list)
		if(R.type in icecream_vat_reagents)
			beaker.reagents.trans_id_to(src, R.type, R.volume)
			say("Internalizing reagent.")
			playsound(src, 'sound/items/drink.ogg', 25, TRUE)
	return

/obj/machinery/icecream_vat/proc/make(mob/user, make_type, amount, list/ingredients)
	var/recipe_amount = amount * 3 //prevents reagent duping by requring roughly the amount of reagenst you gain back by grinding.
	for(var/R in ingredients)
		if(!reagents.has_reagent(R, recipe_amount))
			amount = 0
			break
	if(amount)
		for(var/R in ingredients)
			reagents.remove_reagent(R, recipe_amount)
		product_types[make_type] += amount
		var/obj/item/food/icecream/cone = cone_prototypes[make_type]
		if(cone)
			visible_message(span_info("[user] cooks up some [cone.name]s."))
		else
			visible_message(span_info("[user] whips up some [make_type] icecream."))
	else
		to_chat(user, span_warning("You don't have the ingredients to make this!"))

/obj/machinery/icecream_vat/Topic(href, href_list)
	if(..())
		return
	if(href_list["select"])
		var/datum/ice_cream_flavour/flavour = GLOB.ice_cream_flavours[href_list["select"]]
		if(!flavour || flavour.hidden) //Nice try, tex.
			return
		visible_message(span_notice("[usr] sets [src] to dispense [href_list["select"]] flavoured ice cream."))
		selected_flavour = flavour.name

	if(href_list["cone"])
		var/obj/item/food/icecream/cone_path = text2path(href_list["cone"])
		if(!cone_path)
			return
		if(product_types[cone_path] >= 1)
			product_types[cone_path]--
			var/obj/item/food/icecream/cone = new cone_path(loc)
			visible_message(span_info("[usr] dispenses a crunchy [cone.name] from [src]."))
		else
			to_chat(usr, span_warning("There are no [initial(cone_path.name)]s left!"))

	if(href_list["make"])
		var/datum/ice_cream_flavour/flavour = GLOB.ice_cream_flavours[href_list["make"]]
		if(!flavour || flavour.hidden) //Nice try, tex.
			return
		var/amount = (text2num(href_list["amount"]))
		make(usr, href_list["make"], amount, flavour.ingredients)

	if(href_list["make_cone"])
		var/path = text2path(href_list["make_cone"])
		var/obj/item/food/icecream/cone = cone_prototypes[path]
		if(!cone) //Nice try, tex.
			return
		var/amount = (text2num(href_list["amount"]))
		make(usr, path, amount, cone.ingredients)

	if(href_list["disposeI"])
		reagents.del_reagent(text2path(href_list["disposeI"]))

	if(href_list["refill"])
		RefillFromBeaker()

	updateDialog()

	if(href_list["refresh"])
		updateDialog()

	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null,"window=icecreamvat")
	return

/obj/machinery/icecream_vat/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 4)
	qdel(src)

/obj/machinery/icecream_vat/AltClick(mob/living/user)
	. = ..()
	if(!can_interact(user) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	replace_beaker(user)

/obj/machinery/icecream_vat/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		user.put_in_hands(beaker)
		beaker = null
	if(new_beaker)
		beaker = new_beaker
	return TRUE

#undef PREFILL_AMOUNT
