/atom
	/// If non-null, overrides a/an/some in all cases
	var/article
	/// Text that appears preceding the name in [/atom/proc/examine_title]
	var/examine_thats = "Это"

/**
 * Called when a mob examines this atom: [/mob/verb/examinate]
 *
 * Default behaviour is to get the name and icon of the object and its reagents where
 * the [TRANSPARENT] flag is set on the reagents holder
 *
 * Produces a signal [COMSIG_ATOM_EXAMINE], for modifying the list returned from this proc
 */
/atom/proc/examine(mob/user)
	. = list()
	. += get_name_chaser(user)
	if(desc)
		. += "<i>[desc]</i>"

	var/list/tags_list = examine_tags(user)
	var/list/post_descriptor = examine_post_descriptor(user)
	var/post_desc_string = length(post_descriptor) ? " [jointext(post_descriptor, " ")]" : ""
	if (length(tags_list))
		var/tag_string = list()
		for (var/atom_tag in tags_list)
			tag_string += (isnull(tags_list[atom_tag]) ? atom_tag : span_tooltip(tags_list[atom_tag], atom_tag))
		// some regex to ensure that we don't add another "and" if the final element's main text (not tooltip) has one
		tag_string = english_list(tag_string, and_text = (findtext(tag_string[length(tag_string)], regex(@">.*?и .*?<"))) ? " " : " и ")
		. += "Это [tag_string] [examine_descriptor(user)][post_desc_string]."
	else if(post_desc_string)
		. += "Это [examine_descriptor(user)][post_desc_string]."

	if(reagents)
		var/user_sees_reagents = user.can_see_reagents()
		var/reagent_sigreturn = SEND_SIGNAL(src, COMSIG_ATOM_REAGENT_EXAMINE, user, ., user_sees_reagents)
		if(!(reagent_sigreturn & STOP_GENERIC_REAGENT_EXAMINE))
			if(reagents.flags & TRANSPARENT)
				if(reagents.total_volume)
					. += "Имеется <b>[reagents.total_volume]</b> юнитов различных химикатов[user_sees_reagents ? ":" : "."]"
					if(user_sees_reagents || (reagent_sigreturn & ALLOW_GENERIC_REAGENT_EXAMINE)) //Show each individual reagent for detailed examination
						for(var/datum/reagent/current_reagent as anything in reagents.reagent_list)
							. += "&bull; [round(current_reagent.volume, CHEMICAL_VOLUME_ROUNDING)] юнитов [current_reagent.name]"
						if(reagents.is_reacting)
							. += span_warning("Оно сейчас вступает в реакцию!")
						. += span_notice("pH раствора равен [round(reagents.ph, 0.01)] и имеет температуру в [reagents.chem_temp]K.")
				else
					. += "Внутри:<br>Ничего."
			else if(reagents.flags & AMOUNT_VISIBLE)
				if(reagents.total_volume)
					. += span_notice("Имеется [reagents.total_volume] юнитов.")
				else
					. += span_danger("Пусто.")

		if(HAS_TRAIT(user, TRAIT_KEEN_NOSE))
			var/sniff_text = get_sniff_examine(user)
			if(sniff_text)
				. += sniff_text

	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE, user, .)

/// Returns an examine string describing what the contents of this atom smell like
/atom/proc/get_sniff_examine(mob/living/carbon/sniffer)
	if(!istype(sniffer) || HAS_TRAIT(sniffer, TRAIT_ANOSMIA))
		return
	if(!is_open_container() || !reagents?.total_volume)
		return
	if(!sniffer.is_holding(src))
		return
	if(!sniffer.get_bodypart(BODY_ZONE_HEAD)) // Need a nose to smell
		return
	if(sniffer.is_mouth_covered())
		return span_warning("You can't get a whiff of [src] with your face covered.")

	var/smell_message = generate_reagents_taste_message(reagents.reagent_list, sniffer, 10)
	return span_notice("You catch a whiff of [src]. It smells like [smell_message].")

