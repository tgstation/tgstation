/atom
	/// If non-null, overrides a/an/some in all cases
	var/article
	/// Text that appears preceding the name in [/atom/proc/examine_title]
	var/examine_thats = "That's"

/mob/living/carbon/human
	examine_thats = "This is"

/mob/living/silicon/robot
	examine_thats = "This is"

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
	if (length(tags_list))
		var/tag_string = list()
		for (var/atom_tag in tags_list)
			tag_string += (isnull(tags_list[atom_tag]) ? atom_tag : span_tooltip(tags_list[atom_tag], atom_tag))
		// some regex to ensure that we don't add another "and" if the final element's main text (not tooltip) has one
		tag_string = english_list(tag_string, and_text = (findtext(tag_string[length(tag_string)], regex(@">.*?and .*?<"))) ? " " : " and ")
		var/post_descriptor = examine_post_descriptor(user)
		. += "[p_They()] [p_are()] a [tag_string] [examine_descriptor(user)][length(post_descriptor) ? " [jointext(post_descriptor, " ")]" : ""]."

	if(reagents)
		var/user_sees_reagents = user.can_see_reagents()
		var/reagent_sigreturn = SEND_SIGNAL(src, COMSIG_ATOM_REAGENT_EXAMINE, user, ., user_sees_reagents)
		if(!(reagent_sigreturn & STOP_GENERIC_REAGENT_EXAMINE))
			if(reagents.flags & TRANSPARENT)
				if(reagents.total_volume)
					. += "It contains <b>[reagents.total_volume]</b> units of various reagents[user_sees_reagents ? ":" : "."]"
					if(user_sees_reagents || (reagent_sigreturn & ALLOW_GENERIC_REAGENT_EXAMINE)) //Show each individual reagent for detailed examination
						for(var/datum/reagent/current_reagent as anything in reagents.reagent_list)
							. += "&bull; [round(current_reagent.volume, CHEMICAL_VOLUME_ROUNDING)] units of [current_reagent.name]"
						if(reagents.is_reacting)
							. += span_warning("It is currently reacting!")
						. += span_notice("The solution's pH is [round(reagents.ph, 0.01)] and has a temperature of [reagents.chem_temp]K.")

				else
					. += "It contains:<br>Nothing."
			else if(reagents.flags & AMOUNT_VISIBLE)
				if(reagents.total_volume)
					. += span_notice("It has [reagents.total_volume] unit\s left.")
				else
					. += span_danger("It's empty.")

	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE, user, .)

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
/atom/proc/examine_tags(mob/user)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE_TAGS, user, .)

/// What this atom should be called in examine tags
/atom/proc/examine_descriptor(mob/user)
	return "object"

/// Returns a list of strings to be displayed after the descriptor
/atom/proc/examine_post_descriptor(mob/user)
	. = list()
	if(!custom_materials)
		return
	var/mats_list = list()
	for(var/custom_material in custom_materials)
		var/datum/material/current_material = GET_MATERIAL_REF(custom_material)
		mats_list += span_tooltip("It is made out of [current_material.name].", current_material.name)
	. += "made of [english_list(mats_list)]"

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

/**
 * Get the name of this object for examine
 *
 * You can override what is returned from this proc by registering to listen for the
 * [COMSIG_ATOM_GET_EXAMINE_NAME] signal
 */
/atom/proc/get_examine_name(mob/user)
	var/list/override = list(article, null, "<em>[get_visible_name()]</em>")
	SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override)

	if(!isnull(override[EXAMINE_POSITION_ARTICLE]))
		override -= null // IF there is no "before", don't try to join it
		return jointext(override, " ")
	if(!isnull(override[EXAMINE_POSITION_BEFORE]))
		override -= null // There is no article, don't try to join it
		return "\a [jointext(override, " ")]"
	return "\a [src]"

/mob/living/get_examine_name(mob/user)
	var/visible_name = get_visible_name()
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
/atom/proc/examine_title(mob/user, thats = FALSE)
	var/examine_icon = get_examine_icon(user)
	var/href_text = ""
	if(href)
		var/list/hrefs = examine_hrefs(user, thats)
		if(length(hrefs))
			href_text += "<a href='byond://?" // Non-module change : 516 byond://
			href_text += "src=[REF(src)];"
			for(var/key in hrefs)
				href_text += "[key]=[hrefs[key]];"
			href_text += "loc_at_examine=[loc && REF(loc)];"
			href_text += "examine_time=[world.time]"
			href_text += "'>"

	return "[examine_icon ? "[examine_icon] " : ""][thats ? "[examine_thats] ":""]<em>[href_text][get_examine_name(user)][href_text ? "</a>" : ""]</em>"

/**
 * Used to compose hrefs attached to the name of the item itself in examine
 *
 * Return a list, where each entry is a key-value pair.
 * The key is the id of the href, and the value is the href.
 */
/atom/proc/examine_hrefs(mob/examiner, examine_directly = FALSE)
	return null

/atom/movable/examine_hrefs(mob/examiner, examine_directly = FALSE)
	if(examine_directly)
		return ismob(loc) ? list("point_at" = TRUE) : null

	return list("examine_item" = TRUE)

