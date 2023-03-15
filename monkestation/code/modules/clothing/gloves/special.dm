
/obj/item/clothing/gloves/cargo_gauntlet
	name = "\improper H.A.U.L. gauntlets"
	desc = "These clunky gauntlets allow you to drag things with more confidence on them not getting nabbed from you."
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/hands.dmi'
	icon_state = "haul_gauntlet"
	worn_icon_state = "haul_gauntlet"
	var/datum/weakref/pull_component_weakref


/obj/item/clothing/gloves/cargo_gauntlet/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, .proc/on_glove_equip)
	RegisterSignal(src, COMSIG_ITEM_DROPPED, .proc/on_glove_unequip)

/// Called when the glove is equipped. Adds a component to the equipper and stores a weak reference to it.
/obj/item/clothing/gloves/cargo_gauntlet/proc/on_glove_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(slot != ITEM_SLOT_GLOVES)
		return

	var/datum/component/strong_pull/pull_component = pull_component_weakref?.resolve()
	if(pull_component)
		stack_trace("Gloves already have a pull component associated with \[[pull_component.parent]\] when \[[equipper]\] is trying to equip them.")
		QDEL_NULL(pull_component_weakref)

	to_chat(equipper, "<span class='notice'>You feel the gauntlets activate as soon as you fit them on, making your pulls stronger!")

	pull_component_weakref = WEAKREF(equipper.AddComponent(/datum/component/strong_pull))

/*
 * Called when the glove is unequipped. Deletes the component if one exists.
 *
 * No component being associated on equip is a valid state, as holding the gloves in your hands also counts
 * as having them equipped, or even in pockets. They only give the component when they're worn on the hands.
 */
/obj/item/clothing/gloves/cargo_gauntlet/proc/on_glove_unequip(datum/source, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	var/datum/component/strong_pull/pull_component = pull_component_weakref?.resolve()

	if(!pull_component)
		return

	to_chat(pull_component.parent, "<span class='warning'>You have lost the grip power of [src]!")

	QDEL_NULL(pull_component_weakref)