/**
 * A list of "tags" displayed after atom's description in examine.
 * This should return an assoc list of tags -> tooltips for them. If item is null, then no tooltip is assigned.
 *
 * * TGUI tooltips (not the main text) in chat cannot use HTML stuff at all, so
 * trying something like `<b><big>ffff</big></b>` will not work for tooltips.
 *
 * For example:
 * ```byond
 * . = list()
 * .["small"] = "It is a small item."
 * .["fireproof"] = "It is made of fire-retardant materials."
 * .["and conductive"] = "It's made of conductive materials and whatnot. Blah blah blah." // having "and " in the end tag's main text/key works too!
 * ```
 * will result in
 *
 * It is a *small*, *fireproof* *and conductive* item.
 *
 * where "item" is pulled from [/atom/proc/examine_descriptor]
 */
// BANDASTATION EDIT START — род тегов
/atom/proc/examine_tags(mob/user)
	. = list()
	if(abstract_type == type)
		.[span_hypnophrase("abstract")] = "This is an abstract concept, you should report this to a strange entity called GITHUB!"

	var/is_female = ((examine_descriptor()) in list("структура", "машина") )
	var/he_she_it = is_female ? "Она" : "Он"
	var/he_she_it_low = is_female ? "она" : "он"
	var/adj_very = is_female ? "прочная" : "прочный"
	var/verb_made = is_female ? "сделана" : "сделан"
	var/verb_looks = is_female ? "выглядит довольно прочной" : "выглядит довольно прочным"

	if(resistance_flags & INDESTRUCTIBLE)
		.[is_female ? "неразрушаемая" : "неразрушаемый"] = "[he_she_it] очень [adj_very]! [capitalize(he_she_it)] выдержит всё, что с [is_female ? "ней" : "ним"] может случиться!"
	else
		if(resistance_flags & LAVA_PROOF)
			.[is_female ? "лавастойкая" : "лавастойкий"] = "[he_she_it] [verb_made] из чрезвычайно жаропрочного материала, и, вероятно, сможет выдержать даже лаву!"
		if(resistance_flags & (ACID_PROOF | UNACIDABLE))
			.[is_female ? "кислотостойкая" : "кислотостойкий"] = "[he_she_it] [verb_looks]! Возможно, [he_she_it_low] выдержит воздействие кислоты!"
		if(resistance_flags & FREEZE_PROOF)
			.[is_female ? "морозостойкая" : "морозостойкий"] = "[he_she_it] [verb_made] из моростойких материалов."
		if(resistance_flags & FIRE_PROOF)
			.[is_female ? "огнестойкая" : "огнестойкий"] = "[he_she_it] [verb_made] из огнестойких материалов."
		if(resistance_flags & SHUTTLE_CRUSH_PROOF)
			.[is_female ? "очень прочная" : "очень прочный"] = "[he_she_it] невероятно [adj_very]. Выдержит даже приземление шаттла!"
		if(resistance_flags & BOMB_PROOF)
			.[is_female ? "взрывоустойчивая" : "взрывоустойчивый"] = "[he_she_it] переживёт взрыв!"
		if(resistance_flags & FLAMMABLE)
			.[is_female ? "легковоспламеняющаяся" : "легковоспламеняющийся"] = "[capitalize(he_she_it)] может легко загореться."

	if(flags_1 & HOLOGRAM_1)
		.["голографический"] = "Похоже на голограмму."

	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE_TAGS, user, .)
// BANDASTATION EDIT END

/// What this atom should be called in examine tags
/atom/proc/examine_descriptor(mob/user)
	return "объект"

/// Returns a list of strings to be displayed after the descriptor
/atom/proc/examine_post_descriptor(mob/user)
	. = list()
	if(!custom_materials)
		return
	var/mats_list = list()
	for(var/custom_material in custom_materials)
		var/datum/material/current_material = SSmaterials.get_material(custom_material)
		mats_list += span_tooltip("Объект сделан из [current_material.declent_ru(GENITIVE)].", current_material.declent_ru(GENITIVE))
	. += "из [english_list(mats_list)]"

/**
 * Called when a mob examines (shift click or verb) this atom twice (or more) within EXAMINE_MORE_WINDOW (default 1 second)
 *
 * This is where you can put extra information on something that may be superfluous or not important in critical gameplay
 * moments, while allowing people to manually double-examine to take a closer look
 *
 * Produces a signal [COMSIG_ATOM_EXAMINE_MORE]
 */
