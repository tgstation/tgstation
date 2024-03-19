/obj/item/hand_labeler
	name = "hand labeler"
	desc = "A combined label printer, applicator, and remover, all in a single portable device. Designed to be easy to operate and use."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "labeler0"
	inhand_icon_state = null
	force = 0
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
	if(length(interacting_with.name) + length(label) > 64)
		balloon_alert(user, "label too big!")
		return FALSE
	if(ismob(interacting_with))
		interacting_with.balloon_alert(user, "can't label!")
		return FALSE

	var/cursor_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/cursor_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	if(isnull(cursor_x))
		cursor_x = world.icon_size / 2
	if(isnull(cursor_y))
		cursor_y = world.icon_size / 2

	interacting_with.balloon_alert_to_viewers("labelled")
	user.visible_message(
		span_notice("[user] labels [interacting_with] with \"[label]\"."),
		span_notice("You label [interacting_with] with \"[label]\".")
	)
	interacting_with.AddComponent(/datum/component/label, label, cursor_x, cursor_y)
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

/obj/item/hand_labeler/item_interaction(mob/living/user, obj/item/tool, list/modifiers, is_right_clicking)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(!istype(tool, /obj/item/hand_labeler_refill))
		return .

	balloon_alert(user, "refilled")
	qdel(tool)
	labels_left = initial(labels_left) //Yes, it's capped at its initial value
	return ITEM_INTERACT_SUCCESS

/obj/item/hand_labeler/attackby_storage_insert(datum/storage, atom/storage_holder, mob/user)
	return !mode

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