/obj/item/card/id/examine_hrefs(mob/examiner, examine_directly = FALSE)
	return list("see_id" = TRUE)

/atom/movable/Topic(href, list/href_list)
	. = ..()
	if(href_list["point_at"] || href_list["examine_item"])
		if(!loc || !href_list["loc_at_examine"] || REF(loc) != href_list["loc_at_examine"])
			return
		if(text2num(href_list["examine_time"]) + 3 MINUTES < world.time)
			return

		var/mob/viewer = usr
		var/mob/wearer = get(src, /mob/living) || loc
		if(viewer.incapacitated(IGNORE_STASIS|IGNORE_RESTRAINTS|IGNORE_GRAB))
			return
		if(HAS_TRAIT(wearer, TRAIT_UNKNOWN) || !can_examine_when_worn(viewer))
			to_chat(viewer, span_notice("You can't make out that item anymore."))
			return

		if(href_list["point_at"])
			viewer._pointed(src, skip_view = TRUE)
		else
			viewer.examinate(src)

/// Checks if this item, when examined / pointed at while being worn, can actually be examined by the given mob
/atom/movable/proc/can_examine_when_worn(mob/examiner)
	return (examiner in viewers(loc))

/obj/item/can_examine_when_worn(mob/examiner)
	if(!slot_flags)
		return ..()
	var/mob/living/carbon/wearer = loc
	if(!istype(wearer))
		return ..()
	if(hidden_slots_to_inventory_slots(wearer.obscured_slots) & slot_flags)
		return FALSE
	return ..()

/obj/item/clothing/accessory/can_examine_when_worn(mob/examiner)
	if(isclothing(loc))
		var/obj/item/clothing/shirt = loc
		return shirt.can_examine_when_worn(examiner)
	return ..()

/obj/item/card/id/Topic(href, list/href_list)
	. = ..()
	if(href_list["see_id"])
		var/mob/viewer = usr
		if(viewer.incapacitated(IGNORE_STASIS|IGNORE_RESTRAINTS|IGNORE_GRAB))
			return
		var/mob/old_wearer = locate(href_list["loc_at_examine"]) in GLOB.mob_living_list
		if(old_wearer != loc)
			to_chat(viewer, span_notice("[old_wearer?.p_They() || "They"] [old_wearer?.p_are() || "are"] no longer wearing that ID card."))
			return

		var/can_see_still = (viewer in viewers(old_wearer))
		var/viable_time = can_see_still ? 3 MINUTES : 1 MINUTES // assuming 3min is the length of a hop line visit - give some leeway if they're still in sight
		if((text2num(href_list["examine_time"]) + viable_time) < world.time)
			to_chat(viewer, span_notice("You don't have that good of a memory. Examine [p_them()] again."))
			return
		if(HAS_TRAIT(old_wearer, TRAIT_UNKNOWN))
			to_chat(viewer, span_notice("You can't make out that ID anymore."))
			return
		if(!isobserver(viewer) && get_dist(viewer, old_wearer) > ID_EXAMINE_DISTANCE + 1) // leeway, ignored if the viewer is a ghost
			to_chat(viewer, span_notice("You can't make out that ID from here."))
			return

		var/id_name = registered_name
		var/id_age = registered_age
		var/id_job = assignment
		// Should probably be recorded on the ID, but this is easier (albiet more restrictive) on chameleon ID users
		var/datum/record/crew/record = find_record(id_name)
		var/id_blood_type = record?.blood_type
		var/id_gender = record?.gender
		var/id_species = record?.species
		var/id_icon = jointext(get_id_examine_strings(viewer), "")
		// Fill in some blanks for chameleon IDs to maintain the illusion of a real ID
		if(istype(src, /obj/item/card/id/advanced/chameleon))
			id_gender ||= old_wearer.gender
			if(iscarbon(old_wearer))
				var/mob/living/carbon/carbon_wearer = old_wearer
				id_species ||= carbon_wearer.dna.species.name
				id_blood_type ||= find_blood_type(carbon_wearer.dna?.species?.exotic_bloodtype || carbon_wearer.dna?.human_blood_type)?.name

		var/id_examine = span_slightly_larger(separator_hr("This is <em>[old_wearer]'s ID card</em>."))
		id_examine += "<div class='img_by_text_container'>"
		id_examine += "[id_icon]"
		id_examine += "<div class='img_text'>"
		id_examine += jointext(list(
			"&bull; Name: [id_name || "Unknown"]",
			"&bull; Job: [id_job || "Unassigned"]",
			"&bull; Age: [id_age || "Unknown"]",
			"&bull; Gender: [id_gender || "Unknown"]",
			"&bull; Blood Type: [id_blood_type || "?"]",
			"&bull; Species: [id_species || "Unknown"]",
		), "<br>")
		id_examine += "</div>" // container
		id_examine += "</div>" // text

		to_chat(viewer, examine_block(span_info(id_examine)))

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

/// Used by mobs to determine the name for someone wearing a mask, or with a disfigured or missing face. By default just returns the atom's name. add_id_name will control whether or not we append "(as [id_name])".
/// force_real_name will always return real_name and add (as face_name/id_name) if it doesn't match their appearance
/atom/proc/get_visible_name(add_id_name, force_real_name)
	return name
