/// Ratwood's tent flap (structures/roguetent.dm): a cloth door in a tent wall that a hand opens and closes. Closed it is a wall
/// of cloth that blocks the way and the view, open it lets both through. The packing of a tent kit's own flaps (ShiftClick
/// from the inside) belongs to the tent kit, which the port does not bring.
/obj/structure/roguetent
	/// The flap's states: "[base_state]0" open, "[base_state]1" and "[base_state]2" closed.
	var/base_state = "tent_door"

/obj/structure/roguetent/update_icon_state()
	. = ..()
	icon_state = density ? "[base_state][pick("1", "2")]" : "[base_state]0"

/obj/structure/roguetent/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	if(density)
		open_up(user)
	else
		close_up(user)
	return TRUE

/obj/structure/roguetent/proc/open_up(mob/living/user)
	visible_message(span_info("[user] opens [src]."))
	playsound(src, 'modular_redtard/rockhill/sound/foley/equip/rummaging-02.ogg', 100, FALSE)
	set_density(FALSE)
	set_opacity(FALSE)
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/roguetent/proc/close_up(mob/living/user)
	visible_message(span_info("[user] closes [src]."))
	playsound(src, 'modular_redtard/rockhill/sound/foley/equip/rummaging-02.ogg', 100, FALSE)
	set_density(TRUE)
	set_opacity(TRUE)
	update_appearance(UPDATE_ICON_STATE)
