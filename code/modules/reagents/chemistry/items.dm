///if the ph_meter gives a detailed output
#define DETAILED_CHEM_OUTPUT 1
///if the pH meter gives a shorter output
#define SHORTENED_CHEM_OUTPUT 0

/*
* a pH booklet that contains pH paper pages that will change color depending on the pH of the reagents datum it's attacked onto
*/
/obj/item/ph_booklet
	name = "pH indicator booklet"
	desc = "A booklet containing paper soaked in universal indicator."
	icon_state = "pHbooklet"
	icon = 'icons/obj/medical/chemical.dmi'
	item_flags = NOBLUDGEON
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY
	///How many pages the booklet holds
	var/number_of_pages = 50

//A little janky with pockets
/obj/item/ph_booklet/attack_hand(mob/user)
	if(user.get_held_index_of_item(src))//Does this check pockets too..?
		if(number_of_pages == 50)
			icon_state = "pHbooklet_open"
		if(!number_of_pages)
			to_chat(user, span_warning("[src] is empty!"))
			add_fingerprint(user)
			return
		var/obj/item/ph_paper/page = new(get_turf(user))
		page.add_fingerprint(user)
		user.put_in_active_hand(page)
		to_chat(user, span_notice("You take [page] out of \the [src]."))
		number_of_pages--
		playsound(user.loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
		add_fingerprint(user)
		if(!number_of_pages)
			icon_state = "pHbooklet_empty"
		return
	var/I = user.get_active_held_item()
	if(!I)
		user.put_in_active_hand(src)
	return ..()

/obj/item/ph_booklet/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	var/mob/living/user = usr
	if(!isliving(user) || !Adjacent(user))
		return
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!number_of_pages)
		to_chat(user, span_warning("[src] is empty!"))
		add_fingerprint(user)
		return
	if(number_of_pages == 50)
		icon_state = "pHbooklet_open"
	var/obj/item/ph_paper/P = new(get_turf(user))
	P.add_fingerprint(user)
	user.put_in_active_hand(P)
	to_chat(user, span_notice("You take [P] out of \the [src]."))
	number_of_pages--
	playsound(user.loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
	add_fingerprint(user)
	if(!number_of_pages)
		icon_state = "pHbookletEmpty"

/*
* pH paper will change color depending on the pH of the reagents datum it's attacked onto
*/
/obj/item/ph_paper
	name = "pH indicator strip"
	desc = "A piece of paper that will change colour depending on the pH of a solution."
	icon_state = "pHpaper"
	icon = 'icons/obj/medical/chemical.dmi'
	item_flags = NOBLUDGEON
	color = "#f5c352"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY
	///If the paper was used, and therefore cannot change color again
	var/used = FALSE

/obj/item/ph_paper/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!is_reagent_container(target))
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	var/obj/item/reagent_containers/cont = target
	if(used == TRUE)
		to_chat(user, span_warning("[src] has already been used!"))
		return
	if(!LAZYLEN(cont.reagents.reagent_list))
		return
	CONVERT_PH_TO_COLOR(round(cont.reagents.ph, 1), color)
	desc += " The paper looks to be around a pH of [round(cont.reagents.ph, 1)]"
	name = "used [name]"
	used = TRUE

/*
* pH meter that will give a detailed or truncated analysis of all the reagents in of an object with a reagents datum attached to it. Only way of detecting purity for now.
*/
/obj/item/ph_meter
	name = "Chemical Analyzer"
	desc = "An electrode attached to a small circuit box that will display details of a solution. Can be toggled to provide a description of each of the reagents. The screen currently displays nothing."
	icon_state = "pHmeter"
	icon = 'icons/obj/medical/chemical.dmi'
	w_class = WEIGHT_CLASS_TINY
	///level of detail for output for the meter
	var/scanmode = DETAILED_CHEM_OUTPUT

/obj/item/ph_meter/attack_self(mob/user)
	if(scanmode == SHORTENED_CHEM_OUTPUT)
		to_chat(user, span_notice("You switch the chemical analyzer to provide a detailed description of each reagent."))
		scanmode = DETAILED_CHEM_OUTPUT
	else
		to_chat(user, span_notice("You switch the chemical analyzer to not include reagent descriptions in it's report."))
		scanmode = SHORTENED_CHEM_OUTPUT

