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
	var/label_name

/datum/component/label/Initialize(_label_name)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	label_name = _label_name

	// Add the label to the name of the object in the format of: "Item name (label)"
	var/atom/owner = parent
	owner.name += " ([label_name])"

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/RemoveLabel)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/Examine)

/datum/component/label/Destroy()
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY, COMSIG_PARENT_EXAMINE))
	return ..()

/datum/component/label/proc/RemoveLabel(datum/source, obj/item/attacker, mob/user, params)
	// If the attacking object is not a hand labeler or its mode is 1 (has a label ready to apply), return.
	// The hand labeler should be off (mode is 0), in order to remove a label.
	var/obj/item/hand_labeler/labeler = attacker
	if(!istype(labeler) || labeler.mode)
		return

	var/atom/owner = source // Source will be the owner / parent of this component.
	owner.name = replacetext(owner.name, "([label_name])", "") // Remove the label text from the parent's name, wherever it may be.
	owner.name = trim(owner.name) // Shave off any white space from the beginning or end of the parent's name.
	playsound(owner, 'sound/items/poster_ripped.ogg', 20, TRUE)
	to_chat(user, "<span class='warning'>You remove the label from [owner].</span>")
	Destroy() // Remove the component from the object.

/datum/component/label/proc/Examine(datum/source, mob/user, list/examine_list)
	examine_list += "<span class='notice'>It has a label with some words written on it. Use a hand labeler to remove it.</span>"