/atom/proc/examine_more(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE_MORE, user, .)
	SEND_SIGNAL(user, COMSIG_MOB_EXAMINING_MORE, src, .)

	if (!length(custom_materials) || (material_flags & MATERIAL_NO_DESCRIPTORS) || !HAS_TRAIT(user, TRAIT_RESEARCH_SCANNER))
		return

	for (var/datum/material/material as anything in custom_materials)
		var/list/material_string = list()
		for (var/prop_id in material.mat_properties)
			var/datum/material_property/property = SSmaterials.properties[prop_id]
			var/prop_value = material.get_property(prop_id)
			if (isnull(prop_value)) // Error?
				continue
			var/descriptor = property?.get_descriptor(prop_value)
			var/tooltip_hint = property?.get_tooltip(prop_value)
			if (descriptor) // Overriden derivative property?
				material_string += span_tooltip("[property]: [tooltip_hint]", descriptor)

		if (length(material_string))
			. += span_info("[capitalize(material.name)] is [english_list(material_string)].")

/**
 * Get the name of this object for examine
 *
 * You can override what is returned from this proc by registering to listen for the
 * [COMSIG_ATOM_GET_EXAMINE_NAME] signal
 */
/atom/proc/get_examine_name(mob/user, declent = NOMINATIVE) // BANDASTATION EDIT - Declents
	var/list/override = list(article, null, "<em>[get_visible_name(declent = declent)]</em>") // BANDASTATION EDIT - Declents
	SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override)

	if(!isnull(override[EXAMINE_POSITION_ARTICLE]))
		override -= null // IF there is no "before", don't try to join it
		return jointext(override, " ")
	if(!isnull(override[EXAMINE_POSITION_BEFORE]))
		override -= null // There is no article, don't try to join it
		return "[jointext(override, " ")]" // BANDASTATION EDIT - Declents
	return "[get_visible_name(declent = declent)]" // BANDASTATION EDIT - Declents

/mob/living/get_examine_name(mob/user, declent = NOMINATIVE) // BANDASTATION EDIT - Declents
	var/visible_name = get_visible_name(declent = declent)   // BANDASTATION EDIT - Declents
	var/list/name_override = list(visible_name)
	if(SEND_SIGNAL(user, COMSIG_LIVING_PERCEIVE_EXAMINE_NAME, src, visible_name, name_override) & COMPONENT_EXAMINE_NAME_OVERRIDEN)
		return name_override[1]
	return visible_name

/// Icon displayed in examine
/atom/proc/get_examine_icon(mob/user)
	return icon2html(src, user)

/**
 * Formats the atom's name into a string for use in examine (as the "title" of the atom)
 *
 * * user - the mob examining the atom
 * * thats - whether to include "That's", or similar (mobs use "This is") before the name
 */
/atom/proc/examine_title(mob/user, thats = FALSE, declent = NOMINATIVE) // BANDASTATION EDIT - Declents
	var/examine_icon = get_examine_icon(user)
	return "[examine_icon ? "[examine_icon] " : ""][thats ? "[examine_thats] ":""]<em>[get_examine_name(user, declent)]</em>" // BANDASTATION EDIT - Declents

/**
 * Returns an extended list of examine strings for any contained ID cards.
 *
 * Arguments:
 * * user - The user who is doing the examining.
 */
/atom/proc/get_id_examine_strings(mob/user)
	. = list()

///Used to insert text after the name but before the description in examine()
/atom/proc/get_name_chaser(mob/user, list/name_chaser = list())
	return name_chaser

/**
 * Used by mobs to determine the name for someone wearing a mask, or with a disfigured or missing face.
 * By default just returns the atom's name.
 *
 * * add_id_name - If TRUE, ID information such as honorifics or name (if mismatched) are appended
 * * force_real_name - If TRUE, will always return real_name and add (as face_name/id_name) if it doesn't match their appearance
 */
/atom/proc/get_visible_name(add_id_name = TRUE, force_real_name = FALSE, declent = NOMINATIVE)
	if(name != initial(name))
		return name
	return declent_ru(declent)
