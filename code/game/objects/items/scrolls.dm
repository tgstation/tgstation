/obj/item/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	worn_icon_state = "scroll"
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "paper"
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/cooldown/spell/teleport/area_teleport/wizard/scroll)
	/// Number of uses the scroll gets.
	var/uses = 4

/obj/item/teleportation_scroll/Initialize(mapload)
	. = ..()
	// In the future, this can be generalized into just "magic scrolls that give you a specific spell".
	var/datum/action/cooldown/spell/teleport/area_teleport/wizard/scroll/teleport = locate() in actions
	if(teleport)
		teleport.name = name
		teleport.button_icon = icon
		teleport.button_icon_state = icon_state

/obj/item/teleportation_scroll/item_action_slot_check(slot, mob/user)
	return (slot & ITEM_SLOT_HANDS)

/obj/item/teleportation_scroll/apprentice
	name = "lesser scroll of teleportation"
	uses = 1

/obj/item/teleportation_scroll/examine(mob/user)
	. = ..()
	if(uses > 0)
		. += "It has [uses] use\s remaining."

/obj/item/teleportation_scroll/attack_self(mob/user)
	. = ..()
	if(.)
		return

	if(!uses)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.incapacitated() || !human_user.is_holding(src))
		return
	var/datum/action/cooldown/spell/teleport/area_teleport/wizard/scroll/teleport = locate() in actions
	if(!teleport)
		to_chat(user, span_warning("[src] seems to be a faulty teleportation scroll, and has no magic associated."))
		return
	if(!teleport.Activate(user))
		return
	uses--
	if(uses <= 0)
		to_chat(user, span_warning("[src] runs out of uses and crumbles to dust!"))
		qdel(src)
	return TRUE
