/// A mini-tool used to apply label items onto something to modify its name.
/obj/item/hand_labeler
	name = "hand labeler"
	desc = "A combined label printer, applicator, and remover, all in a single portable device. Designed to be easy to operate and use."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "labeler0"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	drop_sound = 'sound/items/handling/tape_drop.ogg'
	pickup_sound = 'sound/items/handling/tape_pickup.ogg'
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.5,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 1.25,
	)
	/// Tracks the current label text
	var/label
	/// How many labels are left in the current roll? Also serves as our "max".
	var/labels_left = 30
	/// Whether we are in label mode
	VAR_FINAL/mode = FALSE

/obj/item/hand_labeler/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is pointing [src] at [user.p_them()]self. [user.p_Theyre()] going to label [user.p_them()]self as a suicide!"))
	labels_left = max(labels_left - 1, 0)

	var/old_real_name = user.real_name
	user.real_name += " (suicide)"
	// no conflicts with their identification card
	for(var/atom/A in user.get_all_contents())
		if(isidcard(A))
			var/obj/item/card/id/their_card = A

			// only renames their card, as opposed to tagging everyone's
			if(their_card.registered_name != old_real_name)
				continue

			their_card.registered_name = user.real_name
			their_card.update_label()
			their_card.update_icon()

	// NOT EVEN DEATH WILL TAKE AWAY THE STAIN
	user.mind.name += " (suicide)"

	mode = 1
	icon_state = "labeler[mode]"
	label = "suicide"

	return OXYLOSS

/obj/item/hand_labeler/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(!mode) //if it's off, give up.
		return .
	if(!apply_label(interacting_with, user, modifiers))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/obj/item/hand_labeler/proc/apply_label(atom/interacting_with, mob/living/user, list/modifiers)
	if(!labels_left)
		balloon_alert(user, "no labels left!")
		return FALSE
	if(!length(label))
		balloon_alert(user, "no text set!")
		return FALSE
	if(length(interacting_with.name) + length_char(label) > MAX_LABEL_LEN)
		balloon_alert(user, "label too long!")
		return FALSE
	if(ismob(interacting_with))
		interacting_with.balloon_alert(user, "can't label!")
		return FALSE

	var/cursor_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/cursor_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	interacting_with.balloon_alert_to_viewers("labelled")
	user.visible_message(
		span_notice("[user] labels [interacting_with] with \"[label]\"."),
		span_notice("You label [interacting_with] with \"[label]\"."),
	)
	var/obj/item/label/stick_label = new(null, label)
	stick_label.stick_to_atom(interacting_with, cursor_x, cursor_y)
	playsound(interacting_with, 'sound/items/handling/component_pickup.ogg', 20, TRUE)
	labels_left--
	return TRUE

/obj/item/hand_labeler/interact(mob/user)
	. = ..()
	if(.)
		return .
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to use [src]!"))
		return .

	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		to_chat(user, span_notice("You turn on [src]."))
		//Now let them chose the text.
		var/str = reject_bad_text(tgui_input_text(user, "Label text", "Set Label", label, MAX_NAME_LEN))
		if(!str || QDELETED(src) || !user.is_holding(src))
			to_chat(user, span_warning("Invalid text!"))
			return
		label = str
		to_chat(user, span_notice("You set the text to '[str]'."))
	else
		to_chat(user, span_notice("You turn off [src]."))
	return TRUE

/obj/item/hand_labeler/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/hand_labeler_refill))
		return NONE

	balloon_alert(user, "refilled")
	qdel(tool)
	labels_left = initial(labels_left) //Yes, it's capped at its initial value
	return ITEM_INTERACT_SUCCESS

/obj/item/hand_labeler/examine()
	. = ..()
	if(labels_left > 0)
		. += span_notice("It looks like it could label [labels_left] more thing\s.")
	else
		. += span_notice("It's out of labels.")

/obj/item/hand_labeler/borg
	name = "cyborg-hand labeler"

/obj/item/hand_labeler/borg/apply_label(atom/interacting_with, mob/living/silicon/robot/user, list/modifiers)
	if(!istype(user))
		return FALSE

	. = ..()
	if(!.)
		return .

	var/starting_labels = initial(labels_left)
	var/diff = starting_labels - labels_left
	if(diff)
		labels_left = starting_labels
		// 50 per label. Magical cyborg paper doesn't come cheap.
		var/cost = diff * 50

		// If the cyborg manages to use a module without a cell, they get the paper
		// for free.
		user.cell?.use(cost)

	return .

/obj/item/hand_labeler_refill
	name = "hand labeler paper roll"
	icon = 'icons/obj/service/bureaucracy.dmi'
	desc = "A roll of paper. Use it on a hand labeler to refill it."
	icon_state = "labeler_refill"
	inhand_icon_state = "electropack"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	throw_range = 3
	throw_speed = 1
	pressure_resistance = 2
	resistance_flags = FLAMMABLE
	max_integrity = 100
	item_flags = NOBLUDGEON

/// The label item applied when labelling something
/obj/item/label
	name = "label"
	desc = "A strip of paper."
	icon = 'icons/obj/toys/stickers.dmi'
	icon_state = "label"
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	resistance_flags = FLAMMABLE
	max_integrity = 30
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	item_flags = NOBLUDGEON | SKIP_FANTASY_ON_SPAWN
	w_class = WEIGHT_CLASS_TINY

	/// The text on the label
	var/label_name
	/// What atom we're currently stuck to
	VAR_FINAL/atom/sticking_to

/obj/item/label/Initialize(mapload, new_label_name)
	. = ..()
	if(new_label_name)
		update_label_name(new_label_name)