/obj/item/ph_meter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!is_reagent_container(target))
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	var/obj/item/reagent_containers/cont = target
	if(LAZYLEN(cont.reagents.reagent_list) == null)
		return
	var/list/out_message = list()
	to_chat(user, "<i>The chemistry meter beeps and displays:</i>")
	out_message += "<span class='notice'><b>Total volume: [round(cont.volume, 0.01)] Current temperature: [round(cont.reagents.chem_temp, 0.1)]K Total pH: [round(cont.reagents.ph, 0.01)]\n"
	out_message += "Chemicals found in the beaker:</b>\n"
	if(cont.reagents.is_reacting)
		out_message += "[span_warning("A reaction appears to be occuring currently.")]<span class='notice'>\n"
	for(var/datum/reagent/reagent in cont.reagents.reagent_list)
		if(reagent.purity < reagent.inverse_chem_val && reagent.inverse_chem) //If the reagent is impure
			var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
			out_message += "[span_warning("Inverted reagent detected: ")]<span class='notice'><b>[round(reagent.volume, 0.01)]u of [inverse_reagent.name]</b>, <b>Purity:</b> [round(1 - reagent.purity, 0.01)*100]%, [(scanmode?"[(inverse_reagent.overdose_threshold?"<b>Overdose:</b> [inverse_reagent.overdose_threshold]u, ":"")]<b>Base pH:</b> [initial(inverse_reagent.ph)], <b>Current pH:</b> [reagent.ph].":"<b>Current pH:</b> [reagent.ph].")]\n"
		else
			out_message += "<b>[round(reagent.volume, 0.01)]u of [reagent.name]</b>, <b>Purity:</b> [round(reagent.purity, 0.01)*100]%, [(scanmode?"[(reagent.overdose_threshold?"<b>Overdose:</b> [reagent.overdose_threshold]u, ":"")]<b>Base pH:</b> [initial(reagent.ph)], <b>Current pH:</b> [reagent.ph].":"<b>Current pH:</b> [reagent.ph].")]\n"
		if(scanmode)
			out_message += "<b>Analysis:</b> [reagent.description]\n"
	to_chat(user, "[out_message.Join()]</span>")
	desc = "An electrode attached to a small circuit box that will display details of a solution. Can be toggled to provide a description of each of the reagents. The screen currently displays detected vol: [round(cont.volume, 0.01)] detected pH:[round(cont.reagents.ph, 0.1)]."

/obj/item/burner
	name = "burner"
	desc = "A small table size burner used for heating up beakers."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "burner"
	grind_results = list(/datum/reagent/consumable/ethanol = 5, /datum/reagent/silicon = 10)
	item_flags = NOBLUDGEON
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY
	heat = 2000
	///If the flame is lit - i.e. if we're processing and burning
	var/lit = FALSE
	///total reagent volume
	var/max_volume = 50
	///What the creation reagent is
	var/reagent_type = /datum/reagent/consumable/ethanol

/obj/item/burner/Initialize(mapload)
	. = ..()
	create_reagents(max_volume, TRANSPARENT)//We have our own refillable - since we want to heat and pour
	if(reagent_type)
		reagents.add_reagent(reagent_type, 15)

/obj/item/burner/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(is_reagent_container(I))
		if(lit)
			var/obj/item/reagent_containers/container = I
			container.reagents.expose_temperature(get_temperature())
			to_chat(user, span_notice("You heat up the [I] with the [src]."))
			playsound(user.loc, 'sound/chemistry/heatdam.ogg', 50, TRUE)
			return
		else if(I.is_drainable()) //Transfer FROM it TO us. Special code so it only happens when flame is off.
			var/obj/item/reagent_containers/container = I
			if(!container.reagents.total_volume)
				to_chat(user, span_warning("[container] is empty and can't be poured!"))
				return

			if(reagents.holder_full())
				to_chat(user, span_warning("[src] is full."))
				return

			var/trans = container.reagents.trans_to(src, container.amount_per_transfer_from_this, transfered_by = user)
			to_chat(user, span_notice("You fill [src] with [trans] unit\s of the contents of [container]."))
	if(I.heat < 1000)
		return
	set_lit(TRUE)
	user.visible_message(span_notice("[user] lights up the [src]."))

/obj/item/burner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(lit)
		. |= AFTERATTACK_PROCESSED_ITEM
		if(is_reagent_container(target))
			var/obj/item/reagent_containers/container = target
			container.reagents.expose_temperature(get_temperature())
			to_chat(user, span_notice("You heat up the [src]."))
			playsound(user.loc, 'sound/chemistry/heatdam.ogg', 50, TRUE)
			return .
	else if(isitem(target))
		var/obj/item/item = target
		if(item.heat > 1000)
			. |= AFTERATTACK_PROCESSED_ITEM
			set_lit(TRUE)
			user.visible_message(span_notice("[user] lights up the [src]."))

	return .

