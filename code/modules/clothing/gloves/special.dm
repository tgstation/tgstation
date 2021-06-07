
/obj/item/clothing/gloves/cargo_gauntlet
	name = "\improper H.A.U.L. gauntlets"
	desc = "These clunky gauntlets allow you to drag things with more confidence on them not getting nabbed from you."
	icon_state = "haul_gauntlet"
	inhand_icon_state = "bgloves"
	transfer_prints = FALSE
	equip_delay_self = 3 SECONDS
	equip_delay_other = 4 SECONDS
	clothing_traits = list(TRAIT_CHUNKYFINGERS)
	undyeable = TRUE
	var/datum/component/strong_pull/pull_component

/obj/item/clothing/gloves/cargo_gauntlet/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, .proc/on_glove_equip)
	RegisterSignal(src, COMSIG_ITEM_POST_UNEQUIP, .proc/on_glove_unequip)

/obj/item/clothing/gloves/cargo_gauntlet/proc/on_glove_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(slot != ITEM_SLOT_GLOVES)
		return

	if(pull_component)
		stack_trace("Gloves already have a pull component associated with \[[pull_component.parent]\] when \[[equipper]\] is trying to equip them.")
		QDEL_NULL(pull_component)

	to_chat(equipper, "<span class='notice'>You feel the gauntlets activate as soon as you fit them on, making your pulls stronger!</span>")

	pull_component = equipper.AddComponent(/datum/component/strong_pull)

/obj/item/clothing/gloves/cargo_gauntlet/proc/on_glove_unequip(datum/source, force, atom/newloc, no_move, invdrop, silent)
	if(!pull_component)
		return

	to_chat(pull_component.parent, "<span class='warning'>You have lost the grip power of [src]!</span>")

	QDEL_NULL(pull_component)
