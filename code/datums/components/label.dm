/**
	The label component.

	This component is used to manage labels applied by the hand labeler.

	Atoms can only have one instance of this component, and therefore only one label at a time.
	This is to avoid having names like "Backpack (label1) (label2) (label3)". This is annoying and abnoxious to read.

	When a player clicks the atom with a hand labeler to apply a label, this component gets applied to it.
	If the labeler is off, the component will be removed from it, and the label will be removed from its name.
 */
/datum/component/label
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The name of the label the player is applying to the parent.
	VAR_PRIVATE/label_name
	/// A ref to the physical label object stuck onto the target
	VAR_PRIVATE/obj/item/label/label

/datum/component/label/Initialize(label_name, label_px, label_py)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/atom_parent = parent

	label = new()
	label.name = "label ([label_name])"
	// I wanted to merge the two components in some way, or to move the behavior to the label item itself, but stickers proved complex
	if(!parent.AddComponent(/datum/component/sticker, label, atom_parent.dir, label_px, label_py))
		return COMPONENT_INCOMPATIBLE

	RegisterSignals(label, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(clear_label))
	src.label_name = label_name
	apply_label()

/datum/component/label/Destroy()
	if(QDELETED(label))
		// qdeling of our label can trigger qdeling of us so avoid double qdelling
		label = null
	else
		UnregisterSignal(label, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
		QDEL_NULL(label)
	return ..()

/// When the label is qdeleted or peeled off or otherwise moved, it will be deleted, and so will us.
/datum/component/label/proc/clear_label(datum/source, ...)
	SIGNAL_HANDLER

	remove_label()
	qdel(src)

/datum/component/label/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(interacted_with))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(Examine))
	RegisterSignals(parent, list(SIGNAL_ADDTRAIT(TRAIT_WAS_RENAMED), SIGNAL_REMOVETRAIT(TRAIT_WAS_RENAMED)), PROC_REF(reapply))

/datum/component/label/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ITEM_INTERACTION,
		COMSIG_ATOM_EXAMINE,
		SIGNAL_ADDTRAIT(TRAIT_WAS_RENAMED),
		SIGNAL_REMOVETRAIT(TRAIT_WAS_RENAMED),
	))

/**
	This proc will fire after the parent is hit by a hand labeler which is trying to apply another label.
	Since the parent already has a label, it will remove the old one from the parent's name, and apply the new one.
*/
/datum/component/label/InheritComponent(datum/component/label/new_comp , i_am_original, _label_name)
	remove_label()
	if(new_comp)
		label_name = new_comp.label_name
	else
		label_name = _label_name
	apply_label()

/**
	This proc will trigger when any object is used to attack the parent.

	If the attacking object is not a hand labeler, it will return.
	If the attacking object is a hand labeler it will restore the name of the parent to what it was before this component was added to it, and the component will be deleted.

	Arguments:
	* source: The parent.
	* attacker: The object that is hitting the parent.
	* user: The mob who is wielding the attacking object.
*/
/datum/component/label/proc/interacted_with(atom/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER

	// If the attacking object is not a hand labeler or its mode is 1 (has a label ready to apply), return.
	// The hand labeler should be off (mode is 0), in order to remove a label.
	var/obj/item/hand_labeler/labeler = tool
	if(!istype(labeler) || labeler.mode)
		return NONE

	playsound(parent, 'sound/items/poster_ripped.ogg', 20, TRUE)
	source.balloon_alert(user, "label removed")
	remove_label()
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/**
	This proc will trigger when someone examines the parent.
	It will attach the text found in the body of the proc to the `examine_list` and display it to the player examining the parent.

	Arguments:
	* source: The parent.
	* user: The mob exmaining the parent.
	* examine_list: The current list of text getting passed from the parent's normal examine() proc.
*/
/datum/component/label/proc/Examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("It has a label with some words written on it. Use a hand labeler to remove it.")

/// Applies a label to the name of the parent in the format of: "parent_name (label)"
/datum/component/label/proc/apply_label()
	var/atom/owner = parent
	owner.name += " ([label_name])"
	ADD_TRAIT(owner, TRAIT_HAS_LABEL, REF(src))
	owner.update_appearance(UPDATE_ICON)

/// Removes the label from the parent's name
/datum/component/label/proc/remove_label()
	var/atom/owner = parent
	owner.name = replacetext(owner.name, "([label_name])", "") // Remove the label text from the parent's name, wherever it's located.
	owner.name = trim(owner.name) // Shave off any white space from the beginning or end of the parent's name.
	REMOVE_TRAIT(owner, TRAIT_HAS_LABEL, REF(src))
	owner.update_appearance(UPDATE_ICON)

/// Used to re-apply the label when the parent's name changes
/datum/component/label/proc/reapply(datum/source, ...)
	SIGNAL_HANDLER

	remove_label()
	apply_label()

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