/obj/item/label/Destroy()
	clear_stick_to()
	return ..()

/obj/item/label/update_name(updates)
	. = ..()
	if(label_name)
		name = "label ([label_name])"

/// Sets the lable_name var and performs any necessary updates to the label's appearance
/obj/item/label/proc/update_label_name(new_label_name)
	if(label_name == new_label_name)
		return

	if(sticking_to)
		remove_label()
	label_name = new_label_name
	if(sticking_to)
		apply_label()
	update_appearance(UPDATE_NAME)

/obj/item/label/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, label_name))
		update_label_name(var_value)
		datum_flags |= DF_VAR_EDITED
		return TRUE

	return ..()

/obj/item/label/proc/stick_to_atom(atom/applying_to, stick_px = ICON_SIZE_X / 2, stick_py = ICON_SIZE_Y / 2)
	applying_to.AddComponent( \
		/datum/component/sticker, \
		stickering_atom = src, \
		dir = applying_to.dir, \
		px = stick_px, \
		py = stick_py, \
		stick_callback = CALLBACK(src, PROC_REF(on_stick)), \
		peel_callback = CALLBACK(src, PROC_REF(on_peel)), \
	)

/// Callback invoked when the label is attached to something
/obj/item/label/proc/on_stick(atom/applying_to)
	sticking_to = applying_to
	RegisterSignal(sticking_to, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(interacted_with))
	RegisterSignal(sticking_to, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignals(sticking_to, list(SIGNAL_ADDTRAIT(TRAIT_WAS_RENAMED), SIGNAL_REMOVETRAIT(TRAIT_WAS_RENAMED)), PROC_REF(reapply))
	RegisterSignal(sticking_to, COMSIG_QDELETING, PROC_REF(clear_stick_to))
	apply_label()

/// Callback invoked when the label is removed from something
/obj/item/label/proc/on_peel(atom/peeled_from)
	qdel(src)

/// General purpose / signal proc used to clear references and clean up when removed
/obj/item/label/proc/clear_stick_to(...)
	SIGNAL_HANDLER

	if(isnull(sticking_to))
		return
	if(!QDELING(sticking_to))
		remove_label()
	UnregisterSignal(sticking_to, list(
		COMSIG_ATOM_ITEM_INTERACTION,
		COMSIG_ATOM_EXAMINE,
		SIGNAL_ADDTRAIT(TRAIT_WAS_RENAMED),
		SIGNAL_REMOVETRAIT(TRAIT_WAS_RENAMED),
		COMSIG_QDELETING,
	))
	sticking_to = null

/**
 * This proc will trigger when any object is used to attack the thing we're stuck to. .
 *
 * If the attacking object is not a hand labeler, it will return.
 * If the attacking object is a hand labeler, it will either update the label or remove the label entirely.
 *
 * Arguments:
 * * source: The parent.
 * * attacker: The object that is hitting the parent.
 * * user: The mob who is wielding the attacking object.
*/
/obj/item/label/proc/interacted_with(atom/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER

	// If the attacking object is not a hand labeler or its mode is 1 (has a label ready to apply), return.
	// The hand labeler should be off (mode is 0), in order to remove a label.
	var/obj/item/hand_labeler/labeler = tool
	if(!istype(labeler))
		return NONE

	if(labeler.mode)
		if(!length(labeler.label))
			labeler.balloon_alert(user, "no text set!")
			return ITEM_INTERACT_BLOCKING
		if(labeler.label == label_name)
			sticking_to.balloon_alert(user, "already labelled!")
			return ITEM_INTERACT_BLOCKING
		if(length(initial(sticking_to.name)) + length(labeler.label) > MAX_LABEL_LEN)
			sticking_to.balloon_alert(user, "label too long!")
			return ITEM_INTERACT_BLOCKING

		update_label_name(labeler.label)
		playsound(sticking_to, 'sound/items/handling/component_pickup.ogg', 20, TRUE)
		sticking_to.balloon_alert(user, "label renamed")
	else
		playsound(sticking_to, 'sound/items/poster/poster_ripped.ogg', 20, TRUE)
		sticking_to.balloon_alert(user, "label removed")
		qdel(src)
	return ITEM_INTERACT_SUCCESS

/**
 * This proc will trigger when someone examines the thing we're stuck to.
 * It will attach the text found in the body of the proc to the `examine_list` and display it to the player examining the parent.
 *
 * Arguments:
 * * source: The parent.
 * * user: The mob exmaining the parent.
 * * examine_list: The current list of text getting passed from the parent's normal examine() proc.
*/
/obj/item/label/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("It has a label with some words written on it. Use a hand labeler to remove it.")

/// Applies a label to the name of what we're stuck to in the format of: "parent_name (label)"
/obj/item/label/proc/apply_label()
	sticking_to.name += " ([label_name])"
	ADD_TRAIT(sticking_to, TRAIT_HAS_LABEL, REF(src))

/// Removes the label from the name of what we're stuck to
/obj/item/label/proc/remove_label()
	sticking_to.name = replacetext(sticking_to.name, "([label_name])", "") // Remove the label text from the parent's name, wherever it's located.
	sticking_to.name = trim(sticking_to.name) // Shave off any white space from the beginning or end of the parent's name.
	REMOVE_TRAIT(sticking_to, TRAIT_HAS_LABEL, REF(src))

/// Used to re-apply the label when the thing we're stuck to is renamed.
/obj/item/label/proc/reapply(...)
	SIGNAL_HANDLER

	remove_label()
	apply_label()
