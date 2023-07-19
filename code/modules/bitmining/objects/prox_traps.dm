/**
 * ### Bitminer Trap
 * Places a proximity detection device which gives avatars a free sever
 */
/obj/item/assembly/bitminer_trap
	name = "proximity detection module"

	attachable = TRUE
	desc = "When placed on a tile, gives proximity alerts to avatars in the virtual domain."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "chips"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	/// Whether this has been activated already. No reuse.
	var/used = FALSE

/obj/item/assembly/bitminer_trap/attack_self(mob/living/user, list/modifiers)
	. = ..()

	if(used)
		return

	if(get_area_name(user) != "Bitmining Den")
		balloon_alert(user, "not valid here.")
		return

	if(!do_after(user, 3 SECONDS, src))
		return

	var/turf/current = get_turf(src)

	playsound(src, 'sound/effects/chipbagpop.ogg', 30, TRUE)
	RegisterSignal(current, COMSIG_ATOM_ENTERED, PROC_REF(on_atom_entered))
	balloon_alert(user, "tile marked.")
	used = TRUE
	update_appearance()

/obj/item/assembly/bitminer_trap/update_icon_state()
	if(used)
		icon = 'icons/obj/janitor.dmi'
	else
		icon = 'icons/obj/food/food.dmi'

	return ..()

/obj/item/assembly/bitminer_trap/proc/on_atom_entered(atom/movable/arrived, atom/old_loc)
	SIGNAL_HANDLER
	signal_proximity(arrived)

/obj/item/assembly/bitminer_trap/proc/signal_proximity(atom/movable/arrived)
	SEND_SIGNAL(src, COMSIG_BITMINING_PROXIMITY, arrived)
