/obj/item/rsd_interface
	name = "RSD Phylactery"
	desc = "A small device inserted, typically, into inert brains. As Resonance cannot persist in what's referred to as a 'vacuum', RSDs--much like the brains and CPUs they emulate--employ cerebral white noise as a foundation for Resonance to persist in otherwise dead-quiet containers.."
	icon = 'modular_doppler/soulcatcher/icons/implanter.dmi'
	icon_state = "implanter1"
	inhand_icon_state = "syringe_0"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

/// Attempts to use the item on the target brain.
/obj/item/rsd_interface/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/item/organ/brain))
		return NONE

	if(HAS_TRAIT(interacting_with, TRAIT_RSD_COMPATIBLE))
		user.balloon_alert(user, "already upgraded!")
		return ITEM_INTERACT_BLOCKING

	user.visible_message(span_notice("[user] upgrades [interacting_with] with [src]."), span_notice("You upgrade [interacting_with] to be RSD compatible."))
	interacting_with.AddElement(/datum/element/rsd_interface)
	playsound(interacting_with.loc, 'sound/items/weapons/circsawhit.ogg', 50, vary = TRUE)

	qdel(src)
	return ITEM_INTERACT_SUCCESS

/datum/element/rsd_interface/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/item/organ/brain))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	ADD_TRAIT(target, TRAIT_RSD_COMPATIBLE, INNATE_TRAIT)

/// Adds text to the examine text of the parent item, explaining that the item can be used to enable the use of NIFSoft HUDs
/datum/element/rsd_interface/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_cyan("Souls can be transferred to [source], assuming it is inert.")

/datum/element/rsd_interface/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ATOM_EXAMINE)
	REMOVE_TRAIT(target, TRAIT_RSD_COMPATIBLE, INNATE_TRAIT)

	return ..()