/obj/item/burner/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"

/obj/item/burner/proc/set_lit(new_lit)
	if(lit == new_lit)
		return
	lit = new_lit
	if(lit)
		force = 5
		damtype = BURN
		hitsound = 'sound/items/welder.ogg'
		attack_verb_continuous = string_list(list("burns", "singes"))
		attack_verb_simple = string_list(list("burn", "singe"))
		START_PROCESSING(SSobj, src)
	else
		hitsound = SFX_SWING_HIT
		force = 0
		attack_verb_continuous = null //human_defense.dm takes care of it
		attack_verb_simple = null
		STOP_PROCESSING(SSobj, src)
	set_light_on(lit)
	update_icon()

/obj/item/burner/extinguish()
	set_lit(FALSE)

/obj/item/burner/attack_self(mob/living/user)
	. = ..()
	if(.)
		return
	if(lit)
		set_lit(FALSE)
		user.visible_message(span_notice("[user] snuffs out [src]'s flame."))

/obj/item/burner/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(lit && M.ignite_mob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		user.log_message("set [key_name(M)] on fire with [src]", LOG_GAME)
		M.log_message("was set on fire by [key_name(user)] with [src]", LOG_VICTIM, log_globally = FALSE)
	return ..()

/obj/item/burner/process()
	var/current_heat = 0
	var/number_of_burning_reagents = 0
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		reagent.burn(reagents) //burn can set temperatures of reagents
		if(!isnull(reagent.burning_temperature))
			current_heat += reagent.burning_temperature
			number_of_burning_reagents += 1
			reagents.remove_reagent(reagent.type, reagent.burning_volume)
			continue

	if(!number_of_burning_reagents)
		set_lit(FALSE)
		heat = 0
		return
	open_flame()
	current_heat /= number_of_burning_reagents
	heat = current_heat

/obj/item/burner/get_temperature()
	return lit * heat

/obj/item/burner/oil
	reagent_type = /datum/reagent/fuel/oil
	grind_results = list(/datum/reagent/fuel/oil = 5, /datum/reagent/silicon = 10)

/obj/item/burner/fuel
	reagent_type = /datum/reagent/fuel
	grind_results = list(/datum/reagent/fuel = 5, /datum/reagent/silicon = 10)

/obj/item/thermometer
	name = "thermometer"
	desc = "A thermometer for checking a beaker's temperature"
	icon_state = "thermometer"
	icon = 'icons/obj/medical/chemical.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY
	grind_results = list(/datum/reagent/mercury = 5)
	///The reagents datum that this object is attached to, so we know where we are when it's added to something.
	var/datum/reagents/attached_to_reagents

/obj/item/thermometer/Destroy()
	QDEL_NULL(attached_to_reagents) //I have no idea how you can destroy this, but not the beaker, but here we go
	return ..()

/obj/item/thermometer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	. |= AFTERATTACK_PROCESSED_ITEM
	if(target.reagents)
		if(!user.transferItemToLoc(src, target))
			return .
		attached_to_reagents = target.reagents
		to_chat(user, span_notice("You add the [src] to the [target]."))
		ui_interact(usr, null)
	return .

/obj/item/thermometer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Thermometer", name)
		ui.open()

/obj/item/thermometer/ui_close(mob/user)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(remove_thermometer), user)

/obj/item/thermometer/ui_status(mob/user)
	if(!(in_range(src, user)))
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/item/thermometer/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/thermometer/ui_data(mob/user)
	if(!attached_to_reagents)
		ui_close(user)
	var/data = list()
	data["Temperature"] = round(attached_to_reagents.chem_temp)
	return data

/obj/item/thermometer/proc/remove_thermometer(mob/target)
	try_put_in_hand(src, target)
	attached_to_reagents = null

/obj/item/thermometer/proc/try_put_in_hand(obj/object, mob/living/user)
	to_chat(user, span_notice("You remove the [src] from the [attached_to_reagents.my_atom]."))
	if(!issilicon(user) && in_range(src.loc, user))
		user.put_in_hands(object)
	else
		object.forceMove(drop_location())

/obj/item/thermometer/pen
	color = "#888888"
