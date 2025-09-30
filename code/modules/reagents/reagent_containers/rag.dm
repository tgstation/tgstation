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
	/// How many times has this rag been wrung out since last clean?
	var/wrings = 0

/obj/item/rag/Initialize(mapload)
	. = ..()
	create_reagents(5, OPENCONTAINER)
	AddComponent(/datum/component/cleaner, 3 SECONDS, \
		pre_clean_callback = CALLBACK(src, PROC_REF(should_clean)), \
		on_cleaned_callback = CALLBACK(src, PROC_REF(on_cleaned)), \
	)
	AddElement(/datum/element/reagents_exposed_on_fire)
	AddElement(/datum/element/reagents_item_heatable)

/obj/item/rag/examine(mob/user)
	. = ..()
	. += span_notice("Adding [/datum/reagent/water::name] or [/datum/reagent/space_cleaner::name] to it would make it a fair bit better at scrubbing.")
	switch(blood_level)
		if(1 to 4)
			. += span_info("The [name] is a bit dirty, but it should still be good for cleaning.")
		if(5 to 9)
			. += span_warning("This [name] is dirty! But it still probably has a few wipes left in it.")
		if(10 to INFINITY)
			. += span_warning("This [name] is filthy! I couldn't clean a thing with it!")

/obj/item/rag/interact(mob/user)
	. = ..()
	if(loc != user || blood_level <= 4)
		return

	balloon_alert(user, "wringing out...")
	if(!do_after(user, (wrings + 2) * 1 SECONDS, src))
		return

	wrings += 1
	blood_level *= 0.75

/obj/item/rag/pickup(mob/user)
	. = ..()
	if(prob(5 * blood_level))
		bloody_holder(user)

/obj/item/rag/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/reagent_containers/spray))
		if(tool.reagents.total_volume <= 0)
			balloon_alert(user, "spray is empty!")
			return ITEM_INTERACT_BLOCKING

		if(reagents.holder_full())
			balloon_alert(user, "[name] is full!")
			return ITEM_INTERACT_BLOCKING

		tool.reagents.trans_to(reagents, tool.reagents.total_volume, transferred_by = user)
		balloon_alert(user, "[name] spritzed")
		var/obj/item/reagent_containers/spray/spray = tool
		playsound(src, spray.spray_sound, 33, TRUE, -6)
		return ITEM_INTERACT_SUCCESS

	return ..()

/obj/item/rag/proc/bloody_holder(mob/living/holder)
	if(ishuman(holder))
		var/mob/living/carbon/human/human_holder = holder
		human_holder.add_blood_DNA_to_items(GET_ATOM_BLOOD_DNA(src), ITEM_SLOT_GLOVES)
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
	wrings = 0
	if(blood_level)
		blood_level = 0
		update_appearance()
		. |= COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

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
			var/how_dirty = get_blood_level_of_movable(cleaned)
			if(!remove_cleanable_reagents(how_dirty))
				blood_level += how_dirty
		// you didn't think you could "clean" a burning person and escape scot-free did you?
		var/mob/living/living_cleaned = cleaned
		if((cleaned.resistance_flags & ON_FIRE) || (istype(living_cleaned) && living_cleaned.on_fire))
			fire_act(500, 100)

	// FINALLY add the dna to us
	if(length(all_blood_dna))
		add_blood_DNA(all_blood_dna)
	update_appearance()
	if(blood_level >= 10)
		to_chat(cleaner, span_warning("[src] is too dirty to clean anything else! Wash it first!"))
	if(prob(10 * blood_level))
		bloody_holder(cleaner)

/// Checks an atom and returns how "dirty" it is scaled to our rag
/obj/item/rag/proc/get_blood_level_of_movable(atom/movable/what)
	PRIVATE_PROC(TRUE)
	if(istype(what, /obj/item/rag))
		var/obj/item/rag/friend_rag = what
		return friend_rag.blood_level
	if(istype(what, /obj/effect/decal/cleanable/blood))
		var/obj/effect/decal/cleanable/blood/mess = what
		return round(mess.bloodiness / 20, 1)
	return 1

/// Takes in a "dirty" amount and tries to "counteract" it with reagents, returning TRUE if successful
/obj/item/rag/proc/remove_cleanable_reagents(how_dirty = 1)
	PRIVATE_PROC(TRUE)
	var/amount_to_remove = how_dirty * 0.2
	// cleaner is the best at scrubbing blood
	if(reagents.has_reagent(/datum/reagent/space_cleaner, amount_to_remove, check_subtypes = TRUE))
		reagents.remove_reagent(/datum/reagent/space_cleaner, amount_to_remove)
		return TRUE

	// rest of the stuff is generically worse
	amount_to_remove = how_dirty * 1.2
	for(var/datum/reagent/other_reagent as anything in reagents.reagent_list)
		if((other_reagent.chemical_flags & REAGENT_CLEANS) && other_reagent.volume >= amount_to_remove)
			reagents.remove_reagent(other_reagent, amount_to_remove)
			return TRUE

	return FALSE

/obj/item/rag/update_appearance(updates)
	. = ..()
	// Gets closer to the mixed blood color as we get dirtier
	var/blood_color = get_blood_dna_color() || COLOR_RED
	var/list/color_breakdown = rgb2num(blood_color)
	var/v = max(1 - (0.1 * blood_level), 0)
	var/list/colormatrix = list(
		color_breakdown[1] / 255 + v * (1 - color_breakdown[1] / 255), 0, 0, 0,
		0, color_breakdown[2] / 255 + v * (1 - color_breakdown[2] / 255), 0, 0,
		0, 0, color_breakdown[3] / 255 + v * (1 - color_breakdown[3] / 255), 0,
		0, 0, 0, 1,
	)

	add_atom_colour(colormatrix, FIXED_COLOUR_PRIORITY)
