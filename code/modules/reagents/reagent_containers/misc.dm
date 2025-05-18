/obj/item/reagent_containers/cup/maunamug
	name = "mauna mug"
	desc = "A drink served in a classy mug. Now with built-in heating!"
	icon = 'icons/obj/devices/mauna_mug.dmi'
	icon_state = "maunamug"
	base_icon_state = "maunamug"
	spillable = TRUE
	reagent_flags = OPENCONTAINER
	fill_icon_state = "maunafilling"
	fill_icon_thresholds = list(25)
	var/obj/item/stock_parts/power_store/cell
	var/open = FALSE
	var/on = FALSE

/obj/item/reagent_containers/cup/maunamug/Initialize(mapload, vol)
	. = ..()
	cell = new /obj/item/stock_parts/power_store/cell(src)

/obj/item/reagent_containers/cup/maunamug/get_cell()
	return cell

/obj/item/reagent_containers/cup/maunamug/examine(mob/user)
	. = ..()
	. += span_notice("The status display reads: Current temperature: <b>[reagents.chem_temp]K</b> Current Charge:[cell ? "[cell.charge / cell.maxcharge * 100]%" : "No cell found"].")
	if(open)
		. += span_notice("The battery case is open.")
	if(cell && cell.charge > 0)
		. += span_notice("<b>Ctrl+Click</b> to toggle the power.")

/obj/item/reagent_containers/cup/maunamug/process(seconds_per_tick)
	..()
	if(on && (!cell || cell.charge <= 0)) //Check if we ran out of power
		change_power_status(FALSE)
		return FALSE
	cell.use(0.005 * STANDARD_CELL_RATE * seconds_per_tick) //Basic cell goes for like 200 seconds, bluespace for 8000
	if(!reagents.total_volume)
		return FALSE
	var/max_temp = min(500 + (500 * (0.2 * cell.rating)), 1000) // 373 to 1000
	reagents.adjust_thermal_energy(0.4 * cell.maxcharge * reagents.total_volume * seconds_per_tick, max_temp = max_temp) // 4 kelvin every tick on a basic cell. 160k on bluespace
	reagents.handle_reactions()
	update_appearance()
	if(reagents.chem_temp >= max_temp)
		change_power_status(FALSE)
		audible_message(span_notice("The Mauna Mug lets out a happy beep and turns off!"))
		playsound(src, 'sound/machines/chime.ogg', 50)

/obj/item/reagent_containers/cup/maunamug/Destroy()
	if(cell)
		QDEL_NULL(cell)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/reagent_containers/cup/maunamug/item_ctrl_click(mob/user)
	if(on)
		change_power_status(FALSE)
	else
		if(!cell || cell.charge <= 0)
			return FALSE //No power, so don't turn on
		change_power_status(TRUE)
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/cup/maunamug/proc/change_power_status(status)
	on = status
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/reagent_containers/cup/maunamug/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	open = !open
	to_chat(user, span_notice("You screw the battery case on [src] [open ? "open" : "closed"] ."))
	update_appearance()

/obj/item/reagent_containers/cup/maunamug/attackby(obj/item/I, mob/user, list/modifiers)
	add_fingerprint(user)
	if(!istype(I, /obj/item/stock_parts/power_store/cell))
		return ..()
	if(!open)
		to_chat(user, span_warning("The battery case must be open to insert a power cell!"))
		return FALSE
	if(cell)
		to_chat(user, span_warning("There is already a power cell inside!"))
		return FALSE
	else if(!user.transferItemToLoc(I, src))
		return
	cell = I
	user.visible_message(span_notice("[user] inserts a power cell into [src]."), span_notice("You insert the power cell into [src]."))
	update_appearance()

/obj/item/reagent_containers/cup/maunamug/attack_hand(mob/living/user, list/modifiers)
	if(cell && open)
		user.put_in_hands(cell)
		cell = null
		to_chat(user, span_notice("You remove the power cell from [src]."))
		on = FALSE
		update_appearance()
		return TRUE
	return ..()

/obj/item/reagent_containers/cup/maunamug/update_icon_state()
	if(open)
		icon_state = "[base_icon_state][cell ? null : "_no"]_bat"
		return ..()
	icon_state = "[base_icon_state][on ? "_on" : null]"
	return ..()

/obj/item/reagent_containers/cup/maunamug/update_overlays()
	. = ..()
	if(!reagents.total_volume || reagents.chem_temp < 400)
		return

	var/intensity = (reagents.chem_temp - 400) * 1 / 600 //Get the opacity of the incandescent overlay. Ranging from 400 to 1000
	var/mutable_appearance/mug_glow = mutable_appearance(icon, "maunamug_incand")
	mug_glow.alpha = 255 * intensity
	. += mug_glow

/obj/item/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "rag"
	item_flags = NOBLUDGEON
	resistance_flags = FLAMMABLE
	/// How bloody is this rag?
	var/blood_level = 0

/obj/item/rag/Initialize(mapload)
	. = ..()
	create_reagents(5, OPENCONTAINER)
	AddComponent(/datum/component/cleaner, 3 SECONDS, \
		pre_clean_callback = CALLBACK(src, PROC_REF(should_clean)), \
		on_cleaned_callback = CALLBACK(src, PROC_REF(on_cleaned)), \
	)
	AddElement(/datum/element/reagents_exposed_on_fire)
	AddElement(/datum/element/reagents_item_heatable)

/obj/item/rag/pickup(mob/user)
	. = ..()
	if(prob(5 * blood_level))
		bloody_holder(user)

/obj/item/rag/proc/bloody_holder(mob/living/holder)
	var/obj/item/clothing/gloves/gloves = holder.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(gloves)
		gloves.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
		holder.update_worn_gloves()
	else
		holder.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))

/obj/item/rag/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is smothering [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/rag/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!iscarbon(interacting_with) || !reagents?.total_volume)
		return ..()
	var/mob/living/carbon/carbon_target = interacting_with
	carbon_target.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	var/reagentlist = pretty_string_from_reagent_list(reagents.reagent_list)
	var/log_object = "containing [reagentlist]"
	if(!carbon_target.is_mouth_covered())
		reagents.trans_to(carbon_target, reagents.total_volume, transferred_by = user, methods = INGEST)
		carbon_target.visible_message(span_danger("[user] smothers \the [carbon_target] with \the [src]!"), span_userdanger("[user] smothers you with \the [src]!"), span_hear("You hear some struggling and muffled cries of surprise."))
		log_combat(user, carbon_target, "smothered", src, log_object)
	else
		reagents.expose(carbon_target, TOUCH)
		reagents.clear_reagents()
		carbon_target.visible_message(span_notice("[user] touches \the [carbon_target] with \the [src]."))
		log_combat(user, carbon_target, "touched", src, log_object)
	return ITEM_INTERACT_SUCCESS

/obj/item/rag/wash(clean_types)
	. = ..()
	if(!(clean_types & CLEAN_TYPE_BLOOD))
		return
	blood_level = 0
	update_appearance()

///Checks whether or not we should clean.
/obj/item/rag/proc/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if(cleaner.combat_mode && ismob(atom_to_clean))
		return CLEAN_BLOCKED|CLEAN_DONT_BLOCK_INTERACTION
	if(blood_level >= 10)
		// snowflakeeeee check to make it a bit more intuitive when cleaning the rag.
		if(istype(atom_to_clean, /obj/structure/sink))
			return CLEAN_BLOCKED|CLEAN_DONT_BLOCK_INTERACTION
		atom_to_clean.balloon_alert(cleaner, "[name] is too dirty!")
		return CLEAN_BLOCKED
	if(loc == cleaner)
		return CLEAN_ALLOWED
	return CLEAN_ALLOWED|CLEAN_NO_XP

///On cleaning, get the rag dirty
/obj/item/rag/proc/on_cleaned(datum/cleaning_source, atom/clean_target, mob/living/cleaner, was_successful, list/all_cleaned)
	if(!was_successful)
		return

	var/list/all_blood_dna = list()
	for(var/atom/movable/cleaned in all_cleaned)
		if(isturf(clean_target) && !HAS_TRAIT(cleaned, TRAIT_MOPABLE))
			continue
		// collect dna FIRST
		all_blood_dna |= all_cleaned[cleaned]
		// THEN pass on dna (though in some cases the cleaned item is being deleted)
		if(blood_level > 0 && !QDELING(cleaned))
			cleaned.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
		// THEN increment blood level
		if(length(all_cleaned[cleaned]))
			blood_level += get_blood_level_of_movable(cleaned)
		// you didn't think you could "clean" a burning person and escape scot-free did you?
		var/mob/living/living_cleaned = cleaned
		if((cleaned.resistance_flags & ON_FIRE) || (istype(living_cleaned) && living_cleaned.on_fire))
			fire_act(500, 100)

	// FINALLY add the dna to us
	add_blood_DNA(all_blood_dna)
	update_appearance()
	if(blood_level >= 10)
		to_chat(cleaner, span_warning("[src] is too dirty to clean anything else! Wash it first!"))
	if(prob(10 * blood_level))
		bloody_holder(cleaner)

/obj/item/rag/proc/get_blood_level_of_movable(atom/movable/what)
	if(istype(what, /obj/item/rag))
		var/obj/item/rag/friend_rag = what
		return friend_rag.blood_level
	if(istype(what, /obj/effect/decal/cleanable))
		var/obj/effect/decal/cleanable/mess = what
		return round(mess.bloodiness / 20, 1)
	return 1

/obj/item/rag/update_appearance(updates)
	. = ..()
	// v = green and blue color components (reduced as it gets dirtier)
	var/v = max(1 - (0.1 * blood_level), 0)
	var/list/colormatrix = list(
		1, 0, 0, 0,
		0, v, 0, 0,
		0, 0, v, 0,
		0, 0, 0, 1,
	)

	add_atom_colour(colormatrix, FIXED_COLOUR_PRIORITY)
